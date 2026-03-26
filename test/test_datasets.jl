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
end
