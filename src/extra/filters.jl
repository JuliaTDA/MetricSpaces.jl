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

Computes the eccentricity of the metric space `X` with respect to the metric space `Y`. The eccentricity is defined as the mean of the pairwise distances between points in `X` and `Y`, using the provided distance function `d` (default is `dist_euclidean`).

# Arguments
- `X::S`: A metric space of type `S` containing the points to compute eccentricity for.
- `Y::S`: A metric space of type `S` containing the points to compute distances to.
- `d`: A distance function to compute the distance between points in `X` and `Y`. Defaults to `dist_euclidean`.

# Returns
- A scalar value representing the eccentricity of `X` with respect to `Y`.

# Notes
- This function internally uses `pairwise_distance_summary` with the `mean` function to compute the eccentricity.
"""
function eccentricity(X::S, Y::S; d = dist_euclidean) where {S <: MetricSpace{T} where {T}}
    pairwise_distance_summary(X, Y, d, mean)
end
