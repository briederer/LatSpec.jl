# This file should contain all recipes for plotting correlators, effective masses, volume plots, fits and channel-spectra (something else?)
# Automatically creating titles depending on settings in theory.jl (use Plots.default() for this)

"""
modifed version of https://discourse.julialang.org/t/plotting-histogram-on-the-y-axis-at-the-end-of-a-time-series/5381/8
Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
http://creativecommons.org/licenses/by-nc-sa/3.0/deed.en_US
"""

"""
    serieshistogram(x; xlabel1,xlabel2,ylabel1,ylabel2,yticks1,yticks2)

Plot both the series `x` and a histogram of `x`. The labels and ticks  of the
time series are exposed via the options `xlabel1`,`ylabel1` and `yticks1`. The
same options are exposed for the histogram through `xlabel2`,`ylabel2` and
`yticks2`.

"""
@userplot SeriesHistogram

@recipe function f(h::SeriesHistogram; yticks1 = :auto, yticks2 = :none, xlabel1 = "", xlabel2 = "", ylabel1 = "", ylabel2 = "") # define extra keywords to use in the plotting
    mat = h.args[1]

    legend := false # specify the plot attributes
    link := :y
    grid := false
    layout := RecipesBase.grid(1, 2, widths = [0.7, 0.3])

    @series begin         # send the different data to the different subplots
        subplot := 2
        seriestype := :histogram
        orientation := :h
        title  := ""
        xguide := xlabel2
        yguide := ylabel2
        yticks := yticks2
        mat
    end

    subplot := 1
    linealpha --> 1.0
    seriestype := :path
    xguide := xlabel1
    yguide := ylabel1
    yticks := yticks1
    mat
end
