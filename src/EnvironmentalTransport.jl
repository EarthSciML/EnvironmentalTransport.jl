module EnvironmentalTransport

using DocStringExtensions
using SciMLOperators
using LinearAlgebra
using StaticArrays
using SciMLBase: NullParameters
using ModelingToolkit: t, D, get_unit, getdefault, ODESystem, @variables, @parameters,
                       @constants, get_variables, substitute, Equation, subs_constants,
                       build_explicit_observed_function, setp, unknowns, ParentScope
using SciMLBase: terminate!
using DynamicQuantities: @u_str
using EarthSciMLBase
using RuntimeGeneratedFunctions

RuntimeGeneratedFunctions.init(@__MODULE__)

include("advection_stencils.jl")
include("boundary_conditions.jl")
include("advection.jl")
include("PBL_mixing.jl")
include("puff.jl")
include("plume_rise/sofiev_2012.jl")

end
