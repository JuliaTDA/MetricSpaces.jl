# # Sampling Example
#
# This example demonstrates how to use the sampling functions in `MetricSpaces.jl`.

using MetricSpaces

# Create a 3D metric space with 100 points
X = EuclideanSpace(rand(3, 100))

# Perform epsilon-net sampling
ϵ = 0.5
landmarks = epsilon_net(X, ϵ)
println("Epsilon-net landmarks: ", landmarks)

# Perform farthest points sampling
n = 10
sample = farthest_points_sample(X, n)
println("Farthest points sample: ", sample)

# Perform random sampling
random_sample = random_sample(X, 5)
println("Random sample: ", random_sample)