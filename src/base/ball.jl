"""
    ball_ids(X::MetricSpace{T}, x::T, ϵ::Number, distance=dist_euclidean) where {T}

Find the indices of points in metric space `X` that are within distance `ϵ` from point `x`.

This function computes the ball B(x, ϵ) = {y ∈ X : d(x, y) < ϵ} and returns the 
indices of points in X that belong to this open ball.

# Arguments
- `X::MetricSpace{T}`: The metric space containing the points to search
- `x::T`: The center point of the ball
- `ϵ::Number`: The radius of the ball (must be positive)
- `distance`: Distance function to use (default: `dist_euclidean`)

# Returns
- `Vector{Int}`: Indices of points in `X` that are within distance `ϵ` from `x`

# Examples
```julia
# Create a 1D Euclidean space
X = EuclideanSpace(reshape([1.0, 2.0, 3.0, 4.0, 5.0], 1, 5))

# Find indices of points within distance 1.5 from point [3.0]
ball_ids(X, [3.0], 1.5)  # Returns [2, 3, 4]

# Using a different distance function
ball_ids(X, [3.0], 1.5, dist_cityblock)
```

# Notes
- Uses strict inequality (d < ϵ), so points exactly at distance ϵ are excluded
- For empty results, returns an empty vector
- The distance function should be compatible with the metric space type

See also: [`ball`](@ref), [`pairwise_distance`](@ref)
"""
function ball_ids(X::MetricSpace{T}, x::T, ϵ::Number, distance=dist_euclidean) where {T}
    @assert ϵ > 0 "ϵ must be a positive number"
    ids = findall(<(ϵ), pairwise_distance(X, [x], distance)[:, 1])
end

@testitem "ball_ids" begin
    # This creates a Vector{Float64}, not a MetricSpace!
    X = float.(1:5)
    
    @test ball_ids(X, 3.0, 1.5) == [2, 3, 4]  # This will fail!
    @test ball_ids(X, 1.0, 0.5) == [1]
    @test ball_ids(X, 5.0, 0.001) == [5]
    @test ball_ids(X, 6.0, 0.1) == []
end


"""
    ball(X::MetricSpace{T}, x::T, ϵ::Number, distance=dist_euclidean) where {T}

Extract the subset of points from metric space `X` that are within distance `ϵ` from point `x`.

This function returns the actual points (not just indices) that form the ball 
B(x, ϵ) = {y ∈ X : d(x, y) < ϵ} around the center point `x`.

# Arguments
- `X::MetricSpace{T}`: The metric space containing the points to search
- `x::T`: The center point of the ball
- `ϵ::Number`: The radius of the ball (must be positive)
- `distance`: Distance function to use (default: `dist_euclidean`)

# Returns
- `MetricSpace`: A new metric space containing only the points within the ball
- Returns an empty metric space if no points are found within the radius

# Examples
```julia
# Create a 1D Euclidean space
X = EuclideanSpace(reshape([1.0, 2.0, 3.0, 4.0, 5.0], 1, 5))

# Get points within distance 1.5 from [3.0]
subset = ball(X, [3.0], 1.5)  # Contains points [2.0, 3.0, 4.0]

# Using Manhattan distance
subset_l1 = ball(X, [3.0], 1.5, dist_cityblock)

# Check if result is empty
result = ball(X, [10.0], 0.1)
isempty(result)  # true
```

# Implementation Details
- Internally uses [`ball_ids`](@ref) to find the relevant indices
- Preserves the metric space structure in the returned subset
- The distance function should be compatible with the metric space type

# Mathematical Definition
For a metric space (X, d) and point x ∈ X, the open ball of radius ϵ is:
B(x, ϵ) = {y ∈ X : d(x, y) < ϵ}

See also: [`ball_ids`](@ref), [`pairwise_distance`](@ref)
"""
function ball(X::MetricSpace, x::T, ϵ::Number, distance=dist_euclidean) where {T}
    ids = ball_ids(X, x, ϵ, distance)
    X[ids]
end

@testitem "ball" begin
    # Create a mock metric space
    X = [1.0, 2.0, 3.0, 4.0, 5.0]

    # Test ball
    @test ball(X, 3.0, 1.5) == [2.0, 3.0, 4.0]  # Elements within distance 1.5 from 3.0
    @test ball(X, 1.0, 0.5) == [1.0]           # Only the first element is within distance 0.5 from 1.0
    @test ball(X, 5.0, 0.001) == [5.0]           # Only the last element is within distance 0.0 from 5.0
    @test ball(X, 6.0, 0.01) == []           # Only the last element is within distance 0.0 from 5.0
end