@testitem "Sofiev2012PlumeRise" begin
    using EarthSciMLBase, EarthSciData, EnvironmentalTransport
    using ModelingToolkit
    using ModelingToolkit: Initial
    import SciMLBase
    using Dates
    using OrdinaryDiffEqDefault

    starttime = DateTime(2022, 5, 1)
    endtime = DateTime(2022, 5, 1, 0, 1)

    di = DomainInfo(
        starttime, endtime;
        lonrange = deg2rad(-115):deg2rad(1):deg2rad(-68.75),
        latrange = deg2rad(25):deg2rad(1):deg2rad(53.7),
        levrange = 1:72
    )

    puff = Puff(di)

    prob = ODEProblem(mtkcompile(puff), [], get_tspan(di))
    @test prob.ps[Initial(puff.lev)] == 36.5

    gfp = GEOSFP("4x5", di)
    s12 = Sofiev2012PlumeRise()

    model = couple(
        puff,
        s12,
        gfp
    )
    sys = convert(System, model)

    # Warmup: build the prob with an explicit numeric lev=5 to break the
    # chicken-and-egg between the (now symbolic) `dflt[Puff.lev] =
    # ParentScope(s12.lev_p)` and the EarthSciData ≥ 0.16 data buffers, which
    # are zero-initialized until the data-load discrete callback fires at
    # solve start. After solve the buffers in `warm_prob.p` are populated.
    warm_prob = ODEProblem(sys, [sys.Puff₊lev => 5.0], get_tspan(di))
    # `save_start=true, save_end=false` keeps only the t=tspan[1] sample,
    # which is what we want for an "initial" lev_p reading: the data-load
    # callback fires at integrator init (before any stepping), so the
    # interpolators are populated by the time the start sample is recorded.
    warm_sol = solve(warm_prob, save_everystep = false, save_start = true,
        save_end = false)
    @test warm_sol.retcode == SciMLBase.ReturnCode.Success

    # With buffers populated, evaluate `Sofiev2012PlumeRise₊lev_p` numerically
    # via `getu`, then build the actual prob with that value as the puff's
    # initial level. This is equivalent to using the symbolic `initialization_eqs
    # = [Puff.lev ~ s12.lev_p]` pattern but works with the discrete-data-load
    # architecture (where the symbolic-init pathway evaluates `lev_p` against
    # empty buffers and produces NaN).
    # `getu(sys, var)(sol)` returns a time series; take the first (and only)
    # sample.
    lev_p_value = first(ModelingToolkit.getu(sys, sys.Sofiev2012PlumeRise₊lev_p)(warm_sol))
    prob = ODEProblem(sys, [sys.Puff₊lev => lev_p_value], get_tspan(di))

    lev_0 = prob.u0[ModelingToolkit.variable_index(sys, sys.Puff₊lev)]
    @test lev_0 ≈ 4.700049441016632

    sol = solve(prob)
    @test sol.retcode == SciMLBase.ReturnCode.Success
end
