using MetricSpaces.Datasets

@testset "Datasets" begin
    @testset "sphere" begin
        X = sphere(100, dim=3, radius=1.0)
        @test size(X) == (100,)
        @test typeof(X) == EuclideanSpace{3,Float64}
        @test all(extrema(norm.(X)) .≈ (1.0, 1.0))
    end

    @testset "torus" begin
        X = torus(100)
        @test size(X) == (100,)
        @test typeof(X) == EuclideanSpace{3,Float64}
    end

    @testset "cube" begin
        X = cube(100, dim=3)
        @test size(X) == (100,)
        @test typeof(X) == EuclideanSpace{3,Float64}
    end

    @testset "grid" begin
        X = grid(5, dim=2)
        @test length(X) == 25
        @test typeof(X) == EuclideanSpace{2,Float64}
    end

    @testset "star" begin
        X = star(100, n_arms=5, dim=2)
        @test length(X) == 100
        @test typeof(X) == EuclideanSpace{2,Float64}
    end

    @testset "trefoil_knot" begin
        X = trefoil_knot(100)
        @test length(X) == 100
        @test typeof(X) == EuclideanSpace{3,Float64}
    end

    @testset "linked_rings" begin
        X = linked_rings(100)
        @test length(X) == 100
        @test typeof(X) == EuclideanSpace{3,Float64}
    end

    @testset "unlinked_rings" begin
        X = unlinked_rings(100)
        @test length(X) == 100
        @test typeof(X) == EuclideanSpace{3,Float64}
    end

    @testset "two_clusters" begin
        X = two_clusters(100, dim=3)
        @test length(X) == 100
        @test typeof(X) == EuclideanSpace{3,Float64}
    end

    @testset "three_clusters" begin
        X = three_clusters(99, dim=2)
        @test length(X) == 99
        @test typeof(X) == EuclideanSpace{2,Float64}
    end

    @testset "linked_clusters" begin
        X = linked_clusters(3, per_cluster=20, per_link=10, dim=2)
        @test length(X) == 3 * 20 + 2 * 10  # 80
        @test typeof(X) == EuclideanSpace{2,Float64}
    end

    @testset "long_gaussian" begin
        X = long_gaussian(100, dim=4)
        @test length(X) == 100
        @test typeof(X) == EuclideanSpace{4,Float64}
    end

    @testset "random_walk" begin
        X = random_walk(100, dim=3)
        @test length(X) == 100
        @test typeof(X) == EuclideanSpace{3,Float64}
    end

    @testset "orthogonal_curve" begin
        X = orthogonal_curve(10)
        @test length(X) == 10
        @test typeof(X) == EuclideanSpace{10,Float64}
    end

    @testset "swiss_roll" begin
        X = swiss_roll(100)
        @test length(X) == 100
        @test typeof(X) == EuclideanSpace{3,Float64}
    end

    @testset "annulus" begin
        X = annulus(100, r=0.5, R=1.0)
        @test length(X) == 100
        @test typeof(X) == EuclideanSpace{2,Float64}
        norms = norm.(X)
        @test all(n -> 0.5 <= n <= 1.0, norms)
    end

    @testset "ellipse" begin
        X = ellipse(100, a=2.0, b=1.0)
        @test length(X) == 100
        @test typeof(X) == EuclideanSpace{2,Float64}
    end

    @testset "spiral" begin
        X = spiral(100, n_turns=3)
        @test length(X) == 100
        @test typeof(X) == EuclideanSpace{2,Float64}
    end

    @testset "figure_eight" begin
        X = figure_eight(100)
        @test length(X) == 100
        @test typeof(X) == EuclideanSpace{2,Float64}
    end

    @testset "klein_bottle" begin
        X = klein_bottle(100)
        @test length(X) == 100
        @test typeof(X) == EuclideanSpace{4,Float64}
    end

    @testset "mobius_strip" begin
        X = mobius_strip(100)
        @test length(X) == 100
        @test typeof(X) == EuclideanSpace{3,Float64}
    end

    @testset "clifford_torus" begin
        X = clifford_torus(100)
        @test length(X) == 100
        @test typeof(X) == EuclideanSpace{4,Float64}
    end

    @testset "add_noise" begin
        X = sphere(100, dim=2, radius=1.0)
        Y = add_noise(X, 0.01)
        @test length(Y) == 100
        @test typeof(Y) == EuclideanSpace{2,Float64}
    end
end
