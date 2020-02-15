import Base: eltype, Pair, Tuple, show, ==, iterate
import LightGraphs: AbstractEdge, SimpleEdge, src, dst, reverse

export AbstractMultipleEdge, MultipleEdge, mul

abstract type AbstractMultipleEdge{T, U} <: AbstractEdge{T} end

struct MultipleEdge{T<:Integer, U<:Integer} <: AbstractMultipleEdge{T, U}
    src::T
    dst::T
    mul::U
    function MultipleEdge(src::T, dst::T, mul::U) where {T<:Integer, U<:Integer}
        if mul > 0
            return new{T, U}(src, dst, mul)
        else
            error("a multiple edge should have positive multiplicity")
        end
    end
end

MultipleEdge(src, dst) = MultipleEdge(src, dst, one(Int))
function MultipleEdge(a::Vector{T}) where {T<:Integer}
    l = length(a)
    if l == 2
        return MultipleEdge(a[1], a[2])
    elseif l > 2
        return MultipleEdge(a[1], a[2], a[3])
    end
end
MultipleEdge(t::NTuple{3}) = MultipleEdge(t[1], t[2], t[3])
MultipleEdge(t::NTuple{2}) = MultipleEdge(t[1], t[2], one(Int))
MultipleEdge(p::Pair) = MultipleEdge(p.first, p.second, one(Int))
MultipleEdge(e::T) where {T<:AbstractEdge} = MultipleEdge{eltype(e), Int}(src(e), dst(e), one(Int))
eltype(e::T) where {T<:AbstractMultipleEdge} = eltype(src(e))

src(e::AbstractMultipleEdge) = e.src
dst(e::AbstractMultipleEdge) = e.dst
mul(e::AbstractMultipleEdge) = e.mul

show(io::IO, e::AbstractMultipleEdge) = print(io, "Multiple edge $(src(e)) => $(dst(e)) with multiplicity $(mul(e))")

Tuple(e::AbstractMultipleEdge) = (src(e), dst(e), mul(e))
SimpleEdge(e::AbstractMultipleEdge) = SimpleEdge(src(e), dst(e))

reverse(e::T) where {T<:AbstractMultipleEdge} = T(dst(e), src(e), mul(e))
==(e1::AbstractMultipleEdge, e2::AbstractMultipleEdge) = (src(e1) == src(e2) && dst(e1) == dst(e2) && mul(e1) == mul(e2))
==(e1::AbstractMultipleEdge, e2::AbstractEdge) = (src(e1) == src(e2) && dst(e1) == dst(e2) && mul(e1) == 1)
==(e1::AbstractEdge, e2::AbstractMultipleEdge) = (src(e1) == src(e2) && dst(e1) == dst(e2) && mul(e2) == 1)

function iterate(e::MultipleEdge{T, U}, state::U=one(U)) where {T<:Integer, U<:Integer}
    if state > mul(e)
        return nothing
    else
        state += one(U)
        return (SimpleEdge(e), state)
    end
end