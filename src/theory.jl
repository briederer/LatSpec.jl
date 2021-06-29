# This file is supposed to do handle all specifications for separate theories like for instance `su2higgs()` sets all structs and functions to default which are needed for this particular theory.
# Not calling any theory should give warnings when ambigious functions are called

## General Theory type and default struct
struct UndefTheory <: AbstractTheory end

# for converting type to symbol and back
const _theoryType = Dict{Symbol, DataType}(:undef => UndefTheory)
const _theorySymbol = Dict{DataType, Symbol}(UndefTheory => :undef)
# supported theories
const _theories = Symbol[]
const _initialized_theories = Set{Symbol}()
const _default_theories = (:undef)

# Helper functions to get list of supported theories and current theories
"Returns a list of supported Theorys"
theories() = _theories

"Returns the name of the current Theory"
theory_name() = CURRENT_THEORY.sym

# Returns type of theory if supported
function _theory_instance(sym::Symbol)::AbstractTheory
    haskey(_theoryType, sym) ? _theoryType[sym]() : error("Unsupported theory $sym")
end

# macro for initializing new theories
macro init_theory(s)
    package_str = string(s)
    str = lowercase(package_str)
    sym = Symbol(str)
    T = Symbol(package_str * "Theory")
    predef = isdefined(LatSpec,T)
    esc(quote
        if (!$predef)
            struct $T <: AbstractTheory end
            export $sym
        end
        $sym(; kw...) = (#=default(; reset = false, kw...);=# theory($T(; kw...)))
        theory_name(::$T) = Symbol($str)
        push!(_theories, Symbol($str))
        _theoryType[Symbol($str)] = $T
        _theorySymbol[$T] = Symbol($str)
    end)
end

## Struct for currently activated theory
mutable struct CurrentTheory
    sym::Symbol
    theory::AbstractTheory
end
# Constructor
CurrentTheory(sym::Symbol) = CurrentTheory(sym,_theory_instance(sym))

## Default Theory
_fallback_default_theory() = theory(:undef)

function _pick_default_theory()
    env_default = get(ENV, "LATSPEC_DEFAULT_THEORY", "")
    if env_default != ""
        sym = Symbol(lowercase(env_default))
        if sym in _theories
            theory(sym)
        else
            @warn("You have set LATSPEC_DEFAULT_THEORY=$env_default but it is not a valid theory.  Choose from:\n\t" *
                 join(sort(_theories), "\n\t"))
            _fallback_default_theory()
        end
    else
        _fallback_default_theory()
    end
end

## Function overloads of theory
"""
Returns the current theory used for spectroscopy.  Initializes package on first call.
"""
function theory()
    if CURRENT_THEORY.sym == :undef
        _pick_default_theory()
    end

    CURRENT_THEORY.theory
end

"""
Set the Spectroscopy Theory.
"""
function theory(theory::AbstractTheory)
    sym = theory_name(theory)
    if !(sym in _initialized_theories)
        _initialize_theory(theory)
        push!(_initialized_theories, sym)
    end
    CURRENT_THEORY.sym = sym
    CURRENT_THEORY.theory = theory
    theory
end

function theory(sym::Symbol)
    if sym in _theories
        theory(_theory_instance(sym))
    else
        @warn("`:$sym` is not a supported theory.")
        theory()
    end
end

## Init supported theories
@init_theory Undef
@init_theory SU2Higgs
@init_theory SU3Higgs
@init_theory Sp4

# initialize the theory
function _initialize_theory(theory::AbstractTheory)
    sym = theory_name(theory)
    @eval Main begin
        println($sym, " has been initialized")
    end
end
