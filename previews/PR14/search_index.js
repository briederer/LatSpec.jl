var documenterSearchIndex = {"docs":
[{"location":"references/","page":"References","title":"References","text":"","category":"page"},{"location":"#LatSpec.jl-Documentation","page":"Home","title":"LatSpec.jl Documentation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = LatSpec","category":"page"},{"location":"","page":"Home","title":"Home","text":"autocor\nautotimeexp","category":"page"},{"location":"#LatSpec.autocor","page":"Home","title":"LatSpec.autocor","text":"autocor(x,lag)\n\nReturns autocorrelation function for a distance of lag, i.e. between values of x[t] and x[t+lag]. The autocorrelation function is normalized such that autocor(x,0) = 1. This is equvivalent to the quantity Gamma_X(t) of equation (4.61) in  Gattringer/Lang  (2010).\n\n\n\n\n\nautocor(x)\n\nReturns autocorrelation function for a set of lags from 0 up to the closest integer to 10 textlog_10(l). Here l is the number of elements in x.\n\n\n\n\n\n","category":"function"},{"location":"#LatSpec.autotimeexp","page":"Home","title":"LatSpec.autotimeexp","text":"autotimeexp(x)\n\nReturns max(1tau) where tau is the exponential autocorrelation time of a series of measurements x. This is obtained by fitting the autocorrelation function to an exponential function of the form A exp(fracttau).\n\n\n\n\n\n","category":"function"}]
}
