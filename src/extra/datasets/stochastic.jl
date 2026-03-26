"""
    random_walk(num_points::Integer = 100; dim::Integer = 2)

Generate a random walk (Brownian motion) path. Each point is the cumulative sum of Gaussian steps.
"""
function random_walk(num_points::Integer=100; dim::Integer=2)
    M = randn(dim, num_points)
    # Cumulative sum along columns (the walk)
    for j in 2:num_points
        for i in 1:dim
            M[i, j] += M[i, j-1]
        end
    end
    EuclideanSpace(M)
end

"""
    orthogonal_curve(num_points::Integer = 100)

Generate points in `num_points`-dimensional space with mutually orthogonal step patterns.
Each dimension k has a step function that changes at interval k.
"""
function orthogonal_curve(num_points::Integer=100)
    M = Matrix{Float64}(undef, num_points, num_points)
    for k in 1:num_points
        for j in 1:num_points
            M[k, j] = div(j - 1, k) % 2 == 0 ? 1.0 : -1.0
        end
    end
    EuclideanSpace(M)
end
