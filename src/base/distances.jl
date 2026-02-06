"""
    pairwise_distance(M::S, N::S, d) where {S <: MetricSpace{T} where {T}}

Compute the pairwise distances between all elements of metric spaces `M` and `N` using the distance function `d`.

# Arguments
- `M::S`: A metric space of type `S`, where `S` is a subtype of `MetricSpace`.
- `N::S`: Another metric space of the same type as `M`.
- `d`: A function that computes the distance between two elements.
- `show_progress::Bool=false`: Whether to display a progress bar.

# Returns
- A matrix of size `length(M) × length(N)` where the entry `(i, j)` contains the distance `d(M[i], N[j])`.

# Notes
- The computation is parallelized across threads for improved performance.
- Progress is optionally displayed using a progress bar (disabled by default).
"""
function pairwise_distance(
    M::S, N::S, d; show_progress::Bool=false
) where {S<:MetricSpace{T} where {T}}
    s = zeros(length(M), length(N))

    p = Progress(length(M); enabled=show_progress)

    Threads.@threads for (i, x) ∈ collect(enumerate(M))
        for (j, y) ∈ enumerate(N)
            next!(p)

            @inbounds s[i, j] = d(x, y)
        end
    end

    return s
end

"""
    pairwise_distance(M::S, N::S, d::Metric) where {S <: EuclideanSpace{N, T} where {N, T}}

Compute the pairwise distances between all elements in the collections `M` and `N` using the metric `d`.

# Arguments
- `M::S`: A collection of points in a Euclidean space.
- `N::S`: Another collection of points in the same Euclidean space as `M`.
- `d::Metric`: A metric function to compute the distance between points.
- `show_progress::Bool=false`: Whether to display a progress bar.

# Returns
- `s::Matrix{Float64}`: A matrix where the entry `s[i, j]` contains the distance between `M[i]` and `N[j]`.

# Notes
- The computation is parallelized across threads for efficiency.
- Progress is optionally displayed using a progress bar (disabled by default).
- The function assumes that `M` and `N` are compatible with the provided metric and space type.
"""
function pairwise_distance(
    M::S, N::S, d::Metric; show_progress::Bool=false
) where {S<:EuclideanSpace{N,T} where {N,T}}
    s = zeros(length(M), length(N))
    N2 = stack(N)

    p = Progress(length(M); enabled=show_progress)

    Threads.@threads for (i, x) ∈ collect(enumerate(M))
        next!(p)
        @inbounds s[i, :] = colwise(d, x, N2)
    end

    return s
end

"""
    pairwise_distance_summary(M::S, N::S, d, summary_function = mean) where {S <: MetricSpace{T} where {T}}

Compute a summary statistic of pairwise distances between each element of metric space `M` and all elements of metric space `N` using the distance function `d`.

# Arguments
- `M::S`: A metric space (or collection of points) of type `S`.
- `N::S`: Another metric space (or collection of points) of type `S`.
- `d`: A function that computes the distance between two points.
- `summary_function`: (Optional) A function to summarize the distances for each element of `M` (default is `mean`).
- `show_progress::Bool=false`: Whether to display a progress bar.

# Returns
- `s`: An array where each entry `s[i]` contains the summary statistic (e.g., mean) of the distances from the `i`-th element of `M` to all elements of `N`.

# Notes
- The computation is parallelized using threads for improved performance.
- Progress is optionally displayed using a progress bar (disabled by default).
"""
function pairwise_distance_summary(
    M::S, N::S, d, summary_function=mean; show_progress::Bool=false
) where {S<:MetricSpace{T} where {T}}
    s = zeros(length(M))
    v = zeros(length(N))

    p = Progress(length(M); enabled=show_progress)

    Threads.@threads for (i, x) ∈ collect(enumerate(M)) #1:length(M) #
        next!(p)
        v = pairwise_distance([x], N, d)
        @inbounds s[i] = summary_function(v)
    end

    return s
end