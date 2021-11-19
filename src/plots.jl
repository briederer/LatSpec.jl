# This file should contain all recipes for plotting correlators, effective masses, volume plots, fits and channel-spectra (something else?)
# Automatically creating titles depending on settings in theory.jl (use Plots.default() for this)
using RecipesBase

@recipe function plotDataPoint(D::AbstractArray{<:DataPoint})
    st = get(plotattributes,:seriestype,:path)
    if st == :scatter
        yerror := err.(D)
    else
        @series begin
            seriestype := st
            primary   := false
            linecolor := nothing
            fillcolor --> :red
            fillalpha --> 0.5
            fillrange := lower.(D)
            # ensure no markers are shown for the error band
            markershape := :none
            upper.(D)
        end
    end
    value.(D)
end

@recipe function plotDataPoint(x::AbstractArray, Dy::AbstractArray{<:DataPoint})
    st = get(plotattributes,:seriestype,:path)
    if st == :scatter
        yerror := err.(Dy)
    else
        @series begin
            seriestype := st
            primary   := false
            linecolor := nothing
            fillcolor --> :red
            fillalpha --> 0.5
            fillrange := lower.(Dy)
            # ensure no markers are shown for the error band
            markershape := :none
            x, upper.(Dy)
        end
    end
    x, value.(Dy)
end

@recipe function plotDataPoint(Dx::AbstractArray{<:DataPoint}, Dy::AbstractArray{<:DataPoint})
    xerror := err.(Dx)
    if st == :scatter
        yerror := err.(Dy)
    else
        @series begin
            seriestype := st
            primary   := false
            linecolor := nothing
            fillcolor --> :red
            fillalpha --> 0.5
            fillrange := lower.(Dy)
            # ensure no markers are shown for the error band
            markershape := :none
            x, upper.(Dy)
        end
    end
    value.(Dx), value.(Dy)
end

@recipe function plotDataPoint(Dx::AbstractArray{<:DataPoint}, y::AbstractArray)
    xerror := err.(Dx)
    value.(Dx), y
end
