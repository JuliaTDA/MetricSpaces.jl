@testset "Neighborhood" begin
    @testset "k_neighbors_ids" begin
        X = [1.0, 2.0, 3.0, 4.0]
        ids = MetricSpaces.k_neighbors_ids(X, 2.5, 2)
        @test ids == [2, 3]

        ids_all = MetricSpaces.k_neighbors_ids(X, 2.5, 10)
        @test length(ids_all) == length(X)
        @test sort(ids_all) == collect(1:length(X))

        @test MetricSpaces.k_neighbors_ids(Float64[], 0.0, 1) == Int[]
    end

    @testset "k_neighbors" begin
        X = [1.0, 2.0, 3.0, 4.0]
        neighbors = k_neighbors(X, 2.5, 2)
        @test neighbors == [2.0, 3.0]
    end
end
