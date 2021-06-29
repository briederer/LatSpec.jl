module LatSpec

include("parser.jl")
include("plots.jl")
include("spectroscopy.jl")
include("statistics.jl")

# Theory section
abstract type AbstractTheory end
include("theories/su2higgs.jl")
include("theory.jl")
include("statistics.jl")

import LsqFit: curve_fit
import Statistics: mean


export
    theory,
    theories,
    theory_name

const CURRENT_THEORY = CurrentTheory(:undef)

end
