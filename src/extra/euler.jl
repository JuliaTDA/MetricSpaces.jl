"""A sampled Euler characteristic curve (`thresholds`, integer `values`)."""
struct EulerCurve
    thresholds::Vector{Float64}
    values::Vector{Int}
end

"""Sampled directional Euler curves, with exact jump events for integration."""
struct EulerTransform
    thresholds::Vector{Float64}
    directions::Matrix{Float64}
    values::Matrix{Int}
    events::Vector{Tuple{Vector{Float64},Vector{Int}}}
end

"""Centered integrals of directional Euler curves, in threshold×direction order."""
struct SmoothEulerTransform
    thresholds::Vector{Float64}
    directions::Matrix{Float64}
    values::Matrix{Float64}
end

function _euler_thresholds(thresholds)
    t = collect(Float64, thresholds)
    !isempty(t) && all(isfinite,t) && issorted(t) && allunique(t) ||
        throw(ArgumentError("thresholds must be finite, nonempty and strictly increasing"))
    return t
end

# Vertex lower-star cubical convention, matching TDARipserer.Cubical. A cell
# exists only when all of its corner vertices belong to the mask.
function _cubical_events(values, mask; max_cells=10_000_000)
    size(values) == size(mask) || throw(ArgumentError("mask and values must have equal shape"))
    ndims(values)>0 && !isempty(values) || throw(ArgumentError("nonempty array required"))
    all(isfinite, values[mask]) || throw(ArgumentError("included vertex values must be finite"))
    shape = 2 .* size(values) .- 1
    prod(big.(shape)) <= max_cells || throw(ArgumentError("max_cells exceeded"))
    events = Float64[]; weights = Int[]
    for root in CartesianIndices(shape)
        ranges = ntuple(ndims(values)) do k
            r = root[k]
            isodd(r) ? ((r+1)÷2:(r+1)÷2) : (r÷2:r÷2+1)
        end
        corners = CartesianIndices(ranges)
        all(i -> mask[i], corners) || continue
        push!(events, maximum(values[i] for i in corners))
        push!(weights, iseven(count(iseven, Tuple(root))) ? 1 : -1)
    end
    return events, weights
end

"""
    cubical_ecc(values; thresholds=sort(unique(vec(values))), mask=trues(size(values)))

Euler characteristic of the vertex lower-star cubical sublevel complex. A cell
enters at the maximum of its vertices and contributes (-1)^dimension. This is
the same convention as TDARipserer.Cubical, not a union of closed pixel boxes.
Mask-false vertices and incident cells are excluded. Returns `EulerCurve`.
"""
function cubical_ecc(values::AbstractArray{<:Real}; thresholds=nothing,
        mask::AbstractArray{Bool}=trues(size(values)), max_cells=10_000_000)
    events, weights = _cubical_events(values, mask; max_cells=max_cells)
    t = _euler_thresholds(isnothing(thresholds) ?
        (isempty(events) ? [0.0] : sort!(unique(events))) : thresholds)
    return EulerCurve(t,[sum(weights[j] for j in eachindex(events) if events[j]<=x; init=0) for x in t])
end

"""
    sample_directions(d; n=32, rng=Random.default_rng())

Unit directions: equally spaced angles in 2D, a Fibonacci sphere in 3D, and
normalized seeded Gaussian samples in higher dimensions. 1D returns ±1.
"""
function sample_directions(d::Integer; n::Integer=32, rng=Random.default_rng())
    d>0 && n>0 || throw(ArgumentError("positive dimension and sample count required"))
    d==1 && return reshape([-1.0,1.0],1,2)
    d==2 && return [f(2π*j/n) for f in (cos,sin), j in 0:n-1]
    if d==3
        z = [1-2*(j+0.5)/n for j in 0:n-1]
        angle = [π*(3-sqrt(5))*j for j in 0:n-1]
        return permutedims(hcat(sqrt.(1 .- z.^2).*cos.(angle),sqrt.(1 .- z.^2).*sin.(angle),z))
    end
    P = Random.randn(rng,d,n)
    return P ./ sqrt.(sum(abs2,P; dims=1))
end

function _directions(directions,d)
    D = Matrix{Float64}(directions)
    size(D,1)==d && size(D,2)>0 && all(isfinite,D) || throw(ArgumentError("directions must be a finite d×n matrix"))
    lengths = sqrt.(sum(abs2,D; dims=1))
    all(>(0),lengths) || throw(ArgumentError("directions cannot be zero"))
    return D ./ lengths
end

function _euler_result(D,events,thresholds,n_thresholds)
    n_thresholds>=2 || throw(ArgumentError("n_thresholds must be at least two"))
    if isnothing(thresholds)
        births = reduce(vcat,first.(events); init=Float64[])
        lo,hi = isempty(births) ? (-1.0,1.0) : extrema(births)
        lo==hi && ((lo,hi)=(lo-0.5,hi+0.5))
        thresholds = range(lo,hi; length=n_thresholds)
    end
    t = _euler_thresholds(thresholds)
    C = [sum(w[j] for j in eachindex(b) if b[j]<=x; init=0) for x in t, (b,w) in events]
    return EulerTransform(t,D,C,events)
end

"""
    ect(points, simplices; directions=sample_directions(d), thresholds=nothing)

Directional lower-star ECT of a simplicial shape. Points are columns of a matrix
or a vector of coordinate vectors. `simplices` may list maximal faces: all faces
and all input vertices are added. Directions are normalized. A common threshold
grid is used across directions; row order is fixed in `euler_table`.
"""
function ect(points, simplices; directions=nothing, thresholds=nothing, n_thresholds=64)
    X = points isa AbstractMatrix ? Matrix{Float64}(points) : reduce(hcat,collect(points))
    !isempty(X) && all(isfinite,X) || throw(ArgumentError("finite nonempty points required"))
    D = _directions(isnothing(directions) ? sample_directions(size(X,1)) : directions,size(X,1))
    faces = Set{Tuple{Vararg{Int}}}((i,) for i in axes(X,2))
    function addface(s)
        s in faces && return
        push!(faces,s)
        length(s)==1 && return
        for i in eachindex(s)
            addface(Tuple(s[j] for j in eachindex(s) if j!=i))
        end
    end
    for s in simplices
        v = Tuple(sort!(collect(Int,s)))
        !isempty(v) && allunique(v) && all(i -> i in axes(X,2),v) || throw(ArgumentError("invalid simplex"))
        addface(v)
    end
    ordered = sort!(collect(faces); by=s -> (length(s),s))
    events = map(eachcol(D)) do direction
        heights = vec(sum(X .* direction; dims=1))
        ([maximum(heights[i] for i in s) for s in ordered],
         [isodd(length(s)) ? 1 : -1 for s in ordered])
    end
    return _euler_result(D,events,thresholds,n_thresholds)
end

"""
    ect(mask::AbstractArray{Bool}; directions, thresholds, spacing, origin)

ECT of a vertex-based cubical shape; included cells have all corners in `mask`.
`spacing` must be positive and `origin` sets the first vertex's coordinates.
The convention agrees with `cubical_ecc` and TDARipserer.Cubical.
"""
function ect(mask::AbstractArray{Bool}; directions=nothing, thresholds=nothing,
        n_thresholds=64, spacing=ones(ndims(mask)), origin=zeros(ndims(mask)), max_cells=10_000_000)
    spacing,origin = _image_geometry(mask,spacing,origin)
    D = _directions(isnothing(directions) ? sample_directions(ndims(mask)) : directions,ndims(mask))
    events = map(eachcol(D)) do direction
        heights = [sum(direction[k]*(origin[k]+spacing[k]*(i[k]-1)) for k in 1:ndims(mask)) for i in CartesianIndices(mask)]
        _cubical_events(heights,mask; max_cells=max_cells)
    end
    return _euler_result(D,events,thresholds,n_thresholds)
end

"""
    sect(E::EulerTransform)
    sect(args...; kwargs...)

Exact integral of each ECC after subtracting its average on `[first(t),last(t)]`.
Uses jump events, not trapezoidal interpolation of sampled ECC values. Both
endpoints are zero (up to roundoff). The second form first calls `ect`.
Reference: Meng et al. (2022), https://arxiv.org/abs/2204.12699.
"""
function sect(E::EulerTransform)
    a,b = first(E.thresholds),last(E.thresholds)
    b>a || throw(ArgumentError("SECT needs at least two different thresholds"))
    values = zeros(length(E.thresholds),size(E.directions,2))
    for (j,(births,weights)) in enumerate(E.events)
        integral(t) = sum(w*max(t-s,0) for (s,w) in zip(births,weights); init=0.0)
        base = integral(a)
        average = (integral(b)-base)/(b-a)
        values[:,j] = [integral(t)-base-average*(t-a) for t in E.thresholds]
    end
    return SmoothEulerTransform(copy(E.thresholds),copy(E.directions),values)
end
sect(args...;kwargs...) = sect(ect(args...;kwargs...))

"""NamedTuple column table of an ECC/ECT/SECT, suitable for Tables.jl/DataFrames."""
euler_table(C::EulerCurve) = (threshold=copy(C.thresholds),value=copy(C.values))
euler_table(E::Union{EulerTransform,SmoothEulerTransform}) =
    (direction=repeat(collect(axes(E.directions,2)); inner=length(E.thresholds)),
     threshold=repeat(E.thresholds; outer=size(E.directions,2)),value=vec(copy(E.values)))
