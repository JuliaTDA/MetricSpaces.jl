# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MetricSpaces.jl is a Julia package for working with metric spaces in Topological Data Analysis (TDA). It provides data structures and algorithms for metric space operations including distance computation, sampling, neighborhood queries, and nerve complex construction.

## Common Commands

```bash
# Run all tests
julia --project=. -e 'using Pkg; Pkg.test()'

# Run a single test file interactively
julia --project=. -e 'using MetricSpaces; using Test; using Graphs: nv, ne, has_edge; include("test/test_ball.jl")'

# Load package in REPL for development
julia --project=. -e 'using Revise; using MetricSpaces'

# Build documentation
julia --project=docs/ docs/make.jl
```

## Architecture

The package is split into two layers under `src/`:

**`base/`** - Core abstractions:
- `types.jl` - `MetricSpace{T}` (alias for `Vector{T}`) and `EuclideanSpace{N,T}` (uses `SVector` from StaticArrays). Also defines `SubsetIndex` and `CoveringIndices` for representing coverings.
- `real.jl` - `Interval{T}` type for closed intervals with `is_not_disjoint()` intersection check
- `distances.jl` - `pairwise_distance()` and `pairwise_distance_summary()`, parallelized via OhMyThreads
- `ball.jl` - `ball_ids()` / `ball()` for finding points within radius (strict inequality `d < epsilon`)
- `distance functions.jl` - Wrappers around Distances.jl: `dist_euclidean`, `dist_cityblock`, `dist_chebyshev`
- `norm.jl` - Euclidean norm and normalization utilities

**`extra/`** - Extended algorithms:
- `neighborhood.jl` - k-nearest neighbor queries (`k_neighbors_ids`, `k_neighbors`)
- `filters.jl` - `distance_to_measure()` and `eccentricity()` for geometric analysis
- `datasets.jl` - Synthetic data generators: `sphere()`, `torus()`, `cube()`
- `sampling.jl` - `epsilon_net()`, `farthest_points_sample()`, `random_sample()`
- `nerve.jl` - `nerve_1d()` constructs a 1D nerve graph from a covering using Graphs.jl

## Key Design Patterns

- Distance functions are passed as arguments (e.g., `dist_euclidean`) rather than being tied to types, allowing custom distance functions on any `MetricSpace`.
- `EuclideanSpace` is constructed from either a vector of vectors or a matrix (columns = points). Use `as_matrix()` to convert back.
- Heavy computations (`pairwise_distance`, `k_neighbors_ids`, `farthest_points_sample`) use `OhMyThreads.@tasks` with `DynamicScheduler` for multithreading.
- Tests are organized as one file per source module under `test/`, all included from `test/runtests.jl`.

## Dependencies

- **Distances.jl** - metric implementations
- **StaticArrays.jl** - `SVector` for efficient fixed-dimension points
- **OhMyThreads.jl** - parallel computation
- **Graphs.jl** - graph structure for nerve complexes
- **ProgressMeter.jl** - progress bars (optional in many functions via `show_progress` parameter)
