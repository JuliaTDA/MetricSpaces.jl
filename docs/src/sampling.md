# Sampling Methods

MetricSpaces.jl provides several algorithms for sampling representative subsets from metric spaces. These methods are crucial for working with large datasets and creating sparse representations that preserve geometric properties.

## ε-net Sampling

An **ε-net** is a subset of points such that every point in the space is within distance ε of at least one point in the subset.

### `epsilon_net`

```julia
epsilon_net(X::MetricSpace, ε::Number; d=dist_euclidean)
```

**Algorithm**: Greedy selection of points that are not yet covered by existing ε-balls.

**Example:**
```julia
# Create a dense point cloud
points = [randn(2) for _ in 1:100]
X = EuclideanSpace(points)

# Generate ε-net with radius 0.5
ε = 0.5
landmarks = epsilon_net(X, ε)

println("Original space: $(length(X)) points")
println("ε-net: $(length(landmarks)) landmarks")
println("Compression ratio: $(round(length(landmarks)/length(X), digits=3))")

# Extract landmark points
landmark_points = X[landmarks]
```

### Properties of ε-nets

- **Covering**: Every point is within distance ε of some landmark
- **Efficiency**: Provides sparse representation of dense point sets
- **Deterministic**: Greedy algorithm gives reproducible results

```julia
# Verify covering property
function verify_epsilon_net(X, landmarks, ε, distance_func=dist_euclidean)
    uncovered_points = Int[]
    
    for i in 1:length(X)
        min_dist = Inf
        for landmark_idx in landmarks
            dist = distance_func(X[i], X[landmark_idx])
            min_dist = min(min_dist, dist)
        end
        
        if min_dist >= ε
            push!(uncovered_points, i)
        end
    end
    
    if isempty(uncovered_points)
        println("✓ All points are covered by ε-net")
        return true
    else
        println("✗ Uncovered points: ", uncovered_points)
        return false
    end
end

verify_epsilon_net(X, landmarks, ε)
```

## Farthest Point Sampling

**Farthest Point Sampling (FPS)** greedily selects points that are maximally separated from previously chosen points.

### `farthest_points_sample`

```julia
farthest_points_sample(X::MetricSpace, k::Int; d=dist_euclidean, start_idx=nothing)
```

**Algorithm**:
1. Start with a random point (or specified starting point)
2. Iteratively select the point farthest from all previously selected points
3. Continue until k points are selected

**Example:**
```julia
# Sample 10 well-separated points
k = 10
fps_indices = farthest_points_sample(X, k)
fps_points = X[fps_indices]

println("Selected $k points using FPS")
println("Indices: ", fps_indices)

# Analyze separation
function analyze_separation(X, indices, distance_func=dist_euclidean)
    min_dist = Inf
    max_dist = 0.0
    
    for i in 1:length(indices)
        for j in (i+1):length(indices)
            dist = distance_func(X[indices[i]], X[indices[j]])
            min_dist = min(min_dist, dist)
            max_dist = max(max_dist, dist)
        end
    end
    
    return min_dist, max_dist
end

min_sep, max_sep = analyze_separation(X, fps_indices)
println("Minimum separation: $(round(min_sep, digits=3))")
println("Maximum separation: $(round(max_sep, digits=3))")
```

### Controlling the Starting Point

```julia
# Start FPS from a specific point
center_idx = 1  # Start from first point
fps_from_center = farthest_points_sample(X, k, start_idx=center_idx)

# Compare with random start
fps_random_start = farthest_points_sample(X, k)

println("FPS from center: ", fps_from_center)
println("FPS random start: ", fps_random_start)
```

## Random Sampling

Simple random sampling without replacement:

### `random_sample`

```julia
random_sample(X::MetricSpace, k::Int)
```

**Example:**
```julia
# Random sample of 15 points
random_indices = random_sample(X, 15)
random_points = X[random_indices]

println("Random sample indices: ", random_indices)
```

### Reproducible Random Sampling

```julia
using Random

# Set seed for reproducible results
Random.seed!(42)
reproducible_sample = random_sample(X, 10)

# Reset and sample again - should be identical
Random.seed!(42)
identical_sample = random_sample(X, 10)

println("Samples are identical: ", reproducible_sample == identical_sample)
```

## Comparing Sampling Methods

Let's compare the different sampling methods on the same dataset:

```julia
# Generate test data: points on a circle with some noise
function generate_noisy_circle(n_points=200, radius=1.0, noise_level=0.1)
    angles = range(0, 2π, length=n_points+1)[1:end-1]  # Exclude 2π
    points = Vector{Vector{Float64}}()
    
    for θ in angles
        # Perfect circle point
        x = radius * cos(θ)
        y = radius * sin(θ)
        
        # Add noise
        x += randn() * noise_level
        y += randn() * noise_level
        
        push!(points, [x, y])
    end
    
    return EuclideanSpace(points)
end

circle_data = generate_noisy_circle(200, 1.0, 0.05)
k = 20  # Sample 20 points

# Compare sampling methods
eps_net_result = epsilon_net(circle_data, 0.3)
fps_result = farthest_points_sample(circle_data, k)
random_result = random_sample(circle_data, k)

println("Sampling method comparison:")
println("ε-net (ε=0.3): $(length(eps_net_result)) points")
println("FPS (k=$k): $(length(fps_result)) points")
println("Random (k=$k): $(length(random_result)) points")
```

## Advanced Sampling Techniques

### Adaptive Sampling

Combine different sampling methods based on local density:

```julia
function adaptive_sample(X::EuclideanSpace, target_size::Int, density_threshold=2.0)
    # Start with FPS for good coverage
    initial_sample = farthest_points_sample(X, target_size ÷ 2)
    
    # Identify high-density regions
    remaining_points = setdiff(1:length(X), initial_sample)
    high_density_regions = Int[]
    
    for idx in remaining_points
        neighbors = ball_ids(X, X[idx], 0.2)  # Small radius
        if length(neighbors) > density_threshold
            push!(high_density_regions, idx)
        end
    end
    
    # Add random samples from high-density regions
    if length(high_density_regions) > 0
        additional_count = target_size - length(initial_sample)
        if additional_count > 0
            additional_indices = high_density_regions[randperm(length(high_density_regions))[1:min(additional_count, length(high_density_regions))]]
            return vcat(initial_sample, additional_indices)
        end
    end
    
    return initial_sample
end

adaptive_result = adaptive_sample(circle_data, 25)
println("Adaptive sampling: $(length(adaptive_result)) points")
```

### Stratified Sampling

Sample uniformly from different regions:

```julia
function stratified_sample(X::EuclideanSpace, n_strata::Int, points_per_stratum::Int)
    # Simple 2D stratification by quadrants
    strata = [Int[] for _ in 1:n_strata]
    
    # Assign points to strata based on their coordinates
    for i in 1:length(X)
        point = X[i]
        # Simple hash-based assignment
        stratum = (hash(point) % n_strata) + 1
        push!(strata[stratum], i)
    end
    
    # Sample from each stratum
    sampled_indices = Int[]
    for stratum in strata
        if length(stratum) >= points_per_stratum
            sampled = stratum[randperm(length(stratum))[1:points_per_stratum]]
            append!(sampled_indices, sampled)
        else
            append!(sampled_indices, stratum)  # Take all if stratum is small
        end
    end
    
    return sampled_indices
end

stratified_result = stratified_sample(circle_data, 4, 5)
println("Stratified sampling: $(length(stratified_result)) points")
```

## Performance Analysis

### Timing Comparisons

```julia
using BenchmarkTools

# Large dataset for performance testing
large_data = EuclideanSpace([randn(10) for _ in 1:1000])
k = 50

println("Performance comparison on 1000 points in 10D:")

# Benchmark different methods
println("Random sampling:")
@btime random_sample($large_data, $k)

println("Farthest point sampling:")
@btime farthest_points_sample($large_data, $k)

println("ε-net sampling:")
@btime epsilon_net($large_data, 1.0)
```

### Memory Usage

```julia
function memory_usage_analysis(X::EuclideanSpace)
    n = length(X)
    point_dim = length(X[1])
    
    # Estimate memory usage for different operations
    point_size = sizeof(X[1])
    total_points_memory = n * point_size
    
    # Distance matrix would require O(n²) memory
    distance_matrix_memory = n^2 * sizeof(Float64)
    
    println("Memory analysis for $(n) points in $(point_dim)D:")
    println("Points storage: $(round(total_points_memory/1024, digits=2)) KB")
    println("Full distance matrix: $(round(distance_matrix_memory/1024/1024, digits=2)) MB")
    
    # Sampling reduces memory requirements
    sample_fraction = 0.1
    sampled_memory = (n * sample_fraction)^2 * sizeof(Float64)
    println("10% sample distance matrix: $(round(sampled_memory/1024, digits=2)) KB")
end

memory_usage_analysis(large_data)
```

## Applications

### Landmark-Based Approximation

Use sampled points as landmarks for approximating distances:

```julia
function landmark_approximation(X::EuclideanSpace, query_point, landmarks_indices, distance_func=dist_euclidean)
    # Approximate distance from query point to all points in X
    # using distances to landmarks
    
    landmark_distances = [distance_func(query_point, X[idx]) for idx in landmarks_indices]
    approximations = Float64[]
    
    for i in 1:length(X)
        # Use triangle inequality for approximation
        min_approx = Inf
        for (j, landmark_idx) in enumerate(landmarks_indices)
            # Triangle inequality: |d(q,x) - d(q,l)| ≤ d(x,l)
            landmark_to_point = distance_func(X[landmark_idx], X[i])
            approx = abs(landmark_distances[j] - landmark_to_point)
            min_approx = min(min_approx, approx)
        end
        push!(approximations, min_approx)
    end
    
    return approximations
end

# Example usage
landmarks = farthest_points_sample(X, 5)
query = [0.5, 0.5]
approximations = landmark_approximation(X, query, landmarks)
```

### Multi-Scale Sampling

Create hierarchical samples at different scales:

```julia
function multiscale_sampling(X::EuclideanSpace, scales=[1.0, 0.5, 0.25])
    samples = Dict{Float64, Vector{Int}}()
    
    for scale in scales
        # Use ε-net with scale as radius
        sample_indices = epsilon_net(X, scale)
        samples[scale] = sample_indices
        println("Scale $scale: $(length(sample_indices)) points")
    end
    
    return samples
end

multiscale_result = multiscale_sampling(circle_data, [0.5, 0.3, 0.1])
```

## Best Practices

### Choosing Sample Size

```julia
function estimate_sample_size(X::EuclideanSpace, target_error=0.1)
    # Rough heuristic: sample size based on intrinsic dimension
    n = length(X)
    dim = length(X[1])
    
    # More points needed for higher dimensions
    base_sample = max(10, Int(ceil(dim * 5)))
    
    # Scale with dataset size (logarithmically)
    size_factor = log(n) / log(100)  # Normalized to log(100)
    
    estimated_size = Int(ceil(base_sample * size_factor))
    
    println("Estimated sample size for $n points in $(dim)D: $estimated_size")
    return min(estimated_size, n ÷ 2)  # Don't sample more than half
end

recommended_size = estimate_sample_size(circle_data)
optimal_sample = farthest_points_sample(circle_data, recommended_size)
```

### Quality Assessment

```julia
function assess_sample_quality(X::EuclideanSpace, sample_indices, distance_func=dist_euclidean)
    sample_points = X[sample_indices]
    
    # Coverage: average distance to nearest sample point
    coverage_distances = Float64[]
    for i in 1:length(X)
        min_dist = minimum(distance_func(X[i], sample_points[j]) for j in 1:length(sample_points))
        push!(coverage_distances, min_dist)
    end
    
    avg_coverage = mean(coverage_distances)
    max_coverage = maximum(coverage_distances)
    
    # Separation: minimum distance between sample points
    min_separation = Inf
    for i in 1:length(sample_points)
        for j in (i+1):length(sample_points)
            dist = distance_func(sample_points[i], sample_points[j])
            min_separation = min(min_separation, dist)
        end
    end
    
    println("Sample quality assessment:")
    println("  Average coverage distance: $(round(avg_coverage, digits=4))")
    println("  Maximum coverage distance: $(round(max_coverage, digits=4))")
    println("  Minimum separation: $(round(min_separation, digits=4))")
    
    return (coverage=avg_coverage, max_coverage=max_coverage, separation=min_separation)
end

# Compare quality of different sampling methods
println("FPS quality:")
fps_quality = assess_sample_quality(circle_data, fps_result)

println("\nRandom sampling quality:")
random_quality = assess_sample_quality(circle_data, random_result)
```
