using Random

"""
    epsilon_net(X::MetricSpace, ϵ::Number; d = dist_euclidean)

Constructs an epsilon-net for a given metric space `X`. An epsilon-net is a subset of points (landmarks) such that every point in `X` is within a distance `ϵ` of at least one landmark.

# Arguments
- `X::MetricSpace`: The metric space containing the points.
- `ϵ::Number`: The radius of the epsilon ball used to cover the points.
- `d`: A distance function to compute pairwise distances. Defaults to `dist_euclidean`.
- `show_progress::Bool=false`: Whether to display a progress bar.

# Returns
- `landmarks::Vector{Int}`: A vector of indices representing the selected landmarks.

# Details
The function iteratively selects points from `X` that are not yet covered by the epsilon balls of previously selected landmarks. It terminates when all points in `X` are covered.
"""
function epsilon_net(X::MetricSpace, ϵ::Number; d=dist_euclidean, show_progress::Bool=false)

    covered = repeat([0], length(X))
    landmarks = Int[]

    prog = ProgressUnknown("Searching neighborhood of point number"; enabled=show_progress)

    while true

        # select the first non-covered index
        id_center = findfirst(==(0), covered)

        # add it to the landmarks set
        push!(landmarks, id_center)

        # get the elements currently covered by the epsilon ball around the current_center
        currently_covered = ball_ids(X, X[id_center], ϵ, d)

        # update the covered indexes
        covered[currently_covered] .= 1

        # change the progress meter
        ProgressMeter.update!(prog, id_center)

        # if all points are covered, get out of the while loop
        findmin(covered)[1] > 0 && break
    end

    ProgressMeter.finish!(prog)

    return landmarks
end

"""
    farthest_points_sample_ids(X::MetricSpace, n::Integer; d = dist_euclidean)

Sample `n` points from a metric space `X` using the Farthest Point Sampling (FPS) algorithm.

The algorithm works by iteratively selecting points that are farthest from the already selected points,
maximizing the minimum distance to previously selected points.

# Arguments
- `X::MetricSpace`: The input metric space to sample from
- `n::Integer`: Number of points to sample
- `d`: Distance function to use (default: euclidean)
- `show_progress::Bool=false`: Whether to display a progress bar.

# Returns
- Vector of `n` indices representing the sampled points

# Notes
- If `length(X) < n`, returns all indices `[1:length(X)]`
- The first point is selected randomly
- The algorithm runs in O(kN) time, where k is the number of points to sample and N is the total number of points

# Examples
```julia
X = EuclideanSpace(rand(100, 3))
sampled_ids = farthest_points_sample_ids(X, 10)
```

# Details
The algorithm works as follows:
1. Randomly select the first point from `X`.
2. For each subsequent point, compute the distance to all previously selected points.
3. Select the point that is farthest from the previously selected points.
4. Repeat until `n` points are selected.
# Complexity
The algorithm runs in O(kN) time, where k is the number of points to sample and N is the total number of points in `X`.
"""
function farthest_points_sample_ids(X::MetricSpace, n::Integer; d=dist_euclidean, show_progress::Bool=false)
    n <= 0 && return Int[]

    m = length(X)
    m < n && return collect(1:m)

    ids = Vector{Int}(undef, n)
    ids[1] = rand(1:m)
    n == 1 && return ids

    first_point = @inbounds X[ids[1]]

    min_dists = Vector{typeof(d(first_point, first_point))}(undef, m)
    selected = falses(m)
    selected[ids[1]] = true

    @inbounds for j in 1:m
        min_dists[j] = d(first_point, X[j])
    end

    p = Progress(n - 1; enabled=show_progress)

    # Pick the farthest point from the first sampled point.
    max_id = 0
    max_val = zero(eltype(min_dists))
    @inbounds for j in 1:m
        d_j = min_dists[j]
        if !selected[j] && (max_id == 0 || d_j > max_val)
            max_id = j
            max_val = d_j
        end
    end
    ids[2] = max_id
    selected[max_id] = true
    last_id = max_id
    next!(p)

    for i in 3:n
        p_i = @inbounds X[last_id]

        max_id = 0
        max_val = zero(eltype(min_dists))

        @inbounds for j in 1:m
            d_ij = d(p_i, X[j])

            cur = min_dists[j]
            if d_ij < cur
                cur = d_ij
                min_dists[j] = cur
            end

            if !selected[j] && (max_id == 0 || cur > max_val)
                max_id = j
                max_val = cur
            end
        end

        ids[i] = max_id
        selected[max_id] = true
        last_id = max_id
        next!(p)
    end

    ids
end

"""
    farthest_points_sample(X::MetricSpace, n::Integer; d = dist_euclidean)

Sample `n` points from a metric space `X` using the Farthest Point Sampling (FPS) algorithm.

This method iteratively selects points that are farthest from the already selected points,
resulting in a well-distributed subset of points from the original space.

# Arguments
- `X::MetricSpace`: The input metric space to sample from
- `n::Integer`: Number of points to sample
- `d`: Distance function to use (defaults to euclidean distance)
- `show_progress::Bool=false`: Whether to display a progress bar.

# Returns
- A subset of `n` points from `X` that are approximately maximally distant from each other

# Examples
```julia
X = EuclideanSpace(rand(100, 3))
sampled_points = farthest_points_sample(X, 10)
```

# Details
The algorithm works as follows:
1. Randomly select the first point from `X`.
2. For each subsequent point, compute the distance to all previously selected points.
3. Select the point that is farthest from the previously selected points.
4. Repeat until `n` points are selected.

# Complexity
The algorithm runs in O(kN) time, where k is the number of points to sample and N is the total number of points in `X`.
"""
function farthest_points_sample(X::MetricSpace, n::Integer; d=dist_euclidean, show_progress::Bool=false)
    ids = farthest_points_sample_ids(X, n; d=d, show_progress=show_progress)
    return X[ids]
end

"""
    random_sample(X::MetricSpace, n = 1000)

Randomly sample `n` points from a metric space `X` without replacement.

# Arguments
- `X::MetricSpace`: The metric space to sample from
- `n::Integer = 1000`: The number of points to sample (default: 1000)

# Returns
- `Vector`: A vector containing `min(length(X), n)` randomly sampled points from `X`

# Examples
```julia
X = EuclideanSpace(rand(100, 3))
sampled_points = random_sample(X, 10)
```
"""
function random_sample(X::MetricSpace, n=1000)
    shuffle(X)[1:min(length(X), n)]
end
