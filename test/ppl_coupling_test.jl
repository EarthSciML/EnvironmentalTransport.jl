using Test
using EnvironmentalTransport

using EarthSciMLBase, EarthSciData, GasChem
using ModelingToolkit, OrdinaryDiffEq
using ModelingToolkit: t, D
using DynamicQuantities
using Dates
using Distributions
using EarthSciMLBase: SolverStrangThreads, PositiveDomain

@testset "PBL Mixing with GEOS-FP" begin
    domain = DomainInfo(
        DateTime(2016, 5, 1),
        DateTime(2016, 5, 2);
        lonrange=deg2rad(-115):deg2rad(0.625):deg2rad(-68.75),
        latrange=deg2rad(25):deg2rad(0.5):deg2rad(53.7),
        levrange=1:30,
        u_proto=zeros(Float64, 1, 1, 1, 1))

    model = couple(
        SuperFast(),
        NEI2016MonthlyEmis("mrggrid_withbeis_withrwc", domain),
        GEOSFP("0.5x0.625_NA", domain),
        PBLMixingOperator(ZeroGradBC()),
        domain,
    )
    @test model isa CoupledSystem
    
    # Test that the system can be converted to ODESystem
    sys = convert(ODESystem, model; simplify = true)
    @test sys isa ODESystem
    
    # Test that we can create an ODEProblem
    st_strang = SolverStrangThreads(Rosenbrock23(), 300; callback=PositiveDomain(save=false))
    prob_strang = ODEProblem(model, st_strang)
    @test prob_strang isa ODEProblem
    
    # # Test that we can solve the problem (short integration)
    # sol = solve(prob_strang, Rosenbrock23(), dt = 300, save_everystep = false)
    # @test sol isa SciMLBase.ODESolution
end