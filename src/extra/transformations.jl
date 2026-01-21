"""
    include_space(X::MetricSpace, n::Integer)

Include the metric space X of R^m into R^{m+n},
with all extra coordinates equal to 0.

Returns a MetricSpace.
"""
function include_space(X::MetricSpace, n::Integer)
    @assert n >= 0 "n must be non-negative"
    return vcat(X, zeros(n, size(X)[2]))
end

"""
    translate_space(X::MetricSpace, vector::Union{Vector{<:Number}, Tuple})

Translate the space `X` by adding the `vector` to each point of X.

Returns a MetricSpace.
"""
function translate_space(X::MetricSpace, vector::Union{Vector{<:Number}, Tuple})
    return X .+ vector
end