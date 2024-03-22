using MetricSpaces
using Distances

X = EuclideanSpace(rand(2, 2000))

ϵ = 0.1
ids = epsilon_net(X, ϵ)
using Makie, GLMakie

fig, ax, lineplot = scatter(X);

record(fig, "epsilon ball.mp4", X[ids]) do x
    dists = pairwise_distance([x], X, euclidean)[1, :]
    ids_ball = findall(<(ϵ), dists)

    scatter!(X[ids_ball], color = "orange")
    scatter!(x, color = "red")    
    arc!(Point(x), ϵ, -π, π, color = "red")
end

fig

X = EuclideanSpace(rand(2, 2000))
ids = farthest_points_sample(X, 300)

fig, ax, lineplot = scatter(X);

record(fig, "farthest points.gif", X[ids]) do x
    scatter!(x, color = "red", markersize = 20)
end

fig



