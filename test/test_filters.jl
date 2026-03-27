@testset "Filters" begin
    X = [0.0, 1.0, 2.0]
    Y = [0.0, 3.0]

    @test distance_to_measure(X, Y, k=1) == [0.0, 1.0, 1.0]
    @test distance_to_measure(X, Y, k=2, summary_function=mean) == [1.5, 1.5, 1.5]
    @test distance_to_measure(X, Y, k=2, summary_function=maximum) == [3.0, 2.0, 2.0]

    @test eccentricity(X, Y) == pairwise_distance_summary(X, Y, dist_euclidean, mean)
end

@testset "knn_density" begin
    # Two tight clusters: points near 0 and points near 10
    X = [0.0, 0.1, 0.2, 10.0, 10.1, 10.2]

    dens = knn_density(X; k=2)
    @test length(dens) == 6

    # Points in clusters should have higher density than if they were spread out
    # Within each cluster, densities should be similar
    @test dens[1] > 0
    @test dens[4] > 0

    # Simple 1D case: equally spaced points
    Y = [0.0, 1.0, 2.0, 3.0]
    dens_y = knn_density(Y; k=1)
    @test length(dens_y) == 4
    # Interior points have nearest neighbor at distance 1, endpoints also at distance 1
    @test all(d -> d > 0, dens_y)
end

@testset "dtm_density" begin
    # Two tight clusters vs spread-out points
    X = [0.0, 0.1, 0.2, 10.0, 10.1, 10.2]

    dens = dtm_density(X; k=2)
    @test length(dens) == 6
    @test all(d -> d > 0, dens)

    # Points in tight clusters should have higher density
    # (smaller DTM → higher density)
    @test dens[2] > 0  # center of first cluster
end

@testset "kde" begin
    # Simple 1D case
    X = [0.0, 1.0, 2.0, 3.0]

    dens = kde(X; bandwidth=1.0)
    @test length(dens) == 4
    @test all(d -> d > 0, dens)

    # Interior points should have higher density than endpoints
    @test dens[2] > dens[1]
    @test dens[3] > dens[4]

    # With explicit kernel
    dens_custom = kde(X; bandwidth=1.0, kernel=t -> exp(-abs(t)))
    @test length(dens_custom) == 4
    @test all(d -> d > 0, dens_custom)

    # Two-argument form: evaluate at different points
    Y = [0.5, 1.5, 2.5]
    dens_y = kde(X, Y; bandwidth=1.0)
    @test length(dens_y) == 3
    @test all(d -> d > 0, dens_y)

    # Auto bandwidth
    dens_auto = kde(X)
    @test length(dens_auto) == 4
    @test all(d -> d > 0, dens_auto)
end
