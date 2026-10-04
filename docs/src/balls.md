# Metric Balls

A ball answers a radius question: which observations are less than `ε` away from this query? The number of returned observations can vary widely in a nonuniform cloud.

```@example metric_balls
using MetricSpaces
X = EuclideanSpace(reshape([0.0, 1.0, 2.0, 4.0], 1, :))
ids = ball_ids(X, X[2], 1.0)
@assert ids == [2]  # Points at 0 and 2 are on the boundary.
points = ball(X, X[2], 1.1)
@assert points == X[[1, 2, 3]]
(; ids, points)
```

`ball_ids` returns original indices; `ball` returns observations. The radius must be positive. A center can be outside the dataset, but its concrete point type must match the cloud's element type. For an `EuclideanSpace`, constructing queries with the same fixed-size type avoids dispatch errors:

```@example metric_balls
query = typeof(X[1])([1.5])
ball_ids(X, query, 0.6)
```

## Changing the geometry changes the ball

```@example metric_ball_metrics
using MetricSpaces
X = EuclideanSpace([[0.0, 0.0], [0.8, 0.8], [0.5, 0.0]])
(; euclidean=ball_ids(X, X[1], 1.2),
   manhattan=ball_ids(X, X[1], 1.2, dist_cityblock),
   maximum_axis=ball_ids(X, X[1], 1.2, dist_chebyshev))
```

The radius has the units of the selected distance. Reusing a numeric radius after standardization or a distance change does not preserve the neighborhood.

## Constructing a cover

```@example metric_balls
L = epsilon_net(X, 1.1)
C = [ball_ids(X, X[l], 1.1) for l in L]
@assert Set(vcat(C...)) == Set(eachindex(X))
C
```

A manually selected landmark set need not cover all observations. Always inspect `setdiff(eachindex(X), unique(vcat(C...)))` when coverage matters. See [Nerves of covers](@ref) for a graph of the overlaps.

## Balls versus nearest neighbors

Balls fix the radius and let the count vary. Nearest-neighbor queries fix a maximum count and let the radius vary. Use balls when a distance scale has meaning; use nearest neighbors when you need a local scale adapted to observation density. Both include self in a self-query.
