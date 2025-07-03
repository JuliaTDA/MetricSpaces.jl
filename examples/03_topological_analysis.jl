# # Topological Data Analysis with MetricSpaces.jl
#
# This tutorial explores how MetricSpaces.jl can be used for topological data analysis (TDA),
# including persistent homology computations, nerve complexes, and geometric shape analysis.
# We'll work with real-world datasets and demonstrate practical TDA workflows.

using MetricSpaces
using Plots
using Random
using Statistics
using LinearAlgebra
Random.seed!(456)

# ## Introduction to Topological Data Analysis
#
# Topological Data Analysis studies the "shape" of data by examining topological
# features that persist across multiple scales. Key concepts include:
#
# - **Simplicial complexes**: Generalizations of graphs to higher dimensions
# - **Persistent homology**: Tracking topological features across filtrations  
# - **Betti numbers**: Counting holes of different dimensions
# - **Nerve complexes**: Combinatorial representations of geometric data

# ## Generating Topological Test Data
#
# Let's create datasets with known topological features:

# 1. Noisy circle (1-dimensional loop)
function generate_noisy_circle(n_points; radius=3.0, noise=0.3, inner_points=0)
    # Points on circle
    θ = 2π * rand(n_points)
    r = radius .+ noise * randn(n_points)
    circle_points = [[r[i] * cos(θ[i]), r[i] * sin(θ[i])] for i in 1:n_points]
    
    # Optional inner points (to test robustness)
    if inner_points > 0
        inner_r = radius * 0.5 * rand(inner_points)
        inner_θ = 2π * rand(inner_points)
        inner_pts = [[inner_r[i] * cos(inner_θ[i]), inner_r[i] * sin(inner_θ[i])] for i in 1:inner_points]
        circle_points = vcat(circle_points, inner_pts)
    end
    
    return EuclideanSpace(circle_points)
end

# 2. Two circles (multiple connected components)
function generate_two_circles(n_points_each; separation=8.0)
    # First circle centered at origin
    circle1 = generate_noisy_circle(n_points_each; radius=2.0)
    
    # Second circle translated
    circle2_raw = generate_noisy_circle(n_points_each; radius=2.0)
    circle2 = EuclideanSpace([[p[1] + separation, p[2]] for p in circle2_raw])
    
    # Combine both circles
    return EuclideanSpace(vcat(circle1, circle2))
end

# 3. Torus with holes (higher-dimensional topology)
torus_data = torus(300, 4.0, 1.5)  # Built-in torus generator

# Create test datasets
circle_data = generate_noisy_circle(200; inner_points=50)
two_circles_data = generate_two_circles(150)

println("Generated topological datasets:")
println("  Single circle: $(length(circle_data)) points")
println("  Two circles: $(length(two_circles_data)) points") 
println("  Torus: $(length(torus_data)) points")

# ## Visualizing Topological Structure
#
# Let's visualize our datasets to understand their topological features:

function plot_2d_data(space, title_str; markersize=3)
    x_coords = [point[1] for point in space]
    y_coords = [point[2] for point in space]
    
    scatter(x_coords, y_coords,
        title=title_str, xlabel="X", ylabel="Y",
        markersize=markersize, markercolor=:blue, markeralpha=0.6,
        aspect_ratio=:equal, label="")
end

# Plot 2D datasets
p1 = plot_2d_data(circle_data, "Noisy Circle with Inner Points")
p2 = plot_2d_data(two_circles_data, "Two Separate Circles")

topo_viz = plot(p1, p2, layout=(1, 2), size=(800, 400))

#nb display(topo_viz)
#md ![Topological Datasets](topological_data.png)

# ## Building Nerve Complexes
#
# The nerve of a covering captures the combinatorial structure of overlapping regions.
# This is fundamental for many TDA computations.

# Create a Vietoris-Rips style complex using metric balls
function build_nerve_complex(space, epsilon)
    n = length(space)
    
    # Find all epsilon-balls and their intersections
    balls = []
    for i in 1:n
        ball_indices = ball_ids(space, i, epsilon)
        push!(balls, Set(ball_indices))
    end
    
    # Build nerve: vertices are balls, edges connect intersecting balls
    nerve_edges = []
    for i in 1:n
        for j in (i+1):n
            if !isempty(intersect(balls[i], balls[j]))
                push!(nerve_edges, (i, j))
            end
        end
    end
    
    return (vertices=collect(1:n), edges=nerve_edges, balls=balls)
end

# Build nerve complexes at different scales
epsilon_values = [0.5, 1.0, 1.5, 2.0]
circle_nerves = []

for ε in epsilon_values
    nerve = build_nerve_complex(circle_data, ε)
    push!(circle_nerves, (ε, nerve))
    
    n_components = count_connected_components(nerve.edges, length(circle_data))
    println("ε = $ε: $(length(nerve.edges)) edges, $n_components connected components")
end

# Helper function to count connected components
function count_connected_components(edges, n_vertices)
    # Simple union-find to count components
    parent = collect(1:n_vertices)
    
    function find_root(x)
        if parent[x] != x
            parent[x] = find_root(parent[x])
        end
        return parent[x]
    end
    
    function union!(x, y)
        root_x, root_y = find_root(x), find_root(y)
        if root_x != root_y
            parent[root_x] = root_y
        end
    end
    
    for (i, j) in edges
        union!(i, j)
    end
    
    return length(unique([find_root(i) for i in 1:n_vertices]))
end

# ## Persistent Homology Simulation
#
# While full persistent homology requires specialized libraries, we can simulate
# the process using MetricSpaces.jl to understand the concepts:

function filtration_analysis(space, epsilon_range)
    results = []
    
    for ε in epsilon_range
        # Build simplicial complex (approximated by nerve complex)
        nerve = build_nerve_complex(space, ε)
        
        # Count topological features
        n_vertices = length(nerve.vertices)
        n_edges = length(nerve.edges)
        n_components = count_connected_components(nerve.edges, n_vertices)
        
        # Euler characteristic approximation: χ = V - E
        # For a space with b₀ components and b₁ loops: χ = b₀ - b₁
        euler_char = n_vertices - n_edges
        estimated_b1 = n_components - euler_char  # Estimated number of 1D holes
        
        push!(results, (
            epsilon = ε,
            components = n_components,
            euler_char = euler_char,
            estimated_holes = max(0, estimated_b1)  # Can't have negative holes
        ))
    end
    
    return results
end

# Analyze topological persistence
fine_epsilon_range = 0.1:0.2:3.0
circle_filtration = filtration_analysis(circle_data, fine_epsilon_range)
two_circles_filtration = filtration_analysis(two_circles_data, fine_epsilon_range)

# ## Persistence Diagrams (Conceptual)
#
# Let's create a conceptual visualization of how topological features persist:

function plot_persistence_barcode(filtration_results, title_str)
    epsilons = [r.epsilon for r in filtration_results]
    components = [r.components for r in filtration_results]
    holes = [r.estimated_holes for r in filtration_results]
    
    p = plot(epsilons, components, 
        label="Connected Components", linewidth=2, color=:blue,
        title=title_str, xlabel="ε (filtration parameter)", ylabel="Count")
    
    plot!(p, epsilons, holes,
        label="Estimated 1D Holes", linewidth=2, color=:red, linestyle=:dash)
    
    return p
end

# Create persistence plots
p_circle = plot_persistence_barcode(circle_filtration, "Circle: Topological Features vs Scale")
p_two_circles = plot_persistence_barcode(two_circles_filtration, "Two Circles: Topological Features vs Scale")

persistence_plots = plot(p_circle, p_two_circles, layout=(2, 1), size=(800, 600))

#nb display(persistence_plots)
#md ![Persistence Analysis](persistence_plots.png)

# ## Mapper Algorithm Implementation
#
# The Mapper algorithm creates a topological summary by:
# 1. Projecting data to lower dimensions
# 2. Creating overlapping covers
# 3. Clustering within each cover element
# 4. Building a nerve complex

function simple_mapper(space, projection_func, n_intervals, overlap_ratio)
    # Step 1: Project data
    projections = [projection_func(point) for point in space]
    min_proj, max_proj = extrema(projections)
    
    # Step 2: Create overlapping intervals
    interval_length = (max_proj - min_proj) / n_intervals
    overlap = interval_length * overlap_ratio
    
    intervals = []
    for i in 1:n_intervals
        start_val = min_proj + (i-1) * interval_length - (i > 1 ? overlap : 0)
        end_val = min_proj + i * interval_length + (i < n_intervals ? overlap : 0)
        push!(intervals, (start_val, end_val))
    end
    
    # Step 3: Find points in each interval and cluster them
    interval_clusters = []
    for (start_val, end_val) in intervals
        # Find points in this interval
        interval_indices = [i for (i, proj) in enumerate(projections) 
                          if start_val <= proj <= end_val]
        
        if length(interval_indices) > 0
            # Simple clustering: use farthest point sampling for representative points
            n_clusters = min(3, length(interval_indices))  # Max 3 clusters per interval
            if length(interval_indices) >= n_clusters
                cluster_centers = farthest_points_sample(
                    EuclideanSpace(space[interval_indices]), n_clusters)
                cluster_indices = [interval_indices[center_indices] 
                                 for center_indices in cluster_centers]
            else
                cluster_indices = interval_indices
            end
            push!(interval_clusters, cluster_indices)
        end
    end
    
    # Step 4: Build nerve complex (simplified)
    return interval_clusters
end

# Apply Mapper to circle data using height function
height_projection(point) = point[2]  # Project to y-coordinate

circle_mapper = simple_mapper(circle_data, height_projection, 8, 0.3)
println("\nMapper analysis of circle data:")
println("Number of interval clusters: $(length(circle_mapper))")
for (i, cluster) in enumerate(circle_mapper)
    if isa(cluster, Vector) && length(cluster) > 0
        println("  Interval $i: $(length(cluster)) points")
    end
end

# ## Geometric Analysis of Topological Features
#
# Let's analyze the geometric properties of our topological features:

function analyze_geometric_properties(space, epsilon)
    # Build nerve complex
    nerve = build_nerve_complex(space, epsilon)
    
    # Find largest connected component
    components = find_connected_components(nerve.edges, length(space))
    largest_component = maximum(components, key=length)
    
    # Analyze geometric properties of largest component
    component_points = space[largest_component]
    
    # Compute diameter (maximum distance between any two points)
    diameter = 0.0
    for i in 1:length(component_points)
        for j in (i+1):length(component_points)
            d = dist_euclidean(component_points[i], component_points[j])
            diameter = max(diameter, d)
        end
    end
    
    # Compute centroid and average distance to centroid
    centroid = [mean([p[d] for p in component_points]) for d in 1:length(component_points[1])]
    avg_radius = mean([dist_euclidean(p, centroid) for p in component_points])
    
    return (
        diameter = diameter,
        avg_radius = avg_radius,
        n_points = length(component_points),
        centroid = centroid
    )
end

function find_connected_components(edges, n_vertices)
    # Union-find to get all connected components
    parent = collect(1:n_vertices)
    
    function find_root(x)
        if parent[x] != x
            parent[x] = find_root(parent[x])
        end
        return parent[x]
    end
    
    function union!(x, y)
        root_x, root_y = find_root(x), find_root(y)
        if root_x != root_y
            parent[root_x] = root_y
        end
    end
    
    for (i, j) in edges
        union!(i, j)
    end
    
    # Group vertices by their root
    components = Dict()
    for i in 1:n_vertices
        root = find_root(i)
        if !haskey(components, root)
            components[root] = []
        end
        push!(components[root], i)
    end
    
    return collect(values(components))
end

# Analyze geometric properties at different scales
println("\nGeometric analysis of topological features:")
for ε in [1.0, 1.5, 2.0]
    props = analyze_geometric_properties(circle_data, ε)
    println("ε = $ε:")
    println("  Diameter: $(round(props.diameter, digits=2))")
    println("  Avg radius: $(round(props.avg_radius, digits=2))")
    println("  Points: $(props.n_points)")
end

# ## Multi-Scale Topological Analysis
#
# Combine multiple scales to get a complete topological picture:

function multiscale_topology(space, epsilon_range, sample_sizes)
    results = []
    
    for ε in epsilon_range
        for n_sample in sample_sizes
            # Sample the space
            if n_sample >= length(space)
                sample_indices = collect(1:length(space))
            else
                sample_indices = farthest_points_sample(space, n_sample)
            end
            
            sample_space = EuclideanSpace(space[sample_indices])
            
            # Analyze topology
            nerve = build_nerve_complex(sample_space, ε)
            n_components = count_connected_components(nerve.edges, length(sample_space))
            
            # Geometric properties
            props = analyze_geometric_properties(sample_space, ε)
            
            push!(results, (
                epsilon = ε,
                sample_size = n_sample,
                components = n_components,
                diameter = props.diameter,
                avg_radius = props.avg_radius
            ))
        end
    end
    
    return results
end

# Perform multi-scale analysis
multiscale_results = multiscale_topology(circle_data, [0.8, 1.2, 1.6], [50, 100, 150])

println("\nMulti-scale topological analysis:")
println("ε    | Sample Size | Components | Diameter | Avg Radius")
println("-" * 55)
for result in multiscale_results
    println("$(result.epsilon) | $(lpad(result.sample_size, 11)) | $(lpad(result.components, 10)) | $(lpad(round(result.diameter, digits=2), 8)) | $(lpad(round(result.avg_radius, digits=2), 10))")
end

# ## Applications in Shape Analysis
#
# Demonstrate practical applications of topological methods:

#md ### Real-World Applications
#md 
#md 1. **Medical Imaging**: Analyzing blood vessel networks, tumor shapes
#md 2. **Materials Science**: Characterizing porous materials, crystal structures
#md 3. **Biology**: Understanding protein folding, DNA structure
#md 4. **Social Networks**: Community detection, information flow
#md 5. **Computer Vision**: Shape recognition, feature detection

# Example: Detecting circular vs. linear structures
function topology_classifier(space, test_epsilon=1.5)
    nerve = build_nerve_complex(space, test_epsilon)
    n_components = count_connected_components(nerve.edges, length(space))
    
    # Simple heuristic: if we have one component and many edges relative to vertices,
    # it's likely a loop structure
    n_vertices = length(nerve.vertices)
    n_edges = length(nerve.edges)
    
    if n_components == 1
        edge_density = n_edges / n_vertices
        if edge_density > 1.2  # Threshold for "loop-like"
            return "Circular/Loop structure"
        else
            return "Linear/Tree structure"
        end
    else
        return "Multiple components ($n_components)"
    end
end

# Test classifier
circle_classification = topology_classifier(circle_data)
two_circles_classification = topology_classifier(two_circles_data)

println("\nTopological Classification:")
println("Circle data: $circle_classification")
println("Two circles data: $two_circles_classification")

# Create a linear structure for comparison
linear_points = [[i * 0.5, sin(i * 0.3) + 0.1 * randn()] for i in 1:100]
linear_space = EuclideanSpace(linear_points)
linear_classification = topology_classifier(linear_space)
println("Linear data: $linear_classification")

# ## Summary
#
# This tutorial demonstrated topological data analysis techniques using MetricSpaces.jl:
#
# 1. **Nerve complexes** for capturing topological structure
# 2. **Filtration analysis** for understanding feature persistence
# 3. **Mapper algorithm** for topological summaries  
# 4. **Geometric analysis** of topological features
# 5. **Multi-scale methods** for robust analysis
# 6. **Shape classification** using topological invariants
#
# These methods provide powerful tools for understanding the intrinsic geometry
# and topology of complex datasets, with applications across science and engineering.

#nb ### Interactive Exploration
#nb 
#nb Try experimenting with different parameters:
#nb - Change epsilon values to see how topology changes with scale
#nb - Modify noise levels in the generated datasets
#nb - Test with different geometric shapes (sphere, torus, etc.)

#src # Source-only tests
#src using Test
#src @test length(circle_data) > 200
#src @test length(two_circles_data) > 250
#src @test length(circle_nerves) == length(epsilon_values)
#src @test circle_classification == "Circular/Loop structure"
