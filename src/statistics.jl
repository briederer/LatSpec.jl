"""
    autocor(x,lag)

Returns autocorrelation function for a distance of lag, i.e. between values of
```x[t]``` and ```x[t+lag]```. The autocorrelation function is normalized such
that ```autocor(x,0) = 1```. This is equvivalent to the quantity
``\\Gamma_X(t)`` of equation (4.61) in [GattringerLang](@cite).
"""
function autocor(x, lag)
    # (wasteful in terms of allocations but clear)
    z = x .- mean(x)
    a = sum(z[1+lag:end].*z[1:end-lag])/sum(z.*z)
    return a
end
"""
    autocor(x)

Returns autocorrelation function for a set of lags from ``0`` up to the closest
integer to ``10 \\text{log}_{10}(l)``. Here ``l`` is the number of elements in
```x```.
"""
function autocor(x)
    lx   = length(x)
    lags = collect(0:min(lx-1, round(Int,10*log10(lx))))
    a = zeros(eltype(x),length(lags))
    for i in 1:length(lags)
        a[i] = autocor(x, lags[i])
    end
    return a
end
"""
    autotimeexp(x)

Returns ``\\max(1,\\tau)`` where ``\\tau`` is the exponential autocorrelation
time of a series of measurements ``x``. This is obtained by fitting the
autocorrelation function to an exponential function of the form
``A \\exp(\\frac{t}{\\tau})``.
"""
function autotimeexp(O)
    a = autocor(O)
    @. modelτ(x,p) = abs.(p[2])*exp(-x/p[1])
    x = collect(1:length(a))
    c = curve_fit(modelτ, x, a, ones(2))
    τ = c.param[1]
    return max(one(τ),τ)
end
