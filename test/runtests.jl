using EnvironmentalTransport
using Test, SafeTestsets

@testset "EnvironmentalTransport.jl" begin
    @safetestset "Advection Stencils" begin
        include("advection_stencil_test.jl")
    end
    @safetestset "Boundary Conditions" begin
        include("boundary_conditions_test.jl")
    end
    @safetestset "Advection" begin
        include("advection_test.jl")
    end
    @safetestset "Advection Simulator" begin
        include("advection_simulator_test.jl")
    end
    @safetestset "Puff" begin
        include("puff_test.jl")
    end
    @safetestset "Puff-GEOSFP" begin
        include("puff_geosfp_test.jl")
    end
    @safetestset "Sofiev 2012 Plume Rise" begin
        include("plume_rise/sofiev_2012_test.jl")
    end
    @safetestset "Gaussian Dispersion" begin
        include("puff_geosfp_gauss_test.jl")
    end
end
