# Mathematical Background

## Geometry begins with a choice of distance

A metric is a function $d:X\times X\to\mathbb{R}_{\geq0}$ satisfying identity, symmetry, and the triangle inequality. Coordinate data often uses Euclidean distance,

```math
d_2(x,y)=\sqrt{\sum_i(x_i-y_i)^2},
```

but Manhattan and Chebyshev distances describe different notions of proximity. Changing units on one axis changes all three. Choosing and scaling features is therefore part of the model, not just a computational detail.

The package does not check the metric axioms for arbitrary callables. Cosine and correlation dissimilarities are also available, although their mathematical properties and zero-vector behavior differ from a metric. Use a distance compatible with the operation you are applying.

## Open balls, neighbors, and finite covers

`ball_ids(X, x, ε)` represents $B_X(x,\varepsilon)=\{y\in X:d(x,y)<\varepsilon\}$. Its members are **observed points**, rather than all points of an ambient space. A covering is a list of index subsets; a point may occur in more than one subset.

`epsilon_net` greedily selects uncovered points and covers their open balls. Every observation is eventually covered. Selected centers are separated by at least the radius, but the number of centers depends on observation order. Farthest-point sampling instead adds the point maximizing its minimum distance to existing centers; a fixed count does not promise coverage at a given radius.

Nearest-neighbor queries in MetricSpaces include self when the query belongs to the reference collection. For self-queries, `k=1` can therefore give a zero score. Some higher-level density helpers explicitly compensate for this; read their conventions before comparing them.

## Distance-to-measure conventions

For an empirical reference collection with sorted nearest distances $r_1(x),\ldots,r_k(x)$, a common DTM is

```math
\left(\frac1k\sum_{j=1}^k r_j(x)^2\right)^{1/2}.
```

`distance_to_measure` is a general nearest-distance summary. Its default is $r_k(x)$, and `summary_function` selects alternatives, including the RMS above. The interface uses a neighbor count `k`; it does not take a probability mass parameter. Counts larger than the reference size are truncated.

Mean eccentricity averages distances to a reference cloud. It measures global centrality, while nearest-neighbor summaries emphasize local density. A distant but densely sampled component may have high eccentricity and low nearest-neighbor distance at the same time.

## Nerves and graph cycles

The nerve of a cover has a simplex whenever the corresponding subsets share a common member. Its graph records pairwise intersections. A triangle in that graph need not have a common member in all three subsets. `nerve_2d` tests triple intersections explicitly.

Ball-cover nerves and Vietoris–Rips complexes are different constructions: a Rips simplex tests pairwise distances, while a cover nerve tests common intersection. A loop in a graph summary alone is not a proof of a loop in an underlying sampled space. Nerve-theorem conclusions require additional hypotheses on the cover and the space.

## Euler characteristic

For a finite cell complex, $\chi=\sum_k(-1)^k n_k$, where $n_k$ counts cells of dimension $k$. In a planar shape, this is components minus holes. Euler curves evaluate $\chi$ throughout a filtration; an Euler transform repeats this in several directions. These summaries combine homological dimensions, so different shapes may share an Euler curve. See [Euler transforms and image filtrations](@ref) for the cell convention and comparison requirements.
