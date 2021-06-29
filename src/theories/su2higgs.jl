#specific stuff for su2+higgs (fundamental and adjoint)
struct SU2HiggsTheory <: AbstractTheory
    rep::Symbol
end

export su2higgs

function SU2HiggsTheory( ;rep::Symbol = :fun)
    SU2HiggsTheory(rep)
end

export SM
SM() = su2higgs(rep = :fun)
