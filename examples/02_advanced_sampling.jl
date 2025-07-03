# # Advanced Geometric Sampling with MetricSpaces.jl
#
# This tutorial explores sophisticated sampling techniques for geometric data analysis,
# including epsilon-nets, farthest point sampling, and their applications in 
# computational geometry and topological data analysis.

using MetricSpaces
using Plots
using Random
using LinearAlgebra
Random.seed!(123)

# ## Generating Complex Geometric Data
#
# Let's start with more interesting geometric datasets to demonstrate
# advanced sampling techniques:

# Create a noisy circle dataset
function generate_noisy_circle(n_points; radius=5.0, noise=0.5)
    θ = 2π * rand(n_points)
    r = radius .+ noise * randn(n_points)
    points = [[r[i] * cos(θ[i]), r[i] * sin(θ[i])] for i in 1:n_points]
    return EuclideanSpace(points)
end

# Generate datasets
circle_space = generate_noisy_circle(300)
torus_space = torus(200; r=1.0, R=3.0)  # Using built-in torus generator  
sphere_space = sphere(200; dim=3)       # Using built-in sphere generator

println("Generated geometric datasets:")
println("  Circle: $(length(circle_space)) points")
println("  Torus: $(length(torus_space)) points") 
println("  Sphere: $(length(sphere_space)) points")

# ## Epsilon-Net Sampling
#
# An epsilon-net is a subset where every point in the original space
# is within distance epsilon of some point in the subset. This is crucial
# for approximation algorithms and computational geometry.

#md ### Theory
#md An ε-net of a metric space (X,d) is a subset S ⊆ X such that:
#md - **Covering property**: For every x ∈ X, there exists s ∈ S with d(x,s) ≤ ε
#md - **Separation property**: For distinct s₁, s₂ ∈ S, we have d(s₁,s₂) > ε

# Let's compute epsilon-nets for different epsilon values
epsilon_values = [0.5, 1.0, 1.5, 2.0]
circle_nets = []

for ε in epsilon_values
    net_indices = epsilon_net(circle_space, ε)
    push!(circle_nets, (ε, net_indices))
    println("ε = $ε: epsilon-net has $(length(net_indices)) points ($(round(100*length(net_indices)/length(circle_space), digits=1))% of original)")
end

# ## Visualizing Epsilon-Nets
#
# Let's visualize how epsilon-nets capture the structure at different scales:

function plot_epsilon_net(space, epsilon, net_indices; title_suffix="")
    # All points
    all_x = [point[1] for point in space]
    all_y = [point[2] for point in space]
    
    # Net points
    net_x = [space[i][1] for i in net_indices]
    net_y = [space[i][2] for i in net_indices]
    
    p = scatter(all_x, all_y,
        markersize=2, markercolor=:lightblue, markeralpha=0.4,
        label="All points", title="ε-net (ε=$epsilon)$title_suffix")
    
    scatter!(p, net_x, net_y,
        markersize=4, markercolor=:red, markeralpha=0.8,
        label="ε-net points")
    
    return p
end

# Create subplot for different epsilon values
epsilon_plots = []
for (ε, net_indices) in circle_nets[1:4]
    p = plot_epsilon_net(circle_space, ε, net_indices)
    push!(epsilon_plots, p)
end

epsilon_comparison = plot(epsilon_plots..., layout=(2, 2), size=(800, 600))

#nb display(epsilon_comparison)
#md ![Epsilon-Net Comparison](epsilon_nets.png)

# ## Farthest Point Sampling (Greedy Algorithm)
#
# Farthest point sampling iteratively selects points that are maximally
# distant from previously selected points. This creates well-distributed
# samples that capture geometric structure effectively.

# Demonstrate farthest point sampling with different numbers of points
sample_sizes = [10, 25, 50, 100]
farthest_samples = []

for n in sample_sizes
    indices = farthest_points_sample(circle_space, n)
    push!(farthest_samples, (n, indices))
    
    # Compute minimum distance between sample points
    sample_points = circle_space[indices]
    min_dist = Inf
    for i in 1:length(indices)
        for j in (i+1):length(indices)
            d = dist_euclidean(sample_points[i], sample_points[j])
            min_dist = min(min_dist, d)
        end
    end
    
    println("Farthest point sample (n=$n): min distance = $(round(min_dist, digits=3))")
end

# ## Quality Metrics for Sampling
#
# Let's compare different sampling strategies using quantitative metrics:

function sampling_quality_metrics(space, sample_indices)
    sample_points = space[sample_indices]
    n_sample = length(sample_indices)
    
    # 1. Coverage: maximum distance from any point to nearest sample point
    max_coverage_dist = 0.0
    for i in 1:length(space)
        min_dist_to_sample = Inf
        for j in sample_indices
            d = dist_euclidean(space[i], space[j])
            min_dist_to_sample = min(min_dist_to_sample, d)
        end
        max_coverage_dist = max(max_coverage_dist, min_dist_to_sample)
    end
    
    # 2. Separation: minimum distance between sample points
    min_separation = Inf
    for i in 1:n_sample
        for j in (i+1):n_sample
            d = dist_euclidean(sample_points[i], sample_points[j])
            min_separation = min(min_separation, d)
        end
    end
    
    # 3. Dispersion: average distance from sample center
    center = [mean([p[d] for p in sample_points]) for d in 1:length(sample_points[1])]
    avg_dispersion = mean([dist_euclidean(p, center) for p in sample_points])
    
    return (
        coverage = max_coverage_dist,
        separation = min_separation, 
        dispersion = avg_dispersion
    )
end

# Compare random vs farthest point sampling
n_compare = 50
random_indices = random_sample(circle_space, n_compare)
farthest_indices = farthest_points_sample(circle_space, n_compare)

random_metrics = sampling_quality_metrics(circle_space, random_indices)
farthest_metrics = sampling_quality_metrics(circle_space, farthest_indices)

println("\nSampling Quality Comparison (n=$n_compare):")
println("                Random    Farthest")
println("Coverage:      $(round(random_metrics.coverage, digits=3))      $(round(farthest_metrics.coverage, digits=3))")
println("Separation:    $(round(random_metrics.separation, digits=3))      $(round(farthest_metrics.separation, digits=3))")
println("Dispersion:    $(round(random_metrics.dispersion, digits=3))      $(round(farthest_metrics.dispersion, digits=3))")

# ## Working with Higher-Dimensional Spaces
#
# Let's explore sampling in higher dimensions using the built-in sphere generator:

# Create 3D sphere and visualize projections
sphere_3d = sphere(500, 3)  # 500 points on unit sphere in 3D

# Extract coordinates for different projections
x_coords = [point[1] for point in sphere_3d]
y_coords = [point[2] for point in sphere_3d]
z_coords = [point[3] for point in sphere_3d]

# Apply farthest point sampling
n_samples_3d = 50
farthest_3d_indices = farthest_points_sample(sphere_3d, n_samples_3d)
sample_3d_x = [sphere_3d[i][1] for i in farthest_3d_indices]
sample_3d_y = [sphere_3d[i][2] for i in farthest_3d_indices]
sample_3d_z = [sphere_3d[i][3] for i in farthest_3d_indices]

# Create 2D projections
proj_xy = scatter(x_coords, y_coords, 
    markersize=2, markercolor=:lightblue, markeralpha=0.4,
    title="XY Projection", xlabel="X", ylabel="Y", label="All points")
scatter!(proj_xy, sample_3d_x, sample_3d_y,
    markersize=4, markercolor=:red, label="Farthest sample")

proj_xz = scatter(x_coords, z_coords,
    markersize=2, markercolor=:lightblue, markeralpha=0.4, 
    title="XZ Projection", xlabel="X", ylabel="Z", label="All points")
scatter!(proj_xz, sample_3d_x, sample_3d_z,
    markersize=4, markercolor=:red, label="Farthest sample")

proj_yz = scatter(y_coords, z_coords,
    markersize=2, markercolor=:lightblue, markeralpha=0.4,
    title="YZ Projection", xlabel="Y", ylabel="Z", label="All points")
scatter!(proj_yz, sample_3d_y, sample_3d_z,
    markersize=4, markercolor=:red, label="Farthest sample")

sphere_projections = plot(proj_xy, proj_xz, proj_yz, layout=(1, 3), size=(1200, 400))

#nb display(sphere_projections)
#md ![3D Sphere Projections](sphere_projections.png)

# ## Application: Multi-Scale Analysis
#
# Combine epsilon-nets and farthest point sampling for multi-scale geometric analysis:

function multiscale_analysis(space, epsilon_values, sample_sizes)
    results = []
    
    println("Multi-scale Analysis Results:")
    println("="^50)
    
    for ε in epsilon_values
        net_indices = epsilon_net(space, ε)
        
        # Apply farthest point sampling to the epsilon-net
        for n in sample_sizes
            if n <= length(net_indices)
                subsample_indices = farthest_points_sample(space[net_indices], n)
                final_indices = net_indices[subsample_indices]
                
                metrics = sampling_quality_metrics(space, final_indices)
                
                push!(results, (
                    epsilon = ε,
                    sample_size = n,
                    coverage = metrics.coverage,
                    separation = metrics.separation
                ))
                
                println("ε=$ε, n=$n: coverage=$(round(metrics.coverage, digits=3)), separation=$(round(metrics.separation, digits=3))")
            end
        end
    end
    
    return results
end

# Perform multi-scale analysis on torus
multiscale_results = multiscale_analysis(torus_space, [0.5, 1.0, 1.5], [20, 40, 60])

# ## Computational Complexity Analysis
#
# Let's analyze the computational performance of different sampling methods:

function benchmark_sampling(space, method, sizes)
    times = []
    
    for n in sizes
        if method == :random
            t = @elapsed random_sample(space, n)
        elseif method == :farthest
            t = @elapsed farthest_points_sample(space, n)
        elseif method == :epsilon_net
            # Use epsilon = 1.0 for consistency
            t = @elapsed epsilon_net(space, 1.0)
        end
        push!(times, t)
    end
    
    return times
end

# Benchmark different methods (on smaller space for timing)
benchmark_space = generate_noisy_circle(1000)
sample_sizes_bench = [10, 25, 50, 100, 200]

random_times = benchmark_sampling(benchmark_space, :random, sample_sizes_bench)
farthest_times = benchmark_sampling(benchmark_space, :farthest, sample_sizes_bench)

println("\nComputational Performance (1000 point dataset):")
println("Sample Size    Random (ms)    Farthest (ms)")
println("-" * 42)
for (i, n) in enumerate(sample_sizes_bench)
    println("$(lpad(n, 8))     $(lpad(round(random_times[i]*1000, digits=2), 8))      $(lpad(round(farthest_times[i]*1000, digits=2), 10))")
end

# ## Practical Applications
#
# These sampling techniques have important applications:

#md ### Applications in Data Science
#md 
#md 1. **Computational Geometry**: Epsilon-nets for approximation algorithms
#md 2. **Machine Learning**: Representative sampling for large datasets  
#md 3. **Topological Data Analysis**: Well-distributed landmarks for persistence
#md 4. **Computer Graphics**: Level-of-detail representations
#md 5. **Scientific Computing**: Adaptive mesh refinement

# Example: Using samples for efficient k-nearest neighbor approximation
function approximate_knn(space, query_idx, k, sample_ratio=0.1)
    # Use farthest point sampling to create a representative subset
    n_samples = max(k+1, Int(ceil(length(space) * sample_ratio)))
    sample_indices = farthest_points_sample(space, n_samples)
    
    # Find k-nearest neighbors within the sample
    query_point = space[query_idx]
    distances = [(dist_euclidean(query_point, space[i]), i) for i in sample_indices]
    sort!(distances)
    
    # Return the k closest (excluding query point if it's in sample)
    result_indices = []
    for (dist, idx) in distances
        if idx != query_idx && length(result_indices) < k
            push!(result_indices, idx)
        end
    end
    
    return result_indices[1:min(k, length(result_indices))]
end

# Compare exact vs approximate k-NN
query_idx = 1
k_neighbors_exact = k_neighbors(circle_space, query_idx, 5)
k_neighbors_approx = approximate_knn(circle_space, query_idx, 5, 0.2)

println("\nk-NN Comparison (k=5, query point index=$query_idx):")
println("Exact k-NN indices: $k_neighbors_exact")
println("Approximate k-NN indices: $k_neighbors_approx")

# ## Summary
#
# This tutorial demonstrated advanced sampling techniques in MetricSpaces.jl:
#
# 1. **Epsilon-nets** for guaranteed coverage properties
# 2. **Farthest point sampling** for optimal point distribution  
# 3. **Quality metrics** for comparing sampling strategies
# 4. **Multi-scale analysis** combining multiple techniques
# 5. **Performance considerations** and computational trade-offs
# 6. **Practical applications** in data science and geometry
#
# These tools enable sophisticated geometric data analysis and form the
# foundation for advanced algorithms in computational topology and geometry.

#src # Source-only tests
#src using Test
#src @test length(circle_space) == 300
#src @test all(length(net[2]) > 0 for net in circle_nets)
#src @test farthest_metrics.coverage <= random_metrics.coverage  # Farthest should have better coverage
