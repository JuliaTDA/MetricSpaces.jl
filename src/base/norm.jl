
"""
    Euclidean norm.
"""
norm(x) = x.^2 |> sum |> sqrt

normalize(x) = x ./ norm(x)

normalize(X::EuclideanSpace) = map(X, normalize)

function normalize!(M::MetricSpace)
    for i ∈ eachindex(M)
        M[i] = normalize(M[i])
    end
end