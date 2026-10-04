# Getting Started

## Install a source checkout

The packages are developed together and may not be available in the General registry. Use a source checkout so the examples run against the version you are reading. From the directory containing `MetricSpaces.jl`, start Julia and run:

```julia
using Pkg
Pkg.activate("metric-tutorial"; shared=false)
Pkg.develop(path="MetricSpaces.jl")
Pkg.instantiate()
```

For a standalone environment, `Pkg.add(url="https://github.com/JuliaTDA/MetricSpaces.jl")` installs the repository version. The package supports Julia 1.8 and later; optional package extensions require Julia 1.9 or later. Keep the project's `Manifest.toml` if you need the same dependency versions later.

## One observation per vector, one observation per matrix column

Suppose four observations have two coordinates:

```@example metric_intro
using MetricSpaces, Random
X = EuclideanSpace([[0.0, 0.0], [1.0, 0.0], [1.0, 1.0], [4.0, 1.0]])
A = as_matrix(X)
@assert size(A) == (2, 4)
@assert EuclideanSpace(A) == X
(; first_point=X[1], dimensions=size(A))
```

`X[i]` is observation `i`. `A[:, i]` is the same observation in matrix form. If your table has observations in rows, use `EuclideanSpace(Matrix(permutedims(table_matrix)))`. Construct a nonempty collection with equal coordinate lengths. See [Core Types](@ref) for the underlying vector aliases.

## Distances and neighborhoods

```@example metric_intro
D = pairwise_distance(X, X, dist_euclidean)
ids = ball_ids(X, X[1], 1.1)
points = ball(X, X[1], 1.1)
nearest_ids = MetricSpaces.k_neighbors_ids(X, X[1], 2)
@assert points == X[ids]
(; distances_from_first=D[1, :], ids, nearest_ids)
```

`D[i, j]` compares `X[i]` with `X[j]`. Balls use **strict** inequality: a point exactly at the radius is excluded. Nearest-neighbor queries include the query point when it belongs to `X`, so the first neighbor here is the point itself. `k_neighbors` returns points; the qualified `MetricSpaces.k_neighbors_ids` returns indices.

## Landmarks and a cover

```@example metric_intro
landmark_ids = epsilon_net(X, 1.1)
cover = [ball_ids(X, X[i], 1.1) for i in landmark_ids]
@assert sort(unique(vcat(cover...))) == collect(eachindex(X))
Random.seed!(19)
fps_ids = farthest_points_sample_ids(X, 2)
sampled_points = X[fps_ids]
@assert length(sampled_points) == 2
(; landmark_ids, cover, fps_ids)
```

Indices let you retain labels and measurements associated with each observation. `epsilon_net` chooses enough landmarks for a radius; farthest-point sampling chooses a requested number. `random_sample` returns sampled **points**, not indices. See [Sampling Methods](@ref) for their different guarantees.

## A scalar filter for each observation

```@example metric_intro
scores = distance_to_measure(X, X; k=3)
centrality = eccentricity(X)
@assert length(scores) == length(X)
(; scores, most_central=argmin(centrality))
```

The default score is the maximum of the nearest `k` distances, including self when the reference cloud is `X`. It is a nearest-neighbor radius, not the classical root-mean-square DTM unless you supply that summary yourself. Eccentricity here is the **mean** distance to the reference cloud. Both produce useful Mapper filters; their values have the units of your chosen distance.

## Generate a shape

Dataset generators live in a separate module:

```@example metric_shapes
using MetricSpaces, Random
using MetricSpaces.Datasets: sphere, torus
Random.seed!(17)
circle = sphere(40; dim=2)
donut = torus(40; R=3.0, r=1.0)
(; circle_points=length(circle), torus_dimension=length(donut[1]))
```

`dim=2` means coordinates in two dimensions: the unit circle is the sphere $S^1$. See [Datasets](@ref) for the sampling conventions and the full catalogue.

## Continue the analysis

Use [Neighborhoods and filters](@ref) to study density, [Nerves of covers](@ref) to summarize overlaps, or [Euler transforms and image filtrations](@ref) for images. For Mapper graphs, load TDAmapper; for persistent homology, use JuliaTDA's persistence packages. MetricSpaces supplies their geometric input.
