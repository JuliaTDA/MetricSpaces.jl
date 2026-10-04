# Transformations and geodesic distances

## Preprocessing changes the geometry

Translation and centering preserve Euclidean distances. Multiplication by a scalar scales them by its absolute value. Standardization changes the relative weight of axes, while normalizing each observation changes both its length and interpoint distances.

```@example metric_transform
using MetricSpaces
X = EuclideanSpace([[1.0, 10.0], [2.0, 20.0], [3.0, 30.0]])
centered = center(X)
standardized = standardize(X)
shifted = translate_space(X, [5.0, -2.0])
scaled = scale(X, 2.0)
@assert dist_euclidean(X[1], X[2]) ≈ dist_euclidean(shifted[1], shifted[2])
@assert dist_euclidean(scaled[1], scaled[2]) ≈ 2dist_euclidean(X[1], X[2])
(; centered, standardized)
```

`standardize` centers each axis and uses its sample standard deviation; constant axes are only centered. Use floating coordinates and at least two observations. These operations return new clouds. Convert with `EuclideanSpace(result)` when a downstream method specifically requires that representation.

`normalize(x)` divides a coordinate vector by its Euclidean norm; `normalize(X)` normalizes every point. `normalize!` replaces the points in the cloud. A zero vector cannot be normalized by this formula. Per-point normalization is appropriate when direction matters; it removes magnitude information.

## Change ambient dimension

```@example metric_transform
padded = include_space(X, 2)  # append two zeros to every point
projected = embed(X, 5; seed=7)
@assert length(padded[1]) == 4
@assert length(projected[1]) == 5
(; padded_dimension=length(padded[1]), projected_dimension=length(projected[1]))
```

`include_space` preserves Euclidean distances exactly by appending zeros. `embed` applies a seeded Gaussian linear map into a **higher** dimension. It is useful for generating ambient-dimensional variants, but is not an isometry, does not normalize its random matrix, and does not reduce dimension.

## Distances along a neighbor graph

A curved cloud may contain points that are close in ambient coordinates but far along its sampled shape. `geodesic_distance` forms an undirected k-nearest-neighbor graph, weights edges by the selected distance, and computes all shortest paths.

```@example metric_geodesic
using MetricSpaces
X = EuclideanSpace([[0.0, 0.0], [1.0, 0.0], [1.0, 1.0], [0.0, 1.0]])
G = geodesic_distance(X; k=2)
@assert G[1, 3] ≈ 2.0
(; straight_line=dist_euclidean(X[1], X[3]), along_graph=G[1, 3])
```

Here the graph follows the four sides of a square, so opposite corners are distance 2 along its edges. This is an approximation from the observed sample, not an exact manifold geodesic.

Choose `k` large enough to connect the intended structure, but small enough to avoid shortcuts between nearby folds. Disconnected components produce `Inf`; inspect `all(isfinite, G)` before downstream use. The result is an `n × n` dense matrix, and all-pairs shortest paths can be expensive. For a singleton the diagonal is zero; use meaningful positive `k` on larger clouds.
