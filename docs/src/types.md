# Core Types

## Vectors are the underlying storage

`MetricSpace{T}` is an alias for `Vector{T}`. It does not store a metric, create a wrapper, or validate arbitrary objects. A normal Julia vector of words is already a metric space once you supply a distance.

`EuclideanSpace{N,T}` is a vector whose elements are `SVector{N,T}` from StaticArrays. The constructor converts coordinate vectors to this fixed-size representation. Coordinates of each point cannot be mutated in place; replace a point or transform the cloud instead.

```@example metric_types
using MetricSpaces
X = EuclideanSpace([[1.0, 2.0], [3.0, 4.0]])
@assert length(X) == 2
@assert size(as_matrix(X)) == (2, 2)
(; cloud_type=typeof(X), point_type=typeof(X[1]))
```

## Matrix orientation and conversions

`EuclideanSpace(A::Matrix)` reads **columns as points**. `as_matrix(X)` reverses this representation. The same convention is used by distance matrices and many JuliaTDA algorithms. Do not confuse a distance matrix (`n × n`) with a coordinate matrix (`d × n`).

Supply nonempty data with equal coordinate lengths. A constructor on an empty vector cannot infer a coordinate dimension. A vector of scalar values represents scalar objects; use `EuclideanSpace(reshape(values, 1, :))` when you need explicit one-dimensional coordinate vectors.

## Keep metadata aligned with indices

`SubsetIndex` and `CoveringIndices` describe lists of original observation indices. For `C = [[1, 2], [2, 3]]`, the second observation belongs to both subsets. If you reorder or filter `X`, update its labels and every cover that refers to it. Indices refer to rows of your original observation table, not to coordinate axes.

## Closed intervals

`Interval(a, b)` is a closed interval, so both endpoints belong to it. `is_not_disjoint` detects an intersection, including a shared endpoint. Mapper's interval covers therefore differ at their boundaries from MetricSpaces' open metric balls.

```@example metric_types
I = Interval(0.0, 1.0)
J = Interval(1.0, 2.0)
@assert 1.0 in I
@assert is_not_disjoint(I, J)
(; I, J)
```

The [API Reference](@ref) contains constructor signatures and the interval and covering aliases.
