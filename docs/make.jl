using Documenter, DocumenterVitepress
using MetricSpaces

makedocs(;
    modules=[MetricSpaces],
    sitename="MetricSpaces.jl",
    authors="G. Vituri <56522687+vituri@users.noreply.github.com> and contributors",
    format=MarkdownVitepress(
        repo="https://github.com/JuliaTDA/MetricSpaces.jl",
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
        "API Reference" => "api.md"
    ],
    checkdocs=:exports,
    doctest=false
)

# Deploy documentation if running in CI
deploydocs(;
    repo="github.com/JuliaTDA/MetricSpaces.jl.git"
)

