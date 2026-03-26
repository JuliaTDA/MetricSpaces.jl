# real intervals

"""
    Interval{T<:Real}

A parametric interval type representing a closed interval [a, b].

# Fields
- `a::T`: The left endpoint of the interval
- `b::T`: The right endpoint of the interval

# Constructors
- `Interval(a::T, b::T)`: Create an interval with matching types
- `Interval(a::Real, b::Real)`: Create an interval with promoted types

# Throws
- `ArgumentError`: If `a > b`

# Examples
```julia
Interval(1.0, 2.0)      # Interval{Float64}
Interval(1, 2)           # Interval{Int64}
Interval(1, 2.0)         # Interval{Float64} (promoted)
```
"""
struct Interval{T<:Real}
    a::T
    b::T

    function Interval{T}(a::T, b::T) where {T<:Real}
        a <= b || throw(ArgumentError("Interval requires a ≤ b, got a=$a, b=$b"))
        new{T}(a, b)
    end
end

# Constructor for matching types
Interval(a::T, b::T) where {T<:Real} = Interval{T}(a, b)

# Constructor for mixed types - promote to common type
Interval(a::Real, b::Real) = Interval(promote(a, b)...)

IntervalCovering{T} = Vector{<:Interval{T}} where {T}

function Base.in(x::Real, i::Interval)
    i.a <= x <= i.b
end

"""
    is_not_disjoint(i::Interval, j::Interval)

Check whether two intervals have a non-empty intersection.
"""
function is_not_disjoint(i::Interval, j::Interval)
    (i.a <= j.a <= i.b) || (i.a <= j.b <= i.b)
end
