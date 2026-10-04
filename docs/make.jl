using Documenter
using DocumenterVitepress
using MetricSpaces

makedocs(;
    checkdocs = :exports,
    modules = [MetricSpaces],
    sitename = "MetricSpaces.jl",
    authors = "G. Vituri and contributors",
    format = DocumenterVitepress.MarkdownVitepress(
        repo = "https://github.com/JuliaTDA/MetricSpaces.jl",
        devurl = "dev",
    ),
    pages = [
        "Home" => "index.md",
        "Getting Started" => "getting_started.md",
        "Mathematical Background" => "mathematical_background.md",
        "Transformations and geodesics" => "transformations.md",
        "Nerves of covers" => "nerves.md",
        "Troubleshooting" => "troubleshooting.md",
        "Reference" => [
            "Core Types" => "types.md",
            "Distance Functions" => "distances.md",
            "Metric Balls" => "balls.md",
            "Sampling Methods" => "sampling.md",
            "Neighborhood Analysis" => "neighborhoods.md",
            "Datasets" => "datasets.md",
            "Euler transforms and images" => "euler_images.md",
        ],
        "API Reference" => "api.md",
    ],
    warnonly = [:missing_docs, :cross_references],
)

if get(ENV, "CI", "false") == "true" || get(ENV, "JULIATDA_DOCS_DEPLOY", "false") == "true"
    DocumenterVitepress.deploydocs(;
        repo = "github.com/JuliaTDA/MetricSpaces.jl",
        target = "build",
        branch = "gh-pages",
        devbranch = "main",
        push_preview = true,
    )
end
