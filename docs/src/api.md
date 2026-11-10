# API Reference

The indicators are documented on their pages: [`purity`](@ref),
[`gamma_spread`](@ref), [`delta_spread`](@ref), [`covering`](@ref),
[`hypervolume`](@ref), [`normalize_points`](@ref) and
[`normalized_hypervolume`](@ref).

## Package

```@docs
MultiObjectiveMetrics
```

## Tolerance and dominance

```@docs
Tolerance
DominanceRelation
compare
dominates
weakly_dominates
isequivalent
AbstractDominance
WeakDominance
StrictDominance
```

## Point sets

```@docs
nondominated_indices
nondominated
unique_indices
unique_points
ideal_point
nadir_point
```
