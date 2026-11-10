using Documenter
using DocumenterCitations
using MultiObjectiveMetrics

bib = CitationBibliography(
    joinpath(@__DIR__, "src", "refs.bib");
    style = :numeric,
)

DocMeta.setdocmeta!(MultiObjectiveMetrics, :DocTestSetup, :(using MultiObjectiveMetrics); recursive = true)

makedocs(
    sitename = "MultiObjectiveMetrics.jl",
    modules = [MultiObjectiveMetrics],
    plugins = [bib],
    checkdocs = :exports,
    format = Documenter.HTML(
        prettyurls = true,
        edit_link = nothing,
    ),
    pages = [
        "Home" => "index.md",
        "Getting Started" => [
            "Installation" => "installation.md",
            "Quick Start" => "quickstart.md",
        ],
        "Guides" => [
            "Point sets and tolerance" => "guides/input.md",
            "Performance profiles" => "guides/profiles.md",
            "Conventions" => "guides/conventions.md",
        ],
        "Metrics" => [
            "Purity" => "metrics/purity.md",
            "Spread metrics" => "metrics/spread.md",
            "Covering" => "metrics/covering.md",
            "Hypervolume" => "metrics/hypervolume.md",
        ],
        "API Reference" => "api.md",
        "Acknowledgements" => "acknowledgements.md",
        "References" => "references.md",
    ],
)

deploydocs(
    repo = "github.com/VectorOptimizationGroup/MultiObjectiveMetrics.jl.git",
    devbranch = "main",
)
