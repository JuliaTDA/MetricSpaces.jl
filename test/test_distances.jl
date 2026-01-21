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
end
