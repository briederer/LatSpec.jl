# This file should contain all recipes for plotting correlators, effective masses, volume plots, fits and channel-spectra (something else?)
# Automatically creating titles depending on settings in theory.jl (use Plots.default() for this)
using RecipesBase

@recipe function plotDataPoint(D::AbstractArray{<:DataPoint})
    yerror := err.(D)
    value.(D)
end

@recipe function plotDataPoint(x::AbstractArray, Dy::AbstractArray{<:DataPoint})
    yerror := err.(Dy)
    x, value.(Dy)
end

@recipe function plotDataPoint(Dx::AbstractArray{<:DataPoint}, Dy::AbstractArray{<:DataPoint})
    xerror := err.(Dx)
    yerror := err.(Dy)
    value.(Dx), value.(Dy)
end

@recipe function plotDataPoint(Dx::AbstractArray{<:DataPoint}, y::AbstractArray)
    xerror := err.(Dx)
    value.(Dx), y
end
