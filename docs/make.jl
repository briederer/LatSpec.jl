using Documenter
using DocumenterCitations
using LatSpec

bib = CitationBibliography("LatSpec.bib")
const PAGES = [
               "Home"       => "index.md",
               "References" => "references.md"
              ]

makedocs(
    bib,
    sitename="LatSpec.jl",
    pages = PAGES,
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    authors = "Bernd Riederer and Fabian Zierler"
)

deploydocs(
    repo = "github.com/bernd1995/LatSpec.jl",
    push_review = true
)
