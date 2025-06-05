
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

@testitem "normalize" begin    
    @test norm([0, 1]) ≈ 1
    @test norm([1, 1]) ≈ norm([-1, -1])
    @test normalize([1, 1]) ≈ normalize([2, 2])
end