# real intervals
struct Interval{T<:Real}
    a::T
    b::T
    Interval(a::T, b::T) where {T<:Real} = a <= b ? new{T}(a, b) : error("we can't have a > b!")
end

IntervalCovering{T} = Vector{<:Interval{T}} where {T}

function Base.in(x::Real, i::Interval)
    i.a <= x <= i.b
end

# interval is_not_disjointion
function is_not_disjoint(i::Interval, j::Interval)
    (i.a <= j.a <= i.b) || (i.a <= j.b <= i.b)
end
