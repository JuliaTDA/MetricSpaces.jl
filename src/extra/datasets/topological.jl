"""
    trefoil_knot(num_points::Integer = 100; scale::Number = 1)

Generate points on a trefoil knot curve in 3D.

Parametric equations:
- x = sin(t) + 2sin(2t)
- y = cos(t) - 2cos(2t)
- z = -sin(3t)
"""
function trefoil_knot(num_points::Integer=100; scale::Number=1)
    t = rand(num_points) .* 2π

    x = @. (sin(t) + 2sin(2t)) * scale
    y = @. (cos(t) - 2cos(2t)) * scale
    z = @. -sin(3t) * scale

    X = permutedims([x y z], [2, 1])
    return EuclideanSpace(X)
end

"""
    linked_rings(num_points::Integer = 100; r::Number = 1)

Generate two interlocked rings (Hopf link) in 3D.
Ring 1 lies in the XY plane, Ring 2 lies in the XZ plane offset by `r` along X.
"""
function linked_rings(num_points::Integer=100; r::Number=1)
    n_half = div(num_points, 2)
    n_other = num_points - n_half

    # Ring 1: circle in XY plane
    θ1 = rand(n_half) .* 2π
    x1 = @. r * cos(θ1)
    y1 = @. r * sin(θ1)
    z1 = zeros(n_half)

    # Ring 2: circle in XZ plane, centered at (r, 0, 0)
    θ2 = rand(n_other) .* 2π
    x2 = @. r + r * cos(θ2)
    y2 = zeros(n_other)
    z2 = @. r * sin(θ2)

    x = vcat(x1, x2)
    y = vcat(y1, y2)
    z = vcat(z1, z2)

    X = permutedims([x y z], [2, 1])
    return EuclideanSpace(X)
end

"""
    unlinked_rings(num_points::Integer = 100; r::Number = 1, separation::Number = 3)

Generate two separated (unlinked) rings in 3D, both in the XY plane.
"""
function unlinked_rings(num_points::Integer=100; r::Number=1, separation::Number=3)
    n_half = div(num_points, 2)
    n_other = num_points - n_half

    # Ring 1: circle in XY plane at origin
    θ1 = rand(n_half) .* 2π
    x1 = @. r * cos(θ1)
    y1 = @. r * sin(θ1)
    z1 = zeros(n_half)

    # Ring 2: circle in XY plane, offset along X
    θ2 = rand(n_other) .* 2π
    x2 = @. separation + r * cos(θ2)
    y2 = @. r * sin(θ2)
    z2 = zeros(n_other)

    x = vcat(x1, x2)
    y = vcat(y1, y2)
    z = vcat(z1, z2)

    X = permutedims([x y z], [2, 1])
    return EuclideanSpace(X)
end

"""
    figure_eight(num_points::Integer = 100; r::Number = 1.0)

Generate points on a figure-eight (two tangent circles) in 2D.
Produces β₁ = 2, useful for testing PH dimension counting.
"""
function figure_eight(num_points::Integer=100; r::Number=1.0)
    n_half = div(num_points, 2)
    n_other = num_points - n_half

    θ1 = rand(n_half) .* 2π
    x1 = @. r * cos(θ1) - r
    y1 = @. r * sin(θ1)

    θ2 = rand(n_other) .* 2π
    x2 = @. r * cos(θ2) + r
    y2 = @. r * sin(θ2)

    EuclideanSpace(permutedims([vcat(x1, x2) vcat(y1, y2)], [2, 1]))
end

"""
    klein_bottle(num_points::Integer = 100; a::Number = 1.0)

Generate points on a Klein bottle embedded in 4D.
A non-orientable closed surface with interesting H₁ and H₂.
"""
function klein_bottle(num_points::Integer=100; a::Number=1.0)
    u = rand(num_points) .* 2π
    v = rand(num_points) .* 2π

    x1 = @. a * (cos(u / 2) * cos(v) - sin(u / 2) * sin(2v))
    x2 = @. a * (sin(u / 2) * cos(v) + cos(u / 2) * sin(2v))
    x3 = @. a * cos(u) * (1 + sin(v))
    x4 = @. a * sin(u) * (1 + sin(v))

    EuclideanSpace(permutedims([x1 x2 x3 x4], [2, 1]))
end

"""
    mobius_strip(num_points::Integer = 100; R::Number = 1.0, w::Number = 0.5)

Generate points on a Möbius strip in 3D.

# Arguments
- `R`: radius of the central circle
- `w`: width of the strip
"""
function mobius_strip(num_points::Integer=100; R::Number=1.0, w::Number=0.5)
    u = rand(num_points) .* 2π
    v = (rand(num_points) .- 0.5) .* w

    x = @. (R + v * cos(u / 2)) * cos(u)
    y = @. (R + v * cos(u / 2)) * sin(u)
    z = @. v * sin(u / 2)

    EuclideanSpace(permutedims([x y z], [2, 1]))
end

"""
    clifford_torus(num_points::Integer = 100; r1::Number = 1.0, r2::Number = 1.0)

Generate points on a Clifford torus (flat torus) in R⁴.
An isometric embedding of the flat torus; popular in PH papers.

# Arguments
- `r1`: radius of the first circle
- `r2`: radius of the second circle
"""
function clifford_torus(num_points::Integer=100; r1::Number=1.0, r2::Number=1.0)
    θ = rand(num_points) .* 2π
    ϕ = rand(num_points) .* 2π

    x1 = @. r1 * cos(θ)
    x2 = @. r1 * sin(θ)
    x3 = @. r2 * cos(ϕ)
    x4 = @. r2 * sin(ϕ)

    EuclideanSpace(permutedims([x1 x2 x3 x4], [2, 1]))
end
