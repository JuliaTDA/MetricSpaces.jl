using Test
using MetricSpaces

@testset "MetricSpaces.jl" begin
    # Test for MetricSpace and EuclideanSpace
    @testset "MetricSpace and EuclideanSpace" begin
        X = rand(3, 5)
        M = EuclideanSpace(X)
        @test length(M) == 5
        @test size(M) == (5,)
        @test M[1] == X[:, 1]
        @test M[2] == X[:, 2]
    end

    # Test for pairwise_distance
    @testset "pairwise_distance" begin
        X = EuclideanSpace(rand(3, 5))
        d = dist_euclidean
        distances = pairwise_distance(X, X, d)
        @test size(distances) == (5, 5)
        @test distances[1, 1] == 0.0
    end

    # Test for pairwise_distance_summary
    @testset "pairwise_distance_summary" begin
        X = EuclideanSpace(rand(3, 5))
        d = dist_euclidean
        summary = pairwise_distance_summary(X, X, d, mean)
        @test length(summary) == 5
    end

    # Test for ball
    @testset "ball" begin
        X = EuclideanSpace(rand(3, 10))
        ϵ = 0.5
        ids = ball(X, 1, ϵ)
        @test all(id -> id in 1:10, ids)
    end

    # Test for k_neighbors
    @testset "k_neighbors" begin
        X = EuclideanSpace(rand(3, 10))
        neighbors = k_neighbors(X, X[1], 3)
        @test length(neighbors) == 3
    end

    # Test for distance_to_measure
    @testset "distance_to_measure" begin
        X = EuclideanSpace(rand(3, 10))
        distances = distance_to_measure(X, X, k = 3)
        @test length(distances) == 10
    end

    # Test for excentricity
    @testset "excentricity" begin
        X = EuclideanSpace(rand(3, 10))
        exc = excentricity(X, X)
        @test length(exc) == 10
    end

    # Test for sphere
    @testset "sphere" begin
        X = sphere(100, dim = 3, radius = 1)
        @test length(X) == 100
        @test size(X) == (100, 3)
    end

    # Test for torus
    @testset "torus" begin
        X = torus(100, r = 1, R = 3)
        @test length(X) == 100
        @test size(X) == (100, 3)
    end

    # Test for cube
    @testset "cube" begin
        X = cube(100, dim = 3, radius = 1)
        @test length(X) == 100
        @test size(X) == (100, 3)
    end

    # Test for epsilon_net
    @testset "epsilon_net" begin
        X = EuclideanSpace(rand(3, 10))
        ϵ = 0.5
        landmarks = epsilon_net(X, ϵ)
        @test length(landmarks) > 0
    end

    # Test for farthest_points_sample
    @testset "farthest_points_sample" begin
        X = EuclideanSpace(rand(3, 10))
        n = 3
        sample = farthest_points_sample(X, n)
        @test length(sample) == n
    end

    # Test for random_sample
    @testset "random_sample" begin
        X = EuclideanSpace(rand(3, 10))
        n = 5
        sample = random_sample(X, n)
        @test length(sample) == n
    end

    # Test for nerve_1d
    @testset "nerve_1d" begin
        covering = [[1, 2], [2, 3], [3, 4]]
        g = nerve_1d(covering)
        @test length(edges(g)) > 0
    end
end
