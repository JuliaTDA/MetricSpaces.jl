@testset "Filters" begin
    X = [0.0, 1.0, 2.0]
    Y = [0.0, 3.0]

    @test distance_to_measure(X, Y, k=1) == [0.0, 1.0, 1.0]
    @test distance_to_measure(X, Y, k=2, summary_function=mean) == [1.5, 1.5, 1.5]
    @test distance_to_measure(X, Y, k=2, summary_function=maximum) == [3.0, 2.0, 2.0]

    @test eccentricity(X, Y) == pairwise_distance_summary(X, Y, dist_euclidean, mean)
end

@testset "eccentricity (per-point)" begin
    # Three collinear points: 0, 1, 2
    # ecc(0) = mean(|0-0|, |0-1|, |0-2|) = mean(0,1,2) = 1.0
    # ecc(1) = mean(|1-0|, |1-1|, |1-2|) = mean(1,0,1) = 2/3
    # ecc(2) = mean(|2-0|, |2-1|, |2-2|) = mean(2,1,0) = 1.0
    X = [0.0, 1.0, 2.0]
    ecc = eccentricity(X)

    @test length(ecc) == length(X)
    @test ecc ≈ [1.0, 2/3, 1.0]

    # Centre point has the LOWEST eccentricity in the symmetric configuration
    @test ecc[2] < ecc[1]
    @test ecc[2] < ecc[3]

    # One-argument form is equivalent to eccentricity(X, X)
    @test eccentricity(X) == eccentricity(X, X)

    # Custom distance keyword works (cityblock == euclidean for 1-D scalars)
    ecc_cb = eccentricity(X; d=dist_cityblock)
    @test ecc_cb ≈ ecc

    # Output length matches number of points for a larger space
    Z = collect(0.0:0.5:5.0)   # 11 points
    @test length(eccentricity(Z)) == length(Z)

    # Symmetric configuration in 2-D: vertices of an equilateral triangle
    # All points should have equal eccentricity
    p1 = [0.0, 0.0]
    p2 = [1.0, 0.0]
    p3 = [0.5, sqrt(3)/2]
    T = [p1, p2, p3]
    ecc_T = eccentricity(T)
    @test length(ecc_T) == 3
    @test ecc_T[1] ≈ ecc_T[2] ≈ ecc_T[3]
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
