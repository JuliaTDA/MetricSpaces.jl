using MetricSpaces

# types
d(u, v) = (u .- v) .^2 |> sum |> sqrt


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

sort([9:-1:1;])

M = EuclideanSpace(torus(5000))

# M = EuclideanSpace(rand(2, 5000))
dtm = distance_to_measure(M, M, d = d, k = 50)

using Makie
using GLMakie
scatter(as_matrix(M), color = dtm, markersize = dtm .* 20)