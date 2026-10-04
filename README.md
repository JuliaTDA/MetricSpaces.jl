# MetricSpaces.jl

[![Build Status](https://github.com/JuliaTDA/MetricSpaces.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/JuliaTDA/MetricSpaces.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Documentation](https://img.shields.io/badge/docs-stable-blue.svg)](https://juliatda.github.io/MetricSpaces.jl/)

Geometry, neighborhoods, landmark sampling, Euler transforms, and binary-image filtrations for Topological Data Analysis in Julia.

## Installation

Use sibling source checkouts; these packages may not resolve through the General registry. From their parent directory:

```julia
using Pkg
Pkg.activate("tda-tutorial")
Pkg.develop(path="MetricSpaces.jl")
Pkg.instantiate()
```

See the getting-started guide for repository-URL installation and version requirements.

## A first example

```julia
using MetricSpaces
X = EuclideanSpace([[0.0, 0.0], [0.2, 0.0], [0.4, 0.0], [3.0, 0.0]])
nearby = ball_ids(X, X[1], 0.3)                 # [1, 2]
landmarks = epsilon_net(X, 0.5)                 # original point indices
distances = pairwise_distance(X, X, dist_euclidean)
isolation = distance_to_measure(X, X; k=3)     # one score per point
```

Matrix columns are observations. `ball_ids` uses strict distance `< radius`. `epsilon_net` and `farthest_points_sample_ids` return indices, while `farthest_points_sample` and `random_sample` return points. Dataset generators require `using MetricSpaces.Datasets`; see the dataset guide for their sampling conventions.

## Guides and reference

- [Getting started](docs/src/getting_started.md): installation, data layout, and a complete first workflow.
- [Distances](docs/src/distances.md), [neighborhoods and filters](docs/src/neighborhoods.md), and [sampling](docs/src/sampling.md): geometric choices and return conventions.
- [Transformations and geodesics](docs/src/transformations.md) and [nerves](docs/src/nerves.md): preprocessing and overlap summaries.
- [Datasets](docs/src/datasets.md): generator catalogue and actual sampling conventions.
- [Euler transforms and image filtrations](docs/src/euler_images.md): executable cubical/simplicial and binary-image examples.
- [Troubleshooting](docs/src/troubleshooting.md) and [API reference](docs/src/api.md).

The [documentation site](https://juliatda.github.io/MetricSpaces.jl/) renders these guides. The source Markdown links above also work in a checkout.

## Development

Use `julia --project=. -e 'using Pkg; Pkg.test()'` for package tests. The troubleshooting/parameter guide explains how to prepare the docs environment and build it locally. Documentation builds do not publish unless CI or `JULIATDA_DOCS_DEPLOY=true` enables deployment.

Contributions, reproducible bug reports, and example improvements are welcome. License: MIT.
