# Covering

The covering (C-metric) of a front ``B`` by a front ``A`` is the fraction of
``B`` weakly dominated by ``A`` [Zitzler1999Evolutionary](@cite) (Def. 9),
[Zitzler1998Multiobjective](@cite):

```math
C(A, B) = \frac{|\{\, b \in B : \exists\, a \in A,\ a \preceq b \,\}|}{|B|} \in [0, 1],
```

where ``a \preceq b`` (``a`` covers ``b``) means that ``a`` dominates ``b`` or
equals it (Def. 4 of [Zitzler1999Evolutionary](@cite)). ``C(A, B) = 1`` means
that every point of ``B`` is covered. The metric is not symmetric and
``C(A, B) \ne 1 - C(B, A)`` in general, so report both directions.

Some implementations count only strict dominance, so a point shared by both
fronts is not covered. [`covering`](@ref) uses weak dominance by default and
strict dominance with `relation = StrictDominance()`:

```jldoctest
julia> using MultiObjectiveMetrics

julia> A = [[0.0, 1.0], [1.0, 0.0]]; B = [[0.0, 1.0], [2.0, 0.5]];

julia> covering(A, B), covering(A, B; relation = StrictDominance())
(1.0, 0.5)
```

```@docs
covering
```
