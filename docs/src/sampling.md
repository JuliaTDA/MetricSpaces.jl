# Sampling Methods

Landmarks reduce the number of observations you carry into expensive downstream computations. Choose between controlling a radius, a count, or a sampling distribution.

| Operation | Returns | Controls |
|---|---|---|
| `epsilon_net(X, ε; d=...)` | Original indices | Open-ball covering radius |
| `farthest_points_sample_ids(X, n; d=...)` | Original indices | Greedy sample count |
| `farthest_points_sample(X, n; d=...)` | Points | Same greedy sample |
| `random_sample(X, n)` | Points | Count without replacement (capped at cloud size) |

## Cover a cloud with an ε-net

```@example metric_sampling
using MetricSpaces, Random
X = EuclideanSpace(reshape(collect(0.0:0.25:2.0), 1, :))
L = epsilon_net(X, 0.6)
cover = [ball_ids(X, X[i], 0.6) for i in L]
@assert Set(vcat(cover...)) == Set(eachindex(X))
(; landmark_indices=L, landmark_points=X[L], cover)
```

The algorithm starts with the first uncovered point, marks its open ball covered, and repeats in observation order. The radius must be positive. Every observation is covered, but this is not a minimum-cardinality cover. Reordering observations can change the landmarks. Because boundary points at exactly `ε` remain uncovered, a separation equal to `ε` can produce another landmark.

## Select a fixed number of spread-out points

```@example metric_sampling
Random.seed!(19)
ids = farthest_points_sample_ids(X, 3)
Random.seed!(19)
points = farthest_points_sample(X, 3)
@assert points == X[ids]
coverage_radius = maximum(minimum(dist_euclidean(x, X[i]) for i in ids) for x in X)
(; ids, coverage_radius)
```

Farthest-point sampling chooses its first point randomly and repeatedly maximizes distance to the selected set. Set the global RNG seed for reproducibility. A nonpositive count returns an empty sample; a count larger than the cloud returns all original indices. Ties and repeated coordinates mean that distinct indices need not represent distinct geometric locations.

A fixed count alone does not guarantee a cover at your intended radius. The maximum nearest-landmark distance above quantifies the uncovered scale. Choose a strictly larger open-ball radius if you build a cover from this sample.

## Random sampling and metadata

```@example metric_random
using MetricSpaces, Random
X = EuclideanSpace(reshape(collect(1.0:8.0), 1, :))
Random.seed!(21)
points = random_sample(X, 3)
# Choose indices explicitly when you also need labels.
rng = MersenneTwister(21)
ids = randperm(rng, length(X))[1:3]
(; points, indices_for_metadata=ids)
```

Random sampling uses the global RNG. Set a seed for repeatable experiments, or select indices with your own RNG as shown. It does not intentionally preserve rare components or cover the space. A count larger than the cloud is capped at the cloud size.

## Picking a scale

Start from the distribution of nearest-neighbor distances, then try several radii around a scale meaningful for your data. Record landmark count and achieved coverage. An ε-net can select almost every point if the radius is tiny; a very large radius can compress distant structures together.

The greedy routines maintain nearest-distance or coverage state instead of a full distance matrix, but still need repeated distance evaluations. `show_progress=true` is available for ε-nets and farthest-point sampling. Compare landmark choices with the same distance that downstream algorithms use.
