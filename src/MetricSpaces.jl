module MetricSpaces

using Distances
using Base.Threads
using StatsBase: mean
using ProgressMeter
using StaticArrays
using DataFrames
using Graphs
using TestItems

export 
    mean;

include("base/types.jl");
export 
    MetricSpace,
    EuclideanSpace,
    as_matrix,
    SubsetIndex,
    Covering;

include("base/norm.jl");
export 
    norm, 
    normalize, 
    normalize!;

include("base/distances.jl");
export 
    pairwise_distance,
    pairwise_distance_summary;

include("base/ball.jl");
export 
    ball, 
    ball_ids;

include("base/distance functions.jl");
export 
    dist_euclidean,
    dist_cityblock,
    dist_chebyshev;

include("extra/neighborhood.jl");
export 
    k_neighbors;

include("extra/filters.jl");
export
    distance_to_measure, 
    excentricity;

include("extra/datasets.jl");
export 
    sphere,
    torus,
    cube;

include("extra/sampling.jl");
export 
    epsilon_net, 
    farthest_points_sample, 
    random_sample;

include("extra/nerve.jl");
export 
    nerve_1d;

# include("maps.jl");
# export include_space, 
#     translate_space;

end