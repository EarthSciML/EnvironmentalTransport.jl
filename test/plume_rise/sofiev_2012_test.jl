@testitem "Sofiev2012PlumeRise" begin
    using EarthSciMLBase, EarthSciData, EnvironmentalTransport
    using ModelingToolkit
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

    prob = ODEProblem(sys, [], get_tspan(di))

    lev_0 = prob.u0[ModelingToolkit.variable_index(sys, sys.Puff₊lev)]
    @test lev_0 ≈ 4.700049441016632

    sol = solve(prob)
    @test sol.retcode == SciMLBase.ReturnCode.Success
end
