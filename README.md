# MetricSpaces.jl

[![Build Status](https://github.com/vituri/MetricSpaces.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/vituri/MetricSpaces.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliatda.github.io/MetricSpaces.jl)

A Julia package for working with metric spaces in Topological Data Analysis (TDA), providing efficient data structures and algorithms for metric space operations.

## Features

- **Flexible Metric Spaces**: Work with any collection of objects that can be equipped with a distance function
- **Euclidean Spaces**: Optimized handling of numerical point clouds with dimension consistency
- **Distance Functions**: Built-in support for Euclidean, Manhattan, and Chebyshev distances
- **Metric Balls**: Efficient neighborhood queries and ball operations
- **Sampling Algorithms**: ε-nets, farthest point sampling, and random sampling
- **Analysis Tools**: Distance-to-measure, eccentricity, and k-nearest neighbors
- **Geometric Datasets**: Built-in generators for spheres, tori, and cubes
- **Performance**: Multithreaded computations and optimized algorithms

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
center = X[1]
nearby_indices = ball_ids(X, center, 1.0)
println("Points within distance 1.0: ", nearby_indices)

# Compute pairwise distances
distances = pairwise_distance(X, X, dist_euclidean)

# Generate an ε-net covering
landmarks = epsilon_net(X, 2.0)
println("ε-net landmarks: ", landmarks)

# Sample points using farthest point sampling
sample_indices = farthest_points_sample(X, 3)

# Work with built-in datasets
torus_points = EuclideanSpace(torus(1000))  # 1000 points on a torus
sphere_points = EuclideanSpace(sphere(500, dim=3))  # 500 points on a 3D sphere
```

## Core Concepts

### Metric Spaces
The fundamental type `MetricSpace{T}` is simply an alias for `Vector{T}`, providing maximum flexibility for any collection of objects with a distance function.

### Euclidean Spaces
`EuclideanSpace{N,T}` provides optimized handling of numerical point clouds, ensuring all points have consistent dimensions and leveraging static arrays for performance.

### Distance Functions
- `dist_euclidean`: Standard Euclidean (L²) distance
- `dist_cityblock`: Manhattan (L¹) distance  
- `dist_chebyshev`: Chebyshev (L∞) distance
- Support for custom distance functions

## Examples

### Custom Distance Functions
```julia
# Define a custom distance for strings
function string_distance(s1, s2)
    return sum(c1 != c2 for (c1, c2) in zip(s1, s2)) + abs(length(s1) - length(s2))
end

words = ["hello", "world", "help", "word"]
word_space = MetricSpace(words)
```

### Working with High-Dimensional Data
```julia
# Generate high-dimensional random data
high_dim_data = [randn(50) for _ in 1:1000]  # 1000 points in 50D
X = EuclideanSpace(high_dim_data)

# Compute distance-to-measure for outlier detection
dtm = distance_to_measure(X, X, k=10)
```

### Matrix Conversions
```julia
# Convert between matrix and EuclideanSpace representations
matrix_data = rand(3, 100)  # 3D points, 100 samples
X = EuclideanSpace(matrix_data)
matrix_back = as_matrix(X)
```

## Documentation

For detailed documentation, examples, and API reference, visit the [documentation site](https://juliatda.github.io/MetricSpaces.jl).

## Contributing

Contributions are welcome! Please feel free to submit issues, feature requests, or pull requests.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
