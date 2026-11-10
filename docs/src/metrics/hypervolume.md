# Hypervolume

The hypervolume of a set ``F`` with respect to a reference point ``r`` is the
volume of the region dominated by ``F`` and bounded by ``r``
[Zitzler1998Multiobjective](@cite), [Zitzler1999Evolutionary](@cite)
(Def. 8), [Audet2021Performance](@cite):

```math
\mathrm{HV}(F; r) = \lambda_m\Bigl(\bigcup_{y \in F} [y_1, r_1] \times \dots \times [y_m, r_m]\Bigr).
```

Higher is better. [`hypervolume`](@ref) computes it exactly:

- ``m = 2``: sort by the first objective and add one rectangle per point;
- ``m = 3``: the dimension sweep of Paquete et al. described in
  [Fonseca2006Improved](@cite) (Section III-A), sweeping the third objective
  and keeping the non-dominated projections on the first two;
- ``m \ge 4``: the slicing recursion of [Fonseca2006Improved](@cite)
  (Algorithm 1) along the last objective, down to the three-dimensional case.

The value depends strongly on ``r``, so the reference point is always an
argument [Ishibuchi2018How](@cite).

## Normalized hypervolume

[`normalized_hypervolume`](@ref) follows the convention of
[Fazzio2025ActiveSet](@cite) (Section 7.2): map each objective by
``\tilde y_j = (y_j - \mathrm{ideal}_j)/(\mathrm{nadir}_j - \mathrm{ideal}_j)``
with ideal and nadir of the reference front, take ``r = (1.1, \dots, 1.1)``,
and divide by ``1.1^m`` so that the value lies in ``[0, 1]``:

```math
\mathrm{HV}_{\mathrm{norm}}(F) = \frac{\mathrm{HV}(\tilde F; (1.1, \dots, 1.1))}{1.1^m}.
```

Normalizing and placing the reference point slightly beyond the nadir is
common practice, but no numerical rule is standard: [Ishibuchi2018How](@cite)
shows that ``1.1`` is not always appropriate and proposes a rule that depends
on the number of points and objectives. The offset ``1.1`` and the division by
``1.1^m`` are therefore a convention, adjustable through `offset`.

```jldoctest
julia> using MultiObjectiveMetrics

julia> hypervolume([[1.0, 2.0], [2.0, 1.0]], [3.0, 3.0])
3.0

julia> R = [[0.0, 1.0], [1.0, 0.0]];

julia> normalized_hypervolume(R, R) ≈ 0.21 / 1.21
true
```

```@docs
hypervolume
normalize_points
normalized_hypervolume
```
