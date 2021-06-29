using LatSpec
using Test

@testset verbose=true "LatSpec.jl" begin
    include("datapoint.jl")
    include("statistics.jl")
end
