"""
    ball_ids(X::MetricSpace{T}, x::T, ϵ::Number) where {T}

Finds the indices of elements in the metric space `X` that are within a distance `ϵ` from the point `x`.

# Arguments
- `X::MetricSpace{T}`: The metric space containing the elements to search.
- `x::T`: The reference point in the metric space.
- `ϵ::Number`: The radius within which to search for elements.

# Returns
- An array of indices corresponding to the elements in `X` that are within the specified distance `ϵ` from `x`.
"""

function ball_ids(X::MetricSpace{T}, x::T, ϵ::Number) where {T}
    @assert ϵ > 0 "ϵ must be a positive number"
    ids = findall(<(ϵ), pairwise_distance(X, [x], dist_euclidean)[:, 1])
end

"""
    ball(X::MetricSpace, x::T, ϵ::Number) where {T}

Retrieves the elements in the metric space `X` that are within a distance `ϵ` from the point `x`.

# Arguments
- `X::MetricSpace{T}`: The metric space containing the elements to search.
- `x::T`: The reference point in the metric space.
- `ϵ::Number`: The radius within which to search for elements.

# Returns
- A subset of `X` containing the elements that are within the specified distance `ϵ` from `x`.
"""
function ball(X::MetricSpace, x::T, ϵ::Number) where {T}
    ids = ball_ids(X, x, ϵ)
    X[ids]
end