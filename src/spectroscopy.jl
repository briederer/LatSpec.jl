# This file should contain all spectroscopy specifc stuff like correlators, fits, effective masses, ...
function effectivemass(c)
    N = length(c)
    m = similar(c)
    for i in 1:N
        r = c[i]/c[mod1(i+1,N)]
        m[i] = r > 0 ? abs(log(r)) : NaN
    end
    return m
end
function effectivemass_err(c,Δc;norm=1)
    N  = length(c)
    Δm = similar(c)
    for i in 1:N
        j = mod1(i+1,N)
        Δm[i] = norm(Δc[i]/c[i],Δc[j]/c[j],p=norm)
    end
    return Δm
end
effectivemass_err_sys(c,Δc)  = effectivemass_err(c,Δc,norm=1)
effectivemass_err_stat(c,Δc) = effectivemass_err(c,Δc,norm=2)
"""
    effectivemass(c)

Returns the effectivemass ``m_\\text{eff}(t)`` of the data ```x``` given by ``
m_\\text{eff}(t) = \\left| \\log \\left( \\frac{x(t)}{x(t+1)} \\right) \\right| ``. If
```x``` is a vector of ```DataPoint```'s the statistical and systematic
uncertainties are propagated accordingly. If ```x <: Number``` only the the mean
value is calculated. In that case the unexported methods
```effectivemass_err_stat(x,Δx)``` and ```effectivemass_err_sys(x,Δx)``` can be
used for propagation of uncertainty.
"""
function effectivemass(c::Vector{DataPoint{T}}) where T
    val = getfield.(c,:val)
    stat = getfield.(c,:stat)
    sys = getfield.(c,:sys)
    return DataPoint.(effectivemass(val),effectivemass_err_stat(val,stat),effectivemass_err_sys(val,sys))
end
