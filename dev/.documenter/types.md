
# Core Types {#Core-Types}

MetricSpaces.jl provides flexible type definitions for representing metric spaces and related geometric structures.

## MetricSpace {#MetricSpace}

The fundamental type in the package is `MetricSpace{T}`, which is simply an alias for `Vector{T}`:

```julia
MetricSpace{T} = Vector{T} where {T}
```


This design provides maximum flexibility - any collection of objects can form a metric space as long as you can define a distance function between them.

### Basic Usage {#Basic-Usage}

```julia
# Create a metric space from any vector of objects
points = ["hello", "world", "foo", "bar"]
string_space = MetricSpace(points)

# Define a custom distance function for strings (edit distance, etc.)
function string_distance(s1, s2)
    # Simple character difference count (not a true edit distance)
    return sum(c1 != c2 for (c1, c2) in zip(s1, s2)) + abs(length(s1) - length(s2))
end
```


## EuclideanSpace {#EuclideanSpace}

For numerical computations, `EuclideanSpace{N,T}` provides optimized handling of points in Euclidean space:

```julia
EuclideanSpace{N, T} = MetricSpace{SVector{N, T}} where {N, T}
```


### Construction {#Construction}

The `EuclideanSpace` constructor ensures all points have the same dimension:

```julia
# From a vector of vectors
points = [[1.0, 2.0], [3.0, 4.0], [5.0, 6.0]]
X = EuclideanSpace(points)

# This will throw an error - inconsistent dimensions
# bad_points = [[1.0, 2.0], [3.0, 4.0, 5.0]]  # 2D and 3D mixed
# X_bad = EuclideanSpace(bad_points)  # Error!
```


### Properties {#Properties}

```julia
# Access individual points
first_point = X[1]
println("First point: ", first_point)

# Get space properties
println("Number of points: ", length(X))
println("Space dimension: ", length(X[1]))

# EuclideanSpace works with any numeric type
int_points = [[1, 2], [3, 4], [5, 6]]
X_int = EuclideanSpace(int_points)

float32_points = [[1.0f0, 2.0f0], [3.0f0, 4.0f0]]
X_float32 = EuclideanSpace(float32_points)
```


## Matrix Conversion {#Matrix-Conversion}

Convert between different representations:

```julia
# Convert a matrix to EuclideanSpace (columns as points)
matrix_data = rand(3, 100)  # 3D points, 100 samples
points_from_matrix = [matrix_data[:, i] for i in 1:size(matrix_data, 2)]
X_from_matrix = EuclideanSpace(points_from_matrix)

# Convert EuclideanSpace back to matrix format
matrix_back = as_matrix(X_from_matrix)
println("Matrix size: ", size(matrix_back))
```


## Auxiliary Types {#Auxiliary-Types}

### SubsetIndex {#SubsetIndex}

Used for representing subsets of metric spaces:

```julia
# SubsetIndex helps track which points belong to subsets
# This is used internally by sampling algorithms
subset_indices = SubsetIndex([1, 3, 5, 7, 9])  # Odd indices
```


### Covering {#Covering}

Represents geometric coverings of metric spaces:

```julia
# Covering structures are used in nerve computations
# and topological constructions
covering = Covering(...)  # Used internally
```


## Working with Different Data Types {#Working-with-Different-Data-Types}

### High-Dimensional Spaces {#High-Dimensional-Spaces}

```julia
# High-dimensional Euclidean spaces
high_dim_points = [randn(50) for _ in 1:1000]  # 1000 points in 50D
HD = EuclideanSpace(high_dim_points)

# Operations remain the same regardless of dimension
center = HD[1]
nearby = ball_ids(HD, center, 2.0)
```


### Custom Objects {#Custom-Objects}

```julia
# Define a custom type
struct ColoredPoint
    position::Vector{Float64}
    color::String
end

# Create a metric space of custom objects
colored_points = [
    ColoredPoint([1.0, 2.0], "red"),
    ColoredPoint([3.0, 4.0], "blue"),
    ColoredPoint([5.0, 6.0], "green")
]
colored_space = MetricSpace(colored_points)

# Define distance function for colored points
function colored_distance(p1::ColoredPoint, p2::ColoredPoint)
    pos_dist = dist_euclidean(p1.position, p2.position)
    color_penalty = (p1.color == p2.color) ? 0.0 : 1.0
    return pos_dist + color_penalty
end

# Use with package functions
center_colored = colored_space[1]
# ball_ids(colored_space, center_colored, 2.0, colored_distance)
```


## Type Safety and Performance {#Type-Safety-and-Performance}

### Static Arrays {#Static-Arrays}

EuclideanSpace uses `StaticArrays.SVector` internally for performance:

```julia
# The constructor converts to SVector internally
points = [[1.0, 2.0], [3.0, 4.0]]
X = EuclideanSpace(points)

# But returns regular Vector for compatibility
@assert X[1] isa Vector{Float64}
```


### Memory Layout {#Memory-Layout}

```julia
# For maximum performance with large datasets
function create_efficient_space(n_points, dimension)
    # Pre-allocate for better memory usage
    points = Vector{Vector{Float64}}(undef, n_points)
    for i in 1:n_points
        points[i] = randn(dimension)
    end
    return EuclideanSpace(points)
end

efficient_space = create_efficient_space(10000, 10)
```


## Integration with Other Packages {#Integration-with-Other-Packages}

### With Distances.jl {#With-Distances.jl}

```julia
using Distances

# EuclideanSpace works seamlessly with Distances.jl metrics
function distances_jl_example(X::EuclideanSpace)
    # Convert to matrix for Distances.jl
    mat = as_matrix(X)
    
    # Use Distances.jl functions
    euclidean_dist = Euclidean()
    return pairwise(euclidean_dist, mat)
end
```


### With DataFrames.jl {#With-DataFrames.jl}

```julia
using DataFrames

# Create EuclideanSpace from DataFrame
df = DataFrame(x=[1.0, 2.0, 3.0], y=[4.0, 5.0, 6.0])
points_from_df = [[row.x, row.y] for row in eachrow(df)]
X_from_df = EuclideanSpace(points_from_df)
```


## Best Practices {#Best-Practices}

### Choosing the Right Type {#Choosing-the-Right-Type}
- Use `EuclideanSpace` for numerical point clouds in Euclidean space
  
- Use generic `MetricSpace` for non-Euclidean or custom objects
  
- Ensure consistent dimensions when using `EuclideanSpace`
  

### Performance Considerations {#Performance-Considerations}

```julia
# Good: Pre-allocate and reuse
function efficient_computation(X::EuclideanSpace)
    n = length(X)
    results = Vector{Float64}(undef, n)
    
    for i in 1:n
        # Compute something for each point
        results[i] = norm(X[i])
    end
    
    return results
end

# Avoid: Creating temporary arrays in loops
function inefficient_computation(X::EuclideanSpace)
    results = Float64[]
    for point in X
        push!(results, norm(point))  # Repeated allocations
    end
    return results
end
```


### Type Annotations {#Type-Annotations}

```julia
# Good: Explicit type annotations for performance
function compute_distances(X::EuclideanSpace{N,T}) where {N,T}
    distances = Matrix{T}(undef, length(X), length(X))
    # ... computation
    return distances
end
```

