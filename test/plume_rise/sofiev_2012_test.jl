@testitem "Sofiev2012PlumeRise" begin
    using EarthSciMLBase, EarthSciData, EnvironmentalTransport
    using ModelingToolkit
    using ModelingToolkit: Initial
    import SciMLBase
    using Dates
    using OrdinaryDiffEqDefault
    using Test

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

    prob = ODEProblem(sys, [], get_tspan(di))
    sol = solve(prob) # The first solve will fail because the data loaders aren't initialized yet.
    @assert sol[sys.GEOSFP₊A1₊PBLH][1] > 0.0

    prob = remake(prob, p = sol.prob.p)
    sol = solve(prob)
    lev_0 = sol[sys.Puff₊lev][1]
    # Edge-indexed lev convention (EarthSciData PR #208): ℓ=1 is the surface
    # in both gfp.Z_agl and the local Z_at/lev_from_height helpers, so the
    # plume-top lev sits ~0.5 higher than under the previous midpoint-
    # indexed convention (was 4.521).
    @test lev_0 ≈ 5.09721934285556

    @test sol.retcode == SciMLBase.ReturnCode.Success
end
