```@meta
EditURL = "../src/examples/sampling_example.jl"
```

# Sampling Example

This example demonstrates how to use the sampling functions in `MetricSpaces.jl`.

````@example sampling_example
using MetricSpaces
````

Create a 3D metric space with 100 points

````@example sampling_example
X = EuclideanSpace(rand(3, 100))
````

Perform epsilon-net sampling

````@example sampling_example
ϵ = 0.5
landmarks = epsilon_net(X, ϵ)
println("Epsilon-net landmarks: ", landmarks)
````

Perform farthest points sampling

````@example sampling_example
n = 10
sample = farthest_points_sample(X, n)
println("Farthest points sample: ", sample)
````

Perform random sampling

````@example sampling_example
random_sample = random_sample(X, 5)
println("Random sample: ", random_sample)
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

