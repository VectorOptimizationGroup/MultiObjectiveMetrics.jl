"""
    purity(A, R; tol = Tolerance())

Purity of the front `A` of one solver with respect to the reference front `R`
[BPA2004](@cite), [CMVV2011](@cite):

    purity(A, R) = |A ∩ R| / |A|

`R` is normally the non-dominated set of the union of the fronts of all
solvers compared, `nondominated(reduce(vcat, fronts))`. A point of `A` belongs
to `R` when it is equivalent to some point of `R` under `tol`. Equivalent
points of `A` count once (see [`unique_points`](@ref)). The result lies in
`[0, 1]`, higher is better; for performance profiles use `1 / purity`.

Returns `NaN` when `A` is empty.

# Examples

```jldoctest
julia> A = [[0.0, 1.0], [0.6, 0.6]]; B = [[0.5, 0.5], [1.0, 0.0]];

julia> R = nondominated(vcat(A, B));

julia> purity(A, R), purity(B, R)
(0.5, 1.0)
```
"""
function purity(A::PointSet, R::PointSet; tol::Tolerance = Tolerance())
    _checkpoints(A, R, "A", "R")
    T = _floattype(A, R)
    ids = unique_indices(A; tol)
    isempty(ids) && return T(NaN)
    count = 0
    for i in ids
        a = A[i]
        any(r -> isequivalent(a, r; tol), R) && (count += 1)
    end
    return T(count) / T(length(ids))
end
