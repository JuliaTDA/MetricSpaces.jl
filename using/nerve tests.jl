using MetricSpaces
using Graphs

cv = [[1, 2], [2, 3], [3, 1], [1, 4]]

g = nerve_1d(cv)

g



edges(g) |> collect
eltype(g)
neighbors(g, 5)