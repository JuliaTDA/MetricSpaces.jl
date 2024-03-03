# aa 
abstract type MetricSpace end

struct EuclideanSpace <: MetricSpace
    X::Matrix{<:Number}
end

X = rand(3, 6)
M = EuclideanSpace(X)

M[1]
getindex(M, 1)

Base.length(M::MetricSpace) = size(M.X, 2)

function Base.getindex(M::MetricSpace, i::Int)
    1 <= i <= length(M) || throw(BoundsError(S, i))
    return M.X[:, i]
end

M[1]

for x ∈ M
    @show x
end

Y = eachcol(X)
Y[1:2]

points(M::EuclideanSpace) = [x[:] for x ∈ eachcol(M.X)]
points(M)

Base.length(M::MetricSpace) = length(points(M))
length(M)

dim(M::MetricSpace) = nothing
dim(M::EuclideanSpace) = points(M)[1] |> length
dim(M)

Base.iterate(M::MetricSpace, state = 1) = state > length(M) ? nothing : (points(M)[state], state + 1)

points(M)

enumerate(M) |> collect

for (i, p) ∈ enumerate(M)
    @show i, p
end

for x ∈ M
    sum(x)
end

map(sum, M)

sum.(M)
points(M)
maximum.(M)

soma2(x) = x .+ 2

soma2.(M)

M[end]

[[1, 2], [2, 3]]


M[1] .^ 2

Base.firstindex(M::MetricSpace) = 1
Base.lastindex(M::MetricSpace) = length(M)

M[1]
M[end]

Base.getindex(M::MetricSpace, i::Number) = M[convert(Int, i)]
Base.getindex(M::MetricSpace, I) = [M[i] for i in I]
Base.getindex(M::MetricSpace, ::Colon) = points(M)

M[1:2]
M[:]

M[1] .^2 
map(M[[1, 2]]) do x 
    x .^ 50
end

M[1:2] |> collect

Base.size(M::MetricSpace) = (length(M), dim(M))
size(M)

using Distances

Euclidean()

points(M)
p = points(M)[1]

for (i, p) ∈ enumerate(M)
    # @show p, i
    @show colwise(Euclidean(), p, M.X)
end
p = M[1]

colwise(Euclidean(), p, M[:])

Euclidean(1)(1, [3, 2])
euclidean([1, 1], [2, 3])
euclidean([1, 1], [[1, 1], [2, 3]])

euclidean(M[1], M[1:3])

x = Vector.(M[1:2])
y = Vector.(M[1:3])
euclidean(x[1], y[2])
colwise(Euclidean(), x, y)

distance_function(metric) = (x, y) -> metric(x, y)

d = distance_function(Euclidean())
d([1, 2], [2, 3])

Vector.(points(M))

reshape([0.1, 0.3, -0.1], 3, 1)

[0.1; 0.3; -0.1]
M[1]
M[1:2]

using BenchmarkTools
@benchmark M[1]
@benchmark M.X[:, 1]
@benchmark eachcol(M.X)[1]

M.X[:, 1:2]




Y  |> collect


@benchmark 