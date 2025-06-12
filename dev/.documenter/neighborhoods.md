
# Neighborhood Analysis {#Neighborhood-Analysis}

MetricSpaces.jl provides tools for analyzing the local structure of metric spaces through neighborhood-based computations. These methods are essential for understanding local geometry, density, and topological properties.

## k-Nearest Neighbors {#k-Nearest-Neighbors}

Find the k closest points to a given query point.

### `k_neighbors` {#k_neighbors}

```julia
k_neighbors(X::MetricSpace, query_point, k::Int; d=dist_euclidean)
```


**Example:**

```julia
# Create sample data
points = [[0.0, 0.0], [1.0, 0.0], [0.0, 1.0], [1.0, 1.0], [2.0, 0.0], [0.0, 2.0]]
X = EuclideanSpace(points)

# Find 3 nearest neighbors of origin
query = [0.0, 0.0]
neighbors = k_neighbors(X, query, 3)

println("3 nearest neighbors of $query:")
for (i, neighbor_idx) in enumerate(neighbors)
    point = X[neighbor_idx]
    dist = dist_euclidean(query, point)
    println("  $i: Point $neighbor_idx = $point (distance: $(round(dist, digits=3)))")
end
```


### Properties of k-NN {#Properties-of-k-NN}
- **Asymmetry**: If A is a k-neighbor of B, B might not be a k-neighbor of A
  
- **Locality**: Captures local structure around each point
  
- **Scale-free**: Adapts to local density variations
  

```julia
# Analyze k-NN asymmetry
function analyze_knn_asymmetry(X::EuclideanSpace, k::Int)
    n = length(X)
    asymmetric_pairs = 0
    total_pairs = 0
    
    for i in 1:n
        neighbors_i = k_neighbors(X, X[i], k)
        
        for neighbor_idx in neighbors_i
            total_pairs += 1
            neighbors_j = k_neighbors(X, X[neighbor_idx], k)
            
            if !(i in neighbors_j)
                asymmetric_pairs += 1
            end
        end
    end
    
    asymmetry_rate = asymmetric_pairs / total_pairs
    println("k-NN asymmetry rate: $(round(asymmetry_rate * 100, digits=1))%")
    return asymmetry_rate
end

asymmetry = analyze_knn_asymmetry(X, 2)
```


## Distance-to-Measure {#Distance-to-Measure}

Compute density-based measures for outlier detection and filtering.

### `distance_to_measure` {#distance_to_measure}

```julia
distance_to_measure(X::MetricSpace, mass_parameter::Float64; d=dist_euclidean)
```


The distance-to-measure $d_{μ,m}(x)$ for a point $x$ is the minimum radius needed for a ball centered at $x$ to contain at least mass $m$ of the total measure.

**Example:**

```julia
# Create data with outliers
normal_points = [randn(2) for _ in 1:50]  # Clustered points
outliers = [[10.0, 10.0], [-8.0, -8.0]]   # Clear outliers
all_points = vcat(normal_points, outliers)
X_outliers = EuclideanSpace(all_points)

# Compute distance to measure with 10% mass
mass_param = 0.1
dtm_values = distance_to_measure(X_outliers, mass_param)

println("Distance to measure analysis:")
println("Normal points (first 5): ", round.(dtm_values[1:5], digits=3))
println("Outliers: ", round.(dtm_values[end-1:end], digits=3))

# Identify outliers (high DTM values)
threshold = quantile(dtm_values, 0.9)  # Top 10% as outliers
outlier_indices = findall(x -> x > threshold, dtm_values)
println("Detected outlier indices: ", outlier_indices)
```


### DTM Applications {#DTM-Applications}

**Density Estimation:**

```julia
function estimate_density_dtm(X::EuclideanSpace, mass_param=0.05)
    dtm_vals = distance_to_measure(X, mass_param)
    # Density inversely related to DTM
    densities = 1.0 ./ (dtm_vals .+ 1e-10)  # Add small value to avoid division by zero
    return densities ./ sum(densities)  # Normalize
end

densities = estimate_density_dtm(X_outliers)
```


**Robust Filtering:**

```julia
function robust_filter(X::EuclideanSpace, mass_param=0.1, quantile_threshold=0.8)
    dtm_vals = distance_to_measure(X, mass_param)
    threshold = quantile(dtm_vals, quantile_threshold)
    
    # Keep points with low DTM (high density regions)
    filtered_indices = findall(x -> x <= threshold, dtm_vals)
    return filtered_indices
end

filtered_indices = robust_filter(X_outliers, 0.1, 0.8)
filtered_points = X_outliers[filtered_indices]
println("Filtered from $(length(X_outliers)) to $(length(filtered_points)) points")
```


## Eccentricity {#Eccentricity}

Measure how &quot;central&quot; each point is within the metric space.

### `excentricity` {#excentricity}

```julia
excentricity(X::MetricSpace; d=dist_euclidean)
```


The eccentricity of a point is its maximum distance to any other point in the space.

**Example:**

```julia
# Create data with clear center and boundary points
center_points = [0.1 * randn(2) for _ in 1:20]  # Tight cluster at origin
boundary_points = [5.0 * normalize(randn(2)) for _ in 1:10]  # Points on boundary
mixed_data = vcat(center_points, boundary_points)
X_mixed = EuclideanSpace(mixed_data)

# Compute eccentricity
eccentricities = excentricity(X_mixed)

println("Eccentricity analysis:")
println("Center points (first 5): ", round.(eccentricities[1:5], digits=3))
println("Boundary points (last 5): ", round.(eccentricities[end-4:end], digits=3))

# Find most central point (minimum eccentricity)
most_central_idx = argmin(eccentricities)
most_eccentric_idx = argmax(eccentricities)

println("Most central point: index $most_central_idx, eccentricity $(round(eccentricities[most_central_idx], digits=3))")
println("Most eccentric point: index $most_eccentric_idx, eccentricity $(round(eccentricities[most_eccentric_idx], digits=3))")
```


### Eccentricity Applications {#Eccentricity-Applications}

**Geometric Center Finding:**

```julia
function find_geometric_center(X::EuclideanSpace)
    ecc_values = excentricity(X)
    center_idx = argmin(ecc_values)
    return center_idx, X[center_idx]
end

center_idx, center_point = find_geometric_center(X_mixed)
println("Geometric center: $center_point at index $center_idx")
```


**Boundary Detection:**

```julia
function detect_boundary_points(X::EuclideanSpace, percentile=90)
    ecc_values = excentricity(X)
    threshold = quantile(ecc_values, percentile/100)
    boundary_indices = findall(x -> x >= threshold, ecc_values)
    return boundary_indices
end

boundary_indices = detect_boundary_points(X_mixed, 80)
println("Boundary points (top 20%): ", boundary_indices)
```


## Local Dimension Estimation {#Local-Dimension-Estimation}

Estimate the local intrinsic dimension around each point.

```julia
using LinearAlgebra

function estimate_local_dimension(X::EuclideanSpace, k::Int=10; method=:pca)
    local_dimensions = Float64[]
    
    for i in 1:length(X)
        # Get k nearest neighbors
        neighbor_indices = k_neighbors(X, X[i], k)
        neighbor_points = [X[j] for j in neighbor_indices]
        
        if method == :pca
            # Center the neighbor points
            center = mean(neighbor_points)
            centered_points = [p .- center for p in neighbor_points]
            
            # Create data matrix (points as columns)
            data_matrix = hcat(centered_points...)
            
            # Compute SVD
            U, S, V = svd(data_matrix)
            
            # Estimate dimension based on singular value decay
            # Simple approach: count significant singular values
            total_variance = sum(S.^2)
            cumulative_variance = cumsum(S.^2) / total_variance
            
            # Find dimension needed to capture 90% of variance
            dim_estimate = findfirst(x -> x > 0.9, cumulative_variance)
            dim_estimate = dim_estimate === nothing ? length(S) : dim_estimate
            
        else
            # Fallback: use ambient dimension
            dim_estimate = length(X[1])
        end
        
        push!(local_dimensions, dim_estimate)
    end
    
    return local_dimensions
end

# Example usage
local_dims = estimate_local_dimension(X_mixed, 5)
println("Local dimension estimates:")
println("Mean: $(round(mean(local_dims), digits=2))")
println("Range: $(minimum(local_dims)) - $(maximum(local_dims))")
```


## Neighborhood Graphs {#Neighborhood-Graphs}

Construct graphs based on neighborhood relationships.

### k-NN Graph {#k-NN-Graph}

```julia
using Graphs

function build_knn_graph(X::EuclideanSpace, k::Int)
    n = length(X)
    g = SimpleGraph(n)
    
    for i in 1:n
        neighbors = k_neighbors(X, X[i], k)
        for neighbor_idx in neighbors
            if neighbor_idx != i  # Avoid self-loops
                add_edge!(g, i, neighbor_idx)
            end
        end
    end
    
    return g
end

knn_graph = build_knn_graph(X, 2)
println("k-NN graph properties:")
println("Nodes: $(nv(knn_graph))")
println("Edges: $(ne(knn_graph))")
println("Connected components: $(length(connected_components(knn_graph)))")
```


### ε-neighborhood Graph {#ε-neighborhood-Graph}

```julia
function build_epsilon_graph(X::EuclideanSpace, ε::Float64)
    n = length(X)
    g = SimpleGraph(n)
    
    for i in 1:n
        neighbors = ball_ids(X, X[i], ε)
        for neighbor_idx in neighbors
            if neighbor_idx != i && neighbor_idx > i  # Avoid self-loops and duplicates
                add_edge!(g, i, neighbor_idx)
            end
        end
    end
    
    return g
end

eps_graph = build_epsilon_graph(X, 1.5)
println("ε-neighborhood graph properties:")
println("Nodes: $(nv(eps_graph))")
println("Edges: $(ne(eps_graph))")
```


## Advanced Neighborhood Analysis {#Advanced-Neighborhood-Analysis}

### Neighborhood Stability {#Neighborhood-Stability}

Analyze how neighborhoods change under perturbations:

```julia
function neighborhood_stability(X::EuclideanSpace, k::Int, noise_level=0.1, n_trials=10)
    stability_scores = Float64[]
    
    for i in 1:length(X)
        original_neighbors = Set(k_neighbors(X, X[i], k))
        overlap_scores = Float64[]
        
        for trial in 1:n_trials
            # Add noise to the query point
            noisy_point = X[i] .+ noise_level * randn(length(X[i]))
            noisy_neighbors = Set(k_neighbors(X, noisy_point, k))
            
            # Compute Jaccard similarity
            intersection_size = length(intersect(original_neighbors, noisy_neighbors))
            union_size = length(union(original_neighbors, noisy_neighbors))
            jaccard = intersection_size / union_size
            
            push!(overlap_scores, jaccard)
        end
        
        push!(stability_scores, mean(overlap_scores))
    end
    
    return stability_scores
end

stability = neighborhood_stability(X, 3, 0.05, 5)
println("Neighborhood stability (mean): $(round(mean(stability), digits=3))")
```


### Multi-scale Neighborhoods {#Multi-scale-Neighborhoods}

Analyze neighborhoods at different scales:

```julia
function multiscale_neighborhood_analysis(X::EuclideanSpace, point_idx::Int, radii=[0.5, 1.0, 1.5, 2.0])
    analysis = Dict{Float64, Dict{String, Any}}()
    
    for r in radii
        neighbors = ball_ids(X, X[point_idx], r)
        neighbor_points = [X[i] for i in neighbors]
        
        # Compute neighborhood statistics
        n_neighbors = length(neighbors)
        
        if n_neighbors > 1
            # Average distance to neighbors
            center = X[point_idx]
            distances = [dist_euclidean(center, p) for p in neighbor_points]
            avg_dist = mean(distances)
            std_dist = std(distances)
            
            # Neighborhood "spread"
            if n_neighbors > 2
                centroid = mean(neighbor_points)
                spreads = [norm(p .- centroid) for p in neighbor_points]
                neighborhood_spread = mean(spreads)
            else
                neighborhood_spread = 0.0
            end
        else
            avg_dist = 0.0
            std_dist = 0.0
            neighborhood_spread = 0.0
        end
        
        analysis[r] = Dict(
            "n_neighbors" => n_neighbors,
            "avg_distance" => avg_dist,
            "std_distance" => std_dist,
            "neighborhood_spread" => neighborhood_spread
        )
    end
    
    return analysis
end

# Analyze neighborhoods around the first point
multiscale_analysis = multiscale_neighborhood_analysis(X, 1)
println("Multi-scale neighborhood analysis for point 1:")
for (radius, stats) in sort(collect(multiscale_analysis))
    println("Radius $radius:")
    println("  Neighbors: $(stats["n_neighbors"])")
    println("  Avg distance: $(round(stats["avg_distance"], digits=3))")
    println("  Neighborhood spread: $(round(stats["neighborhood_spread"], digits=3))")
end
```


## Applications in Data Analysis {#Applications-in-Data-Analysis}

### Clustering Validation {#Clustering-Validation}

Use neighborhood analysis to validate clustering results:

```julia
function validate_clustering_with_neighborhoods(X::EuclideanSpace, cluster_labels, k::Int=5)
    n_clusters = maximum(cluster_labels)
    intra_cluster_cohesion = Float64[]
    
    for cluster_id in 1:n_clusters
        cluster_points = findall(x -> x == cluster_id, cluster_labels)
        
        if length(cluster_points) > k
            cohesion_scores = Float64[]
            
            for point_idx in cluster_points
                neighbors = k_neighbors(X, X[point_idx], k)
                # Count how many neighbors are in the same cluster
                same_cluster_neighbors = sum(cluster_labels[neighbors] .== cluster_id)
                cohesion = same_cluster_neighbors / k
                push!(cohesion_scores, cohesion)
            end
            
            push!(intra_cluster_cohesion, mean(cohesion_scores))
        end
    end
    
    return mean(intra_cluster_cohesion)
end

# Example with simple clustering
cluster_labels = [1, 1, 1, 2, 2, 2]  # Simple manual clustering
cohesion = validate_clustering_with_neighborhoods(X, cluster_labels, 2)
println("Clustering cohesion score: $(round(cohesion, digits=3))")
```


### Anomaly Detection {#Anomaly-Detection}

Combine multiple neighborhood-based measures:

```julia
function comprehensive_anomaly_detection(X::EuclideanSpace)
    # Compute multiple measures
    dtm_vals = distance_to_measure(X, 0.1)
    ecc_vals = excentricity(X)
    
    # Local density (inverse of average k-NN distance)
    k = min(5, length(X) - 1)
    local_densities = Float64[]
    
    for i in 1:length(X)
        if length(X) > 1
            neighbors = k_neighbors(X, X[i], min(k, length(X)-1))
            avg_dist = mean([dist_euclidean(X[i], X[j]) for j in neighbors if j != i])
            push!(local_densities, 1.0 / (avg_dist + 1e-10))
        else
            push!(local_densities, 1.0)
        end
    end
    
    # Normalize measures to [0, 1]
    dtm_norm = (dtm_vals .- minimum(dtm_vals)) ./ (maximum(dtm_vals) - minimum(dtm_vals) + 1e-10)
    ecc_norm = (ecc_vals .- minimum(ecc_vals)) ./ (maximum(ecc_vals) - minimum(ecc_vals) + 1e-10)
    density_norm = 1.0 .- ((local_densities .- minimum(local_densities)) ./ (maximum(local_densities) - minimum(local_densities) + 1e-10))
    
    # Combine measures (equal weights)
    anomaly_scores = (dtm_norm .+ ecc_norm .+ density_norm) ./ 3
    
    return anomaly_scores
end

anomaly_scores = comprehensive_anomaly_detection(X_outliers)
println("Top 3 anomalies:")
top_anomalies = sortperm(anomaly_scores, rev=true)[1:3]
for (rank, idx) in enumerate(top_anomalies)
    println("  $rank: Point $idx (score: $(round(anomaly_scores[idx], digits=3)))")
end
```

