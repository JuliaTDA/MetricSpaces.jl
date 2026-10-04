# MetricSpaces.jl

MetricSpaces provides the geometry layer of JuliaTDA: represent observations, choose a distance, ask which observations are nearby, and build small summaries that retain their relationships. It also provides Euler characteristic transforms and binary-image filtrations.

A point can be a numerical coordinate vector or an object such as a string. The distance is passed to an operation; it is not stored in the point cloud. This makes it easy to compare the same observations using different geometries.

## A small cloud, three useful questions

```@example metric_home
using MetricSpaces
X = EuclideanSpace([[0.0, 0.0], [0.2, 0.0], [0.4, 0.0], [3.0, 0.0]])
nearby = ball_ids(X, X[1], 0.3)
landmarks = epsilon_net(X, 0.5)
outlier_scores = distance_to_measure(X, X; k=3)
(; nearby, landmarks, outlier_scores)
```

The first query finds a local neighborhood. The second returns indices of landmarks whose open balls cover the cloud. The third assigns large values to observations far from their nearest neighbors. These are building blocks for Mapper, clustering, and exploratory analysis; the package does not decide which geometry is scientifically appropriate for your data.

## Where to begin

| Your goal | Start here |
|---|---|
| Install the package and learn the data layout | [Getting Started](@ref) |
| Understand the mathematical conventions | [Mathematical Background](@ref) |
| Query neighbors or score unusual observations | [Neighborhoods and filters](@ref) |
| Select representative observations | [Sampling Methods](@ref) |
| Preprocess coordinates or follow a curved manifold | [Transformations and geodesic distances](@ref) |
| Connect overlapping subsets | [Nerves of covers](@ref) |
| Create example shapes | [Datasets](@ref) |
| Analyze binary images or Euler transforms | [Euler transforms and image filtrations](@ref) |

The [API Reference](@ref) collects docstrings. Each guide supplies context, examples, and limits that a signature alone cannot communicate.
