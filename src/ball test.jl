using MetricSpaces
X = sphere(200)
i = 1
ϵ = 0.5

ball(X, 1, 0.01)
ball(X, [1, 2, 3], 0.1)

ball_X(I, ϵ) = ball(X, I, ϵ)

ball_X([1, 2], 0.01)

@code_warntype ball(X, 1, 1)