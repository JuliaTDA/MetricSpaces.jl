using Random

"""
    epsilon_net(X::MetricSpace, ϵ::Number; d = dist_euclidean)

Constructs an epsilon-net for a given metric space `X`. An epsilon-net is a subset of points (landmarks) such that every point in `X` is within a distance `ϵ` of at least one landmark.

# Arguments
- `X::MetricSpace`: The metric space containing the points.
- `ϵ::Number`: The radius of the epsilon ball used to cover the points.
- `d`: A distance function to compute pairwise distances. Defaults to `dist_euclidean`.

# Returns
- `landmarks::Vector{Int}`: A vector of indices representing the selected landmarks.

# Details
The function iteratively selects points from `X` that are not yet covered by the epsilon balls of previously selected landmarks. It uses a progress meter to track the process and terminates when all points in `X` are covered.
"""
function epsilon_net(X::MetricSpace, ϵ::Number; d = dist_euclidean)

    covered = repeat([0], length(X))
    landmarks = Int[]
    
    prog = ProgressUnknown("Searching neighborhood of point number")

    while true

        # select the first non-covered index
        id_center = findfirst(==(0), covered)

        # add it to the landmarks set
        push!(landmarks, id_center)

        # get the elements currently covered by the epsilon ball around the current_center
        currently_covered = ball(X, id_center, ϵ) #findall(<(ϵ), pairwise_distance([x], X, d)[1, :]) 
        
        # update the covered indexes
        covered[currently_covered] .= 1

        # change the progress meter
        ProgressMeter.update!(prog, id_center)

        # if all points are covered, get out of the while loop
        findmin(covered)[1] > 0 && break
    end

    ProgressMeter.finish!(prog);

    return landmarks
end

"""
    farthest_points_sample_ids(X::MetricSpace, n::Integer; d = euclidean)

Sample `n` points from a metric space `X` using the Farthest Point Sampling (FPS) algorithm.

The algorithm works by iteratively selecting points that are farthest from the already selected points,
maximizing the minimum distance to previously selected points.

# Arguments
- `X::MetricSpace`: The input metric space to sample from
- `n::Integer`: Number of points to sample
- `d`: Distance function to use (default: euclidean)

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
function farthest_points_sample_ids(X::MetricSpace, n::Integer; d = euclidean)
    length(X) < n && return [1:length(X);]

    ids = zeros(Int, n)
    ids[1] = rand(1:n)

    n == 1 && return ids    

    p_0 = X[ids[1]]

    commom_max_distance = pairwise_distance([p_0], X, d)[1, :]

    @showprogress for i in 2:n
        p_i = X[ids[i-1]]
        
        d_i = pairwise_distance([p_i], X, d)[1, :] #colwise(metric, X[:, ids[i-1]], X)

        commom_max_distance = mapslices(minimum, [commom_max_distance d_i], dims = 2)[:, 1]
        
        ids[i] = findmax(commom_max_distance)[2]
    end

    return ids
end
"""
    farthest_points_sample(X::MetricSpace, n::Integer; d = euclidean)

Sample `n` points from a metric space `X` using the Farthest Point Sampling (FPS) algorithm.

This method iteratively selects points that are farthest from the already selected points,
resulting in a well-distributed subset of points from the original space.

# Arguments
- `X::MetricSpace`: The input metric space to sample from
- `n::Integer`: Number of points to sample
- `d`: Distance function to use (defaults to euclidean distance)

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
function farthest_points_sample(X::MetricSpace, n::Integer; d = euclidean)
    ids = fartest_points_sample_ids(X, n, d)
    X[ids]
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
function random_sample(X::MetricSpace, n = 1000)
    shuffle(X)[1:min(length(X), n)]
end