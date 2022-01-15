using Plots

@testset "plotting" begin
    x = randn(1000)
    plt = serieshistogram(x,ylabel1="values",xlabel1="time series",xlabel2="histogram")
    @test typeof(plt) <: Plots.Plot
end
