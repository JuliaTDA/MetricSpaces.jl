"""
    pairwise_distance(M::S, N::S, d::Function) where {S <: MetricSpace{T} where {T}}

Calculate the distance of each element of M to each element of N 
and return a matrix where the entry [i, j] is the distance from
x_i to y_j.

## Arguments:
- `M, N`: Metric spaces.
- `d`: a distance function defined on the elements of M and N.

## Details:
Parallel details
"""
function pairwise_distance(
    M::S, N::S, d::Function
    ) where {S <: MetricSpace{T} where {T}}
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

# using Distances.jl
"""
    pairwise_distance(M::S, N::S, d::Metric) where {S <: EuclideanSpace{N, T} where {N, T}}

Calculate the distance of each element of M to each element of N 
and return a matrix where the entry [i, j] is the distance from
x_i to y_j.

## Arguments:
- `M, N`: Metric spaces.
- `d`: a distance function defined on the elements of M and N.

## Details:
This method implements a faster version of the calculation using the Distances.jl package.
"""
function pairwise_distance(
    M::S, N::S, d::Metric
    ) where {S <: EuclideanSpace{N, T} where {N, T}}
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
    pairwise_distance_summary(M::T, N::T, d::Function, summary_function = mean) where {T <: MetricSpace}

For each x ∈ M, calculate the distance from x to all elements of N; then, apply
the `summary_function` to summarise this array to a number.

## Arguments:
- `M, N`: Metric spaces.
- `d`: a distance function.
- `summary_function`: a function that takes an array of elements and returns a single element.
By default: the mean.
"""
function pairwise_distance_summary(
    M::S, N::S, d::Function, summary_function = mean
    ) where {S <: MetricSpace{T} where {T}}
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

function distance_to_measure(
    M::S, N::S; 
    d = euclidean
    ,k::Integer = 5
    ,summary_function = maximum
    ) where {S <: MetricSpace{T} where {T}}

    s = zeros(length(M))

    Threads.@threads for (i, x) ∈ collect(enumerate(M))
        ds = sort(pairwise_distance([x], N, d)[1, :])[1:min(end, k)]
        s[i] = summary_function(ds)
    end

    return s    
end

# function distance_to_measure(
#     M::MetricSpace, N::MetricSpace = M; 
#     d = Euclidean()
#     , k = 5
#     ,summary_function = mean
#     )
#     tree = BallTree(X, metric; reorder = false)

#     n = n_points(p)        
#     s = zeros(Float64, n)    
#     n == 0 && return(s)

#     columns = eachcol(p)
#     @threads for i ∈ 1:n
#         v = columns[i]
#         _, d = knn(tree, v, k)
#         @inbounds s[i] = d |> summary_function
#     end

#     return s
# end