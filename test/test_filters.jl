@testset "Filters" begin
    X = [0.0, 1.0, 2.0]
    Y = [0.0, 3.0]

    @test distance_to_measure(X, Y, k=1) == [0.0, 1.0, 1.0]
    @test distance_to_measure(X, Y, k=2, summary_function=mean) == [1.5, 1.5, 1.5]
    @test distance_to_measure(X, Y, k=2, summary_function=maximum) == [3.0, 2.0, 2.0]

    @test eccentricity(X, Y) == pairwise_distance_summary(X, Y, dist_euclidean, mean)
end
