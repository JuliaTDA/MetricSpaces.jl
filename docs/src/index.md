# MetricSpaces.jl

A Julia package for working with metric spaces in Topological Data Analysis (TDA), providing efficient data structures and algorithms for metric space operations.

## Overview

MetricSpaces.jl provides a comprehensive toolkit for working with metric spaces, including:

- **Core Types**: Flexible metric space representations optimized for performance
- **Distance Functions**: Multiple distance metrics (Euclidean, Manhattan, Chebyshev) with custom function support
- **Metric Balls**: Efficient neighborhood queries for point clouds
- **Sampling Methods**: Epsilon-nets, farthest point sampling, and random sampling algorithms
- **Datasets**: Built-in geometric dataset generators (spheres, tori, cubes)
- **Analysis Tools**: Neighborhood analysis, filtering, and nerve computations

## Installation

```julia
using Pkg
Pkg.add("MetricSpaces")
```

## Quick Start

```julia
using MetricSpaces

# Create a metric space from 2D points
points = [[1.0, 2.0], [3.0, 4.0], [5.0, 6.0], [1.1, 2.1]]
X = EuclideanSpace(points)

# Find points within distance 1.0 of the first point
nearby_indices = ball_ids(X, X[1], 1.0)

# Compute pairwise distances
distances = pairwise_distance(X, X, dist_euclidean)

# Generate a sphere dataset
S = sphere(1000, dim=3)

# Sample landmarks using farthest point sampling
landmarks = farthest_points_sample(S, 100)
```

## Key Features

### Efficient Algorithms

Optimized implementations of fundamental metric space operations with multi-threading support and progress tracking for large datasets.

### Rich Dataset Support

Built-in generators for common geometric datasets used in TDA research and education, including spheres, tori, and cubes with configurable parameters.

### Flexible Distance Functions

Support for multiple distance metrics with easy extensibility for custom distance functions. Compatible with the Distances.jl ecosystem.

### Analysis Tools

Comprehensive tools for neighborhood analysis, distance-to-measure computations, eccentricity calculations, and nerve complex construction.

## Mathematical Foundation

This package is built on solid mathematical foundations from metric geometry and topological data analysis. The core concepts include:

- **Metric Spaces**: Sets equipped with distance functions satisfying the metric axioms (non-negativity, identity, symmetry, triangle inequality)
- **Metric Balls**: Open balls B(x, r) = {y : d(x,y) < r} as fundamental neighborhoods
- **Covering Properties**: Epsilon-nets and geometric covering constructions
- **Sampling Theory**: Farthest point sampling for landmark selection

## Documentation Structure

- **[Getting Started](@ref)**: Practical tutorial with examples
- **[Mathematical Background](@ref)**: Theoretical foundations
- **Reference**: Detailed documentation for each module
- **[API Reference](@ref)**: Complete function and type reference
