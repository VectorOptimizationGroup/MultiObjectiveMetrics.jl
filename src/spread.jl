"""
    gamma_spread(A, R; tol = Tolerance())
    gamma_spread(A, ideal, nadir; tol = Tolerance())

Γ-spread of the front `A` [Custodio2011Direct](@cite) (eq. 5.1): the largest gap between
consecutive values of any objective, with the extreme values `ideal[j]` and
`nadir[j]` added at both ends,

    Γ = max_j max_{i = 0,…,N} (f_{i+1,j} - f_{i,j}),

where `f_{1,j} ≤ … ≤ f_{N,j}` are the sorted values of objective `j` in `A`,
`f_{0,j} = ideal[j]` and `f_{N+1,j} = nadir[j]`. With a reference front `R`,
`ideal = ideal_point(R)` and `nadir = nadir_point(R)`. Lower is better.

Conventions (see [Conventions](@ref)):

- values of `A` outside `[ideal[j], nadir[j]]` are clipped to that interval;
- an objective with `ideal[j] ≈ nadir[j]` (under `tol`) is skipped;
- `NaN` if `A` is empty or every objective is skipped; `Inf` if `A` has one point.

`A` is used as given: pass the non-dominated front of the solver. Repeated
points are not removed.

# Examples

```jldoctest
julia> R = [[0.0, 1.0], [0.5, 0.5], [1.0, 0.0]];

julia> gamma_spread(R, R)
0.5

julia> gamma_spread([[0.0, 1.0], [1.0, 0.0]], R)
1.0
```
"""
gamma_spread(A::PointSet, R::PointSet; tol::Tolerance = Tolerance()) = _spread_from_reference(_gamma, A, R, tol)

gamma_spread(A::PointSet, ideal::AbstractVector{<:Real}, nadir::AbstractVector{<:Real}; tol::Tolerance = Tolerance()) =
    _spread(_gamma, A, ideal, nadir, tol)

"""
    delta_spread(A, R; tol = Tolerance())
    delta_spread(A, ideal, nadir; tol = Tolerance())

Δ-spread of the front `A` [Custodio2011Direct](@cite) (eq. 5.2), the extension to `m`
objectives of the Δ of [Deb2002Fast](@cite):

    Δ = max_j (δ_{0,j} + δ_{N,j} + Σ_{i=1}^{N-1} |δ_{i,j} - δ̄_j|) / (δ_{0,j} + δ_{N,j} + (N - 1) δ̄_j),

with `δ_{i,j} = f_{i+1,j} - f_{i,j}` as in [`gamma_spread`](@ref) and `δ̄_j` the
mean of `δ_{i,j}`, `i = 1, …, N-1`. Lower is better; `Δ = 0` for equally spaced
points that reach both extremes.

Conventions (see [Conventions](@ref)): the same as [`gamma_spread`](@ref).
An objective in which all points of `A` coincide gives `Δ_j = 1`.

# Examples

```jldoctest
julia> R = [[0.0, 1.0], [0.5, 0.5], [1.0, 0.0]];

julia> delta_spread(R, R)
0.0

julia> delta_spread([[0.0, 1.0], [0.25, 0.75], [1.0, 0.0]], R)
0.5
```
"""
delta_spread(A::PointSet, R::PointSet; tol::Tolerance = Tolerance()) = _spread_from_reference(_delta, A, R, tol)

delta_spread(A::PointSet, ideal::AbstractVector{<:Real}, nadir::AbstractVector{<:Real}; tol::Tolerance = Tolerance()) =
    _spread(_delta, A, ideal, nadir, tol)

function _spread_from_reference(kernel::K, A::PointSet, R::PointSet, tol::Tolerance) where {K}
    _checkpoints(A, R, "A", "R")
    if isempty(R)
        isempty(A) || throw(ArgumentError("the reference front R is empty"))
        return _floattype(A, R)(NaN)
    end
    return _spread(kernel, A, ideal_point(R), nadir_point(R), tol)
end

function _spread(kernel::K, A::PointSet, ideal::AbstractVector{<:Real}, nadir::AbstractVector{<:Real},
                 tol::Tolerance) where {K}
    m = _checkpoints(A, 0, "A")
    _checkbounds(ideal, nadir, m)
    T = promote_type(_floattype(A), float(eltype(ideal)), float(eltype(nadir)))
    N = length(A)
    N == 0 && return T(NaN)
    active = 0
    for j in eachindex(ideal, nadir)
        _close(tol, ideal[j], nadir[j]) || (active += 1)
    end
    active == 0 && return T(NaN)
    N == 1 && return T(Inf)
    values = Vector{T}(undef, N)
    result = T(-Inf)
    i0 = firstindex(ideal)
    for j in 1:length(ideal)
        lo = T(ideal[i0 + j - 1])
        hi = T(nadir[firstindex(nadir) + j - 1])
        _close(tol, lo, hi) && continue
        for (k, a) in enumerate(A)
            values[k] = clamp(T(a[firstindex(a) + j - 1]), lo, hi)
        end
        sort!(values)
        result = max(result, kernel(values, lo, hi))
    end
    return result
end

# Largest gap of one sorted objective, extremes included (eq. 5.1).
function _gamma(values::Vector{T}, lo::T, hi::T) where {T}
    N = length(values)
    gap = max(values[1] - lo, hi - values[N])
    @inbounds for i in 1:(N - 1)
        gap = max(gap, values[i + 1] - values[i])
    end
    return gap
end

# Δ of one sorted objective (eq. 5.2); the denominator equals hi - lo > 0.
function _delta(values::Vector{T}, lo::T, hi::T) where {T}
    N = length(values)
    first_gap = values[1] - lo
    last_gap = hi - values[N]
    total = zero(T)
    @inbounds for i in 1:(N - 1)
        total += values[i + 1] - values[i]
    end
    mean_gap = total / (N - 1)
    deviation = zero(T)
    @inbounds for i in 1:(N - 1)
        deviation += abs(values[i + 1] - values[i] - mean_gap)
    end
    return (first_gap + last_gap + deviation) / (first_gap + last_gap + (N - 1) * mean_gap)
end
