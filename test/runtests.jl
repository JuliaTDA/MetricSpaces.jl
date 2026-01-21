using Test
using MetricSpaces
using Graphs: nv, ne, has_edge

@testset "MetricSpaces.jl" begin
    include("test_types.jl")
    include("test_norm.jl")
    include("test_distances.jl")
    include("test_ball.jl")
    include("test_datasets.jl")
    include("test_sampling.jl")
    include("test_nerve.jl")
end
