using Test
using MetricSpaces
using MetricSpaces.Datasets: sphere, swiss_roll
using Random

@testset "geodesic_distance" begin
    @testset "basic shape" begin
        Random.seed!(1)
        X = sphere(50, dim=2)
        D = geodesic_distance(X; k=8)
        n = length(X)
        @test size(D) == (n, n)
        @test all(D[i, i] == 0 for i in 1:n)
        @test isapprox(D, permutedims(D); atol=1e-10)
        @test all(D .>= 0)
    end

    @testset "geodesic >= euclidean (on a curved manifold)" begin
        Random.seed!(2)
        X = swiss_roll(200)
        D_geo = geodesic_distance(X; k=8)
        i, j = 1, 100
        eucl = dist_euclidean(X[i], X[j])
        @test D_geo[i, j] >= eucl - 1e-9   # numerical slop
    end

    @testset "disconnected components return Inf" begin
        Random.seed!(3)
        Xa = sphere(20, dim=2)
        Xb = [p .+ 1000.0 for p in sphere(20, dim=2)]
        X = vcat(Xa, Xb)
        D = geodesic_distance(X; k=3)
        @test any(isinf.(D[1:20, 21:40]))
    end
end
