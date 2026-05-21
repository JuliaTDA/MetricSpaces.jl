import Statistics
import Random

"""
    include_space(X::MetricSpace, n::Integer)

Include the metric space `X` in `R^m` into `R^{m+n}` by extending each point
with `n` extra zero coordinates.

Returns a new MetricSpace.
"""
function include_space(X::MetricSpace, n::Integer)
    @assert n >= 0 "n must be non-negative"
    return [vcat(collect(x), zeros(n)) for x in X]
end

"""
    translate_space(X::MetricSpace, vec::Union{AbstractVector{<:Number}, Tuple})

Translate the space `X` by adding `vec` to every point.

Returns a new MetricSpace.
"""
function translate_space(X::MetricSpace, vec::Union{AbstractVector{<:Number}, Tuple})
    return [x .+ vec for x in X]
end

"""
    center(X::MetricSpace)

Translate `X` so its centroid is at the origin.

Returns a new MetricSpace.
"""
function center(X::MetricSpace)
    c = sum(X) ./ length(X)
    return [x - c for x in X]
end

"""
    scale(X::MetricSpace, factor::Number)

Multiply every point of `X` by `factor`.

Returns a new MetricSpace.
"""
function scale(X::MetricSpace, factor::Number)
    return [x .* factor for x in X]
end

"""
    standardize(X::EuclideanSpace)

Center `X` and divide each coordinate by its standard deviation (per-axis
scaling to unit variance). Useful before applying density estimators or Mapper
filters on anisotropic data.

Returns a new MetricSpace with the same per-point dimension.
"""
function standardize(X::EuclideanSpace{N,T}) where {N,T}
    c = sum(X) ./ length(X)
    Y = [x - c for x in X]
    M = stack(Y)
    σ = [Statistics.std(@view M[i, :]) for i in 1:N]
    σ_safe = [s == 0 ? one(T) : T(s) for s in σ]
    return [y ./ σ_safe for y in Y]
end

"""
    embed(X::EuclideanSpace, target_dim::Integer; seed=nothing)

Embed `X` into a higher-dimensional Euclidean space via a Gaussian random
linear projection. Useful for stress-testing dimensionality reductions and
creating ambient-dimension variants of low-dim datasets.

`target_dim` must be greater than `dim(X)`. Optional `seed` makes the embedding
reproducible.
"""
function embed(X::EuclideanSpace{N,T}, target_dim::Integer; seed=nothing) where {N,T}
    @assert target_dim > N "target_dim ($target_dim) must be greater than current dim ($N)"
    rng = seed === nothing ? Random.default_rng() : Random.MersenneTwister(seed)
    A = randn(rng, target_dim, N)
    return [A * collect(x) for x in X]
end
