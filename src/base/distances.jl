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
    m = length(M)
    n = length(N)
    s = Matrix{Float64}(undef, m, n)

    (m == 0 || n == 0) && return s

    p = Progress(m; enabled=show_progress)

    if nthreads() == 1
        @inbounds for i ∈ 1:m
            x = M[i]
            for j ∈ 1:n
                s[i, j] = d(x, N[j])
            end
            next!(p)
        end
    else
        tforeach(1:m; scheduler=:dynamic) do i
            x = @inbounds M[i]
            @inbounds for j ∈ 1:n
                s[i, j] = d(x, N[j])
            end
            next!(p)
        end
    end

    s
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
    m = length(M)
    n = length(N)
    s = Matrix{Float64}(undef, m, n)

    (m == 0 || n == 0) && return s

    N2 = stack(N)

    p = Progress(m; enabled=show_progress)

    if nthreads() == 1
        @inbounds for i ∈ 1:m
            colwise!(d, view(s, i, :), M[i], N2)
            next!(p)
        end
    else
        tforeach(1:m; scheduler=:dynamic) do i
            x = @inbounds M[i]
            colwise!(d, @view(s[i, :]), x, N2)
            next!(p)
        end
    end

    s
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
    m = length(M)
    n = length(N)
    s = zeros(m)

    p = Progress(m; enabled=show_progress)

    if summary_function === mean
        if n == 0
            empty_vals = Float64[]
            @inbounds for i ∈ 1:m
                s[i] = summary_function(empty_vals)
            end
            return s
        end

        inv_n = inv(float(n))
        if nthreads() == 1
            @inbounds for i ∈ 1:m
                x = M[i]
                acc = 0.0
                for j ∈ 1:n
                    acc += d(x, N[j])
                end
                s[i] = acc * inv_n
                next!(p)
            end
        else
            tforeach(1:m; scheduler=:dynamic) do i
                x = @inbounds M[i]
                acc = 0.0
                @inbounds for j ∈ 1:n
                    acc += d(x, N[j])
                end
                @inbounds s[i] = acc * inv_n
                next!(p)
            end
        end
    else
        if nthreads() == 1
            @inbounds for i ∈ 1:m
                x = M[i]
                vals = Vector{Float64}(undef, n)
                for j ∈ 1:n
                    vals[j] = d(x, N[j])
                end
                s[i] = summary_function(vals)
                next!(p)
            end
        else
            tforeach(1:m; scheduler=:dynamic) do i
                x = @inbounds M[i]
                vals = Vector{Float64}(undef, n)
                @inbounds for j ∈ 1:n
                    vals[j] = d(x, N[j])
                end
                @inbounds s[i] = summary_function(vals)
                next!(p)
            end
        end
    end

    s
end
