## New Type: DataPoint
"""
    DataPoint(x,err)
Parametric type that stores a value and its respective statistical uncertainty.
The uncertainty can either be a number for a symmetric uncertainty or a tuple
for lower and upper bounds. It can be created by either providing
positional arguments (e.g. `DataPoint(1.0,0.1)` or `DataPoint(1.0,(0.09,0.11))`)
or by using the keyword arguments `lower` and `upper`
(e.g. `DataPoint(1.0,lower=0.1,upper=0.2). If only one keyword is given, the
other is assumed to be zero.

It can also be created by using the ± symbol, e.g. `x ± err` with err a `Number`,
a usual `Tuple{Number,Number}` or a NamedTuple for using the keyword arguments.
"""
struct DataPoint{T<:Number} <: Number
    val::T
    err::Tuple{T,T}
    DataPoint{T}(val,err) where {T<:Number} = new(val,err)
end
"""
    value(x::DataPoint)
Returns the mean value of the data point.
"""
value(x::DataPoint) = x.val
"""
    err(x::DataPoint)
Returns the uncertainty of the data point as a tuple of lower and
upper bounds. If none is provided it will default to zero.
"""
err(x::DataPoint) = x.err
"""
    relerr(x::DataPoint)
Returns the relative uncertainty of the data point as a tuple of lower and upper
relative uncertainties.
"""
relerr(x::DataPoint) = x.err ./ abs(x.val)
"""
    bounds(x::DataPoint)
Returns a tuple with the lower and upper bound of this DatPoint.
"""
#TODO: I would like to have an inverse function of that, but don't know how to implement it nicely and how to name it
bounds(x::DataPoint) = @. x.val + (-1,1)*x.err
"""
    lower(x::DataPoint)
Returns the lower bound of the data point.
"""
lower(x::DataPoint) = x.val - x.err[1]
"""
    upper(x::DataPoint)
Returns the upper bound of the data point.
"""
upper(x::DataPoint) = x.val + x.err[2]
# Helper functions
_to_tuple(x::T where T<:Number) = (x,x)
_to_tuple(x::Tuple) = promote(x...)
_to_tuple(x::T,y::U) where {T<:Number,U<:Number} = promote(x,y)
_check_error_positivity(err) = all(x -> isnan(x) || (π/2 >= angle(x)>=0), err)

## Constructors
# default constructor               (calls immediately inner constructor)
DataPoint() = DataPoint{Float64}(0.0,_to_tuple(0.0))
# parameter constructors            (calls type-safe keyword constructor)
DataPoint(x::T, err; kws...) where {T <: Number} = DataPoint{T}(x, err = err; kws...)
DataPoint(x::T, lower, upper; kws...) where {T <: Number} = DataPoint{T}(x, err = _to_tuple(lower,upper); kws...)
# keyword constructor               (calls type-safe keyword constructor)
DataPoint(x::T; lower=zero(T), upper=zero(T), kws...) where {T <: Number} = DataPoint{T}(x, err = _to_tuple(lower,upper); kws...)
# type-safe keyword constructor     (calls inner constructor)
function DataPoint{T}(x::T=zero(T); err=zero(T), check::Bool = true) where {T <: Number}
    isnan(x) && return DataPoint{T}(NaN,(NaN,NaN))
    check && @assert _check_error_positivity(err) "Only use positive uncertainties!"
    err = _to_tuple(err)
    U = promote_type(typeof(x), eltype(err))
    DataPoint{U}(x,err)
end
# Operators for construction
# common operators                  (calls parameter constructor)
const ±(val, err) = DataPoint(val, err)
# "keyword" operator                (calls parameter constructor)
const ±(val, err::NamedTuple) = DataPoint(val, (get(err,:lower,zero(val)), get(err,:upper,zero(val))))

## Convert DataPoint-types
Base.convert(::Type{DataPoint{T}}, D::DataPoint) where {T<:Number}    = DataPoint{T}(T(D.val),T.(D.err))
Base.convert(::Type{DataPoint{T}}, D::DataPoint) where {T<:Integer}   = DataPoint{T}(T(D.val),T.(ceil.(D.err)))
Base.convert(::Type{DataPoint{T}}, x::U) where {T<:Number,U<:Number}  = DataPoint{T}(T(x))
Base.promote_rule(::Type{Vector{DataPoint{T}}}, ::Type{Vector{T}}) where {T<:Number} = Vector{Number}
Base.promote_rule(::Type{Vector{T}}, ::Type{Vector{DataPoint{T}}}) where {T<:Number} = Vector{Number}
Base.promote_rule(::Type{DataPoint{T}}, ::Type{U}) where {T<:Number,U<:Number} = DataPoint{T}
Base.Complex(D::DataPoint{T}) where {T<:Number} = DataPoint(Complex(D.val), Complex.(D.err))
## ErrorPropagation macro
"""
    @ErrorPropagation function derivative
Creates overloads for the given function to work with the `DataPoint` type.
More info to be added.
"""
macro ErrorPropagation(funname, derivative)
    esc(quote
        possders = [der.nargs-1 for der in methods($derivative)]
        if (2 ∈ possders && applicable($funname,zeros(1)...))
            function $funname(D::DataPoint)
                DataPoint($funname(D.val),@. $derivative(D.val,D.err))
            end
        elseif (2 ∈ possders && !applicable($funname,zeros(1)...))
            @error("There is no function $($funname) with 1 variable!")
        end
        if (4 ∈ possders && applicable($funname,zeros(2)...))
            function $funname(D1::DataPoint, D2::DataPoint)
                DataPoint($funname(D1.val, D2.val),@. $derivative(D1.val,D1.err,D2.val,D2.err))
            end

            function $funname(D::DataPoint, s::T) where {T<:Number}
                DataPoint($funname(D.val, s),@. $derivative(D.val,D.err,s,zero(T)))
            end

            function $funname(s::T, D::DataPoint) where {T<:Number}
                DataPoint($funname(s,D.val),@. $derivative(s,zero(T),D.val,D.err))
            end
        elseif (4 ∈ possders && !applicable($funname,zeros(2)...))
            @error("There is no function $($funname) with 2 variables!")
        end
        if (any(possders.>=5))
            @warn "Functions in more than 2 variables are not supported!\nPlease create manual overloads for this case."
        end
    end)
end

macro OperatorErrorPropagation(op, derivative)
    esc(quote
        function $op(D1::DataPoint, D2::DataPoint)
            DataPoint($op(D1.val, D2.val),@.$derivative(D1.val,D1.err,D2.val,D2.err))
        end

        function $op(D::DataPoint, s::T) where {T<:Number}
            DataPoint($op(D.val, s),@.$derivative(D.val,D.err,s,zero(T)))
        end

        function $op(s::T, D::DataPoint) where {T<:Number}
            DataPoint($op(s,D.val),@.$derivative(s,zero(T),D.val,D.err))
        end
    end)
end
## DataPoint math
# Binary operators
@OperatorErrorPropagation Base.:/ (x,dx,y,dy)->sqrt((dx/y)^2.0+(x*dy/y^2.0)^2.0)
@OperatorErrorPropagation Base.:* (x,dx,y,dy)->sqrt((x*dy)^2.0+(y*dx)^2.0)
@OperatorErrorPropagation Base.:+ (x,dx,y,dy)->sqrt(dx^2.0+dy^2.0)
@OperatorErrorPropagation Base.:- (x,dx,y,dy)->sqrt(dx^2.0+dy^2.0)
@OperatorErrorPropagation Base.:^ (x,dx,y,dy)->sqrt((y*x^(y-1.0)*dx)^2.0+(x^y*Base.log(x)*dy)^2.0)
# sign-change
Base.:-(D::DataPoint) = DataPoint(-D.val,reverse(D.err))
Base.abs(D::DataPoint{T}) where {T} = (value(D) < zero(T) ? -D : D)
Base.zero(D::DataPoint{T}) where {T} = DataPoint{T}()
Base.isless(D1::DataPoint,D2::DataPoint) = Base.isless(value(D1),value(D2))
Base.isless(D::DataPoint,x) = Base.isless(value(D),x)
Base.isless(x,D::DataPoint) = Base.isless(x,value(D))
Base.isnan(D::DataPoint) = all(Base.isnan(value(D)) && Base.isnan.(err(D)))
function Base.sort(D::DataPoint)
    d⁻, d, d⁺ = sort([value(D),bounds(D)...])
    d⁻ = d - d⁻
    d⁺ = d⁺ - d
    DataPoint(d,d⁻,d⁺)
end
# Math functions
@ErrorPropagation Base.real (x,dx)->real(dx)
@ErrorPropagation Base.imag (x,dx)->imag(dx)
@ErrorPropagation Base.log (x,dx)->abs(dx/x)
@ErrorPropagation Base.exp (x,dx)->abs(Base.exp(x)*dx)
@ErrorPropagation Base.sqrt (x,dx)->abs(dx/(2.0*Base.sqrt(x)))
@ErrorPropagation Base.sin (x,dx)->abs(Base.cos(x)*dx)
@ErrorPropagation Base.cos (x,dx)->abs(Base.sin(x)*dx)
@ErrorPropagation Base.tan (x,dx)->abs((1.0+Base.tan(x)^2.0)*dx)
@ErrorPropagation Base.cot (x,dx)->abs((1.0+Base.cot(x)^2.0)*dx)
@ErrorPropagation Base.asin (x,dx)->abs(dx/Base.sqrt(1.0-x^2.0))
@ErrorPropagation Base.acos (x,dx)->abs(dx/Base.sqrt(1.0-x^2.0))
@ErrorPropagation Base.atan (x,dx)->abs(dx/(1.0+x^2.0))
@ErrorPropagation Base.atan (x,dx,y,dy)->sqrt((dx*y)^2.0+(dy*x)^2.0)/(x^2.0+y^2.0)
@ErrorPropagation Base.acot (x,dx)->abs(dx/(1.0+x^2.0))
@ErrorPropagation Base.sinh (x,dx)->abs(Base.cosh(x)*dx)
@ErrorPropagation Base.cosh (x,dx)->abs(Base.sinh(x)*dx)
@ErrorPropagation Base.acosh (x,dx)->abs(dx/Base.sqrt(x^2-1))
@ErrorPropagation Base.asinh (x,dx)->abs(dx/Base.sqrt(x^2+1))

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
