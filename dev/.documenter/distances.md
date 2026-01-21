
# Distance Functions {#Distance-Functions}

MetricSpaces.jl provides several built-in distance functions and makes it easy to work with custom distance metrics.

## Built-in Distance Functions {#Built-in-Distance-Functions}

### Euclidean Distance {#Euclidean-Distance}

The standard Euclidean (L²) distance:

```julia
dist_euclidean(x, y)
```


**Mathematical Definition:**

$$d_2(x, y) = \sqrt{\sum_{i=1}^n (x_i - y_i)^2}$$

**Example:**

```julia
p1 = [1.0, 2.0, 3.0]
p2 = [4.0, 5.0, 6.0]
d = dist_euclidean(p1, p2)  # ≈ 5.196
```


### Manhattan Distance (City Block) {#Manhattan-Distance-City-Block}

The L¹ distance, also known as taxicab distance:

```julia
dist_cityblock(x, y)
```


**Mathematical Definition:**

$$d_1(x, y) = \sum_{i=1}^n |x_i - y_i|$$

**Example:**

```julia
p1 = [1.0, 2.0, 3.0]
p2 = [4.0, 5.0, 6.0]
d = dist_cityblock(p1, p2)  # = 9.0
```


### Chebyshev Distance {#Chebyshev-Distance}

The L∞ distance, also known as maximum distance:

```julia
dist_chebyshev(x, y)
```


**Mathematical Definition:**

$$d_\infty(x, y) = \max_{1 \leq i \leq n} |x_i - y_i|$$

**Example:**

```julia
p1 = [1.0, 2.0, 3.0]
p2 = [4.0, 5.0, 6.0]
d = dist_chebyshev(p1, p2)  # = 3.0
```


## Using Distance Functions {#Using-Distance-Functions}

### With Ball Queries {#With-Ball-Queries}

```julia
# Create a metric space
points = [[1.0, 2.0], [3.0, 4.0], [5.0, 6.0], [1.1, 2.1]]
X = EuclideanSpace(points)

center = X[1]
radius = 2.0

# Using different distance functions
euclidean_ball = ball_ids(X, center, radius, dist_euclidean)
manhattan_ball = ball_ids(X, center, radius, dist_cityblock)
chebyshev_ball = ball_ids(X, center, radius, dist_chebyshev)

println("Euclidean ball: ", euclidean_ball)
println("Manhattan ball: ", manhattan_ball)
println("Chebyshev ball: ", chebyshev_ball)
```


### With Sampling Algorithms {#With-Sampling-Algorithms}

```julia
# ε-net with different distance functions
epsilon = 1.5

euclidean_net = epsilon_net(X, epsilon, d=dist_euclidean)
manhattan_net = epsilon_net(X, epsilon, d=dist_cityblock)
chebyshev_net = epsilon_net(X, epsilon, d=dist_chebyshev)
```


### With Pairwise Distances {#With-Pairwise-Distances}

```julia
# Compute pairwise distance matrices
euclidean_matrix = pairwise_distance(X, dist_euclidean)
manhattan_matrix = pairwise_distance(X, dist_cityblock)
chebyshev_matrix = pairwise_distance(X, dist_chebyshev)
```


## Distance Function Comparison {#Distance-Function-Comparison}

Let&#39;s compare how different distance functions behave:

```julia
# Create test points
center = [0.0, 0.0]
test_points = [
    [1.0, 0.0],   # Point 1: on x-axis
    [0.0, 1.0],   # Point 2: on y-axis  
    [1.0, 1.0],   # Point 3: diagonal
    [2.0, 1.0],   # Point 4: further on x
]

X_test = EuclideanSpace([center; test_points])

println("Distance comparisons from origin:")
println("Point\t\tEuclidean\tManhattan\tChebyshev")
for (i, point) in enumerate(test_points)
    d_euc = dist_euclidean(center, point)
    d_man = dist_cityblock(center, point) 
    d_che = dist_chebyshev(center, point)
    println("$point\t$(round(d_euc, digits=3))\t\t$(round(d_man, digits=3))\t\t$(round(d_che, digits=3))")
end
```


Output:

```
Point           Euclidean    Manhattan    Chebyshev
[1.0, 0.0]      1.0          1.0          1.0
[0.0, 1.0]      1.0          1.0          1.0  
[1.0, 1.0]      1.414        2.0          1.0
[2.0, 1.0]      2.236        3.0          2.0
```


## Custom Distance Functions {#Custom-Distance-Functions}

You can define your own distance functions and use them throughout the package:

### Simple Custom Distance {#Simple-Custom-Distance}

```julia
# Weighted Euclidean distance
function weighted_euclidean(x, y, weights=[1.0, 2.0])
    diff = x .- y
    return sqrt(sum(weights .* diff.^2))
end

# Use with ball queries
custom_ball = ball_ids(X, center, radius, 
                      (a, b) -> weighted_euclidean(a, b, [2.0, 1.0]))
```


### Distance for Custom Types {#Distance-for-Custom-Types}

```julia
# Distance function for complex numbers viewed as 2D points
function complex_distance(z1::Complex, z2::Complex)
    return abs(z1 - z2)  # Built-in complex distance
end

# Distance function for strings (Hamming distance)
function hamming_distance(s1::String, s2::String)
    if length(s1) != length(s2)
        return Inf  # Different lengths
    end
    return sum(c1 != c2 for (c1, c2) in zip(s1, s2))
end

# Example usage
strings = ["hello", "hallo", "hullo", "world"]
string_space = MetricSpace(strings)

# Find strings within Hamming distance 2 of "hello"
similar_strings = ball_ids(string_space, "hello", 2, hamming_distance)
```


### Parametric Distance Functions {#Parametric-Distance-Functions}

```julia
# Minkowski distance with adjustable p
function minkowski_distance(x, y, p=2)
    if p == Inf
        return maximum(abs.(x .- y))
    else
        return sum(abs.(x .- y).^p)^(1/p)
    end
end

# Create different Minkowski distances
l1_distance(x, y) = minkowski_distance(x, y, 1)      # Manhattan
l2_distance(x, y) = minkowski_distance(x, y, 2)      # Euclidean  
l3_distance(x, y) = minkowski_distance(x, y, 3)      # Cubic
linf_distance(x, y) = minkowski_distance(x, y, Inf)  # Chebyshev
```


## Performance Considerations {#Performance-Considerations}

### Efficient Distance Computation {#Efficient-Distance-Computation}

```julia
# For repeated distance computations, avoid allocations
function efficient_euclidean(x, y)
    sum_sq = 0.0
    for i in eachindex(x)
        diff = x[i] - y[i]
        sum_sq += diff * diff
    end
    return sqrt(sum_sq)
end

# Compare performance
using BenchmarkTools

p1 = randn(1000)
p2 = randn(1000)

@btime dist_euclidean($p1, $p2)        # Built-in version
@btime efficient_euclidean($p1, $p2)   # Optimized version
```


### Distance Function Properties {#Distance-Function-Properties}

When creating custom distance functions, ensure they satisfy the metric axioms:

```julia
function verify_metric_axioms(distance_func, points)
    n = length(points)
    
    # Test non-negativity and identity
    for i in 1:n
        for j in 1:n
            d = distance_func(points[i], points[j])
            
            # Non-negativity
            @assert d >= 0 "Distance must be non-negative"
            
            # Identity of indiscernibles
            if i == j
                @assert d == 0 "Distance from point to itself must be zero"
            end
        end
    end
    
    # Test symmetry and triangle inequality
    for i in 1:n
        for j in 1:n
            for k in 1:n
                d_ij = distance_func(points[i], points[j])
                d_ji = distance_func(points[j], points[i])
                d_ik = distance_func(points[i], points[k])
                d_kj = distance_func(points[k], points[j])
                
                # Symmetry
                @assert abs(d_ij - d_ji) < 1e-10 "Distance must be symmetric"
                
                # Triangle inequality
                @assert d_ij <= d_ik + d_kj + 1e-10 "Triangle inequality must hold"
            end
        end
    end
    
    println("All metric axioms verified!")
end

# Test built-in functions
test_points = [[1.0, 2.0], [3.0, 4.0], [0.0, 1.0]]
verify_metric_axioms(dist_euclidean, test_points)
```


## Integration with Distances.jl {#Integration-with-Distances.jl}

For more advanced distance functions, you can integrate with the Distances.jl package:

```julia
using Distances

# Create Distances.jl metric objects
euclidean_metric = Euclidean()
cityblock_metric = Cityblock()
chebyshev_metric = Chebyshev()

# Wrapper function to use with MetricSpaces.jl
function distances_jl_wrapper(metric)
    return (x, y) -> evaluate(metric, x, y)
end

# Use with MetricSpaces.jl functions
wrapped_euclidean = distances_jl_wrapper(euclidean_metric)
ball_with_distances_jl = ball_ids(X, center, radius, wrapped_euclidean)
```


## Advanced Distance Functions {#Advanced-Distance-Functions}

### Mahalanobis Distance {#Mahalanobis-Distance}

```julia
using LinearAlgebra

function mahalanobis_distance(x, y, Σ_inv)
    diff = x .- y
    return sqrt(diff' * Σ_inv * diff)
end

# Use with covariance matrix
data_matrix = hcat([X[i] for i in 1:length(X)]...)
Σ = cov(data_matrix')
Σ_inv = inv(Σ)

mahalanobis_func = (x, y) -> mahalanobis_distance(x, y, Σ_inv)
```


### Earth Mover&#39;s Distance (for probability distributions) {#Earth-Mover's-Distance-for-probability-distributions}

```julia
# Simplified 1D Earth Mover's Distance
function earth_mover_1d(p, q)
    # Assumes p and q are probability distributions (sum to 1)
    @assert abs(sum(p) - 1.0) < 1e-10 && abs(sum(q) - 1.0) < 1e-10
    
    cumsum_p = cumsum(p)
    cumsum_q = cumsum(q)
    
    return sum(abs.(cumsum_p .- cumsum_q))
end
```

