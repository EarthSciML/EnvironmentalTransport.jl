export ZeroGradBC, ConstantBC, SpeciesConstantBC

"""
An array with external indexing implemented for boundary conditions.
"""
abstract type BCArray{T, N} <: AbstractArray{T, N} end

"""
$(SIGNATURES)

An array with zero gradient boundary conditions.
"""
struct ZeroGradBCArray{P, T, N} <: BCArray{T, N}
    parent::P
    function ZeroGradBCArray(x::AbstractArray{T, N}) where {T, N}
        return new{typeof(x), T, N}(x)
    end
end
zerogradbcindex(i::Int, N::Int) = clamp(i, 1, N)
zerogradbcindex(i::UnitRange, N::Int) = zerogradbcindex.(i, N)
Base.size(A::ZeroGradBCArray) = size(A.parent)
Base.checkbounds(::Type{Bool}, ::ZeroGradBCArray, i...) = true

function Base.getindex(A::ZeroGradBCArray{P, T, N},
        ind::Vararg{Union{Int, UnitRange}, N}) where {P, T, N}
    v = A.parent
    i = map(zerogradbcindex, ind, size(A))
    @boundscheck checkbounds(v, i...)
    @inbounds ret = v[i...]
    ret
end

"""
$(SIGNATURES)

Zero gradient boundary conditions.
"""
struct ZeroGradBC end
(bc::ZeroGradBC)(x) = ZeroGradBCArray(x)

"""
$(SIGNATURES)

An array with zero constant boundary conditions.
"""
struct ConstantBCArray{P, T, N} <: BCArray{T, N}
    parent::P
    value::T
    function ConstantBCArray(x::AbstractArray{T, N}, value::T) where {T, N}
        return new{typeof(x), T, N}(x, value)
    end
end
Base.size(A::ConstantBCArray) = size(A.parent)
Base.checkbounds(::Type{Bool}, ::ConstantBCArray, i...) = true

function Base.getindex(A::ConstantBCArray{P, T, N},
        ind::Vararg{Union{Int, UnitRange}, N}) where {P, T, N}
    v = A.parent
    if checkbounds(Bool, v, ind...)
        @inbounds ret = v[ind...]
        return ret
    end
    return A.value
end

"""
$(SIGNATURES)

Constant boundary conditions.
"""
struct ConstantBC
    value::AbstractFloat
    ConstantBC(value::AbstractFloat) = new(value)
end

"""
$(SIGNATURES)

An array with species-specific constant boundary conditions.
"""
struct SpeciesConstantBCArray{P, T, N} <: BCArray{T, N}
    parent::P
    values::Dict{Int, T}
    default_value::T
    function SpeciesConstantBCArray(x::AbstractArray{T, N}, values::Dict{Int, T}, default_value::T) where {T, N}
        return new{typeof(x), T, N}(x, values, default_value)
    end
end
Base.size(A::SpeciesConstantBCArray) = size(A.parent)
Base.checkbounds(::Type{Bool}, ::SpeciesConstantBCArray, i...) = true

function Base.getindex(A::SpeciesConstantBCArray{P, T, N},
        ind::Vararg{Union{Int, UnitRange}, N}) where {P, T, N}
    v = A.parent
    if checkbounds(Bool, v, ind...)
        @inbounds ret = v[ind...]
        return ret
    end
    # For out-of-bounds access, return species-specific boundary value
    # The first dimension is the species dimension
    species_idx = first(ind)
    if isa(species_idx, Int)
        return get(A.values, species_idx, A.default_value)
    else
        # For range access, return the default value
        return A.default_value
    end
end

"""
$(SIGNATURES)

Species-specific constant boundary conditions.
Takes a dictionary mapping species names/indices to boundary values and a default value.

Examples:
- `SpeciesConstantBC(Dict("O3" => 40.0), 0.0)` sets O3 to 40.0 and others to 0.0
- `SpeciesConstantBC(Dict(1 => 40.0), 0.0)` sets species 1 to 40.0 and others to 0.0
- `SpeciesConstantBC(Dict("O3" => 40.0, "NO2" => 10.0), 0.0)` sets multiple species

Note: When using species names, they will be resolved to indices when the boundary 
condition is applied to a system with known species variables.
"""
struct SpeciesConstantBC
    values::Dict{Union{String, Int}, AbstractFloat}
    default_value::AbstractFloat
    
    function SpeciesConstantBC(values::Dict{<:Union{String, Int}, <:AbstractFloat}, default_value::AbstractFloat)
        new(values, default_value)
    end
end

# Simple application like ConstantBC and ZeroGradBC - handles integer indices only
function (bc::SpeciesConstantBC)(x)
    # Extract integer keys and convert to proper types
    int_values = Dict{Int, eltype(x)}()
    for (key, value) in bc.values
        if isa(key, Int)
            int_values[key] = eltype(x)(value)
        end
        # String keys are ignored in simple application - need species info for those
    end
    return SpeciesConstantBCArray(x, int_values, eltype(x)(bc.default_value))
end

"""
$(SIGNATURES)

Helper function to resolve species names to indices and create a SpeciesConstantBCArray.
This is used by AdvectionOperator when species information is available.
"""
function resolve_species_bc(bc::SpeciesConstantBC, x, species_vars)
    resolved_values = Dict{Int, eltype(x)}()
    
    for (key, value) in bc.values
        if isa(key, Int)
            # Already an index
            resolved_values[key] = eltype(x)(value)
        elseif isa(key, String)
            # Need to find the index for this species name
            species_idx = findfirst(var -> contains(string(var), key), species_vars)
            if species_idx !== nothing
                resolved_values[species_idx] = eltype(x)(value)
            else
                @warn "Species '$key' not found in system variables. Ignoring boundary condition for this species."
            end
        end
    end
    
    return SpeciesConstantBCArray(x, resolved_values, eltype(x)(bc.default_value))
end

(bc::ConstantBC)(x) = ConstantBCArray(x, bc.value + zero(eltype(x)))
