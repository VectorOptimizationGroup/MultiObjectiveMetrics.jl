# Conventions

The sources define the metrics for non-empty fronts in general position and do
not discuss tolerances or degenerate cases. Where they are silent, this
package follows the conventions of MetricsRel.jl from
[MAMBO-paper](https://github.com/lfprudente/MAMBO-paper)
[Fazzio2025ActiveSet](@cite), except in the two cases marked below, where a
literal reading of the source gives a defined value.

## Edge cases

| Case | Γ, Δ | Purity | Covering | Normalized HV | Reason |
| --- | --- | --- | --- | --- | --- |
| empty front `A` (or `B` for covering) | `NaN` | `NaN` | `NaN` | `NaN` | no information; a failure in profiles |
| one point in `A` | `Inf` | defined | defined | defined | Δ needs at least two points (the mean gap is over ``N-1`` gaps); Γ follows Δ |
| `ideal[j] ≈ nadir[j]` | objective `j` skipped | — | — | guarded by `eps` | a constant objective has no spread |
| `ideal ≈ nadir` in every objective | `NaN` | — | — | `NaN` | no range to measure |
| points of `A` outside `[ideal, nadir]` | **clipped** | — | — | contribute zero if beyond the reference point | see below |
| all points of `A` equal in objective `j` | Δ: **``Δ_j = 1``** | — | — | — | see below |

Equivalence (`≈`) is the tolerance of [`Tolerance`](@ref). For Purity and
Covering, equivalent points count once, and Covering first reduces both sets
to their non-dominated points (the source assumes non-dominated sets). For Γ
and Δ the front is used as given, so repeated points lower the spread score,
as clustering should.

## Points beyond the extremes (Γ and Δ)

Γ and Δ measure the front of one solver between extreme values taken from the
reference front `R`, the non-dominated points of all solvers
[Custodio2011Direct](@cite). Formulas (5.1) and (5.2) of that paper sort the
values of each objective with the extremes at both ends, so they assume that
the front lies between the extremes. A point of `A` that `R` dominates can
violate this: its value may exceed the nadir of `R`.

Used literally, the last gap ``δ_{N,j} = \mathrm{nadir}_j - \max_i f_{i,j}`` becomes
negative and is subtracted from the numerator of Δ. A front made entirely of
dominated points can then score Δ = 0, the best possible value, or a negative
Δ. Example: with `R = [[0, 1], [0.5, 0.5], [1, 0]]`, the front
`A = [[0.6, 1.2], [1.2, 0.6], [3.0, 0.1]]` (all three points dominated by
`R`) gets Δ = 0 with the literal formula, the same value as `R` itself.

This package clips each value of `A` to ``[\mathrm{ideal}_j, \mathrm{nadir}_j]``
before computing Γ and Δ. Inside the box nothing changes; outside it, a point
beyond the nadir is treated as sitting on the nadir. Then Δ ≥ 0 and
``Γ \le \max_j (\mathrm{nadir}_j - \mathrm{ideal}_j)`` always hold. In the
example, Δ(A) = 1.

```jldoctest
julia> using MultiObjectiveMetrics

julia> R = [[0.0, 1.0], [0.5, 0.5], [1.0, 0.0]];

julia> A = [[0.6, 1.2], [1.2, 0.6], [3.0, 0.1]];

julia> delta_spread(A, R), delta_spread(R, R)
(1.0, 0.0)
```

## Collapsed objective (Δ)

If all points of `A` have the same value in objective `j`, every inner gap is
zero and formula (5.2) gives ``Δ_j = 1``: the numerator and the denominator
both equal ``\mathrm{nadir}_j - \mathrm{ideal}_j``. This agrees with
[Deb2002Fast](@cite), where Δ equals one when all solutions coincide. The
package uses this value. MetricsRel.jl skips such an objective instead.

## Differences from other implementations

| Topic | This package | MetricsRel.jl (MAMBO) |
| --- | --- | --- |
| Covering | weak dominance by default, as in [Zitzler1999Evolutionary](@cite) (Def. 9); `StrictDominance()` available | strict dominance |
| Γ, Δ outside `[ideal, nadir]` | clipped | literal formula (Δ can be negative) |
| Δ with a collapsed objective | ``Δ_j = 1`` | objective skipped |
| Non-dominated filter with tolerance | a point is kept when no other point dominates it | sequential archive |
| Hypervolume | exact, own implementation | Metaheuristics.jl |

The covering of Metaheuristics.jl also counts strict dominance, without tolerance.

The test suite checks every metric against values computed with MetricsRel.jl
and asserts each of these differences explicitly. The parity cases include
fronts inside and outside the box, duplicates, a single point, degenerate and
collapsed objectives, and two to four objectives. With
`relation = StrictDominance()` and with the front clipped, the values agree to
rounding.
