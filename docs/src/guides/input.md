# Point sets and tolerance

## Point sets

A point set is any `AbstractVector` whose elements are objective vectors of
the same length `m ≥ 1` with finite real entries. Common forms:

```jldoctest input
julia> using MultiObjectiveMetrics

julia> F = [[0.0, 1.0], [0.5, 0.5], [1.0, 0.0]];       # vector of vectors

julia> M = [0.0 0.5 1.0; 1.0 0.5 0.0];                 # one point per column

julia> gamma_spread(eachcol(M), F) == gamma_spread(F, F)
true

julia> gamma_spread(eachrow(permutedims(M)), F)        # one point per row
0.5
```

`eachcol` and `eachrow` are views: no data are copied. Every function checks
that all points have the same length and finite values, and throws a
`DimensionMismatch` or an `ArgumentError` otherwise. All objectives are
minimized; negate an objective to maximize it. Results use the
floating-point type of the input (`Float32` in, `Float32` out).

## Dominance with tolerance

Objective values produced by solvers carry rounding errors, so two runs that
reach the same point rarely agree to the last bit. Comparisons therefore use a
componentwise tolerance ([`Tolerance`](@ref)),

```math
\varepsilon_i = \max\bigl(\mathrm{atol},\ \mathrm{rtol}\cdot\max(|u_i|, |v_i|)\bigr),
```

and [`compare`](@ref) classifies a pair of vectors as follows
[Fazzio2025ActiveSet](@cite):

- `u` dominates `v` if ``u_i \le v_i + \varepsilon_i`` for all ``i`` and
  ``u_j < v_j - \varepsilon_j`` for some ``j``;
- `u` and `v` are equivalent if ``|u_i - v_i| \le \varepsilon_i`` for all ``i``.

The default `Tolerance()` takes `atol = rtol = √eps(Float64) ≈ 1.5e-8`, so
``\varepsilon_i = 1.5\cdot 10^{-8}\max(1, |u_i|, |v_i|)``. `Tolerance(0)`
gives exact Pareto dominance. Every function that compares points accepts a
`tol` keyword.

```jldoctest input
julia> compare([1.0, 2.0], [1.0 + 1e-10, 2.0])
Equivalent::DominanceRelation = 0

julia> compare([1.0, 2.0], [1.0 + 1e-10, 2.0]; tol = Tolerance(0))
Dominates::DominanceRelation = 1
```

With a positive tolerance, dominance is not transitive: `a` may dominate `b`
and `b` dominate `c` while `a` and `c` are equivalent. [`nondominated`](@ref)
keeps a point exactly when no other point of the set dominates it, so the
result does not depend on the order of the input.
