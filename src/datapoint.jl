## New Type: DataPoint
# Struct for carrying statistic and systematic uncertainty of a DataPoint
"""
    DataPoint(x,stat,sys)
Parametric type that stores a value and its respective statistical and systematic
uncertainties. The uncertainties can either be numbers for symmetric uncertainties
or a tuple for upper and lower bounds. It can be created by either providing
positional arguments ( e.g. `DataPoint(1.0,0.1,0.2)` or
`DataPoint(1.0,(0.09,0.11),(0.21,0.19))`) or using the keyword arguments `stat`
and `sys` ( e.g. `DataPoint(1.0,stat=0.1,sys=0.2) . If only one uncertainty is
provided without a keyword, it is assumed to be statistical.

It can also be created by using the ± symbol, e.g. `x ± stat` and `x ± stat ± sys`.
"""
struct DataPoint{T<:Number} <: Number
    val::T
    stat_err::Tuple{T,T}
    sys_err::Tuple{T,T}
end
"""
    value(x::DataPoint)
Returns the mean value of the data point.
"""
value(x::DataPoint) = x.val
"""
    staterr(x::DataPoint)
Returns the statistical uncertainty of the data point as a tuple of upper and
lower bounds. If none is provided it will default to zero.
"""
staterr(x::DataPoint) = x.stat_err
"""
    syserr(x::DataPoint)
Returns the systematic uncertainty of the data point as a tuple of upper and
lower bounds. If none is provided it will default to zero.
"""
syserr(x::DataPoint) = x.sys_err
# Helper functions
_to_tuple(x::T where T<:Number) = (x,x)
_to_tuple(x::Tuple) = promote(x...)
_check_error_positivity(err) = all(x -> (π/2 >= angle(x)>=0), err)

## Constructors
# default constructor
DataPoint() = DataPoint(NaN, (NaN, NaN), (NaN, NaN))
# dispatch constructor
DataPoint(x::Number, stat, sys = zero(x)) = DataPoint(x, stat = stat, sys = sys)
# keyword constructor for integers (ceils uncertainties)
# function DataPoint(x::Integer; stat=zero(x), sys=zero(x))
#     @assert _check_error_positivity(stat) && _check_error_positivity(sys) "Only use positive uncertainties!"
#     stat = _to_tuple(stat)
#     sys = _to_tuple(sys)
#     T = typeof(x)
#     DataPoint(x,T.(ceil.(stat)),T.(ceil.(sys)))
# end
# keyword constructor for real numbers
function DataPoint(x::Number; stat=zero(x), sys=zero(x))
    @assert _check_error_positivity(stat) && _check_error_positivity(sys) "Only use positive uncertainties!"
    stat = _to_tuple(stat)
    sys = _to_tuple(sys)
    T = promote_type(typeof(x), eltype(stat), eltype(sys))
    DataPoint(T(x),T.(stat),T.(sys))   # with keywords
end
# Operators for construction
const ±(val, err) = DataPoint(val, err)
const ±(val, err::NamedTuple) = DataPoint(val, hasproperty(err,:stat) ? err.stat : zero(val), hasproperty(err,:sys) ? err.sys : zero(val))
const ±(D::DataPoint, sys) = DataPoint(D.val, D.stat_err, sys)

## Convert DataPoint-types
convert(::Type{DataPoint{T}}, D::DataPoint) where {T} = DataPoint{T}(T( D.val),T.(D.stat_err), T.(D.sys_err))
convert(::Type{DataPoint{T}}, D::DataPoint) where {T<:Integer} = DataPoint{T}(T(D.val),T.(ceil.(D.stat_err)), T.(ceil.(D.sys_err)))

## Pretty-printing
# Printing of results
function show(io::IO, ::MIME"text/plain", D::DataPoint{T}; drop::Bool = true) where {T}
    println(io, "DataPoint{",T,"}:")
    print(io, "Value → ", D.val)
    if (!drop || D.stat_err != (0,0)) print(io, "\tStatistic unc. → ", (1,-1) .* D.stat_err); end
    if (!drop || D.sys_err != (0,0)) print(io, "\tSystematic unc. → ", (1,-1) .* D.sys_err); end
end

# Print(ln)-function and Juno-Workspace
function show(io::IO, D::DataPoint{T}) where {T}
    if get(io, :compact, false)     # e.g. in arrays
        print(io, D.val, " ± ", D.stat_err)
        print(io, " ± ", D.sys_err)
    else
        show(io, MIME("text/plain"), D; drop = false)
    end
end
