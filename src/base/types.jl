# types

# metric spaces
""" 
The abstract Metric Space type is just an alias for Vector{T}.
"""
MetricSpace{T} = Vector{T} where {T}

"""
A type to model metric spaces where each element is an array of the same length.
"""
EuclideanSpace{N, T} = MetricSpace{SVector{N, T}} where {N, T}

function EuclideanSpace(X::Vector{T}) where {T}
    sizes = length.(X)
    m1, m2 = minimum(sizes), maximum(sizes) 

    if m1 != m2
        throw(error("All vectors should have the same length."))
    end

    X2 = SVector{m1}.(X)
    T2 = eltype(eltype(X2))

    EuclideanSpace{m1, T2}(X2)
end

function EuclideanSpace(M::Matrix{T}) where {T}
    X = Vector.(eachcol(M))
    EuclideanSpace(X)
end

"""
    as_matrix(M::EuclideanSpace)

Convert a euclidean space into a matrix.
"""
as_matrix(X::EuclideanSpace) = stack(X)

"""
    Euclidean norm.
"""
norm(x) = x.^2 |> sum |> sqrt
normalize(X::EuclideanSpace) = map(normalize) do x
    x ./ norm(x)
end

# covering

"""
A vector of integers, generally interpreted as 
indexes of a metric space.
"""
SubsetIndex = Vector{<:Integer}

"""
A covering is interpreted as a vector of subsets of indexes 
of a given metric space `X`.
"""
CoveringIndices = Vector{<:SubsetIndex}

"""
A covering is a vector of metric spaces,
where each metric space is a subset of the original metric space `X`.
"""
Covering = Vector{<:MetricSpace}