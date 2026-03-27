@testset "Distances" begin
    @testset "pairwise_distance" begin
        M = EuclideanSpace([0, 1, 2])
        N = EuclideanSpace([3, 4, 5])
        @test pairwise_distance(M, N, dist_euclidean) == [
            3.0 4.0 5.0
            2.0 3.0 4.0
            1.0 2.0 3.0
        ]
    end

    @testset "pairwise_distance_summary" begin
        M = EuclideanSpace([[0, 0], [0, 1], [1, 0]])
        N = EuclideanSpace([[1, 1]])
        @test pairwise_distance_summary(M, N, dist_euclidean) == pairwise_distance(M, N, dist_euclidean)[:, 1]
    end

    @testset "distance wrappers" begin
        using StaticArrays: SVector
        x = SVector(1.0, 0.0, 0.0)
        y = SVector(0.0, 1.0, 0.0)

        @test dist_euclidean(x, y) ≈ sqrt(2.0)
        @test dist_cityblock(x, y) ≈ 2.0
        @test dist_chebyshev(x, y) ≈ 1.0
        @test dist_cosine(x, y) ≈ 1.0
        @test dist_minkowski(2)(x, y) ≈ sqrt(2.0)
        @test dist_minkowski(1)(x, y) ≈ 2.0
        @test dist_hamming(x, y) ≈ 2.0
        @test dist_correlation(x, y) isa Number
    end
end
