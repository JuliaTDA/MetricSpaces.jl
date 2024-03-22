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

function excentricity(X::S, Y::S; d = dist_euclidean) where {S <: MetricSpace{T} where {T}}
    pairwise_distance_summary(X, Y, d, mean)
end