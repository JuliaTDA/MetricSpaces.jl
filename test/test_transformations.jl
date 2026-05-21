using Test
using MetricSpaces
using StaticArrays: SVector
using MetricSpaces.Datasets: sphere
using Random
using StatsBase: std

@testset "transformations" begin
    @testset "include_space" begin
        X = sphere(50, dim=2)
        Y = include_space(X, 1)
        @test length(Y) == length(X)
        @test length(Y[1]) == 3
        @test all(y[3] == 0 for y in Y)
    end

    @testset "translate_space" begin
        X = sphere(50, dim=2)
        Y = translate_space(X, [10.0, 20.0])
        @test all(isapprox(Y[i][1] - X[i][1], 10.0) for i in eachindex(X))
        @test all(isapprox(Y[i][2] - X[i][2], 20.0) for i in eachindex(X))
    end

    @testset "center" begin
        Random.seed!(1)
        X = sphere(100, dim=3)
        Y = translate_space(X, [5.0, -3.0, 7.0])
        Z = center(Y)
        c = sum(Z) ./ length(Z)
        @test all(abs(ci) < 1e-10 for ci in c)
    end

    @testset "scale" begin
        Random.seed!(2)
        X = sphere(100, dim=2)
        Y = scale(X, 3.0)
        @test all(isapprox(norm(Y[i]), 3.0 * norm(X[i])) for i in eachindex(X))
    end

    @testset "standardize" begin
        Random.seed!(3)
        pts = [SVector{2,Float64}(2randn(), 5randn()) for _ in 1:500]
        X = EuclideanSpace(pts)
        Z = standardize(X)
        coord1 = [z[1] for z in Z]
        coord2 = [z[2] for z in Z]
        @test abs(sum(coord1) / length(coord1)) < 0.1
        @test abs(sum(coord2) / length(coord2)) < 0.1
        @test isapprox(std(coord1), 1.0; atol=0.1)
        @test isapprox(std(coord2), 1.0; atol=0.1)
    end

    @testset "embed" begin
        Random.seed!(4)
        X = sphere(50, dim=2)
        Y = embed(X, 5)
        @test length(Y) == length(X)
        @test length(Y[1]) == 5
    end
end
