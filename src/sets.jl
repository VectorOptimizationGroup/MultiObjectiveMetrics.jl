"""
    nondominated_indices(F; tol = Tolerance()) -> Vector{Int}

Indices, in increasing order, of the points of `F` that no other point of `F`
dominates under [`compare`](@ref). Equivalent points are all kept; use
[`unique_points`](@ref) to keep one representative. The result does not depend
on the order of `F`.

# Examples

```jldoctest
julia> nondominated_indices([[1.0, 3.0], [2.0, 2.0], [2.0, 4.0], [1.0, 3.0]])
3-element Vector{Int64}:
 1
 2
 4
```
"""
function nondominated_indices(F::PointSet; tol::Tolerance = Tolerance())
    _checkpoints(F)
    keep = Int[]
    for i in eachindex(F)
        p = F[i]
        dominated = false
        for j in eachindex(F)
            j == i && continue
            if compare(F[j], p; tol) == Dominates
                dominated = true
                break
            end
        end
        dominated || push!(keep, i)
    end
    return keep
end

"""
    nondominated(F; tol = Tolerance())

The points of `F` selected by [`nondominated_indices`](@ref), in their
original order.
"""
nondominated(F::PointSet; tol::Tolerance = Tolerance()) = F[nondominated_indices(F; tol)]

"""
    unique_indices(F; tol = Tolerance()) -> Vector{Int}

Indices of the first point of each group of equivalent points of `F`
(see [`isequivalent`](@ref)): a point is kept unless an earlier kept point is
equivalent to it.
"""
function unique_indices(F::PointSet; tol::Tolerance = Tolerance())
    _checkpoints(F)
    keep = Int[]
    for i in eachindex(F)
        p = F[i]
        any(k -> isequivalent(F[k], p; tol), keep) || push!(keep, i)
    end
    return keep
end

"""
    unique_points(F; tol = Tolerance())

The points of `F` selected by [`unique_indices`](@ref), in their original order.

# Examples

```jldoctest
julia> unique_points([[1.0, 2.0], [1.0 + 1e-12, 2.0], [0.0, 3.0]])
2-element Vector{Vector{Float64}}:
 [1.0, 2.0]
 [0.0, 3.0]
```
"""
unique_points(F::PointSet; tol::Tolerance = Tolerance()) = F[unique_indices(F; tol)]

"""
    ideal_point(F) -> Vector

Componentwise minimum of the points of `F`. Throws an `ArgumentError` if `F`
is empty.

# Examples

```jldoctest
julia> ideal_point([[1.0, 3.0], [2.0, 2.0]])
2-element Vector{Float64}:
 1.0
 2.0
```
"""
ideal_point(F::PointSet) = _extreme(min, F)

"""
    nadir_point(F) -> Vector

Componentwise maximum of the points of `F`. Applied to the non-dominated
points of a reference set, this is the nadir point of that set. Throws an
`ArgumentError` if `F` is empty.
"""
nadir_point(F::PointSet) = _extreme(max, F)

function _extreme(op::F, P::PointSet) where {F}
    m = _checkpoints(P)
    m == 0 && throw(ArgumentError("cannot compute an extreme point of an empty point set"))
    T = _floattype(P)
    z = Vector{T}(undef, m)
    first = true
    for p in P
        if first
            copyto!(z, p)
            first = false
        else
            for j in 1:m
                z[j] = op(z[j], p[firstindex(p) + j - 1])
            end
        end
    end
    return z
end
