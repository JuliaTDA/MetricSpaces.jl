
"""
    Euclidean norm.
"""
norm(x) = sqrt(sum(abs2, x))

normalize(x) = x ./ norm(x)

normalize(X::EuclideanSpace) = map(normalize, X)

function normalize!(M::MetricSpace)
    for i ∈ eachindex(M)
        M[i] = normalize(M[i])
    end
end
