# This file should contain all recipes for plotting correlators, effective masses, volume plots, fits and channel-spectra (something else?)
# Automatically creating titles depending on settings in theory.jl (use Plots.default() for this)

"""
modifed version of https://discourse.julialang.org/t/plotting-histogram-on-the-y-axis-at-the-end-of-a-time-series/5381/8
Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
http://creativecommons.org/licenses/by-nc-sa/3.0/deed.en_US
"""
@userplot SeriesHistogram

@recipe function f(h::SeriesHistogram; xlabel1 = "", xlabel2 = "") # define extra keywords to use in the plotting
    mat = h.args[1]

    legend := false # specify the plot attributes
    link := :y
    grid := false
    layout := grid(1, 2, widths = [0.7, 0.3])

    @series begin         # send the different data to the different subplots
        subplot := 2
        seriestype := :histogram
        orientation := :h
        xguide := xlabel2
        title  := ""
        yguide := ""
        yticks := :none
        mat
    end

    subplot := 1
    linealpha --> 1.0
    seriestype := :path
    xguide := xlabel1
    yguide := ""
    mat
end
