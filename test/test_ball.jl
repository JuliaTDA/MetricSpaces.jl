@testset "Ball" begin
    @testset "ball_ids" begin
        X = float.(1:5)

        @test ball_ids(X, 3.0, 1.5) == [2, 3, 4]
        @test ball_ids(X, 1.0, 0.5) == [1]
        @test ball_ids(X, 5.0, 0.001) == [5]
        @test ball_ids(X, 6.0, 0.1) == []
    end

    @testset "ball" begin
        X = [1.0, 2.0, 3.0, 4.0, 5.0]

        @test ball(X, 3.0, 1.5) == [2.0, 3.0, 4.0]
        @test ball(X, 1.0, 0.5) == [1.0]
        @test ball(X, 5.0, 0.001) == [5.0]
        @test ball(X, 6.0, 0.01) == []
    end
end
