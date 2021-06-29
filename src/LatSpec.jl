module LatSpec

import Base: show, convert
import LsqFit: curve_fit
import Statistics: mean

include("datapoint.jl")
include("parser.jl")
include("plots.jl")
include("spectroscopy.jl")
include("statistics.jl")
include("theory.jl")


export
    theory,
    theories,
    theory_name

export DataPoint, ±, value, staterr, syserr

const CURRENT_THEORY = CurrentTheory(:none)

end
