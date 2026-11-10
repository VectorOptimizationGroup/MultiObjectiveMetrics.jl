"""
    normalize_points(F, ideal, nadir) -> Vector{Vector}

Map every point `f` of `F` to `(f - ideal) ./ max.(nadir - ideal, eps)`, so
that `ideal` goes to the origin and `nadir` to the vector of ones. The
`eps` of the floating-point type guards objectives with `ideal[j] == nadir[j]`.

# Examples

```jldoctest
julia> normalize_points([[1.0, 4.0], [3.0, 2.0]], [1.0, 2.0], [3.0, 4.0])
2-element Vector{Vector{Float64}}:
 [0.0, 1.0]
 [1.0, 0.0]
```
"""
function normalize_points(F::PointSet, ideal::AbstractVector{<:Real}, nadir::AbstractVector{<:Real})
    m = _checkpoints(F, 0, "F")
    _checkbounds(ideal, nadir, m)
    m = length(ideal)
    T = promote_type(_floattype(F), float(eltype(ideal)), float(eltype(nadir)))
    lo = Vector{T}(undef, m)
    copyto!(lo, ideal)
    width = Vector{T}(undef, m)
    copyto!(width, nadir)
    @. width = max(width - lo, eps(T))
    normalized = Vector{Vector{T}}(undef, length(F))
    for (k, p) in enumerate(F)
        q = Vector{T}(undef, m)
        copyto!(q, p)
        @. q = (q - lo) / width
        normalized[k] = q
    end
    return normalized
end

"""
    normalized_hypervolume(F, R; offset = 1.1, tol = Tolerance())
    normalized_hypervolume(F, ideal, nadir; offset = 1.1, tol = Tolerance())

Hypervolume of `F` after [`normalize_points`](@ref), with reference point
`offset * ones(m)`, divided by `offset^m`:

    HV_norm(F) = HV(normalize(F); (offset, …, offset)) / offset^m.

With a reference front `R`, `ideal = ideal_point(R)` and
`nadir = nadir_point(R)`. The value lies in `[0, 1]`; higher is better, and for
performance profiles use `1 / HV_norm`.

This is the convention of [Fazzio2025ActiveSet](@cite) (Section 7.2), not a definition
from the hypervolume literature: normalizing by ideal and nadir and taking a
reference point slightly worse than the nadir is common practice, but
`offset = 1.1` and the division by `offset^m` are the authors' choices; see
[Ishibuchi2018How](@cite) for the effect of the reference point. Use
[`hypervolume`](@ref) for any other reference point.

Returns `NaN` when `F` is empty or when `ideal ≈ nadir` in every objective
(under `tol`).

# Examples

```jldoctest
julia> R = [[0.0, 1.0], [1.0, 0.0]];

julia> normalized_hypervolume(R, R) ≈ 0.21 / 1.21
true
```
"""
function normalized_hypervolume(F::PointSet, R::PointSet; offset::Real = 1.1, tol::Tolerance = Tolerance())
    _checkpoints(F, R, "F", "R")
    if isempty(R)
        isempty(F) || throw(ArgumentError("the reference front R is empty"))
        return _floattype(F, R)(NaN)
    end
    return normalized_hypervolume(F, ideal_point(R), nadir_point(R); offset, tol)
end

function normalized_hypervolume(F::PointSet, ideal::AbstractVector{<:Real}, nadir::AbstractVector{<:Real};
                                offset::Real = 1.1, tol::Tolerance = Tolerance())
    m = _checkpoints(F, 0, "F")
    _checkbounds(ideal, nadir, m)
    (isfinite(offset) && offset > 0) || throw(ArgumentError("offset must be finite and positive, got $offset"))
    T = promote_type(_floattype(F), float(eltype(ideal)), float(eltype(nadir)), float(typeof(offset)))
    isempty(F) && return T(NaN)
    all(j -> _close(tol, ideal[j], nadir[j]), eachindex(ideal, nadir)) && return T(NaN)
    m = length(ideal)
    reference = fill(T(offset), m)
    return hypervolume(normalize_points(F, ideal, nadir), reference) / T(offset)^m
end
