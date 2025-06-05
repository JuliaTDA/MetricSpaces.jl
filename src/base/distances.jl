"""
    pairwise_distance(M::S, N::S, d) where {S <: MetricSpace{T} where {T}}

Compute the pairwise distances between all elements of metric spaces `M` and `N` using the distance function `d`.

# Arguments
- `M::S`: A metric space of type `S`, where `S` is a subtype of `MetricSpace`.
- `N::S`: Another metric space of the same type as `M`.
- `d`: A function that computes the distance between two elements.

# Returns
- A matrix of size `length(M) × length(N)` where the entry `(i, j)` contains the distance `d(M[i], N[j])`.

# Notes
- The computation is parallelized across threads for improved performance.
- Progress is displayed using a progress bar.
"""
function pairwise_distance(
    M::S, N::S, d
) where {S<:MetricSpace{T} where {T}}
    s = zeros(length(M), length(N))

    p = Progress(length(M))

    Threads.@threads for (i, x) ∈ collect(enumerate(M))
        for (j, y) ∈ enumerate(N)
            next!(p)

            @inbounds s[i, j] = d(x, y)
        end
    end

    return s
end
@testitem "pairwise_distance_summary" begin
    M = EuclideanSpace([0, 1, 2])
    N = EuclideanSpace([3, 4, 5])
    pairwise_distance(M, N, dist_euclidean) == [
        3.0 4.0 5.0
        2.0 3.0 4.0
        1.0 2.0 3.0
    ]
end

"""
    pairwise_distance(M::S, N::S, d::Metric) where {S <: EuclideanSpace{N, T} where {N, T}}

Compute the pairwise distances between all elements in the collections `M` and `N` using the metric `d`.

# Arguments
- `M::S`: A collection of points in a Euclidean space.
- `N::S`: Another collection of points in the same Euclidean space as `M`.
- `d::Metric`: A metric function to compute the distance between points.

# Returns
- `s::Matrix{Float64}`: A matrix where the entry `s[i, j]` contains the distance between `M[i]` and `N[j]`.

# Notes
- The computation is parallelized across threads for efficiency.
- Progress is displayed using a progress bar.
- The function assumes that `M` and `N` are compatible with the provided metric and space type.
"""
function pairwise_distance(
    M::S, N::S, d::Metric
) where {S<:EuclideanSpace{N,T} where {N,T}}
    s = zeros(length(M), length(N))
    N2 = stack(N)

    p = Progress(length(M))

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

# Returns
- `s`: An array where each entry `s[i]` contains the summary statistic (e.g., mean) of the distances from the `i`-th element of `M` to all elements of `N`.

# Notes
- The computation is parallelized using threads for improved performance.
- Progress is displayed using a progress bar.
"""
function pairwise_distance_summary(
    M::S, N::S, d, summary_function=mean
) where {S<:MetricSpace{T} where {T}}
    s = zeros(length(M))
    v = zeros(length(N))

    p = Progress(length(M))

    Threads.@threads for (i, x) ∈ collect(enumerate(M)) #1:length(M) #
        next!(p)
        v = pairwise_distance([x], N, d)
        @inbounds s[i] = summary_function(v)
    end

    return s
end

@testitem "pairwise_distance_summary" begin
    M = EuclideanSpace([[0, 0], [0, 1], [1, 0]])
    N = EuclideanSpace([[1, 1]])
    @test pairwise_distance_summary(M, N, dist_euclidean) == pairwise_distance(M, N, dist_euclidean)[:, 1]
end