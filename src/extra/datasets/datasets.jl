module Datasets

using ..MetricSpaces: EuclideanSpace, normalize, norm
using StaticArrays: SVector

include("geometric.jl")
include("topological.jl")
include("clusters.jl")
include("stochastic.jl")
include("mammoth.jl")
include("stanford_bunny.jl")

"""
    add_noise(X::EuclideanSpace{N,T}, σ::Number = 0.01) where {N,T}

Add Gaussian noise with standard deviation `σ` to each point in the space.
Returns a new EuclideanSpace with the noisy points.
"""
function add_noise(X::EuclideanSpace{N,T}, σ::Number=0.01) where {N,T}
    [x + SVector{N,T}(σ .* randn(N)) for x in X]
end

export sphere, cube, torus, grid, star,
       swiss_roll, annulus, ellipse, spiral,
       trefoil_knot, linked_rings, unlinked_rings,
       figure_eight, klein_bottle, mobius_strip, clifford_torus,
       projective_plane, interlocked_tori,
       two_clusters, three_clusters, linked_clusters, long_gaussian,
       random_walk, orthogonal_curve,
       mammoth, stanford_bunny,
       add_noise

end
