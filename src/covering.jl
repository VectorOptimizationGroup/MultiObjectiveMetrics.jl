"""
    covering(A, B; relation = WeakDominance(), tol = Tolerance())

Covering (C-metric) of `B` by `A` [Zitzler1998Multiobjective](@cite), [Zitzler1999Evolutionary](@cite) (Def. 9):
the fraction of the points of `B` covered by at least one point of `A`,

    C(A, B) = |{b ∈ B : ∃ a ∈ A, a ⪰ b}| / |B|.

With the default [`WeakDominance`](@ref), `a ⪰ b` means that `a` dominates or
equals `b`, as in the source. [`StrictDominance`](@ref) does not count equal
points; it reproduces the covering of [Fazzio2025ActiveSet](@cite) and of
Metaheuristics.jl. Before counting, both sets are reduced to their
non-dominated points and equivalent points are counted once.

`C(A, B) = 1` means that `A` covers all of `B`. The metric is not symmetric;
report both `C(A, B)` and `C(B, A)`. Returns `NaN` when `B` is empty.

# Examples

```jldoctest
julia> A = [[0.0, 1.0], [1.0, 0.0]]; B = [[0.0, 1.0], [2.0, 0.5]];

julia> covering(A, B)
1.0

julia> covering(A, B; relation = StrictDominance())
0.5
```
"""
function covering(A::PointSet, B::PointSet; relation::AbstractDominance = WeakDominance(),
                  tol::Tolerance = Tolerance())
    _checkpoints(A, B, "A", "B")
    T = _floattype(A, B)
    Bs = _reduced(B, tol)
    isempty(Bs) && return T(NaN)
    As = _reduced(A, tol)
    count = 0
    for b in Bs
        any(a -> dominates(relation, a, b; tol), As) && (count += 1)
    end
    return T(count) / T(length(Bs))
end

# Non-dominated points with equivalent points counted once.
function _reduced(F::PointSet, tol::Tolerance)
    nd = nondominated(F; tol)
    return unique_points(nd; tol)
end
