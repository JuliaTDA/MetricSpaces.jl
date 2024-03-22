k_neighbors = function(X::MetricSpace{T}, x::T, k::Int, d = dist_euclidean) where {T}
    ds = pairwise_distance([x], X, d)
    ids = partialsortperm(ds, k = 1:min(length(ds), k))

    ids
end

# k_neighbors = function(X::MetricSpace{T}, k::Int) where {T}
    
# end