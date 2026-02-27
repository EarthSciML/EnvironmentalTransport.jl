@testitem "PBL Mixing with GEOS-FP" begin
    using EnvironmentalTransport
    using EarthSciMLBase, EarthSciData, GasChem
    using ModelingToolkit, OrdinaryDiffEq
    using ModelingToolkit: t, D
    using DynamicQuantities
    using Dates
    using Distributions
    using EarthSciMLBase: SolverStrangThreads, PositiveDomain

    domain = DomainInfo(
        DateTime(2016, 5, 1),
        DateTime(2016, 5, 2);
        lonrange = deg2rad(-115):deg2rad(4):deg2rad(-68.75),
        latrange = deg2rad(25):deg2rad(4):deg2rad(53.7),
        levrange = 1:30,
        u_proto = zeros(Float64, 1, 1, 1, 1)
    )

    model = couple(
        SuperFast(),
        NEI2016MonthlyEmis("mrggrid_withbeis_withrwc", domain),
        GEOSFP("4x5", domain),
        PBLMixingCallback(600.0),
        domain
    )
    @test model isa CoupledSystem

    # Test that the system can be converted to System
    sys = convert(System, model)
    @test sys isa System

    # Test that we can create an ODEProblem
    st_strang = SolverStrangThreads(Rosenbrock23(), 300; callback = PositiveDomain(save = false))
    prob_strang = ODEProblem(model, st_strang)
    @test prob_strang isa ODEProblem
end
