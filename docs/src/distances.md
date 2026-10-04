# Distance Functions

## Choose the meaning of proximity

| Callable | Interpretation | Appropriate data |
|---|---|---|
| `dist_euclidean(x, y)` | Euclidean distance | Continuous coordinates with comparable units |
| `dist_cityblock(x, y)` | Sum of absolute coordinate differences | Additive coordinate deviations |
| `dist_chebyshev(x, y)` | Largest absolute coordinate difference | Maximum deviation across axes |
| `dist_minkowski(p)(x, y)` | Minkowski distance with exponent `p` | Coordinates; `p ≥ 1` gives a metric |
| `dist_hamming(x, y)` | Number of unequal entries | Equal-length categorical sequences |
| `dist_cosine(x, y)` | Cosine dissimilarity | Nonzero vectors where direction matters |
| `dist_correlation(x, y)` | Correlation dissimilarity | Nonconstant profiles where centered shape matters |

These wrap Distances.jl. The package leaves domain restrictions to the distance implementation. Zero vectors or constant profiles can make angular/correlation comparisons undefined. Do not supply them blindly to an algorithm requiring finite distances.

## Pairwise comparisons

```@example metric_distances
using MetricSpaces
X = EuclideanSpace([[0.0, 0.0], [3.0, 4.0], [6.0, 0.0]])
Y = X[[1, 3]]
D = pairwise_distance(X, Y, dist_euclidean)
@assert size(D) == (3, 2)
@assert D[2, 1] == 5.0
means = pairwise_distance_summary(X, Y, dist_euclidean)
maxima = pairwise_distance_summary(X, Y, dist_euclidean, maximum)
(; D, means, maxima)
```

Both collections must have compatible concrete vector types. Rows refer to the first argument; columns refer to the second. The result of `pairwise_distance` is a dense `Float64` matrix. A `Distances.Metric` object, such as `Distances.Euclidean()`, can also be used for Euclidean clouds.

`pairwise_distance_summary` produces one value per point in the first cloud. Its default is the mean; pass another reducer as the fourth positional argument. If you only need summaries, avoid allocating the full matrix.

## A custom metric on objects

```@example metric_strings
using MetricSpaces
words = ["cat", "bat", "dog"]
hamming3(a, b) = count(t -> t[1] != t[2], zip(a, b))
D = pairwise_distance(words, words, hamming3)
nearby = ball_ids(words, words[1], 2, hamming3)
(; D, nearby)
```

This example uses equal-length strings and counts character substitutions. The same function must be used consistently in ball queries, sampling, and distance summaries if you want them to describe the same geometry.

## Cost and threading

Comparing `m` with `n` observations needs `m × n` distance evaluations. A square `Float64` matrix for 10,000 observations occupies about 800 MB before temporary allocations. Use summaries or a smaller landmark cloud when the full matrix is unnecessary.

Julia starts with a configurable thread count (`julia --threads=auto`). The current implementation distributes supported distance/neighbor workloads through Julia threads. Callbacks must be safe to call concurrently. `show_progress=true` is an explicit option for pairwise operations; progress bars are disabled by default.
