module MetricSpaces

# Write your package code here.
# using LinearAlgebra
using Distances
# using NearestNeighbors
using Distances
using Base.Threads
using StatsBase: mean
using ProgressMeter
using StaticArrays
using BenchmarkTools
using DataFrames

export 
    mean;

include("types.jl");
export 
    MetricSpace,
    EuclideanSpace,
    as_matrix;

include("distances.jl");
export 
    pairwise_distance,
    pairwise_distance_summary,
    distance_to_measure;

include("datasets.jl");
export 
    sphere,
    torus,
    cube;

# include("maps.jl");
# export include_space, 
#     translate_space;

# include("sampling.jl");
# export epsilon_net, 
#     farthest_points_sample;

# include("manifolds.jl");
# export sphere, cube, torus;

# include("density.jl");
# export pairwise_distance_summary, density_estimation, excentricity;

# include("distance to measure.jl");
# export distance_to_measure;



end
