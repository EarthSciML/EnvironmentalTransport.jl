module EnvironmentalTransport

using DocStringExtensions
using LinearAlgebra
using ModelingToolkit: t, D, get_unit, getdefault, System, @brownians, @variables,
                       @parameters,
                       @constants, Equation, unknowns, ParentScope, get_defaults, @unpack
using SciMLBase: terminate!, NullParameters
using DynamicQuantities: @u_str
using EarthSciMLBase
import RuntimeGeneratedFunctions

RuntimeGeneratedFunctions.init(@__MODULE__) # Needed even though we don't use it directly.

include("advection_stencils.jl")
include("boundary_conditions.jl")
include("advection.jl")
include("puff.jl")
include("plume_rise/sofiev_2012.jl")
include("GaussianDispersion.jl")
include("BoundaryLayerMixingKC.jl")

end
