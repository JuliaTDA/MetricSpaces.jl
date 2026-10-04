function _image_geometry(mask,spacing,origin)
    !isempty(mask) || throw(ArgumentError("image must be nonempty"))
    length(spacing)==length(origin)==ndims(mask) || throw(ArgumentError("one spacing/origin per dimension"))
    all(x -> isfinite(x) && x>0,spacing) && all(isfinite,origin) || throw(ArgumentError("positive finite spacing and finite origin required"))
    return collect(Float64,spacing),collect(Float64,origin)
end

"""
    height_filtration(mask; direction=ones(ndims(mask)), spacing, origin)

Projection of foreground vertex coordinates along a normalized direction;
background is Inf. Use a finite Cubical threshold to omit background vertices.
"""
function height_filtration(mask::AbstractArray{Bool}; direction=ones(ndims(mask)),
        spacing=ones(ndims(mask)), origin=zeros(ndims(mask)))
    spacing,origin = _image_geometry(mask,spacing,origin)
    length(direction)==ndims(mask) && all(isfinite,direction) || throw(ArgumentError("invalid direction"))
    l = sqrt(sum(abs2,direction)); l>0 || throw(ArgumentError("zero direction"))
    return [mask[i] ? sum(direction[k]*(origin[k]+spacing[k]*(i[k]-1)) for k in 1:ndims(mask))/l : Inf for i in CartesianIndices(mask)]
end

"""`radial_filtration(mask; center, spacing, origin)` assigns Euclidean distance to a center."""
function radial_filtration(mask::AbstractArray{Bool}; center=nothing,
        spacing=ones(ndims(mask)), origin=zeros(ndims(mask)))
    spacing,origin = _image_geometry(mask,spacing,origin)
    c = isnothing(center) ? origin .+ spacing .* ((collect(size(mask)).-1)./2) : collect(Float64,center)
    length(c)==ndims(mask) && all(isfinite,c) || throw(ArgumentError("invalid center"))
    return [mask[i] ? sqrt(sum((origin[k]+spacing[k]*(i[k]-1)-c[k])^2 for k in 1:ndims(mask))) : Inf for i in CartesianIndices(mask)]
end

# Lower envelope of sampled parabolas: exact separable Euclidean distance transform.
function _edt_line(f,spacing)
    sites = findall(isfinite,f)
    isempty(sites) && return fill(Inf,length(f))
    v = zeros(Int,length(sites)); z = fill(Inf,length(sites)+1)
    v[1]=first(sites); z[1]=-Inf; k=1
    a=spacing^2
    for q in Iterators.drop(sites,1)
        s=((f[q]+a*q^2)-(f[v[k]]+a*v[k]^2))/(2a*(q-v[k]))
        while s<=z[k]
            k-=1
            s=((f[q]+a*q^2)-(f[v[k]]+a*v[k]^2))/(2a*(q-v[k]))
        end
        k+=1; v[k]=q; z[k]=s; z[k+1]=Inf
    end
    result=zeros(length(f)); k=1
    for q in eachindex(f)
        while z[k+1]<q
            k+=1
        end
        result[q]=a*(q-v[k])^2+f[v[k]]
    end
    return result
end

"""
    euclidean_distance_transform(mask; target=true, spacing=ones(ndims(mask)))

Exact distance to the nearest vertex equal to `target`, in physical coordinates.
Runs in O(ndims(mask)*length(mask)); absent targets give Inf. No implicit exterior
is included here. `signed_distance_filtration` can include exterior background.
"""
function euclidean_distance_transform(mask::AbstractArray{Bool}; target::Bool=true,
        spacing=ones(ndims(mask)))
    spacing,_ = _image_geometry(mask,spacing,zeros(ndims(mask)))
    D = ifelse.(mask .== target,0.0,Inf)
    for axis in 1:ndims(mask)
        shape = ntuple(k -> k==axis ? 1 : size(mask,k),ndims(mask))
        for i in CartesianIndices(shape)
            idx = ntuple(k -> k==axis ? Colon() : i[k],ndims(mask))
            line = view(D,idx...)
            line .= _edt_line(collect(line),spacing[axis])
        end
    end
    return sqrt.(D)
end

function _background_distance(mask,spacing,exterior)
    exterior || return euclidean_distance_transform(mask; target=false,spacing=spacing)
    padded=falses(size(mask).+2)
    interior=ntuple(k -> 2:size(mask,k)+1,ndims(mask))
    padded[interior...] = mask
    return euclidean_distance_transform(padded; target=false,spacing=spacing)[interior...]
end

"""Distance-to-foreground sublevels; threshold r gives the Euclidean dilation by r."""
dilation_filtration(mask::AbstractArray{Bool}; spacing=ones(ndims(mask))) =
    euclidean_distance_transform(mask; target=true,spacing=spacing)

"""
    erosion_filtration(mask; spacing, exterior=true)

Negative distance to background on foreground, Inf outside. The sublevel at -r
keeps foreground vertices at distance at least r from background. With `exterior`
the domain is padded with one layer of background vertices.
"""
function erosion_filtration(mask::AbstractArray{Bool}; spacing=ones(ndims(mask)),exterior::Bool=true)
    spacing,_=_image_geometry(mask,spacing,zeros(ndims(mask)))
    D=_background_distance(mask,spacing,exterior)
    return ifelse.(mask,-D,Inf)
end

"""
    signed_distance_filtration(mask; spacing, exterior=true)

Negative distance to background inside, positive distance to foreground outside.
This vertex-distance convention includes one exterior layer when requested.
An empty foreground yields Inf throughout; a full foreground has finite negative
distances with the default exterior. Sublevel threshold 0 recovers the mask.
"""
function signed_distance_filtration(mask::AbstractArray{Bool}; spacing=ones(ndims(mask)),exterior::Bool=true)
    spacing,_=_image_geometry(mask,spacing,zeros(ndims(mask)))
    outside=euclidean_distance_transform(mask; spacing=spacing)
    inside=_background_distance(mask,spacing,exterior)
    return ifelse.(mask,-inside,outside)
end

"""
    ImageFiltration(kind=:signed_distance; kwargs...)

Callable image transform, where kind is :height, :radial, :dilation, :erosion or
:signed_distance. Stores explicit geometric keyword parameters. Inputs are binary
vertex masks; threshold grayscale images explicitly before applying this transform.
"""
struct ImageFiltration{K}
    kind::Symbol
    kwargs::K
    function ImageFiltration(kind::Symbol=:signed_distance;kwargs...)
        kind in (:height,:radial,:dilation,:erosion,:signed_distance) || throw(ArgumentError("unknown image filtration"))
        new{typeof((;kwargs...))}(kind,(;kwargs...))
    end
end
function (f::ImageFiltration)(mask::AbstractArray{Bool})
    fun = f.kind==:height ? height_filtration : f.kind==:radial ? radial_filtration :
        f.kind==:dilation ? dilation_filtration : f.kind==:erosion ? erosion_filtration : signed_distance_filtration
    return fun(mask;f.kwargs...)
end

"""Create an optional MLJ image transformer; load MLJModelInterface first."""
function image_filtration_model end
