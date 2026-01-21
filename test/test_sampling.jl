@testset "Sampling" begin
    @testset "farthest_points_sample_ids" begin
        X = sphere(1000)
        ids = farthest_points_sample_ids(X, 100)
        @test length(ids) == 100
        @test all(1 .<= ids .<= 1000)
        @test length(unique(ids)) == 100  # All unique indices
    end

    @testset "farthest_points_sample" begin
        X = sphere(1000)
        sampled = farthest_points_sample(X, 100)
        @test length(sampled) == 100
    end

    @testset "random_sample" begin
        X = [1, 2, 3, 4, 5]
        Y = random_sample(X, 5)

        @test length(random_sample(X, 1)) == 1
        @test isequal(Set(X), Set(Y))

        # Test that sampling more than available returns all
        @test length(random_sample(X, 10)) == 5
    end
end
