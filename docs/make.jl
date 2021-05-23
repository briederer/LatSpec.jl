using Documenter
using DocumenterCitations
using LatSpec

bib = CitationBibliography("LatSpec.bib")
makedocs(
    bib,
    sitename="LatSpec.jl",
    pages = [
        "Home"       => "index.md",
        "References" => "references.md"
    ],
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true")
)
