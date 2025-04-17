using Test
using MetricSpaces

@test ball([0, 1, 2], 0, 0.5) == [0]
@test ball([0, 1, 2],  0, 1.2) == [0, 1]
@test ball([0, 1, 2],  1, 1.1) == [0, 1, 2]

@testset "ball_ids and ball tests" begin
    # Create a mock metric space
    X = [1.0, 2.0, 3.0, 4.0, 5.0]

    # Test ball_ids
    @test ball_ids(X, 3.0, 1.5) == [2, 3, 4]  # Indices of elements within distance 1.5 from 3.0
    @test ball_ids(X, 1.0, 0.5) == [1]       # Only the first element is within distance 0.5 from 1.0
    @test ball_ids(X, 5.0, 0.001) == [5]       # Only the last element is within distance 0.0 from 5.0

    # Test ball
    @test ball(X, 3.0, 1.5) == [2.0, 3.0, 4.0]  # Elements within distance 1.5 from 3.0
    @test ball(X, 1.0, 0.5) == [1.0]           # Only the first element is within distance 0.5 from 1.0
    @test ball(X, 5.0, 0.001) == [5.0]           # Only the last element is within distance 0.0 from 5.0
end