"""
    sphere(num_points::Integer = 100; dim::Integer = 2, radius::Number = 1, noise::Function = zeros)

Generates a set of points uniformly distributed on the surface of a sphere in the Euclidean space.

# Arguments
- `num_points::Integer=100`: The number of points to generate on the sphere.
- `dim::Integer=2`: The dimensionality of the sphere.
- `radius::Number=1`: The radius of the sphere.
- `noise::Function=zeros`: A function that generates noise to be added to each point. The function should accept the dimensionality `dim` as an argument and return a vector of the same size.

# Returns
- An instance of `EuclideanSpace` containing the generated points.

# Example
    sphere(100, dim=3, radius=2.0, noise=randn)
end
"""
function sphere(num_points::Integer=100; dim::Integer=2, radius::Number=1)
    X = EuclideanSpace(rand(dim, num_points) .- 0.5)
    normalize.(X) .* radius
end

@testitem "sphere" begin
    X = sphere(100, dim=3, radius=1.0)
    @test size(X) == (100,)
    @test typeof(X) == EuclideanSpace{3,Float64}
    @test all(extrema(norm.(X)) .≈ (1.0, 1.0))
end

"""
    cube(num_points::Integer = 100; dim::Integer = 2, radius::Number = 1, noise::Function = zeros)

    cube(
        num_points::Integer = 100; dim::Integer = 2, 
        radius::Number = 1, 
        noise::Function = zeros
        )

Create a cube in R^(`dim`) with `num_points` points and radius `radius`.

# Arguments
- `num_points::Integer`: the number of points.
- `dim::Integer`: the dimension of the cube (that is: in which R^dim it is).
- `radius::Number`: the "radius" of the cube, that is, the distance from the center to one of its sides..
- `noise::Function`: a function such that `y = noise(dim)` is a `Vector{<:Number}` with `size(y) = (dim;)`.
"""
function cube(num_points::Integer=100; dim::Integer=2, radius::Number=1, noise::Function=zeros)
    X = rand(dim, num_points) .- 0.5
    X = mapslices(X, dims=1) do x
        y = x ./ norm(x) .* radius + noise(dim)
        return y
    end

    return EuclideanSpace(X)
end

"""
    torus(num_points::Integer = 100; r::Number = 1, R::Number = 3)

# Arguments
- `num_points::Integer`: the number of points.
- `r::Number`: the inner radius.
- `R::Number`: the outer radius.
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