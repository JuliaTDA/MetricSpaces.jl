"""
    k_neighbors(X::MetricSpace{T}, x::T, k::Int, d=dist_euclidean) where {T}

Finds the indices of the `k` nearest neighbors of a point `x` in the metric space `X`.

# Arguments
- `X::MetricSpace{T}`: The metric space containing the points to search.
- `x::T`: The query point for which the nearest neighbors are to be found.
- `k::Int`: The number of nearest neighbors to find.
- `d`: A distance function (default is `dist_euclidean`) used to compute the distance between points.

# Returns
- `ids`: A vector of indices corresponding to the `k` nearest neighbors of `x` in `X`.

# Notes
- If `k` is greater than the number of points in `X`, the function will return indices for all points in `X`.
- The distance function `d` must be compatible with the elements of `X` and `x`.

"""
k_neighbors_ids = function (X::MetricSpace{T}, x::T, k::Int, d=dist_euclidean) where {T}
    @assert k > 0 "k must be a positive integer"
    dists = pairwise_distance([x], X, d)
    ids = partialsortperm(dists, k=1:min(length(dists), k))

    ids
end

"""
    k_neighbors(X::MetricSpace{T}, x::T, k::Int, d=dist_euclidean) where {T}

Finds the `k` nearest neighbors of a given point `x` in the metric space `X`.

# Arguments
- `X::MetricSpace{T}`: The metric space containing the points.
- `x::T`: The query point for which the nearest neighbors are to be found.
- `k::Int`: The number of nearest neighbors to retrieve.
- `d`: The distance function to use for computing distances. Defaults to `dist_euclidean`.

# Returns
- A collection of the `k` nearest neighbors of `x` in `X`.

# Notes
This function internally uses `k_neighbors_ids` to retrieve the indices of the nearest neighbors and then returns the corresponding elements from `X`.
"""
k_neighbors = function (X::MetricSpace{T}, x::T, k::Int, d=dist_euclidean) where {T}
    ids = k_neighbors_ids(X, x, k, d)
    X[ids]
end