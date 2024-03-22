using MetricSpaces
using Makie, GLMakie

X = EuclideanSpace(rand(2, 2000))
exc = distance_to_measure(X, X, k = 50, summary_function = mean)
scatter(X, color = exc)


X = EuclideanSpace(rand(2, 2000))
exc = excentricity(X, X)
scatter(X, color = exc)


X = EuclideanSpace(randn(2, 2000))
exc = excentricity(X, X, d = dist_cityblock)
scatter(X, color = exc)