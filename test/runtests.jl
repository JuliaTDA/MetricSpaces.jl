using Test
using MetricSpaces
using Graphs: nv, ne, has_edge
using Aqua

# `EuclideanSpace` is currently an alias for `Vector{SVector}`, so its two
# convenience constructors are necessarily reported as piracy. Keep that known
# design debt explicit while enforcing every other Aqua check.
Aqua.test_all(MetricSpaces; piracies=false)
Aqua.test_piracies(MetricSpaces; broken=true)

@testset "MetricSpaces.jl" begin
    include("test_real.jl")
    include("test_types.jl")
    include("test_norm.jl")
    include("test_distances.jl")
    include("test_ball.jl")
    include("test_neighborhood.jl")
    include("test_filters.jl")
    include("test_datasets.jl")
    include("test_sampling.jl")
    include("test_nerve.jl")
    include("test_transformations.jl")
    include("test_geodesic.jl")
    include("test_euler_images.jl")
end
