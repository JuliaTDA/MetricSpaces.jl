using MetricSpaces

# types
EuclideanSpace([[1, 2], [3, 4]])

EuclideanSpace([[1, 2], [3, 4, 4]])

X = rand(3, 6)
EuclideanSpace(X)

eachcol(X) .|> Vector

M = EuclideanSpace(X)

as_matrix(M)

M[1]
M[1] isa MetricSpace

i = 1

M[i:i]

M[1:1] isa MetricSpace
M[1:2]
M[1:2] isa MetricSpace
M[1:2] isa EuclideanSpace

for (i, p) ∈ enumerate(M)
    @show i, p
end

sum.(M)
maximum.(M)
M[1] .^ 2

# defina d
d(u, v) = (u .- v) .^2 |> sum |> sqrt

function d2(u, v) 
    s = zeros(length(u))
    for i ∈ 1:length(s)
        s[i] = (u[i] - v[i]) ^ 2
    end

    sqrt(sum(s))
end

d([1, 2, 3], [4, 5, 6])
d2([1, 2, 3], [4, 5, 6])

using BenchmarkTools
@benchmark d([1:100;], [1:100;])
@benchmark d2([1:100;], [1:100;])

M = EuclideanSpace(rand(5, 100))

M[1]
stack(M)
as_matrix(M)

pairwise_distance(M, M, d)

@benchmark pairwise_distance(M, M, d)
@benchmark pairwise_distance($M, $M, $d)


M = EuclideanSpace(rand(5, 5000))
@time pairwise_distance(M, M, d)

using Distances

pairwise_distance(M, M, Euclidean())
@which pairwise_distance(M, M, Euclidean())

@benchmark pairwise_distance(M, M, Euclidean())
@benchmark pairwise_distance($M, $M, $Euclidean())

D = pairwise_distance(M, M, d)
pairwise_distance_summary(EuclideanSpace(rand(5, 10000)), EuclideanSpace(rand(5, 100_000)), d, maximum)

@benchmark pairwise_distance_summary(M, M, d, maximum)

# benchmarks

M = EuclideanSpace(rand(20, 500))

pairwise(Euclidean(), M, M)

@benchmark $(M)[1]

M = EuclideanSpace(rand(10, 1000))

@benchmark pairwise_distance($M, $M, d)
@benchmark pairwise_distance($M, $M, Euclidean())
@benchmark pairwise(Euclidean(), $stack(M), $stack(M))

M = EuclideanSpace(rand(10, 5000))
@time pairwise_distance(M, M, d)
@time pairwise_distance_summary(M, M, d, maximum)


N = EuclideanSpace(rand(10, 15000))
pairwise_distance_summary(M, N, d, maximum)
# outras métricas

d_sq(x, y) = abs.(x .- y) |> sum

pairwise_distance(M, M, d_sq)
@time pairwise_distance_summary(N, N, d, maximum)

