# Spread metrics

Γ and Δ measure how well a front of ``N`` points spreads between extreme
values that are the same for all solvers [Custodio2011Direct](@cite)
(Section 5.3.3). The extremes come from the reference front `R`, the
non-dominated points of all solvers: for each objective ``j``,
``f_{0,j} = \min_{y \in R} y_j`` (ideal) and ``f_{N+1,j} = \max_{y \in R} y_j``
(nadir). Let ``f_{1,j} \le \dots \le f_{N,j}`` be the sorted values of
objective ``j`` in the front and ``\delta_{i,j} = f_{i+1,j} - f_{i,j}``,
``i = 0, \dots, N``.

## Γ-spread

The largest gap, eq. (5.1) of [Custodio2011Direct](@cite):

```math
\Gamma = \max_{j \in \{1,\dots,m\}} \ \max_{i \in \{0,\dots,N\}} \delta_{i,j}.
```

For two objectives this is the largest distance, in the infinity norm,
between consecutive points, counting the extremes.

## Δ-spread

The extension to ``m`` objectives, eq. (5.2) of [Custodio2011Direct](@cite),
of the Δ of [Deb2002Fast](@cite):

```math
\Delta = \max_{j \in \{1,\dots,m\}}
\frac{\delta_{0,j} + \delta_{N,j} + \sum_{i=1}^{N-1} |\delta_{i,j} - \bar\delta_j|}
     {\delta_{0,j} + \delta_{N,j} + (N-1)\,\bar\delta_j},
\qquad
\bar\delta_j = \frac{1}{N-1}\sum_{i=1}^{N-1} \delta_{i,j}.
```

The original Δ of [Deb2002Fast](@cite) is defined for two objectives with
Euclidean distances between consecutive points and extremes of the true
front; [Custodio2011Direct](@cite) uses per-objective differences and extremes
from the merged fronts, which extends it to any ``m``.

Both are lower-is-better. Δ is zero for equally spaced points that reach both
extremes. See [Conventions](@ref) for single points, degenerate objectives and
points outside the extremes.

```jldoctest
julia> using MultiObjectiveMetrics

julia> R = [[0.0, 1.0], [0.5, 0.5], [1.0, 0.0]];

julia> A = [[0.0, 1.0], [0.25, 0.75], [1.0, 0.0]];

julia> gamma_spread(A, R), delta_spread(A, R)
(0.75, 0.5)
```

```@docs
gamma_spread
delta_spread
```
