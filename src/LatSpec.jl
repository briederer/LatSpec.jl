module LatSpec

include("parser.jl")
include("plots.jl")
include("spectroscopy.jl")
include("theory.jl")

export
    theory,
    theories,
    theory_name

const CURRENT_THEORY = CurrentTheory(:none)

end
