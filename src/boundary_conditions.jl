export ZeroGradBC

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
