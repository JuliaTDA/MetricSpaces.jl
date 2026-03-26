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
