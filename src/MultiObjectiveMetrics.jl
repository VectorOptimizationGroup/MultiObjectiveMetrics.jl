"""
Performance indicators for multiobjective optimization: dominance with
tolerance, non-dominated filtering, Purity, Γ-spread, Δ-spread, Covering and
exact hypervolume. All objectives are minimized.

A point set is any `AbstractVector` of objective vectors, for example a
`Vector{Vector{Float64}}`, `eachcol(M)` or `eachrow(M)`. See
[`purity`](@ref), [`gamma_spread`](@ref), [`delta_spread`](@ref),
[`covering`](@ref) and [`hypervolume`](@ref).
"""
module MultiObjectiveMetrics

export Tolerance
export DominanceRelation, Equivalent, Dominates, DominatedBy, Incomparable
export AbstractDominance, StrictDominance, WeakDominance
export compare, dominates, weakly_dominates, isequivalent
export nondominated_indices, nondominated, unique_indices, unique_points
export ideal_point, nadir_point
export purity, gamma_spread, delta_spread, covering
export hypervolume, normalize_points, normalized_hypervolume

include("tolerance.jl")
include("points.jl")
include("dominance.jl")
include("sets.jl")
include("purity.jl")
include("spread.jl")
include("covering.jl")
include("hypervolume.jl")
include("normalization.jl")

end
