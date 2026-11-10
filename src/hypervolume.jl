"""
    hypervolume(F, reference)

Exact hypervolume of the point set `F` with respect to `reference`
[Zitzler1998Multiobjective](@cite), [Zitzler1999Evolutionary](@cite): the Lebesgue measure of the region
dominated by `F` and bounded by `reference`,

    HV(F; r) = λ_m(∪_{y ∈ F} [y, r]).

Higher is better. The reference point is always explicit: there is no
default, because the value depends strongly on it [Ishibuchi2018How](@cite). Points
that are not strictly better than `reference` in every objective contribute
nothing; dominated and repeated points do not change the value. An empty set,
or a set with no contributing point, has hypervolume zero.

Algorithms: sorting for `m = 2`; the dimension sweep of Paquete et al.
described in [Fonseca2006Improved](@cite) (Section III-A) for `m = 3`, in
`O(n²)` worst-case time with a sorted vector instead of a balanced tree; and
the slicing recursion of [Fonseca2006Improved](@cite) (Algorithm 1), down to the
three-dimensional case, for `m ≥ 4`.

See [`normalized_hypervolume`](@ref) for the normalized variant.

# Examples

```jldoctest
julia> hypervolume([[1.0, 2.0], [2.0, 1.0]], [3.0, 3.0])
3.0

julia> hypervolume([[1.0, 1.0, 1.0]], [2.0, 3.0, 4.0])
6.0
```
"""
function hypervolume(F::PointSet, reference::AbstractVector{<:Real})
    m = length(reference)
    m == 0 && throw(ArgumentError("the reference point must not be empty"))
    all(isfinite, reference) || throw(ArgumentError("the reference point must be finite"))
    _checkpoints(F, m, "F")
    T = promote_type(_floattype(F), float(eltype(reference)))
    r = Vector{T}(undef, m)
    copyto!(r, reference)
    points = Vector{Vector{T}}()
    for p in F
        q = Vector{T}(undef, m)
        copyto!(q, p)
        all(j -> q[j] < r[j], 1:m) && push!(points, q)
    end
    return _hypervolume(points, r, m)
end

# Hypervolume of the first `d` coordinates of `points`, all strictly below `r`.
function _hypervolume(points::AbstractVector{Vector{T}}, r::Vector{T}, d::Int) where {T}
    isempty(points) && return zero(T)
    d == 1 && return r[1] - minimum(p -> p[1], points)
    d == 2 && return _hypervolume2d(points, r)
    d == 3 && return _hypervolume3d(points, r)
    return _hypervolume_slices(points, r, d)
end

# Sweep along objective 1; each point lowering objective 2 adds a strip.
function _hypervolume2d(points::AbstractVector{Vector{T}}, r::Vector{T}) where {T}
    order = sortperm(points; by = p -> (p[1], p[2]))
    volume = zero(T)
    lowest = r[2]
    @inbounds for k in order
        p = points[k]
        if p[2] < lowest
            volume += (r[1] - p[1]) * (lowest - p[2])
            lowest = p[2]
        end
    end
    return volume
end

# Dimension sweep along objective 3 (Fonseca2006Improved, Section III-A). The
# non-dominated projections on objectives 1-2 form a staircase stored by
# increasing objective 1 (so decreasing objective 2); `area` is the area it
# dominates up to (r[1], r[2]).
function _hypervolume3d(points::AbstractVector{Vector{T}}, r::Vector{T}) where {T}
    order = sortperm(points; by = p -> p[3])
    xs = T[]
    ys = T[]
    area = zero(T)
    volume = zero(T)
    previous = points[order[1]][3]
    for k in order
        p = points[k]
        px, py, pz = p[1], p[2], p[3]
        volume += area * (pz - previous)
        previous = pz
        # Dominated in projection: some staircase point has x ≤ px and y ≤ py.
        last_le = searchsortedlast(xs, px)
        last_le >= 1 && ys[last_le] <= py && continue
        # Predecessor: last staircase point with x < px.
        before = searchsortedfirst(xs, px) - 1
        height = before >= 1 ? ys[before] : r[2]
        x = px
        gained = zero(T)
        stop = before + 1
        while stop <= length(xs) && ys[stop] >= py
            gained += (xs[stop] - x) * (height - py)
            height = ys[stop]
            x = xs[stop]
            stop += 1
        end
        next_x = stop <= length(xs) ? xs[stop] : r[1]
        gained += (next_x - x) * (height - py)
        area += gained
        # Replace the points dominated by p with p.
        removed = (before + 1):(stop - 1)
        if isempty(removed)
            insert!(xs, before + 1, px)
            insert!(ys, before + 1, py)
        else
            xs[before + 1] = px
            ys[before + 1] = py
            if length(removed) > 1
                deleteat!(xs, (before + 2):(stop - 1))
                deleteat!(ys, (before + 2):(stop - 1))
            end
        end
    end
    return volume + area * (r[3] - previous)
end

# Slicing along objective d (Fonseca2006Improved, Algorithm 1): the slab between
# consecutive values of objective d has as base the (d-1)-dimensional
# hypervolume of the points already swept.
function _hypervolume_slices(points::AbstractVector{Vector{T}}, r::Vector{T}, d::Int) where {T}
    sorted = sort(points; by = p -> p[d])
    volume = zero(T)
    n = length(sorted)
    for k in 1:n
        top = k < n ? sorted[k + 1][d] : r[d]
        height = top - sorted[k][d]
        height > 0 || continue
        volume += height * _hypervolume(view(sorted, 1:k), r, d - 1)
    end
    return volume
end
