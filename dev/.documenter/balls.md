
# Metric Balls {#Metric-Balls}

Metric balls are fundamental geometric objects in metric spaces that represent neighborhoods around points. MetricSpaces.jl provides efficient functions for working with balls and performing neighborhood queries.

## Basic Concepts {#Basic-Concepts}

### Open Balls {#Open-Balls}

An **open ball** $B(x, r)$ centered at point $x$ with radius $r$ is the set of all points within distance $r$ of $x$:

$$B(x, r) = \{y \in X : d(x, y) < r\}$$

### Closed Balls {#Closed-Balls}

A **closed ball** $\overline{B}(x, r)$ includes points exactly at distance $r$:

$$\overline{B}(x, r) = \{y \in X : d(x, y) \leq r\}$$

_Note: MetricSpaces.jl implements open balls by default (using strict inequality)._

## Ball Functions {#Ball-Functions}

### `ball_ids` - Get Indices in Ball {#ball_ids-Get-Indices-in-Ball}

Find the indices of points within a ball:

```julia
ball_ids(X::MetricSpace, center, radius, distance_function=dist_euclidean)
```


**Example:**

```julia
# Create a 2D metric space
points = [[0.0, 0.0], [1.0, 0.0], [0.0, 1.0], [1.0, 1.0], [2.0, 2.0]]
X = EuclideanSpace(points)

# Find points within distance 1.5 of origin
center = [0.0, 0.0]
radius = 1.5
indices = ball_ids(X, center, radius)
println("Points in ball: ", indices)  # [1, 2, 3, 4]
```


### `ball` - Get Points in Ball {#ball-Get-Points-in-Ball}

Retrieve the actual points (not just indices) within a ball:

```julia
ball(X::MetricSpace, center, radius, distance_function=dist_euclidean)
```


**Example:**

```julia
# Get the actual points in the ball
points_in_ball = ball(X, center, radius)
println("Points in ball:")
for (i, point) in enumerate(points_in_ball)
    println("  $i: $point")
end
```


## Working with Different Distance Functions {#Working-with-Different-Distance-Functions}

### Euclidean Balls {#Euclidean-Balls}

```julia
# Standard Euclidean ball
euclidean_ball = ball_ids(X, [0.0, 0.0], 1.5, dist_euclidean)
```


### Manhattan Balls {#Manhattan-Balls}

```julia
# Manhattan distance creates diamond-shaped "balls"
manhattan_ball = ball_ids(X, [0.0, 0.0], 2.0, dist_cityblock)
```


### Chebyshev Balls {#Chebyshev-Balls}

```julia
# Chebyshev distance creates square-shaped "balls"  
chebyshev_ball = ball_ids(X, [0.0, 0.0], 1.0, dist_chebyshev)
```


## Visual Comparison of Ball Shapes {#Visual-Comparison-of-Ball-Shapes}

Let&#39;s create a comprehensive example showing how different distance functions create different ball shapes:

```julia
# Create a grid of points for visualization
function create_grid_points(range_x, range_y, step=0.5)
    points = Vector{Vector{Float64}}()
    for x in range_x[1]:step:range_x[2]
        for y in range_y[1]:step:range_y[2]
            push!(points, [x, y])
        end
    end
    return EuclideanSpace(points)
end

# Create a 5x5 grid centered at origin
grid = create_grid_points((-2, 2), (-2, 2), 0.5)
center = [0.0, 0.0]
radius = 1.0

# Compare different ball shapes
euclidean_indices = ball_ids(grid, center, radius, dist_euclidean)
manhattan_indices = ball_ids(grid, center, radius, dist_cityblock)
chebyshev_indices = ball_ids(grid, center, radius, dist_chebyshev)

println("Ball comparison with radius $radius:")
println("Euclidean ball contains $(length(euclidean_indices)) points")
println("Manhattan ball contains $(length(manhattan_indices)) points") 
println("Chebyshev ball contains $(length(chebyshev_indices)) points")

# Get the actual points for each ball type
euclidean_points = ball(grid, center, radius, dist_euclidean)
manhattan_points = ball(grid, center, radius, dist_cityblock)
chebyshev_points = ball(grid, center, radius, dist_chebyshev)
```


## Advanced Ball Operations {#Advanced-Ball-Operations}

### Multiple Centers {#Multiple-Centers}

Find points within balls around multiple centers:

```julia
# Multiple centers
centers = [[0.0, 0.0], [2.0, 2.0], [-1.0, 1.0]]
radius = 1.0

# Find points in union of all balls
union_points = Set{Int}()
for center in centers
    ball_indices = ball_ids(X, center, radius)
    union!(union_points, ball_indices)
end

println("Points in union of balls: ", sort(collect(union_points)))
```


### Nested Balls {#Nested-Balls}

Analyze the structure of nested balls:

```julia
# Create nested balls with increasing radii
center = [0.0, 0.0]
radii = [0.5, 1.0, 1.5, 2.0, 2.5]

println("Nested ball structure:")
for r in radii
    ball_indices = ball_ids(X, center, r)
    println("Radius $r: $(length(ball_indices)) points")
end
```


### Ball Intersection {#Ball-Intersection}

Find points that are in the intersection of multiple balls:

```julia
# Two centers with overlapping balls
center1 = [0.0, 0.0]
center2 = [1.0, 0.0]
radius = 1.0

ball1_indices = Set(ball_ids(X, center1, radius))
ball2_indices = Set(ball_ids(X, center2, radius))

# Intersection
intersection_indices = intersect(ball1_indices, ball2_indices)
println("Points in intersection: ", sort(collect(intersection_indices)))

# Union  
union_indices = union(ball1_indices, ball2_indices)
println("Points in union: ", sort(collect(union_indices)))

# Difference
difference_indices = setdiff(ball1_indices, ball2_indices)
println("Points in ball1 but not ball2: ", sort(collect(difference_indices)))
```


## Performance Optimization {#Performance-Optimization}

### Efficient Ball Queries {#Efficient-Ball-Queries}

For repeated ball queries, consider pre-computing distance matrices:

```julia
# For small spaces, pre-compute distance matrix
function precompute_distances(X::EuclideanSpace, distance_func=dist_euclidean)
    n = length(X)
    distances = Matrix{Float64}(undef, n, n)
    
    for i in 1:n
        for j in 1:n
            distances[i, j] = distance_func(X[i], X[j])
        end
    end
    
    return distances
end

# Fast ball queries using pre-computed distances
function fast_ball_ids(distances::Matrix, center_idx::Int, radius::Float64)
    return findall(d -> d < radius, distances[center_idx, :])
end

# Example usage
distances = precompute_distances(X)
center_idx = 1
fast_ball = fast_ball_ids(distances, center_idx, 1.5)
```


### Large-Scale Ball Queries {#Large-Scale-Ball-Queries}

For large datasets, use spatial data structures or approximate methods:

```julia
# Approximate ball query for large datasets
function approximate_ball_ids(X::EuclideanSpace, center, radius, sample_fraction=0.1)
    n = length(X)
    sample_size = max(1, Int(floor(n * sample_fraction)))
    
    # Random sample for approximate query
    sample_indices = randperm(n)[1:sample_size]
    
    ball_indices = Int[]
    for idx in sample_indices
        if dist_euclidean(X[idx], center) < radius
            push!(ball_indices, idx)
        end
    end
    
    return ball_indices
end
```


## Applications {#Applications}

### Outlier Detection {#Outlier-Detection}

Use ball queries to identify outliers:

```julia
function detect_outliers(X::EuclideanSpace, min_neighbors=2, radius=1.0)
    outliers = Int[]
    
    for i in 1:length(X)
        neighbors = ball_ids(X, X[i], radius)
        # Remove the point itself from neighbor count
        neighbor_count = length(neighbors) - 1
        
        if neighbor_count < min_neighbors
            push!(outliers, i)
        end
    end
    
    return outliers
end

# Find outliers in the dataset
outlier_indices = detect_outliers(X, 1, 1.0)
println("Outlier indices: ", outlier_indices)
```


### Local Density Estimation {#Local-Density-Estimation}

Estimate local density using ball counts:

```julia
function local_density(X::EuclideanSpace, radius=1.0)
    densities = Float64[]
    
    for i in 1:length(X)
        ball_indices = ball_ids(X, X[i], radius)
        # Density = number of neighbors / ball volume
        # For 2D: ball area = π * r²
        density = length(ball_indices) / (π * radius^2)
        push!(densities, density)
    end
    
    return densities
end

densities = local_density(X, 1.0)
println("Local densities: ", densities)
```


### Clustering {#Clustering}

Use balls for simple clustering:

```julia
function ball_clustering(X::EuclideanSpace, radius=1.0)
    n = length(X)
    visited = falses(n)
    clusters = Vector{Vector{Int}}()
    
    for i in 1:n
        if !visited[i]
            # Start new cluster
            cluster = ball_ids(X, X[i], radius)
            
            # Mark all points in cluster as visited
            for idx in cluster
                visited[idx] = true
            end
            
            push!(clusters, cluster)
        end
    end
    
    return clusters
end

clusters = ball_clustering(X, 1.5)
println("Found $(length(clusters)) clusters:")
for (i, cluster) in enumerate(clusters)
    println("  Cluster $i: $cluster")
end
```


## Edge Cases and Considerations {#Edge-Cases-and-Considerations}

### Empty Balls {#Empty-Balls}

```julia
# Very small radius might result in empty balls
tiny_radius = 1e-10
tiny_ball = ball_ids(X, [0.0, 0.0], tiny_radius)
println("Tiny ball contains: ", length(tiny_ball), " points")
```


### Large Balls {#Large-Balls}

```julia
# Very large radius includes all points
large_radius = 1000.0
large_ball = ball_ids(X, [0.0, 0.0], large_radius)
println("Large ball contains: ", length(large_ball), " points (total: $(length(X)))")
```


### Boundary Effects {#Boundary-Effects}

When working with finite point sets, be aware that balls near the boundary might have fewer neighbors than expected:

```julia
# Points on the boundary of the point cloud
boundary_point = X[end]  # Likely on boundary
interior_point = X[1]    # Likely more central

boundary_ball = ball_ids(X, boundary_point, 1.0)
interior_ball = ball_ids(X, interior_point, 1.0)

println("Boundary point has $(length(boundary_ball)) neighbors")
println("Interior point has $(length(interior_ball)) neighbors")
```

