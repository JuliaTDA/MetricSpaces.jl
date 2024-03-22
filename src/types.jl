# types

# metric spaces
""" 
The abstract Metric Space type.
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
        throw(error("Variable length of vectors!"))
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

Convert a euclidean space to a matrix.
"""
as_matrix(X::EuclideanSpace) = stack(X)

"""
    Euclidean norm.
"""
norm(x::Vector{<: Number}) = x.^2 |> sum |> sqrt
normalize(x::Vector{<: Number}) = x ./ norm(x)

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
Covering = Vector{<:SubsetIndex}