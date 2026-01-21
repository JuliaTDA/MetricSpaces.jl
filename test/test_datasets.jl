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
end
