@testset "Norm" begin
    @testset "normalize" begin
        @test norm([0, 1]) ≈ 1
        @test norm([1, 1]) ≈ norm([-1, -1])
        @test normalize([1, 1]) ≈ normalize([2, 2])
    end
end
