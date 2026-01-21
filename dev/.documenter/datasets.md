
# Datasets {#Datasets}

MetricSpaces.jl provides several built-in geometric datasets commonly used in topological data analysis and computational geometry research.

## Geometric Datasets {#Geometric-Datasets}

### Sphere {#Sphere}

Generate points on the surface of an n-dimensional sphere.

#### `sphere(n_points, dimension)` {#spheren_points,-dimension}

```julia
sphere(n_points::Int, dimension::Int)
```


**Parameters:**
- `n_points`: Number of points to generate
  
- `dimension`: Dimension of the sphere (2 for circle, 3 for standard sphere, etc.)
  

**Mathematical Background:** Points are generated on the unit sphere $S^{n-1} \subset \mathbb{R}^n$:

$$S^{n-1} = \{x \in \mathbb{R}^n : \|x\|_2 = 1\}$$

**Example:**

```julia
# Generate 100 points on a 2-sphere (surface of a ball in 3D)
sphere_points = sphere(100, 3)
S = EuclideanSpace(sphere_points)

println("Generated $(length(S)) points on a 2-sphere")
println("First point: $(S[1])")
println("Distance from origin: $(norm(S[1]))")  # Should be ≈ 1.0

# Verify points are on unit sphere
distances_from_origin = [norm(point) for point in S]
println("All points on unit sphere: ", all(abs.(distances_from_origin .- 1.0) .< 1e-10))
```


### Applications of Sphere Data {#Applications-of-Sphere-Data}

**Clustering on Spheres:**

```julia
# Spherical data often requires specialized clustering
function spherical_kmeans_demo(sphere_data, k=3)
    # Simple spherical k-means (not implemented in full here)
    # In practice, use specialized spherical clustering algorithms
    
    # For demonstration, use standard k-means on sphere data
    centers = sphere_data[randperm(length(sphere_data))[1:k]]
    
    println("Spherical clustering with $k centers:")
    for (i, center) in enumerate(centers)
        println("  Center $i: $(round.(center, digits=3))")
    end
    
    return centers
end

sphere_centers = spherical_kmeans_demo(sphere_points, 4)
```


### Torus {#Torus}

Generate points on the surface of a torus.

#### `torus(n_points)` {#torusn_points}

```julia
torus(n_points::Int)
```


**Mathematical Background:** A torus is parameterized by two angles $(θ, φ)$:

$$\begin{align}
x &= (R + r\cos φ) \cos θ \\
y &= (R + r\cos φ) \sin θ \\
z &= r \sin φ
\end{align}$$

where $R$ is the major radius and $r$ is the minor radius.

**Example:**

```julia
# Generate 200 points on a torus
torus_points = torus(200)
T = EuclideanSpace(torus_points)

println("Generated $(length(T)) points on a torus")
println("Sample points:")
for i in 1:3
    println("  Point $i: $(round.(T[i], digits=3))")
end

# Analyze torus structure
function analyze_torus_structure(torus_data)
    # Distance from z-axis (should reveal torus structure)
    xy_distances = [sqrt(point[1]^2 + point[2]^2) for point in torus_data]
    z_coordinates = [point[3] for point in torus_data]
    
    println("Torus analysis:")
    println("  XY distances - min: $(round(minimum(xy_distances), digits=3)), max: $(round(maximum(xy_distances), digits=3))")
    println("  Z coordinates - min: $(round(minimum(z_coordinates), digits=3)), max: $(round(maximum(z_coordinates), digits=3))")
    
    return xy_distances, z_coordinates
end

xy_dists, z_coords = analyze_torus_structure(torus_points)
```


### Applications of Torus Data {#Applications-of-Torus-Data}

**Persistent Homology:**

```julia
# Torus data is excellent for testing persistent homology algorithms
# The torus has known topology: H_0 = ℤ, H_1 = ℤ², H_2 = ℤ

function torus_homology_demo(torus_data)
    # Compute some basic topological features
    # (This would typically use a specialized TDA library)
    
    # For demonstration: analyze 1-dimensional holes using simple graph methods
    using Graphs
    
    # Build neighborhood graph
    g = SimpleGraph(length(torus_data))
    threshold = 0.5  # Connection threshold
    
    for i in 1:length(torus_data)
        for j in (i+1):length(torus_data)
            if dist_euclidean(torus_data[i], torus_data[j]) < threshold
                add_edge!(g, i, j)
            end
        end
    end
    
    components = connected_components(g)
    println("Graph analysis at threshold $threshold:")
    println("  Connected components: $(length(components))")
    println("  Edges: $(ne(g))")
    
    return g
end

torus_graph = torus_homology_demo(torus_points)
```


### Cube {#Cube}

Generate points uniformly distributed in an n-dimensional cube.

#### `cube(n_points, dimension)` {#cuben_points,-dimension}

```julia
cube(n_points::Int, dimension::Int)
```


**Mathematical Background:** Points are generated uniformly in the unit cube $[0,1]^n$:

$$\{x \in \mathbb{R}^n : 0 \leq x_i \leq 1 \text{ for all } i\}$$

**Example:**

```julia
# Generate 150 points in a 3D cube
cube_points = cube(150, 3)
C = EuclideanSpace(cube_points)

println("Generated $(length(C)) points in a 3D cube")

# Verify points are in unit cube
function verify_cube_bounds(cube_data, dimension)
    all_in_bounds = true
    for point in cube_data
        for coord in point
            if coord < 0 || coord > 1
                all_in_bounds = false
                break
            end
        end
        if !all_in_bounds
            break
        end
    end
    
    println("All points in unit cube: $all_in_bounds")
    return all_in_bounds
end

verify_cube_bounds(cube_points, 3)

# Analyze cube properties
function analyze_cube_distribution(cube_data)
    dimension = length(cube_data[1])
    
    println("Cube distribution analysis:")
    for dim in 1:dimension
        coords = [point[dim] for point in cube_data]
        println("  Dimension $dim: mean=$(round(mean(coords), digits=3)), std=$(round(std(coords), digits=3))")
    end
    
    # Check for uniform distribution (should be close to uniform)
    return [mean([point[dim] for point in cube_data]) for dim in 1:dimension]
end

means = analyze_cube_distribution(cube_points)
```


### Applications of Cube Data {#Applications-of-Cube-Data}

**Curse of Dimensionality Studies:**

```julia
function curse_of_dimensionality_demo(dimensions=[2, 5, 10, 20])
    println("Curse of dimensionality demonstration:")
    
    for dim in dimensions
        # Generate points in high-dimensional cube
        n_points = 1000
        points = cube(n_points, dim)
        
        # Compute pairwise distances
        distances = Float64[]
        for i in 1:min(100, n_points)  # Sample for efficiency
            for j in (i+1):min(100, n_points)
                push!(distances, dist_euclidean(points[i], points[j]))
            end
        end
        
        avg_dist = mean(distances)
        std_dist = std(distances)
        
        println("  Dimension $dim: avg_distance=$(round(avg_dist, digits=3)), std=$(round(std_dist, digits=3)), ratio=$(round(std_dist/avg_dist, digits=3))")
    end
end

curse_of_dimensionality_demo()
```


## Custom Dataset Generation {#Custom-Dataset-Generation}

### Noisy Geometric Datasets {#Noisy-Geometric-Datasets}

Add controlled noise to perfect geometric datasets:

```julia
function add_noise_to_dataset(dataset, noise_level=0.1)
    noisy_dataset = Vector{Vector{Float64}}()
    
    for point in dataset
        noisy_point = point .+ noise_level * randn(length(point))
        push!(noisy_dataset, noisy_point)
    end
    
    return noisy_dataset
end

# Create noisy versions of datasets
noisy_sphere = add_noise_to_dataset(sphere_points, 0.05)
noisy_torus = add_noise_to_dataset(torus_points, 0.1)
noisy_cube = add_noise_to_dataset(cube_points, 0.02)

println("Created noisy versions of datasets")
```


### Composite Datasets {#Composite-Datasets}

Combine multiple geometric objects:

```julia
function create_composite_dataset()
    # Create multiple geometric objects
    small_sphere = sphere(50, 3)
    small_torus = torus(75)
    small_cube = cube(60, 3)
    
    # Translate objects to different locations
    translated_sphere = [point .+ [3.0, 0.0, 0.0] for point in small_sphere]
    translated_torus = [point .+ [0.0, 3.0, 0.0] for point in small_torus]
    translated_cube = [point .+ [0.0, 0.0, 3.0] for point in small_cube]
    
    # Combine all datasets
    composite = vcat(translated_sphere, translated_torus, translated_cube)
    
    # Create labels for different components
    labels = vcat(
        fill(1, length(translated_sphere)),
        fill(2, length(translated_torus)),
        fill(3, length(translated_cube))
    )
    
    return EuclideanSpace(composite), labels
end

composite_data, component_labels = create_composite_dataset()
println("Created composite dataset with $(length(composite_data)) points")
println("Components: $(length(unique(component_labels)))")
```


### Fractal-like Datasets {#Fractal-like-Datasets}

Generate datasets with fractal-like properties:

```julia
function sierpinski_triangle_2d(n_points=1000, n_iterations=10)
    # Simple Sierpinski triangle using chaos game
    vertices = [[0.0, 0.0], [1.0, 0.0], [0.5, sqrt(3)/2]]
    
    # Start at random point
    current_point = [0.5, 0.25]
    points = Vector{Vector{Float64}}()
    
    for i in 1:n_points
        # Choose random vertex
        vertex = vertices[rand(1:3)]
        
        # Move halfway to chosen vertex
        current_point = 0.5 * (current_point + vertex)
        
        # Add point after some iterations to avoid initial transients
        if i > n_iterations
            push!(points, copy(current_point))
        end
    end
    
    return points
end

sierpinski_points = sierpinski_triangle_2d(2000)
SP = EuclideanSpace(sierpinski_points)
println("Generated Sierpinski triangle with $(length(SP)) points")
```


## Dataset Utilities {#Dataset-Utilities}

### Dataset Comparison {#Dataset-Comparison}

Compare properties of different datasets:

```julia
function compare_datasets(datasets, names)
    println("Dataset comparison:")
    println("Name\t\tPoints\tDim\tAvg_Dist\tStd_Dist\tDiameter")
    
    for (dataset, name) in zip(datasets, names)
        n_points = length(dataset)
        dimension = length(dataset[1])
        
        # Sample distances for efficiency
        sample_size = min(500, n_points * (n_points - 1) ÷ 2)
        distances = Float64[]
        
        for _ in 1:sample_size
            i, j = rand(1:n_points, 2)
            if i != j
                push!(distances, dist_euclidean(dataset[i], dataset[j]))
            end
        end
        
        avg_dist = mean(distances)
        std_dist = std(distances)
        diameter = maximum(distances)
        
        println("$name\t\t$n_points\t$dimension\t$(round(avg_dist, digits=3))\t$(round(std_dist, digits=3))\t$(round(diameter, digits=3))")
    end
end

# Compare our generated datasets
datasets = [sphere_points, torus_points, cube_points, sierpinski_points]
names = ["Sphere", "Torus", "Cube", "Sierpinski"]
compare_datasets(datasets, names)
```


### Dataset Visualization Helpers {#Dataset-Visualization-Helpers}

Generate data suitable for visualization:

```julia
function prepare_for_visualization(dataset, max_points=200)
    # Subsample if dataset is too large
    if length(dataset) > max_points
        indices = randperm(length(dataset))[1:max_points]
        dataset = dataset[indices]
    end
    
    # Extract coordinates for plotting
    if length(dataset[1]) >= 2
        x_coords = [point[1] for point in dataset]
        y_coords = [point[2] for point in dataset]
        
        if length(dataset[1]) >= 3
            z_coords = [point[3] for point in dataset]
            return x_coords, y_coords, z_coords
        else
            return x_coords, y_coords
        end
    end
    
    return nothing
end

# Prepare sphere data for visualization
sphere_viz = prepare_for_visualization(sphere_points, 150)
println("Prepared sphere data for visualization: $(length(sphere_viz)) coordinates")
```


## Real-World Dataset Integration {#Real-World-Dataset-Integration}

### Loading External Data {#Loading-External-Data}

```julia
function load_point_cloud_from_matrix(matrix_data)
    # Convert matrix (points as columns) to EuclideanSpace
    points = [matrix_data[:, i] for i in 1:size(matrix_data, 2)]
    return EuclideanSpace(points)
end

# Example: Create EuclideanSpace from random matrix
random_matrix = randn(4, 100)  # 4D points, 100 samples
external_data = load_point_cloud_from_matrix(random_matrix)
println("Loaded external data: $(length(external_data)) points in $(length(external_data[1]))D")
```


### Dataset Preprocessing {#Dataset-Preprocessing}

```julia
function preprocess_dataset(dataset; center=true, normalize=true, remove_duplicates=true)
    processed = copy(dataset)
    
    # Remove duplicates
    if remove_duplicates
        unique_points = Vector{Vector{Float64}}()
        seen = Set{Vector{Float64}}()
        
        for point in processed
            if !(point in seen)
                push!(unique_points, point)
                push!(seen, point)
            end
        end
        processed = unique_points
        println("Removed $(length(dataset) - length(processed)) duplicate points")
    end
    
    # Center data
    if center && length(processed) > 0
        centroid = mean(processed)
        processed = [point .- centroid for point in processed]
        println("Centered dataset at origin")
    end
    
    # Normalize to unit variance
    if normalize && length(processed) > 1
        # Compute overall standard deviation
        all_coords = vcat([point for point in processed]...)
        overall_std = std(all_coords)
        
        if overall_std > 1e-10
            processed = [point ./ overall_std for point in processed]
            println("Normalized dataset to unit variance")
        end
    end
    
    return EuclideanSpace(processed)
end

# Example preprocessing
raw_data = vcat(sphere_points, sphere_points[1:10])  # Add some duplicates
processed_data = preprocess_dataset(raw_data)
```


## Performance Benchmarks {#Performance-Benchmarks}

### Dataset Generation Performance {#Dataset-Generation-Performance}

```julia
using BenchmarkTools

function benchmark_dataset_generation()
    println("Dataset generation benchmarks:")
    
    # Sphere generation
    println("Sphere generation (1000 points, 3D):")
    @btime sphere(1000, 3)
    
    # Torus generation  
    println("Torus generation (1000 points):")
    @btime torus(1000)
    
    # Cube generation
    println("Cube generation (1000 points, 3D):")
    @btime cube(1000, 3)
end

benchmark_dataset_generation()
```

