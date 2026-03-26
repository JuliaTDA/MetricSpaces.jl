module Datasets

using ..MetricSpaces: EuclideanSpace, normalize, norm

include("geometric.jl")
include("topological.jl")
include("clusters.jl")
include("stochastic.jl")
include("mammoth.jl")

export sphere, cube, torus, grid, star,
       trefoil_knot, linked_rings, unlinked_rings,
       two_clusters, three_clusters, linked_clusters, long_gaussian,
       random_walk, orthogonal_curve,
       mammoth

end
