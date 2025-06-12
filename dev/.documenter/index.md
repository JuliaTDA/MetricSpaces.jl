
# MetricSpaces.jl {#MetricSpaces.jl}

A Julia package for working with metric spaces in Topological Data Analysis (TDA), providing efficient data structures and algorithms for metric space operations.

## Overview {#Overview}

MetricSpaces.jl provides a comprehensive toolkit for working with metric spaces, including:
- **Core Types**: Flexible metric space representations
  
- **Distance Functions**: Various distance metrics (Euclidean, Manhattan, Chebyshev)
  
- **Metric Balls**: Efficient neighborhood queries
  
- **Sampling Methods**: ε-nets, farthest point sampling, random sampling
  
- **Datasets**: Built-in geometric datasets (spheres, tori, cubes)
  
- **Analysis Tools**: Neighborhood analysis, filtering, and nerve computations
  

## Installation {#Installation}

```julia
using Pkg
Pkg.add("MetricSpaces")
```


## Quick Start {#Quick-Start}

```julia
using MetricSpaces

# Create a metric space from 2D points
points = [[1.0, 2.0], [3.0, 4.0], [5.0, 6.0], [1.1, 2.1]]
X = EuclideanSpace(points)

# Find points within distance 1.0 of the first point
center = X[1]
nearby_indices = ball_ids(X, center, 1.0)

# Compute pairwise distances
distances = pairwise_distance(X)

# Generate an ε-net covering
landmarks = epsilon_net(X, 2.0)
```


## Mathematical Foundation {#Mathematical-Foundation}

This package is built on solid mathematical foundations from metric geometry and topological data analysis. The core concepts include:
- **Metric Spaces**: Sets equipped with distance functions satisfying the metric axioms
  
- **Metric Balls**: Fundamental neighborhoods in metric spaces
  
- **Covering Properties**: ε-nets and other geometric covering constructions
  
- **Sampling Theory**: Geometric sampling methods for large metric spaces
  

## Key Features {#Key-Features}

### 🎯 **Efficient Algorithms** {#Efficient-Algorithms}

Optimized implementations of fundamental metric space operations with progress tracking for large datasets.

### 📊 **Rich Dataset Support** {#Rich-Dataset-Support}

Built-in generators for common geometric datasets used in TDA research and education.

### 🔧 **Flexible Distance Functions** {#Flexible-Distance-Functions}

Support for multiple distance metrics with easy extensibility for custom distance functions.

### 📈 **Analysis Tools** {#Analysis-Tools}

Comprehensive tools for neighborhood analysis, filtering, and geometric property computation.

## Getting Started {#Getting-Started}

Continue to the mathematical background to understand the theory behind metric spaces, or jump to the getting started guide for practical examples.
