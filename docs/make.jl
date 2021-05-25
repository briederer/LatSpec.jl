using Documenter
using DocumenterCitations
using LatSpec

bib = CitationBibliography(joinpath(@__DIR__,"LatSpec.bib"))
const PAGES = [
               "Home"       => "index.md",
               "References" => "references.md"
              ]

makedocs(bib;
    authors = "Bernd Riederer and Fabian Zierler",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", nothing) == "true",
        assets=String[],
    ),
    pages = PAGES,
    repo="https://github.com/bernd1995/LatSpec.jl/blob/{commit}{path}#{line}",
    sitename="LatSpec.jl"
)

deploydocs(;
    repo = "github.com/bernd1995/LatSpec.jl",
    target = "build",
    push_preview = true
)
