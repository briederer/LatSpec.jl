## New Type: DataPoint
# Struct for carrying statistic and systematic uncertainty of a DataPoint
"""
    DataPoint(x,err)
Parametric type that stores a value and its respective statistical uncertainty.
The uncertainty can either be a number for a symmetric uncertainty or a tuple
for lower and upper bounds. It can be created by either providing
positional arguments (e.g. `DataPoint(1.0,0.1)` or `DataPoint(1.0,(0.09,0.11))`)
or by using the keyword arguments `lower` and `upper`
(e.g. `DataPoint(1.0,lower=0.1,upper=0.2). If only one keyword is given, the
other is assumed to be zero.

It can also be created by using the ± symbol, e.g. `x ± err`.
"""
struct DataPoint{T<:Number} <: Number
    val::T
    err::Tuple{T,T}
end
"""
    value(x::DataPoint)
Returns the mean value of the data point.
"""
value(x::DataPoint) = x.val
"""
    err(x::DataPoint)
Returns the statistical uncertainty of the data point as a tuple of upper and
lower bounds. If none is provided it will default to zero.
"""
err(x::DataPoint) = x.err

relerr(x::DataPoint) = x.err / abs(x.val)

bounds(x::DataPoint) = @. x.val + (-1,1)*x.err
# Helper functions
_to_tuple(x::T where T<:Number) = (x,x)
_to_tuple(x::Tuple) = promote(x...)
_check_error_positivity(err) = all(x -> (π/2 >= angle(x)>=0), err)

## Constructors
# default constructor
DataPoint(x::T, err=zero(T)) where {T} = DataPoint{T}(x, err=err)
DataPoint() = DataPoint{Float64}(0.0)
# keyword constructor for separate errors
#function DataPoint{T}()
# keyword constructor for real numbers
function DataPoint{T}(x::T=zero(T); err=zero(T)) where {T <: Number}
    @assert _check_error_positivity(err) "Only use positive uncertainties!"
    err = _to_tuple(err)
    U = promote_type(typeof(x), eltype(err))
    DataPoint{U}(x,err)
end
# Operators for construction
const ±(val, err) = DataPoint(val, err)
#const ±(val, err::NamedTuple) = DataPoint(val, hasproperty(err,:stat) ? err.stat : zero(val), hasproperty(err,:sys) ? err.sys : zero(val))


## Convert DataPoint-types
convert(::Type{DataPoint{T}}, D::DataPoint) where {T} = DataPoint{T}(T(D.val),T.(D.err))
convert(::Type{DataPoint{T}}, D::DataPoint) where {T<:Integer} = DataPoint{T}(T(D.val),T.(ceil.(D.err)))
convert(::Type{DataPoint{T}}, D::DataPoint) where {T} = DataPoint{T}(T(D.val),T.(D.err))

## DataPoint math
Base.:/(D::DataPoint, s::T) where {T <: Number} = DataPoint(D.val/s,D.err/s)
function Base.:/(D1::DataPoint, D2::DataPoint)
    err = abs.(D1.err/D2.val) .+ abs.(D1.val/D2.val^2.0 .* D2.err)
    DataPoint(D1.val/D2.val,err)
end
Base.:*(D::DataPoint, s::T) where {T <: Number} = DataPoint(D.val*s,D.err*s)
function Base.log(D::DataPoint, kws...)
    DataPoint(log(D.val, kws...),abs.(D.err./D.val))
end

## Pretty-printing
# Printing of results
function show(io::IO, ::MIME"text/plain", D::DataPoint{T}; drop::Bool = true) where {T}
    println(io, "DataPoint{",T,"}:")
    print(io, "Value → ")
    show(io, D.val)
    if (!drop || D.err != (0,0)) print(io, "\tStatistic unc. → ", (-1,1) .* D.err); end
end

# Print(ln)-function and Juno-Workspace
function show(io::IO, D::DataPoint{T}) where {T}
    if get(io, :compact, false)     # e.g. in arrays
        print(io, D.val, " ± ", D.err)
    else
        show(io, MIME("text/plain"), D; drop = false)
    end
end
