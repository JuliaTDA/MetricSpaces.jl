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

"""
    EuclideanSpace(X::Vector{T}) where {T}

Constructs a `EuclideanSpace` object from a vector of vectors `X`, ensuring all inner vectors have the same length.

# Arguments
- `X::Vector{T}`: A vector of vectors, where each inner vector represents a point in Euclidean space.

# Returns
- `EuclideanSpace{N, T2}`: An instance of `EuclideanSpace` with dimension `N` (the length of the inner vectors) and element type `T2`.

# Throws
- An error if the inner vectors of `X` do not all have the same length.

# Notes
- Converts the input vectors to `SVector`s for internal consistency, then back to regular vectors for compatibility.
"""
function EuclideanSpace(X::Vector{T}) where {T}
    sizes = length.(X)
    m1, m2 = minimum(sizes), maximum(sizes) 

    if m1 != m2
        throw(error("All vectors should have the same length."))
    end

    X2 = SVector{m1}.(X)
    T2 = eltype(eltype(X2))

    # Convert SVectors back to regular Vectors for compatibility with test expectations
    EuclideanSpace{m1, T2}(Vector.(X2))
end

@testitem "EuclideanSpace" begin    
    X = eachcol(rand(3, 5)) |> collect
    M = EuclideanSpace(X)
    @test length(M) == 5
    @test size(M) == (5,)
    for i ∈ 1:5
        @test M[i] == X[i]
    end    

    X = [[1], [2], [3, 3]]
    @test_throws ErrorException EuclideanSpace(X)       
end

"""
    EuclideanSpace(M::Matrix{T}) where {T}

Constructs a `EuclideanSpace` object from a matrix `M` of type `Matrix{T}`. Each column of the matrix `M` is interpreted as a point in the Euclidean space, and the resulting space is constructed from the collection of these points.

# Arguments
- `M::Matrix{T}`: A matrix where each column represents a point in the Euclidean space.

# Returns
- A `EuclideanSpace` object containing the points represented by the columns of `M`.

# Example
"""
function EuclideanSpace(M::Matrix{T}) where {T}
    X = Vector.(eachcol(M))
    EuclideanSpace(X)
end

"""
    as_matrix(X::EuclideanSpace)

Convert an Euclidean space into a matrix.
"""
function as_matrix(X::EuclideanSpace)
    stack(X)
end

@testitem "as_matrix" begin    
    M = rand(10, 10)
    X = EuclideanSpace(M)    
    @test M == as_matrix(X)
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