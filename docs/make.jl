using Documenter
using DocumenterVitepress
using Literate
using MetricSpaces

makedocs(
    format = MarkdownVitepress(
        repo = "https://github.com/vituri/MetricSpaces.jl",
        devbranch = "main",
        devurl = "dev"
    ),
    modules = [MetricSpaces],
    sitename = "MetricSpaces.jl",
    pages = [
        "Home" => "index.md",
        "Getting Started" => "getting_started.md",
        "API" => "api.md",
        "Examples" => Literate.markdown("src/examples/sampling_example.jl", "examples/")
    ]
)