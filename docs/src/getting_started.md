# Getting Started

This guide will walk you through the basic usage of MetricSpaces.jl with practical examples.

## Installation

First, install the package:

```julia
using Pkg
Pkg.add("MetricSpaces")
```

Then load it:

```julia
using MetricSpaces
```

## Creating Metric Spaces

### From Point Collections

The most common way to create a metric space is from a collection of points:

```julia
# 2D points
points_2d = [[1.0, 2.0], [3.0, 4.0], [5.0, 6.0], [1.1, 2.1], [3.2, 4.1]]
X = EuclideanSpace(points_2d)

println("Number of points: ", length(X))
println("First point: ", X[1])
```

```julia
# 3D points
points_3d = [[1.0, 2.0, 3.0], [4.0, 5.0, 6.0], [0.5, 1.5, 2.5]]
Y = EuclideanSpace(points_3d)
```

### Using Built-in Datasets

MetricSpaces.jl provides several built-in geometric datasets:

```julia
# Generate points on a sphere
sphere_points = sphere(100, 2)  # 100 points on a 2-sphere
S = EuclideanSpace(sphere_points)

# Generate points on a torus
torus_points = torus(50)  # 50 points on a torus
T = EuclideanSpace(torus_points)

# Generate points in a cube
cube_points = cube(75, 3)  # 75 points in a 3D cube
C = EuclideanSpace(cube_points)
```

## Basic Operations

### Computing Distances

```julia
# Distance between two specific points
point1 = X[1]
point2 = X[2]
dist = dist_euclidean(point1, point2)
println("Distance between points: ", dist)

# Using different distance functions
dist_manhattan = dist_cityblock(point1, point2)
dist_chebyshev = dist_chebyshev(point1, point2)

println("Manhattan distance: ", dist_manhattan)
println("Chebyshev distance: ", dist_chebyshev)
```

### Pairwise Distance Matrices

```julia
# Compute all pairwise distances
distances = pairwise_distance(X)
println("Distance matrix size: ", size(distances))

# Get summary statistics
summary = pairwise_distance_summary(X)
println("Distance summary: ", summary)
```

## Working with Metric Balls

### Finding Neighborhoods

```julia
# Find all points within distance 1.5 of the first point
center = X[1]
radius = 1.5
nearby_ids = ball_ids(X, center, radius)
println("Points within radius $radius: ", nearby_ids)

# Get the actual points in the ball
nearby_points = ball(X, center, radius)
println("Number of nearby points: ", length(nearby_points))
```

### k-Nearest Neighbors

```julia
# Find the 3 nearest neighbors of the first point
k = 3
neighbors = k_neighbors(X, X[1], k)
println("$k nearest neighbors: ", neighbors)
```

## Sampling Methods

### ε-net Construction

An ε-net provides a sparse covering of the metric space:

```julia
# Create an ε-net with radius 2.0
epsilon = 2.0
landmarks = epsilon_net(X, epsilon)
println("ε-net landmarks: ", landmarks)
println("Number of landmarks: ", length(landmarks))

# Extract the landmark points
landmark_points = X[landmarks]
```

### Farthest Point Sampling

Generate well-separated points using farthest point sampling:

```julia
# Sample 5 points using farthest point sampling
num_samples = 5
fps_indices = farthest_points_sample(X, num_samples)
println("Farthest point sample indices: ", fps_indices)

# Get the sampled points
sampled_points = X[fps_indices]
```

### Random Sampling

```julia
# Random sample of 10 points
random_indices = random_sample(X, 10)
random_points = X[random_indices]
```

## Analysis and Filtering

### Distance to Measure

Compute density-based measures for outlier detection:

```julia
# Compute distance to measure for each point
measure_distances = distance_to_measure(X, 0.1)  # 10% mass parameter
println("Distance to measure: ", measure_distances[1:5])  # First 5 values
```

### Eccentricity

Measure how "central" each point is:

```julia
# Compute eccentricity for each point
eccentricities = excentricity(X)
println("Eccentricities: ", eccentricities[1:5])  # First 5 values

# Find the most central point (minimum eccentricity)
most_central_idx = argmin(eccentricities)
println("Most central point index: ", most_central_idx)
```

## Working with Different Distance Functions

You can use different distance functions throughout the package:

```julia
# Using Manhattan distance for ball queries
manhattan_ball = ball_ids(X, center, radius, dist_cityblock)

# Using Chebyshev distance for ε-net
chebyshev_net = epsilon_net(X, epsilon, d=dist_chebyshev)

# Custom distance function
function custom_distance(x, y)
    # Example: weighted Euclidean distance
    weights = [2.0, 1.0]  # Different weights for each dimension
    return sqrt(sum(weights .* (x .- y).^2))
end

# Use custom distance (where supported)
custom_ball = ball_ids(X, center, radius, custom_distance)
```

## Performance Tips

### Working with Large Datasets

```julia
# For large datasets, use progress tracking
large_points = sphere(10000, 3)  # 10,000 points on a 3-sphere
L = EuclideanSpace(large_points)

# Operations will show progress bars automatically
large_epsilon_net = epsilon_net(L, 0.5)
```

### Memory Efficiency

```julia
# For memory efficiency with large distance matrices,
# compute distances on-demand rather than storing the full matrix
function compute_distance_on_demand(X, i, j)
    return dist_euclidean(X[i], X[j])
end
```

## Next Steps

- Learn about the core types for more advanced metric space constructions
- Explore distance functions for custom distance implementations
- Check out sampling methods for advanced sampling algorithms
- See the datasets section for more built-in geometric datasets
