# Troubleshooting and performance

| Symptom | Likely cause and action |
|---|---|
| `Pkg.add("MetricSpaces")` cannot resolve | Use a source checkout with `Pkg.develop(path=...)` or the repository URL; see [Getting Started](@ref). |
| `sphere` or `torus` is undefined | Import `MetricSpaces.Datasets` or individual generators from it. |
| `pairwise_distance(X)` has no method | Pass both clouds and a distance: `pairwise_distance(X, X, dist_euclidean)`. |
| A matrix becomes a cloud with the wrong number of points | Matrices use columns as observations; transpose row-oriented data. |
| A query vector has a dispatch error | Match the query to the cloud's element type; use `typeof(X[1])(coordinates)` for fixed-size points. |
| `X[random_sample(X, n)]` fails | `random_sample` returns points. Select indices explicitly with `randperm` when needed. |
| A density score is `Inf` | Self-neighbors or duplicates give zero radius. Increase `k` and inspect duplicates. |
| Geodesic distances are `Inf` | The k-neighbor graph is disconnected. Inspect components and assess whether a larger `k` is appropriate. |
| Radius changes appear ineffective | Distances, standardization, and open versus closed boundaries can change expectations; inspect individual distances. |
| Memory grows rapidly | Dense pairwise/geodesic matrices need quadratic memory; use summaries or landmarks when possible. |

## Threaded execution

Start Julia with `--threads=auto` to enable parallel work. The distance callable can run concurrently; avoid callbacks that mutate shared state. Threading does not change the quadratic number of comparisons, and tiny examples can be faster on one thread. Time repeated runs after compilation before attributing startup cost to an algorithm.

## Reproduce a result

Keep the project and manifest, Julia version, observation ordering, distance definition, and RNG seed. An ε-net depends on input order; farthest-point sampling depends on random initialization and tie order. Index covers always refer to the cloud used to create them; rebuild covers after filtering or reordering data.

## Build this documentation locally

From the package directory, prepare its documentation environment:

```sh
julia docs/setup.jl
julia --project=docs docs/make.jl
```

Then run `julia --project=docs docs/make.jl` from a terminal. The setup script resolves source paths relative to its own location and refreshes a stale docs manifest. The Documenter examples use small local datasets. The configured VitePress renderer also needs its Node/npm build dependencies. Deployment is handled by repository CI; a local build does not need publishing credentials.
