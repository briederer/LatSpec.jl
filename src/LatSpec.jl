module LatSpec

import Base: show, convert
import LsqFit: curve_fit
import Statistics: mean
using RecipesBase

include("datapoint.jl")
include("parser.jl")
include("spectroscopy.jl")
include("statistics.jl")
include("theory.jl")
include("plots.jl")

export
    theory,
    theories,
    theory_name

export DataPoint, ±, value, staterr, syserr
export serieshistogram

const CURRENT_THEORY = CurrentTheory(:none)

end
