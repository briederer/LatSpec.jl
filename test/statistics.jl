@testset "statistics" begin
    # taken from StatsBase.jl
    @test LatSpec.autocor(1.0:5.0) ≈ [1.0, 0.4, -0.1, -0.4, -0.4]
    # uncorrelated random numbers should give a autocorrelation time of one
    @test LatSpec.autotimeexp(rand(100)) ≈ 1
    # TODO: we still need a test for autocorrelated data 
end 
