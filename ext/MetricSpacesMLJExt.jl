module MetricSpacesMLJExt
using MetricSpaces
import MLJModelInterface as MMI

mutable struct ImageFiltrationModel <: MMI.Unsupervised
    filtration::ImageFiltration
end
MetricSpaces.image_filtration_model(kind::Symbol=:signed_distance;kwargs...) =
    ImageFiltrationModel(ImageFiltration(kind;kwargs...))
MMI.fit(::ImageFiltrationModel,::Int,X) = (nothing,nothing,NamedTuple())
MMI.transform(m::ImageFiltrationModel,::Nothing,X) = map(m.filtration,X)
MMI.input_scitype(::Type{ImageFiltrationModel}) = AbstractVector
MMI.output_scitype(::Type{ImageFiltrationModel}) = AbstractVector
MMI.is_pure_julia(::Type{ImageFiltrationModel}) = true
MMI.metadata_pkg(ImageFiltrationModel; name="MetricSpaces",uuid="737298cd-3e4b-40c4-a4ce-863151543a8d",
    url="https://github.com/JuliaTDA/MetricSpaces.jl",license="MIT",julia=true,is_wrapper=false)
end
