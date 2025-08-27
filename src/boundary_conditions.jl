export ZeroGradBC, ConstantBC

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
(bc::ConstantBC)(x) = ConstantBCArray(x, bc.value)
