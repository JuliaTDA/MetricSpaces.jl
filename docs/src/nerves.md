# Nerves of covers

A cover is a list of index subsets. Its nerve describes how those subsets overlap. The graph has one vertex per subset, including a vertex for an empty subset if one is supplied; edges represent an intersection condition.

```@example metric_nerve
using MetricSpaces
using Graphs: nv, ne
C = [[1, 2], [2, 3], [1, 3]]
g = nerve_1d(C)
K = nerve_2d(C)
@assert nv(g) == 3 && ne(g) == 3
@assert isempty(K.triangles)
(; edges=ne(g), triangles=K.triangles)
```

Every pair overlaps, but all three subsets have no common member. Therefore the graph contains a cycle while the full nerve has no filled triangle. This distinction matters if you use a cover to build a simplicial shape.

## Require stronger overlap

```@example metric_nerve
C = [[1, 2, 3], [2, 3, 4], [3, 4, 5]]
(; any_overlap=ne(nerve_1d(C)),
   two_members=ne(nerve_1d(C, min_intersection(2))),
   mutual_half=ne(nerve_1d(C, percentage_intersection(0.5; mode=:and))),
   jaccard=ne(nerve_1d(C, jaccard_threshold(0.4))))
```

`min_intersection(n)` requires at least `n` shared observations. `percentage_intersection(p; mode=:or)` requires that the overlap fraction exceed `p` for either subset; `mode=:and` requires both. `jaccard_threshold(t)` divides shared count by union count. Use nonnegative count thresholds and fractions in `[0, 1]`.

Custom edge predicates receive two subsets, so you can use `nerve_1d(C, (a, b) -> ...)` for application-specific overlap. Represent each subset without duplicate indices: count-based predicates assume set-like membership and duplicates can inflate scores.

## True triple intersections

```@example metric_nerve
filled = nerve_2d([[1, 2, 3], [2, 3, 4], [3, 4, 5]])
@assert filled.triangles == [(1, 2, 3)]
filled.triangles
```

`nerve_2d` returns `(graph, triangles)`. Triangle entries are triples of **cover-element indices**, not original point indices. It applies the ordinary nonempty intersection rule, not the stricter edge predicates above. Pairwise construction compares cover pairs; triangle construction adds triple checks. Large, highly overlapping covers can grow rapidly.

For complete Mapper pipelines, including refinement of cover elements and higher-dimensional simplicial nerves, use TDAmapper's [package documentation](https://juliatda.github.io/TDAmapper.jl/).
