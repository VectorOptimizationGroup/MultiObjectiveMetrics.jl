# MultiObjectiveMetrics.jl

Performance indicators for comparing approximations of the Pareto front
produced by multiobjective optimization solvers. All objectives are
minimized, and every indicator is implemented from its primary source.

| Indicator | Function | Better | Source |
| --- | --- | --- | --- |
| Purity | [`purity`](@ref) | higher | [Bandyopadhyay2004Multiobjective, Custodio2011Direct](@cite) |
| Γ-spread | [`gamma_spread`](@ref) | lower | [Custodio2011Direct](@cite) |
| Δ-spread | [`delta_spread`](@ref) | lower | [Custodio2011Direct, Deb2002Fast](@cite) |
| Covering | [`covering`](@ref) | higher | [Zitzler1998Multiobjective, Zitzler1999Evolutionary](@cite) |
| Hypervolume | [`hypervolume`](@ref), [`normalized_hypervolume`](@ref) | higher | [Zitzler1998Multiobjective, Fonseca2006Improved](@cite) |

They rest on dominance with an explicit tolerance ([`Tolerance`](@ref),
[`compare`](@ref)) and on non-dominated filtering ([`nondominated`](@ref)).
The package has no runtime dependencies and accepts any vector of objective
vectors, including the columns or rows of a matrix.

- [Installation](@ref) and [Quick Start](@ref): get started.
- [Point sets and tolerance](@ref): input formats and comparisons.
- [Performance profiles](@ref): comparing several solvers on many problems.
- [Conventions](@ref): edge cases and differences from other implementations.
- Metrics: [Purity](@ref), [Spread metrics](@ref), [Covering](@ref), [Hypervolume](@ref).
- [API Reference](@ref), [Acknowledgements](@ref) and [References](@ref).

For a survey of performance indicators, see [Audet2021Performance](@cite).
