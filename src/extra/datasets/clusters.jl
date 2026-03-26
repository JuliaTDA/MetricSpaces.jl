"""
    two_clusters(num_points::Integer = 100; dim::Integer = 2, separation::Number = 10)

Generate two Gaussian clusters separated along the first axis.
"""
function two_clusters(num_points::Integer=100; dim::Integer=2, separation::Number=10)
    n_half = div(num_points, 2)
    n_other = num_points - n_half

    M = randn(dim, num_points)
    # Shift second cluster along first dimension
    for j in (n_half+1):num_points
        M[1, j] += separation
    end

    EuclideanSpace(M)
end

"""
    three_clusters(num_points::Integer = 100; dim::Integer = 2)

Generate three Gaussian clusters at increasing separations along the first axis.
Centers at 0, 10, and 50.
"""
function three_clusters(num_points::Integer=100; dim::Integer=2)
    n1 = div(num_points, 3)
    n2 = div(num_points, 3)
    n3 = num_points - n1 - n2

    M = randn(dim, num_points)
    # Shift second cluster
    for j in (n1+1):(n1+n2)
        M[1, j] += 10
    end
    # Shift third cluster
    for j in (n1+n2+1):num_points
        M[1, j] += 50
    end

    EuclideanSpace(M)
end

"""
    linked_clusters(n_clusters::Integer = 3; per_cluster::Integer = 100, per_link::Integer = 50, dim::Integer = 2)

Generate Gaussian clusters connected by bridge points interpolated between consecutive cluster centers.
"""
function linked_clusters(n_clusters::Integer=3; per_cluster::Integer=100, per_link::Integer=50, dim::Integer=2)
    # Generate cluster centers spaced apart
    centers = [randn(dim) .* 10 .* i for i in 1:n_clusters]

    total = n_clusters * per_cluster + (n_clusters - 1) * per_link
    M = Matrix{Float64}(undef, dim, total)
    col = 0

    for i in 1:n_clusters
        # Cluster points
        for _ in 1:per_cluster
            col += 1
            for d in 1:dim
                M[d, col] = centers[i][d] + randn() * 0.2
            end
        end

        # Bridge to next cluster
        if i < n_clusters
            for k in 1:per_link
                col += 1
                t = k / (per_link + 1)
                for d in 1:dim
                    M[d, col] = (1 - t) * centers[i][d] + t * centers[i+1][d] + randn() * 0.01
                end
            end
        end
    end

    EuclideanSpace(M)
end

"""
    long_gaussian(num_points::Integer = 100; dim::Integer = 2)

Generate points from an elongated Gaussian where variance decays per dimension.
Dimension j has standard deviation 1/(1+j).
"""
function long_gaussian(num_points::Integer=100; dim::Integer=2)
    M = Matrix{Float64}(undef, dim, num_points)
    for j in 1:num_points
        for i in 1:dim
            M[i, j] = randn() / (1 + i)
        end
    end
    EuclideanSpace(M)
end
