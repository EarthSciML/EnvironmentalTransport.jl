module EnvironmentalTransport

using DocStringExtensions
using LinearAlgebra
using StaticArrays
using SciMLBase: NullParameters
using DiffEqCallbacks: PeriodicCallback, DiscreteCallback
using ModelingToolkit: t, D, get_unit, getdefault, System, @variables, @parameters, @named,
                       @constants, get_variables, substitute, Equation,
                       build_explicit_observed_function, setp, unknowns, ParentScope,
                       get_defaults, @unpack, @component
using SciMLBase: terminate!
using DynamicQuantities: @u_str
using EarthSciMLBase
using RuntimeGeneratedFunctions
using SciMLOperators: FunctionOperator, cache_operator

RuntimeGeneratedFunctions.init(@__MODULE__) # Needed even though we don't use it directly.

include("advection_stencils.jl")
include("boundary_conditions.jl")
include("advection.jl")
include("PBL_mixing.jl")
include("puff.jl")
include("plume_rise/sofiev_2012.jl")
include("GaussianDispersion.jl")
include("seinfeld_pandis_ch1.jl")
include("local_scale_meteorology.jl")

end
