# API Reference

The guides explain conventions and show executable examples. This page collects public docstrings by task. Distance wrapper names and normalization helpers are explained in [Distance Functions](@ref) and [Transformations and geodesic distances](@ref).

## Core types and intervals

```@autodocs
Modules = [MetricSpaces]
Order = [:type, :constant, :function]
Pages = ["types.jl", "real.jl"]
Public = true
Private = false
```

## Distance matrices and norms

```@autodocs
Modules = [MetricSpaces]
Order = [:type, :constant, :function]
Pages = ["distances.jl", "norm.jl"]
Public = true
Private = false
```

## Balls and nearest neighbors

```@autodocs
Modules = [MetricSpaces]
Order = [:type, :constant, :function]
Pages = ["ball.jl", "neighborhood.jl"]
Public = true
Private = false
```

The index-returning helper is available with its module qualifier:

```@docs
MetricSpaces.k_neighbors_ids
```

## Filters and density scores

```@autodocs
Modules = [MetricSpaces]
Order = [:type, :constant, :function]
Pages = ["filters.jl"]
Public = true
Private = false
```

## Landmark and random sampling

```@autodocs
Modules = [MetricSpaces]
Order = [:type, :constant, :function]
Pages = ["sampling.jl"]
Public = true
Private = false
```

## Coordinate transformations

```@autodocs
Modules = [MetricSpaces]
Order = [:type, :constant, :function]
Pages = ["transformations.jl"]
Public = true
Private = false
```

## Geodesic distances

```@autodocs
Modules = [MetricSpaces]
Order = [:type, :constant, :function]
Pages = ["geodesic.jl"]
Public = true
Private = false
```

## Cover nerves

```@autodocs
Modules = [MetricSpaces]
Order = [:type, :constant, :function]
Pages = ["nerve.jl"]
Public = true
Private = false
```

## Binary-image filtrations

```@autodocs
Modules = [MetricSpaces]
Order = [:type, :constant, :function]
Pages = ["images.jl"]
Public = true
Private = false
```

## Euler curves and transforms

```@autodocs
Modules = [MetricSpaces]
Order = [:type, :constant, :function]
Pages = ["euler.jl"]
Public = true
Private = false
```

## Dataset generators

```@autodocs
Modules = [MetricSpaces.Datasets]
Order = [:function]
Public = true
Private = false
```
