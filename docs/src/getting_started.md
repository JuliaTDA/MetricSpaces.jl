# Getting Started

To use `MetricSpaces.jl`, add it to your project:

```julia
using Pkg
Pkg.add("MetricSpaces")
```

## Example: Creating a Metric Space

```
using MetricSpaces

X = rand(3, 10)  # 10 points in 3D space
M = EuclideanSpace(X)

println("Number of points: ", length(M))
println("First point: ", M[1])
```

For more examples, see the Examples section.

