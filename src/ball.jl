function ball(X::MetricSpace, I::SubsetIndex, ϵ::Number)
    # get the epsilon-close points
    ids = findall(<(ϵ), pairwise_distance(X, X[I], dist_euclidean))
    
    # return just the points ids
    [j[1] for j ∈ ids] |> unique

end

function ball(X::MetricSpace, i::Integer, ϵ::Number)
    ball(X, [i], ϵ)    
end