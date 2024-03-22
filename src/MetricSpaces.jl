module MetricSpaces

# using LinearAlgebra
# using NearestNeighbors
using Distances
using Base.Threads
using StatsBase: mean
using ProgressMeter
using StaticArrays
# using BenchmarkTools
using DataFrames
using Graphs

export 
    mean;

include("types.jl");
export 
    MetricSpace,
    EuclideanSpace,
    as_matrix,
    SubsetIndex,
    Covering;

include("distances.jl");
export 
    pairwise_distance,
    pairwise_distance_summary;

include("ball.jl");
export 
    ball;

include("neighborhood.jl");
export 
    k_neighbors;

include("filters.jl");
export
    distance_to_measure, 
    excentricity;

include("datasets.jl");
export 
    sphere,
    torus,
    cube;

include("sampling.jl");
export 
    epsilon_net, 
    farthest_points_sample;

include("distance functions.jl");
export 
    dist_euclidean,
    dist_cityblock,
    dist_chebyshev;

include("nerve.jl");
export 
    nerve_1d;

# include("maps.jl");
# export include_space, 
#     translate_space;

# include("sampling.jl");
# export epsilon_net, 
#     farthest_points_sample;

# include("density.jl");
# export pairwise_distance_summary, density_estimation, excentricity;

end