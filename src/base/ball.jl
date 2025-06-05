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

@testitem "ball_ids" begin
    X = [1.0, 2.0, 3.0, 4.0, 5.0]

    @test ball_ids(X, 3.0, 1.5) == [2, 3, 4]  # Indices of elements within distance 1.5 from 3.0
    @test ball_ids(X, 1.0, 0.5) == [1]       # Only the first element is within distance 0.5 from 1.0
    @test ball_ids(X, 5.0, 0.001) == [5]       # Only the last element is within distance 0.0 from 5.0
    @test ball_ids(X, 6.0, 0.1) == []
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

@testitem "ball_ids and ball tests" begin
    # Create a mock metric space
    X = [1.0, 2.0, 3.0, 4.0, 5.0]

    # Test ball
    @test ball(X, 3.0, 1.5) == [2.0, 3.0, 4.0]  # Elements within distance 1.5 from 3.0
    @test ball(X, 1.0, 0.5) == [1.0]           # Only the first element is within distance 0.5 from 1.0
    @test ball(X, 5.0, 0.001) == [5.0]           # Only the last element is within distance 0.0 from 5.0
    @test ball(X, 6.0, 0.01) == []           # Only the last element is within distance 0.0 from 5.0
end