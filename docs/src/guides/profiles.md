# Performance profiles

Purity, Γ, Δ and the normalized hypervolume compare fronts obtained by several
solvers on the same problem. To summarize a test set, the usual practice is a
performance profile [Custodio2011Direct](@cite): for each problem `p` and
solver `s`, a cost ``t_{p,s}`` where lower is better.

| Metric | Cost ``t_{p,s}`` |
| --- | --- |
| Purity | `1 / purity(A, R)` (`Inf` when no point of `A` is in `R`) |
| Γ-spread | `gamma_spread(A, R)` |
| Δ-spread | `delta_spread(A, R)` |
| Normalized hypervolume | `1 / normalized_hypervolume(A, R)` |

For each problem, build `R` from the non-dominated fronts of **all** solvers
compared (and of all runs, if available), so that the extremes of Γ and Δ and
the membership test of Purity are the same for every solver
[Custodio2011Direct](@cite):

```julia
using MultiObjectiveMetrics

# fronts[p][s]: objective vectors returned by solver s on problem p
T = fill(NaN, nproblems, nsolvers)
for p in 1:nproblems
    nd = [nondominated(fronts[p][s]) for s in 1:nsolvers]
    R = nondominated(reduce(vcat, nd))
    for s in 1:nsolvers
        T[p, s] = gamma_spread(nd[s], R)
    end
end
```

`T` can be passed to a profile package such as
[BenchmarkProfiles.jl](https://github.com/JuliaSmoothOptimizers/BenchmarkProfiles.jl),
which treats `NaN`, `Inf` and negative entries as failures. The
[Conventions](@ref) of this package return `NaN` or `Inf` exactly in the cases
where a metric carries no information (empty front, single point, degenerate
reference), so those cases count as failures, and never return negative values.

Purity depends on which solvers enter `R`: two similar solvers share the
reference points and both lose against a third one. [Custodio2011Direct](@cite)
therefore compares Purity in pairs of solvers.
