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
    d=dist_euclidean,
    k::Integer=5,
    summary_function=maximum,
) where {S <: MetricSpace{T} where {T}}
    @assert k > 0 "k must be a positive integer"

    m = length(X)
    n = length(Y)
    s = zeros(m)

    if n == 0
        empty_vals = Float64[]
        @inbounds for i ∈ 1:m
            s[i] = summary_function(empty_vals)
        end
        return s
    end

    k_eff = min(n, Int(k))

    if nthreads() == 1
        @inbounds for i ∈ 1:m
            s[i] = _k_neighbors_summary(X[i], Y, d, k_eff, summary_function)
        end
    else
        tforeach(1:m; scheduler=:dynamic) do i
            @inbounds s[i] = _k_neighbors_summary(X[i], Y, d, k_eff, summary_function)
        end
    end

    s
end

function _k_neighbors_summary(x, Y::MetricSpace, d, k::Int, summary_function)
    n = length(Y)
    if k <= 32
        best = fill(Inf, k)
        max_idx = 1
        max_val = best[1]
        @inbounds for j ∈ 1:n
            dist = d(x, Y[j])
            if dist < max_val
                best[max_idx] = dist

                max_idx = 1
                max_val = best[1]
                for r ∈ 2:k
                    v = best[r]
                    if v > max_val
                        max_idx = r
                        max_val = v
                    end
                end
            end
        end

        sort!(best)
        return summary_function(best)
    end

    vals = Vector{Float64}(undef, n)
    @inbounds for j ∈ 1:n
        vals[j] = d(x, Y[j])
    end
    partialsort!(vals, 1:k)
    summary_function(@view vals[1:k])
end


"""
    eccentricity(X::S, Y::S; d=dist_euclidean) where {S <: MetricSpace{T}}

Computes the eccentricity of each point in metric space `X` with respect to the
metric space `Y`. For each point `x` in `X`, the eccentricity is the mean distance
from `x` to all points in `Y`, using the distance function `d`.

# Arguments
- `X::S`: A metric space of type `S` containing the points to compute eccentricity for.
- `Y::S`: A metric space of type `S` containing the reference points.
- `d`: A distance function to compute the distance between points in `X` and `Y`. Defaults to `dist_euclidean`.

# Returns
- A `Vector{Float64}` of length `length(X)`, where the `i`-th entry is the mean
  distance from `X[i]` to all points in `Y`.

# Notes
- This function internally uses `pairwise_distance_summary` with the `mean` function.
- For a self-eccentricity filter suitable for use in Mapper, use the single-argument
  form `eccentricity(X)`.

See also: [`eccentricity(X)`](@ref).
"""
function eccentricity(X::S, Y::S; d = dist_euclidean) where {S <: MetricSpace{T} where {T}}
    pairwise_distance_summary(X, Y, d, mean)
end

"""
    eccentricity(X::S; d=dist_euclidean) where {S <: MetricSpace{T}}

Computes the per-point eccentricity of each point in metric space `X` with respect
to itself. For each point `x ∈ X`, the eccentricity is the mean distance from `x`
to every point in `X`.

This is a convenient Mapper filter function: points near the "centre" of the cloud
receive low eccentricity values, while outliers receive high values.

# Arguments
- `X::S`: A metric space of type `S` containing the points to compute eccentricity for.
- `d`: A distance function. Defaults to `dist_euclidean`.

# Returns
- A `Vector{Float64}` of length `length(X)`, where entry `i` is the mean distance
  from `X[i]` to all points in `X`.

# Notes
- Equivalent to `eccentricity(X, X; d=d)`.
- Time complexity is O(n²) in the number of points.

# Example
```julia
X = [0.0, 1.0, 2.0]
eccentricity(X)   # ≈ [1.0, 0.667, 1.0] — centre point has lowest eccentricity
```

See also: [`eccentricity(X, Y)`](@ref).
"""
function eccentricity(X::S; d = dist_euclidean) where {S <: MetricSpace{T} where {T}}
    eccentricity(X, X; d = d)
end


"""
    knn_density(X::MetricSpace; d=dist_euclidean, k::Integer=5)

Estimate the density at each point in `X` using the k-nearest neighbor method.
For each point, the density is proportional to `k / r_k^dim`, where `r_k` is the
distance to the k-th nearest neighbor (excluding self) and `dim` is the ambient
dimension inferred from the data.

# Arguments
- `X::MetricSpace`: The metric space to estimate density for.
- `d`: Distance function. Defaults to `dist_euclidean`.
- `k::Integer`: Number of nearest neighbors. Defaults to `5`.

# Returns
- A `Vector{Float64}` of density estimates, one per point in `X`.
"""
function knn_density(
    X::MetricSpace;
    d=dist_euclidean,
    k::Integer=5,
)
    @assert k > 0 "k must be a positive integer"
    m = length(X)
    @assert m > 1 "X must have at least 2 points"

    # k+1 because distance_to_measure includes self (distance 0)
    k_eff = min(m, k + 1)
    dtm = distance_to_measure(X, X; d=d, k=k_eff, summary_function=maximum)

    # Infer ambient dimension from data
    dim = length(X[1])

    densities = zeros(m)
    @inbounds for i in 1:m
        r = dtm[i]
        densities[i] = r > 0 ? k / r^dim : Inf
    end

    densities
end


"""
    dtm_density(X::MetricSpace; d=dist_euclidean, k::Integer=5)

Estimate the density at each point in `X` using the distance-to-measure (DTM).
The density is computed as the inverse of `distance_to_measure(X, X; k=k)`.
This is more robust to outliers than `knn_density`.

# Arguments
- `X::MetricSpace`: The metric space to estimate density for.
- `d`: Distance function. Defaults to `dist_euclidean`.
- `k::Integer`: Number of nearest neighbors for DTM. Defaults to `5`.

# Returns
- A `Vector{Float64}` of density estimates, one per point in `X`.
"""
function dtm_density(
    X::MetricSpace;
    d=dist_euclidean,
    k::Integer=5,
)
    @assert k > 0 "k must be a positive integer"
    @assert length(X) > 0 "X must be non-empty"

    dtm = distance_to_measure(X, X; d=d, k=k, summary_function=mean)

    densities = similar(dtm)
    @inbounds for i in eachindex(dtm)
        densities[i] = dtm[i] > 0 ? 1.0 / dtm[i] : Inf
    end

    densities
end


"""
    kde(X::MetricSpace; d=dist_euclidean, bandwidth=nothing, kernel=nothing)
    kde(X::MetricSpace, Y::MetricSpace; d=dist_euclidean, bandwidth=nothing, kernel=nothing)

Kernel density estimation on a metric space. Evaluates the density at each point
in `X` (single-argument form) or at each point in `Y` using `X` as the data
(two-argument form).

The density at a point `y` is: `(1/n) * Σ kernel(d(y, x) / bandwidth)` for `x ∈ X`.

# Arguments
- `X::MetricSpace`: The data points.
- `Y::MetricSpace`: (optional) Points at which to evaluate the density. Defaults to `X`.
- `d`: Distance function. Defaults to `dist_euclidean`.
- `bandwidth`: Kernel bandwidth. If `nothing`, uses a heuristic based on the median
  pairwise nearest-neighbor distance.
- `kernel`: A function `ℝ → ℝ` applied to scaled distances. Defaults to the Gaussian
  kernel `t -> exp(-t^2 / 2)`.

# Returns
- A `Vector{Float64}` of density estimates.
"""
function kde(
    X::MetricSpace;
    d=dist_euclidean,
    bandwidth=nothing,
    kernel=nothing,
)
    kde(X, X; d=d, bandwidth=bandwidth, kernel=kernel)
end

function kde(
    X::S, Y::S;
    d=dist_euclidean,
    bandwidth=nothing,
    kernel=nothing,
) where {S <: MetricSpace{T} where {T}}
    n = length(X)
    m = length(Y)
    @assert n > 0 "X must be non-empty"
    @assert m > 0 "Y must be non-empty"

    if isnothing(kernel)
        kernel = t -> exp(-t^2 / 2)
    end

    if isnothing(bandwidth)
        # Heuristic: median nearest-neighbor distance
        nn_dists = distance_to_measure(X, X; d=d, k=2, summary_function=maximum)
        bandwidth = median(nn_dists)
        if bandwidth ≈ 0
            bandwidth = 1.0
        end
    end

    densities = zeros(m)

    if nthreads() == 1
        @inbounds for i in 1:m
            s = 0.0
            for j in 1:n
                s += kernel(d(Y[i], X[j]) / bandwidth)
            end
            densities[i] = s / n
        end
    else
        tforeach(1:m; scheduler=:dynamic) do i
            s = 0.0
            @inbounds for j in 1:n
                s += kernel(d(Y[i], X[j]) / bandwidth)
            end
            @inbounds densities[i] = s / n
        end
    end

    densities
end
