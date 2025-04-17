"""
    distance_to_measure(X::S, Y::S; d=dist_euclidean, k::Integer=5, summary_function=maximum) where {S <: MetricSpace{T}}

Computes a measure of distance from each point in the metric space `X` to the metric space `Y`. For each point in `X`, the function calculates the distances to the `k` nearest neighbors in `Y` using the provided distance function `d` (default is `dist_euclidean`). The resulting distances are summarized using the specified `summary_function` (default is `maximum`).

# Arguments
- `X::S`: A metric space of type `S` containing the points to measure distances from.
- `Y::S`: A metric space of type `S` containing the points to measure distances to.
- `d`: A distance function to compute the distance between points in `X` and `Y`. Defaults to `dist_euclidean`.
- `k::Integer`: The number of nearest neighbors in `Y` to consider for each point in `X`. Defaults to `5`.
- `summary_function`: A function to summarize the `k` nearest distances. Defaults to `maximum`.

# Returns
- A vector of summarized distances for each point in `X`.

# Notes
- The computation is parallelized using `Threads.@threads` for improved performance.
- The function assumes that the input metric spaces `X` and `Y` are compatible with the provided distance function `d`.

"""
function distance_to_measure(
    X::S, Y::S; 
    d = dist_euclidean
    ,k::Integer = 5
    ,summary_function = maximum
    ) where {S <: MetricSpace{T} where {T}}

    s = zeros(length(X))

    Threads.@threads for (i, x) ∈ collect(enumerate(X))
        ds = sort(pairwise_distance([x], Y, d)[1, :])[1:min(end, k)]
        @inbounds s[i] = summary_function(ds)
    end

    return s
end


"""
    excentricity(X::S, Y::S; d=dist_euclidean) where {S <: MetricSpace{T}}

Computes the excentricity of the metric space `X` with respect to the metric space `Y`. The excentricity is defined as the mean of the pairwise distances between points in `X` and `Y`, using the provided distance function `d` (default is `dist_euclidean`).

# Arguments
- `X::S`: A metric space of type `S` containing the points to compute excentricity for.
- `Y::S`: A metric space of type `S` containing the points to compute distances to.
- `d`: A distance function to compute the distance between points in `X` and `Y`. Defaults to `dist_euclidean`.

# Returns
- A scalar value representing the excentricity of `X` with respect to `Y`.

# Notes
- This function internally uses `pairwise_distance_summary` with the `mean` function to compute the excentricity.
"""
function excentricity(X::S, Y::S; d = dist_euclidean) where {S <: MetricSpace{T} where {T}}
    pairwise_distance_summary(X, Y, d, mean)
end