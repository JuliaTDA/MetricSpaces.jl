@testset "Types" begin
    @testset "EuclideanSpace" begin
        X = eachcol(rand(3, 5)) |> collect
        M = EuclideanSpace(X)
        @test length(M) == 5
        @test size(M) == (5,)
        for i in 1:5
            @test M[i] == X[i]
        end

        X = [[1], [2], [3, 3]]
        @test_throws ErrorException EuclideanSpace(X)
    end

    @testset "as_matrix" begin
        M = rand(10, 10)
        X = EuclideanSpace(M)
        @test M == as_matrix(X)
    end
end
