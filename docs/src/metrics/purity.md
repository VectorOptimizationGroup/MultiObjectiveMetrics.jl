# Purity

Let ``\mathcal{F}_s`` be the non-dominated front returned by solver ``s`` and
``\mathcal{F}`` the non-dominated points of ``\bigcup_s \mathcal{F}_s``. Purity
is the fraction of the points of ``\mathcal{F}_s`` that remain non-dominated
when all fronts are merged [Bandyopadhyay2004Multiobjective](@cite) (eq. 7–8),
[Custodio2011Direct](@cite) (Section 5.3.2):

```math
\bar t_s = \frac{|\mathcal{F}_s \cap \mathcal{F}|}{|\mathcal{F}_s|} \in [0, 1].
```

The denominator is the size of the solver's own front. Higher is better; in a
performance profile use ``t_s = 1/\bar t_s``, which is ``+\infty`` when the
solver contributes no point to ``\mathcal{F}``.

In [`purity`](@ref), membership in ``\mathcal{F}`` means equivalence to some
point of `R` under the tolerance, and equivalent points of `A` count once,
since the source treats fronts as sets.

```jldoctest
julia> using MultiObjectiveMetrics

julia> A = [[0.0, 1.0], [0.6, 0.6], [1.0, 0.0]]; B = [[0.5, 0.5]];

julia> R = nondominated(vcat(A, B));

julia> purity(A, R), purity(B, R)
(0.6666666666666666, 1.0)
```

```@docs
purity
```
