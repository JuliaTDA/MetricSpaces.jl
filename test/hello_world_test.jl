using Test

@testset "Hello World Tests" begin
    @test "Hello World should return 'Hello, World!'" begin
        result = hello_world()
        @test result == "Hello, World!"
    end
end