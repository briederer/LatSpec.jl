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
    # here are some allocations that are not strictly needed
    val = value.(c)
    stat = staterr.(c)
    sys = syserr.(c)
    return DataPoint.(effectivemass(val),effectivemass_err_stat(val,stat),effectivemass_err_sys(val,sys))
end
function effectivemass_cosh(c)
    T = length(c)
    t = 1:T
    mid  = div(T,2)+1 # 1-based indexing
    return @. abs(acosh(c/c[mid])/(mid-t))
end
_acoshderiv(x) = 1/sqrt(x^2 + 1)
function effectivemass_cosh_err(c,Δc;norm=1)
    T = length(c)
    mid  = div(T,2) + 1 # 1-based indexing
    Δm = similar(c)
    for t in 1:T
        err1 = _acoshderiv(c[t]/c[mid])*Δc[t]/c[mid]
        err2 = _acoshderiv(c[t]/c[mid])*c[t]*Δc[mid]/c[mid]^2
        Δm[t] = LinearAlgebra.norm((err1,err2),norm)/abs(mid-t)
    end
    return Δm
end
