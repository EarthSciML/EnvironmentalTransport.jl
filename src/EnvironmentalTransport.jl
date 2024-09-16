module EnvironmentalTransport

using DocStringExtensions
using SciMLOperators
using LinearAlgebra
using SciMLBase: NullParameters
using ModelingToolkit: t, D, get_unit, getdefault, ODESystem, @variables, @parameters,
    @constants, get_variables, substitute
using SciMLBase: terminate!
using EarthSciMLBase

include("advection_stencils.jl")
include("boundary_conditions.jl")
include("advection.jl")
include("puff.jl")

end
