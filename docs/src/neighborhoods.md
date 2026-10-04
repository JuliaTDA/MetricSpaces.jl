# Neighborhoods and filters

A scalar value per observation can summarize density, centrality, or distance to a reference sample. It can become a Mapper filter, an exploratory color, or a score to inspect. A large score does not by itself establish that an observation is erroneous.

## Nearest neighbors

```@example metric_neighbors
using MetricSpaces
X = EuclideanSpace(reshape([0.0, 0.1, 0.3, 3.0], 1, :))
ids = MetricSpaces.k_neighbors_ids(X, X[1], 3)
points = k_neighbors(X, X[1], 3)
@assert points == X[ids]
(; ids, points)
```

The count is positive and is capped at the reference collection's size. Self is included when it is present. Coincident observations have zero distance even when their indices differ; there is no automatic deduplication or leave-one-out mode. `k_neighbors_ids` is accessed with its module qualifier.

## Which filter answers which question?

| Function | Current definition | Higher values suggest |
|---|---|---|
| `distance_to_measure(X, Y; k, summary_function)` | Summary of nearest `k` distances in `Y` | Isolation from a reference sample |
| `eccentricity(X, Y)` or `eccentricity(X)` | Mean distance to `Y` or to `X` | Global peripherality |
| `knn_density(X; k)` | `k / r^d` with neighbor radius excluding self | Dense local sampling |
| `dtm_density(X; k)` | Reciprocal mean nearest distance, including self | Dense local sampling |
| `kde(X, Y; bandwidth)` | Mean kernel score at `Y`, from sample `X` | Similarity to many reference observations |

The density helpers are relative scores. `knn_density` omits the volume of a unit ball and sample-count normalization, and `kde` omits bandwidth/dimension normalization. Do not interpret their numbers as calibrated probability densities.

## Compare local isolation and global centrality

```@example metric_neighbors
radii = distance_to_measure(X, X; k=3)
rms = distance_to_measure(X, X; k=3,
    summary_function=ds -> sqrt(sum(abs2, ds) / length(ds)))
centrality = eccentricity(X)
(; radii, rms, centrality)
```

The default summary is `maximum`: the distance to the `k`th neighbor. Supply the RMS reducer for the common empirical DTM convention. `X` contains query points and `Y` contains reference points; the result always has `length(X)` values. In contrast, `kde(X, Y)` returns `length(Y)` scores. Keep this orientation explicit when using held-out query observations.

## Density scores

```@example metric_neighbors
local_density = knn_density(X; k=2)
reciprocal_distance = dtm_density(X; k=3)
kernel_score = kde(X; bandwidth=0.3)
(; local_density, reciprocal_distance, kernel_score)
```

`knn_density` needs at least two points and uses the ambient coordinate count as its exponent. On a lower-dimensional manifold in a large ambient space, this exponent need not describe intrinsic density. Choose `k` below the number of other observations. `dtm_density` with `k=1` on self-queries gives `Inf`; duplicate points can also produce infinite density scores. KDE's default bandwidth is the median second-neighbor radius, with a fallback of 1 for an approximately zero radius. Use an explicit positive bandwidth for comparisons across datasets.

## Choosing parameters and avoiding leakage

Small `k` responds to very local variation and duplicates; larger `k` smooths across neighboring structures. Small bandwidths emphasize narrow peaks; large bandwidths erase them. Compare a small set of candidate scales and inspect known observations, rather than selecting a graph only because it looks interesting.

For predictive use, fit preprocessing and choose bandwidths on training data. Evaluate held-out queries against the training reference cloud. Otherwise the query set influences its own geometry. These helpers perform no automatic split, imputation, or normalization.
