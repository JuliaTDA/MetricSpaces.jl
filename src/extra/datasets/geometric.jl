"""
    sphere(num_points::Integer = 100; dim::Integer = 2, radius::Number = 1)

Generate points uniformly distributed on the surface of a sphere.
"""
function sphere(num_points::Integer=100; dim::Integer=2, radius::Number=1)
    X = EuclideanSpace(rand(dim, num_points) .- 0.5)
    normalize.(X) .* radius
end

"""
    cube(num_points::Integer = 100; dim::Integer = 2, radius::Number = 1, noise::Function = zeros)

Generate points uniformly distributed on the surface of a hypercube.
"""
function cube(num_points::Integer=100; dim::Integer=2, radius::Number=1, noise::Function=zeros)
    X = rand(dim, num_points) .- 0.5

    @inbounds for j ∈ axes(X, 2)
        col = view(X, :, j)
        col ./= norm(col)
        col .*= radius
        col .+= noise(dim)
    end

    EuclideanSpace(X)
end

"""
    torus(num_points::Integer = 100; r::Number = 1, R::Number = 3)

Generate points uniformly distributed on a torus in 3D.

# Arguments
- `r`: inner radius (tube radius)
- `R`: outer radius (distance from center of tube to center of torus)
"""
function torus(num_points::Integer=100; r::Number=1, R::Number=3)
    θ = rand(num_points) * 2π
    ϕ = rand(num_points) * 2π

    x = @. (R + r * cos(θ)) * cos(ϕ)
    y = @. (R + r * cos(θ)) * sin(ϕ)
    z = @. r * sin(θ)

    X = permutedims([x y z], [2, 1])
    return EuclideanSpace(X)
end

"""
    grid(size::Integer = 10; dim::Integer = 2)

Generate a regular lattice of points at integer coordinates. Returns `size^dim` points.
"""
function grid(size::Integer=10; dim::Integer=2)
    ranges = ntuple(_ -> 0:(size-1), dim)
    points = vec(collect(Iterators.product(ranges...)))
    M = Matrix{Float64}(undef, dim, length(points))
    for (j, p) in enumerate(points)
        for i in 1:dim
            M[i, j] = Float64(p[i])
        end
    end
    EuclideanSpace(M)
end

"""
    star(num_points::Integer = 100; n_arms::Integer = 5, dim::Integer = 2)

Generate points along radiating arms from the origin, with small Gaussian noise.
"""
function star(num_points::Integer=100; n_arms::Integer=5, dim::Integer=2)
    per_arm = div(num_points, n_arms)
    remainder = num_points - per_arm * n_arms
    M = Matrix{Float64}(undef, dim, num_points)
    col = 0

    for arm in 1:n_arms
        n_pts = per_arm + (arm <= remainder ? 1 : 0)
        # direction for this arm
        angle = 2π * (arm - 1) / n_arms
        dir = zeros(dim)
        dir[1] = cos(angle)
        if dim >= 2
            dir[2] = sin(angle)
        end

        for _ in 1:n_pts
            col += 1
            t = rand()
            for i in 1:dim
                M[i, col] = t * dir[i] + 0.01 * randn()
            end
        end
    end

    EuclideanSpace(M)
end
