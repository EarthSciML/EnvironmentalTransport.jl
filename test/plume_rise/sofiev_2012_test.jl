@testitem "Sofiev2012PlumeRise" begin
    using EarthSciMLBase, EarthSciData
    using ModelingToolkit
    using Dates
    using OrdinaryDiffEq

    starttime = DateTime(2022, 5, 1)
    endtime = DateTime(2022, 5, 1, 0, 1)

    di = DomainInfo(
        starttime, endtime;
        lonrange = deg2rad(-115):deg2rad(1):deg2rad(-68.75),
        latrange = deg2rad(25):deg2rad(1):deg2rad(53.7),
        levrange = 1:15
    )

    puff = Puff(di)

    prob = ODEProblem(mtkcompile(puff), [], get_tspan(di))
    @test prob.ps[Initial(puff.lev)] == 8.0

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
    @test lev_0 ≈ 4.39566616801431

    sol = solve(prob, Tsit5())
    @test sol.retcode == SciMLBase.ReturnCode.Success
end
