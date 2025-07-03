# # Getting Started with MetricSpaces.jl
#
# This tutorial introduces the basic concepts and usage of MetricSpaces.jl,
# a powerful Julia package for working with metric spaces, distance functions,
# and geometric data analysis.
#
# ## What is a Metric Space?
#
# A metric space is a set equipped with a distance function (metric) that
# satisfies certain properties. MetricSpaces.jl provides tools to work with
# such spaces efficiently in Julia.

using MetricSpaces
using Plots
using Random
Random.seed!(42)

# ## Creating Your First Metric Space
#
# Let's start by creating a simple 2D Euclidean space with some random points:

# Generate random 2D points
n_points = 50
points_2d = [rand(2) * 10 for _ in 1:n_points]

# Create a metric space
space = EuclideanSpace(points_2d)

println("Created a metric space with $(length(space)) points")
println("First few points: $(space[1:3])")

# ## Visualizing Our Metric Space
#
# Let's visualize our points to better understand the structure:

# Extract x and y coordinates for plotting
x_coords = [point[1] for point in space]
y_coords = [point[2] for point in space]

# Create a scatter plot
p1 = scatter(x_coords, y_coords, 
    title="2D Metric Space", 
    xlabel="X", ylabel="Y",
    markersize=6, markercolor=:blue, markeralpha=0.7)

#nb display(p1)  # This line only appears in notebook output
#md ![2D Metric Space](example_space.png)  # This appears in markdown
#src println("Plot created - would display here")  # Source-only debugging line

# ## Computing Distances
#
# The core of any metric space is the distance function. Let's compute
# pairwise distances between points:

# Compute pairwise distances (this creates a distance matrix)
dist_matrix = pairwise_distance(space)

println("Distance matrix shape: $(size(dist_matrix))")
println("Sample distances from point 1:")
for i in 2:5
    d = dist_matrix[1, i]
    println("  Point 1 → Point $i: $(round(d, digits=3))")
end

# ## Working with Metric Balls
#
# A metric ball B(x, r) contains all points within distance r from point x.
# This is fundamental for many geometric algorithms:

# Choose a center point and radius
center_idx = 1
center_point = space[center_idx]
radius = 2.5

# Find all points in the ball using the center point
ball_indices = ball_ids(space, center_point, radius)
ball_points = space[ball_indices]

println("Center point: $center_point")
println("Radius: $radius")
println("Points in ball: $(length(ball_points))")

# ## Visualizing Metric Balls
#
# Let's visualize the metric ball on our scatter plot:

# Create visualization with the ball
p2 = scatter(x_coords, y_coords, 
    title="Metric Ball Visualization", 
    xlabel="X", ylabel="Y",
    markersize=4, markercolor=:lightblue, markeralpha=0.6,
    label="All points")

# Highlight points in the ball
ball_x = [space[i][1] for i in ball_indices]
ball_y = [space[i][2] for i in ball_indices]
scatter!(p2, ball_x, ball_y, 
    markersize=6, markercolor=:red, markeralpha=0.8,
    label="Points in ball")

# Mark the center
scatter!(p2, [center_point[1]], [center_point[2]], 
    markersize=8, markercolor=:black, markershape=:cross,
    label="Center")

# Draw the ball boundary
θ = 0:0.1:2π
circle_x = center_point[1] .+ radius * cos.(θ)
circle_y = center_point[2] .+ radius * sin.(θ)
plot!(p2, circle_x, circle_y, 
    linewidth=2, linecolor=:red, linestyle=:dash,
    label="Ball boundary")

#nb display(p2)
#md ![Metric Ball](metric_ball.png)

# ## Distance Functions
#
# MetricSpaces.jl supports various distance functions. Let's compare different metrics:

# Create a simple 2D point for demonstration
test_points = [
    [0.0, 0.0],
    [1.0, 1.0],
    [2.0, 0.0],
    [0.0, 2.0]
]
test_space = EuclideanSpace(test_points)

println("Comparing distance functions:")
println("Points: $test_points")
println()

# Point pairs to test
pairs = [(1, 2), (1, 3), (1, 4)]

for (i, j) in pairs
    p1, p2 = test_space[i], test_space[j]
    
    # Different distance functions
    euclidean_dist = dist_euclidean(p1, p2)
    manhattan_dist = dist_cityblock(p1, p2)
    chebyshev_dist = dist_chebyshev(p1, p2)
    
    println("Distance from $p1 to $p2:")
    println("  Euclidean: $(round(euclidean_dist, digits=3))")
    println("  Manhattan: $(round(manhattan_dist, digits=3))")
    println("  Chebyshev: $(round(chebyshev_dist, digits=3))")
    println()
end

# ## Sampling Techniques
#
# MetricSpaces.jl provides several sampling methods for geometric analysis:

# Generate a denser point cloud for sampling
dense_points = [rand(2) * 10 for _ in 1:200]
dense_space = EuclideanSpace(dense_points)

# Random sampling
random_subset = random_sample(dense_space, 20)

println("Original space: $(length(dense_space)) points")
println("Random sample: $(length(random_subset)) points")

# Farthest point sampling (gives well-distributed points)
farthest_indices = farthest_points_sample_ids(dense_space, 20)
farthest_subset = dense_space[farthest_indices]

println("Farthest point sample: $(length(farthest_subset)) points")

# ## Visualizing Sampling Results
#
# Let's compare the different sampling methods:

# Original points
all_x = [point[1] for point in dense_space]
all_y = [point[2] for point in dense_space]

# Random sample coordinates
rand_x = [point[1] for point in random_subset]
rand_y = [point[2] for point in random_subset]

# Farthest point sample coordinates  
far_x = [dense_space[i][1] for i in farthest_indices]
far_y = [dense_space[i][2] for i in farthest_indices]

# Create comparison plots
p3 = scatter(all_x, all_y, 
    title="Random Sampling", xlabel="X", ylabel="Y",
    markersize=2, markercolor=:lightgray, markeralpha=0.5,
    label="All points")
scatter!(p3, rand_x, rand_y,
    markersize=6, markercolor=:blue,
    label="Random sample")

p4 = scatter(all_x, all_y,
    title="Farthest Point Sampling", xlabel="X", ylabel="Y", 
    markersize=2, markercolor=:lightgray, markeralpha=0.5,
    label="All points")
scatter!(p4, far_x, far_y,
    markersize=6, markercolor=:red,
    label="Farthest points")

# Combine plots
sampling_plot = plot(p3, p4, layout=(1, 2), size=(800, 400))

#nb display(sampling_plot)
#md ![Sampling Comparison](sampling_comparison.png)
#src println("Sampling plots created - would display here")

# ## Neighborhood Analysis
#
# Finding k-nearest neighbors is a common operation in metric spaces:

# Find 5 nearest neighbors of the first point
query_point = dense_space[1]
k = 5
neighbors_ids = k_neighbors_ids(dense_space, query_point, k)
neighbors = dense_space[neighbors_ids]

println("$k nearest neighbors of point $query_point:")
for (i, neighbor_idx) in enumerate(neighbors_ids)
    neighbor_point = dense_space[neighbor_idx]
    distance = dist_euclidean(query_point, neighbor_point)
    println("  $i. Point $neighbor_idx: $neighbor_point (distance: $(round(distance, digits=3)))")
end

# ## Summary
#
# In this tutorial, we've covered the basics of MetricSpaces.jl:
#
# 1. **Creating metric spaces** from collections of points
# 2. **Computing distances** between points using various metrics
# 3. **Working with metric balls** to find nearby points
# 4. **Sampling techniques** for data reduction and analysis
# 5. **Neighborhood analysis** for finding closest points
#
# These tools form the foundation for more advanced geometric data analysis,
# including topological data analysis, clustering, and manifold learning.

#src # This is only in the source - let's add some tests
#src using Test
#src @test length(space) == n_points
#src @test size(dist_matrix) == (n_points, n_points)
#src @test length(ball_indices) > 0
