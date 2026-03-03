module EnvironmentalTransport

using DocStringExtensions
using LinearAlgebra
using ModelingToolkit: t, D, get_unit, getdefault, System, PDESystem, Differential,
    @brownians, @variables,
    @parameters, @named, @component,
    @constants, Equation, unknowns, ParentScope, initial_conditions, @unpack,
    @register_symbolic
# Symbolics is needed for @register_symbolic macro expansion.
# Access it from loaded modules (transitive dep of ModelingToolkit) to avoid
# direct dependency version conflicts.
const Symbolics = Base.loaded_modules[
    Base.PkgId(
        Base.UUID("0c5d862f-8b57-4792-8d23-62f2024744c7"), "Symbolics"
    ),
]
using SciMLBase: terminate!, NullParameters
using StaticArrays: SVector
using DynamicQuantities: @u_str
using DomainSets: Interval
using EarthSciMLBase
import RuntimeGeneratedFunctions

RuntimeGeneratedFunctions.init(@__MODULE__) # Needed even though we don't use it directly.

include("advection_stencils.jl")
include("boundary_conditions.jl")
include("advection.jl")
include("PBL_mixing.jl")
include("puff.jl")
include("plume_rise/sofiev_2012.jl")
include("GaussianDispersion.jl")
include("BoundaryLayerMixingKC.jl")
include("surface_runoff.jl")
include("vapor_transfer.jl")

end
