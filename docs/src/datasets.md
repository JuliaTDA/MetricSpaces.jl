# Datasets

Example shapes make it easier to understand what a method detects. Import generators from `MetricSpaces.Datasets`; `using MetricSpaces` alone does not export them into your namespace.

```@example metric_datasets
using MetricSpaces, Random
using MetricSpaces.Datasets
Random.seed!(12)
X = sphere(32; dim=2, radius=1.0)
Y = torus(32; R=3.0, r=1.0)
@assert length(X) == 32 && length(X[1]) == 2
@assert all(x -> isapprox(MetricSpaces.norm(x), 1.0), X)
(; circle_dimension=length(X[1]), torus_dimension=length(Y[1]))
```

All return point collections suitable for `EuclideanSpace` operations. Most use Julia's global RNG, so seed it before generating or adding noise. The requested `dim` is the **ambient coordinate count**: `sphere(; dim=2)` is a circle, and `dim=3` is a spherical surface in three coordinates.

## Geometric shapes

| Generator | Main keywords | Useful question |
|---|---|---|
| `sphere(n)` | `dim=2`, `radius=1` | Can the method distinguish a surface from filled space? |
| `torus(n)` | `r=1`, `R=3` | How do handles appear in a graph or filtration? |
| `grid(size)` | `dim=2` | What happens at a controlled spacing? Returns `size^dim` points. |
| `star(n)` | `n_arms=5`, `dim=2` | Can branches be resolved? |
| `swiss_roll(n)` | `noise=0` | Do neighbor edges shortcut folds? |
| `annulus(n)` | `r=0.5`, `R=1` | Can a hole survive nonuniform scale choices? |
| `ellipse(n)` | `a=1`, `b=0.5` | What changes when a circular shape is elongated? |
| `spiral(n)` | `n_turns=3` | How do density and curvature affect neighborhoods? |

The current `sphere` implementation normalizes vectors sampled in a centered cube. Points have the requested radius, but the directional distribution is **not uniform on the sphere**. `torus` samples its two angles uniformly, which is not uniform surface-area sampling. These are exploratory fixtures; do not assume a sampling distribution when using them to validate a statistical estimator.

Despite its name, the current `cube(n; dim, radius, noise)` also normalizes vectors using their Euclidean norm. Without noise, its output lies on a sphere, not throughout a cube or on a cube boundary. For points uniformly distributed inside a unit cube, use an explicit construction:

```@example metric_datasets
rng = MersenneTwister(12)
filled_cube = EuclideanSpace(rand(rng, 3, 20))
@assert all(p -> all(c -> 0 <= c <= 1, p), filled_cube)
length(filled_cube)
```

## Knots, linked objects, and surfaces

| Generator | Main keywords / ambient dimension |
|---|---|
| `trefoil_knot(n)` | `scale=1`; 3D |
| `linked_rings(n)` | `r=1`; two linked circles in 3D |
| `unlinked_rings(n)` | `r=1`, `separation=3`; 3D |
| `figure_eight(n)` | `r=1`; 2D |
| `klein_bottle(n)` | `a=1`; immersed in 3D |
| `mobius_strip(n)` | `R=1`, `w=0.5`; 3D |
| `clifford_torus(n)` | `r1=1`, `r2=1`; 4D |
| `projective_plane(n)` | `scale=1`; 4D embedding |
| `interlocked_tori(n)` | `R=2`, `r=0.6`; 3D |

Immersions can introduce geometric intersections that are absent from the abstract surface. Counts for composite generators are allocated between components; consult the API docstring for details. A sampled knot or linked pair cannot be identified by graph cycle count alone.

## Clusters and stochastic curves

`two_clusters(n; dim=2, separation=10)` and `three_clusters(n; dim=2)` create Gaussian groups. `linked_clusters(n_clusters; per_cluster=100, per_link=50, dim=2)` adds bridges. `long_gaussian(n; dim=2)` elongates a Gaussian cloud. `random_walk(n; dim=2)` and `orthogonal_curve(n)` create sequential curves.

```@example metric_datasets
clusters = two_clusters(40; dim=2, separation=4.0)
noisy_circle = add_noise(X, 0.03)
@assert length(noisy_circle) == length(X)
(; cluster_points=length(clusters), noisy_points=length(noisy_circle))
```

`add_noise(X, σ)` adds independent Gaussian coordinate noise and returns a new cloud. Noise changes distances, so a radius chosen for the clean shape may cease to cover the noisy one.

## Downloaded point clouds

`mammoth(; cache_dir=nothing)` and `stanford_bunny(; cache_dir=nothing)` download external point clouds and cache them. Their first call needs a network connection and a writable cache directory. They are excluded from the executable documentation examples so the basic guide builds offline. Use these once a synthetic example gives the behavior you expect.

## Make experiments interpretable

Record the generator, all its parameters, seed, preprocessing, and distance. Compare multiple seeds when conclusions depend on random sampling. For a controlled topology demonstration, a deterministic parametrized circle such as `EuclideanSpace([[cos(t), sin(t)] for t in range(0, 2π; length=65)[1:end-1]])` is often easier to interpret than a small random cloud.
