@testitem "Puff GEOSFP" begin
    using EarthSciMLBase
    using EarthSciData
    using ModelingToolkit
    using ModelingToolkit: t
    using DynamicQuantities
    using OrdinaryDiffEqDefault
    using OrdinaryDiffEqTsit5: Tsit5
    import SciMLBase
    using Dates

    starttime = DateTime(2022, 5, 1)
    endtime = DateTime(2022, 5, 2)

    di = DomainInfo(
        starttime, endtime;
        lonrange = deg2rad(-80):deg2rad(1):deg2rad(-75),
        latrange = deg2rad(38):deg2rad(1):deg2rad(42),
        levrange = 1:15
    )

    geosfp = GEOSFP("4x5", di; stream = false)

    puff = Puff(di)

    model = couple(puff, geosfp)
    sys = convert(System, model; compile = true)

    @test length(equations(sys)) == 3
    @test occursin("PS", string(observed(sys))) # Check that we're using the GEOSFP pressure data.
    @test issetequal(
        [Symbol("Puff₊lon(t)"), Symbol("Puff₊lat(t)"), Symbol("Puff₊lev(t)")],
        Symbol.(unknowns(sys))
    )
    @test length(parameters(sys)) == 82
    @test length(observed(sys)) == 91

    tspan = EarthSciMLBase.get_tspan(di)
    prob = ODEProblem(sys, [], tspan)
    sol = solve(prob, Tsit5())
    @test sol.retcode == SciMLBase.ReturnCode.Terminated
end
