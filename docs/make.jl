using Documenter, DocumenterVitepress
using MetricSpaces

makedocs(;
    modules=[MetricSpaces],
    sitename="MetricSpaces.jl",
    authors="G. Vituri <56522687+vituri@users.noreply.github.com> and contributors",
    format=Documenter.HTML(
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://vituri.github.io/MetricSpaces.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Mathematical Background" => "mathematical_background.md",
        "Getting Started" => "getting_started.md",
        "Core Types" => "types.md",
        "Distance Functions" => "distances.md",
        "Metric Balls" => "balls.md",
        "Sampling Methods" => "sampling.md",
        "Neighborhood Analysis" => "neighborhoods.md",
        "Datasets" => "datasets.md",
        "API Reference" => "api.md",
    ],
    repo="https://github.com/vituri/MetricSpaces.jl/blob/{commit}{path}#{line}",
    checkdocs=:exports,
)

# Deploy documentation if running in CI
if get(ENV, "CI", nothing) == "true"
    deploydocs(;
        repo="github.com/vituri/MetricSpaces.jl.git",
        devbranch="main",
        push_preview=true,
    )
end
