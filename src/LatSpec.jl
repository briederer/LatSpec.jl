module LatSpec

include("parser.jl")
include("plots.jl")
include("spectroscopy.jl")
include("theory.jl")
include("statistics.jl")

import LsqFit: curve_fit
import Statistics: mean

export
    theory,
    theories,
    theory_name

const CURRENT_THEORY = CurrentTheory(:none)

end
