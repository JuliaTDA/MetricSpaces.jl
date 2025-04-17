using Test
using MetricSpaces


@testset "100 points in sphere with radius 1" begin
    X = sphere(100, dim=3, radius=1.0)
    @test size(X) == (100,)
    @test typeof(X) == EuclideanSpace{3, Float64}
    @test all(x -> norm(x) ≈ 1.0, X)
end