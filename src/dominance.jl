"""
    DominanceRelation

Result of [`compare`](@ref)`(u, v)` for minimization: `Dominates` (`u`
dominates `v`), `DominatedBy` (`v` dominates `u`), `Equivalent` (every
component within the tolerance) or `Incomparable`.
"""
@enum DominanceRelation Equivalent Dominates DominatedBy Incomparable

"""
    compare(u, v; tol = Tolerance()) -> DominanceRelation

Compare objective vectors `u` and `v` (minimization) under the componentwise
tolerance `ε_i` of [`Tolerance`](@ref):

- `Dominates`: `u_i ≤ v_i + ε_i` for all `i` and `u_j < v_j - ε_j` for some `j`;
- `DominatedBy`: the same with `u` and `v` swapped;
- `Equivalent`: `|u_i - v_i| ≤ ε_i` for all `i`;
- `Incomparable`: otherwise.

This is the rule of [FPS2025](@cite); `Tolerance(0)` gives Pareto dominance.

# Examples

```jldoctest
julia> compare([1.0, 2.0], [2.0, 3.0])
Dominates::DominanceRelation = 1

julia> compare([1.0, 3.0], [2.0, 2.0])
Incomparable::DominanceRelation = 3
```
"""
function compare(u::AbstractVector{<:Real}, v::AbstractVector{<:Real}; tol::Tolerance = Tolerance())
    ubetter = false
    vbetter = false
    @inbounds for i in eachindex(u, v)
        ui = u[i]
        vi = v[i]
        e = _componenttol(tol, ui, vi)
        if ui < vi - e
            ubetter = true
        elseif vi < ui - e
            vbetter = true
        end
        ubetter && vbetter && return Incomparable
    end
    ubetter && return Dominates
    vbetter && return DominatedBy
    return Equivalent
end

"""
    dominates(u, v; tol = Tolerance()) -> Bool
    dominates(relation::AbstractDominance, u, v; tol = Tolerance()) -> Bool

Whether `u` dominates `v` (minimization). Without `relation`, or with
[`StrictDominance`](@ref), this is `compare(u, v; tol) == Dominates`. With
[`WeakDominance`](@ref) it is [`weakly_dominates`](@ref).
"""
dominates(u::AbstractVector{<:Real}, v::AbstractVector{<:Real}; tol::Tolerance = Tolerance()) =
    compare(u, v; tol) == Dominates

"""
    weakly_dominates(u, v; tol = Tolerance()) -> Bool

Whether `u` weakly dominates `v`: `u_i ≤ v_i + ε_i` for every component, that
is, `u` dominates `v` or is equivalent to it. This is the "covers" relation of
[ZT1998](@cite) and [Zit1999](@cite) (Def. 4).

# Examples

```jldoctest
julia> weakly_dominates([1.0, 2.0], [1.0, 2.0])
true

julia> dominates([1.0, 2.0], [1.0, 2.0])
false
```
"""
function weakly_dominates(u::AbstractVector{<:Real}, v::AbstractVector{<:Real}; tol::Tolerance = Tolerance())
    @inbounds for i in eachindex(u, v)
        u[i] <= v[i] + _componenttol(tol, u[i], v[i]) || return false
    end
    return true
end

"""
    isequivalent(u, v; tol = Tolerance()) -> Bool

Whether `|u_i - v_i| ≤ ε_i` for every component (see [`Tolerance`](@ref)).
"""
function isequivalent(u::AbstractVector{<:Real}, v::AbstractVector{<:Real}; tol::Tolerance = Tolerance())
    @inbounds for i in eachindex(u, v)
        _close(tol, u[i], v[i]) || return false
    end
    return true
end

"""
    AbstractDominance

Supertype of the relations accepted by [`covering`](@ref) and
[`dominates`](@ref)`(relation, u, v)`: [`WeakDominance`](@ref) and
[`StrictDominance`](@ref).
"""
abstract type AbstractDominance end

"""
    WeakDominance()

`u` weakly dominates `v`: it dominates or is equivalent to `v`. See
[`weakly_dominates`](@ref).
"""
struct WeakDominance <: AbstractDominance end

"""
    StrictDominance()

`u` dominates `v` and is not equivalent to it. See [`dominates`](@ref).
"""
struct StrictDominance <: AbstractDominance end

dominates(::StrictDominance, u::AbstractVector{<:Real}, v::AbstractVector{<:Real}; tol::Tolerance = Tolerance()) =
    dominates(u, v; tol)
dominates(::WeakDominance, u::AbstractVector{<:Real}, v::AbstractVector{<:Real}; tol::Tolerance = Tolerance()) =
    weakly_dominates(u, v; tol)
