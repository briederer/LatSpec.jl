# Autocorrelation for a specifig lag
function autocor(x::AbstractVector, lag::Integer)
    # (wasteful in terms of allocations but clear)
    z = x .- mean(x)
    a = sum(z[1+lag:end].*z[1:end-lag])/sum(z.*z)
    return a
end
# Autocorrelation for a automatically choosen number of lags
function autocor(x)
    lx   = length(x)
    # heuristic for choosing a suitable number of lags
    lags = collect(0:min(lx-1, round(Int,10*log10(lx))))
    a = zeros(eltype(x),length(lags))
    for i in 1:length(lags)
        a[i] = autocor(x, lags[i])
    end
    return a
end
# Perform exponential fit of autocorrelation and extract characteristic time
function autotimeexp(O)
    a = autocor(O)
    @. modelτ(x,p) = abs.(p[2])*exp(-x/p[1])
    x = collect(1:length(a))
    c = curve_fit(modelτ, x, a, ones(2))
    τ = c.param[1]
    # if autocorrelation time τ is smaller than 1 return just 1
    return max(one(τ),τ)
end
