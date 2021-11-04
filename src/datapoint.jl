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
# Helper functions
_to_tuple(x::T where T<:Number) = (x,x)
_to_tuple(x::Tuple) = promote(x...)
_to_tuple(x::T,y::U) where {T<:Number,U<:Number} = promote(x,y)
_check_error_positivity(err) = all(x -> (π/2 >= angle(x)>=0), err)

## Constructors
# default constructor               (calls immediately inner constructor)
DataPoint() = DataPoint{Float64}(0.0,_to_tuple(0.0))
# parameter constructors            (calls type-safe keyword constructor)
DataPoint(x::T, err) where {T <: Number} = DataPoint{T}(x, err = err)
DataPoint(x::T, lower, upper) where {T <: Number} = DataPoint{T}(x, err = _to_tuple(lower,upper))
# keyword constructor               (calls type-safe keyword constructor)
DataPoint(x::T; lower=zero(T), upper=zero(T)) where {T <: Number} = DataPoint{T}(x, err = _to_tuple(lower,upper))
# type-safe keyword constructor     (calls inner constructor)
function DataPoint{T}(x::T=zero(T); err=zero(T)) where {T <: Number}
    @assert _check_error_positivity(err) "Only use positive uncertainties!"
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
convert(::Type{DataPoint{T}}, D::DataPoint) where {T<:Number}    = DataPoint{T}(T(D.val),T.(D.err))
convert(::Type{DataPoint{T}}, D::DataPoint) where {T<:Integer} = DataPoint{T}(T(D.val),T.(ceil.(D.err)))

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
# sign-change
Base.:-(D::DataPoint) = DataPoint(-D.val,D.err[[2,1]])
# Math functions
@ErrorPropagation Base.log (x,dx)->abs(dx/x)
@ErrorPropagation Base.exp (x,dx)->abs(Base.exp(x)*dx)

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