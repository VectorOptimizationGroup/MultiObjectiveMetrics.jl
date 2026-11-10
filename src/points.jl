# Input validation and element types shared by every indicator.

const PointSet = AbstractVector{<:AbstractVector{<:Real}}

# Floating-point type of the values of a point set.
_floattype(F::PointSet) = float(eltype(eltype(F)))
_floattype(F::PointSet, G::PointSet) = promote_type(_floattype(F), _floattype(G))

# Checks that every point has `m` finite components; `m = 0` takes the
# dimension of the first point. Returns the dimension (0 for an empty set).
function _checkpoints(F::PointSet, m::Int = 0, name::AbstractString = "point set")
    for p in F
        len = length(p)
        len == 0 && throw(ArgumentError("$name contains an empty objective vector"))
        if m == 0
            m = len
        elseif len != m
            throw(DimensionMismatch("$name mixes objective vectors of lengths $m and $len"))
        end
        all(isfinite, p) || throw(ArgumentError("$name contains a non-finite objective value"))
    end
    return m
end

# Checks two point sets and returns their common dimension.
function _checkpoints(F::PointSet, G::PointSet, nameF::AbstractString, nameG::AbstractString)
    mF = _checkpoints(F, 0, nameF)
    mG = _checkpoints(G, 0, nameG)
    mF == 0 || mG == 0 || mF == mG ||
        throw(DimensionMismatch("$nameF has $mF objectives but $nameG has $mG"))
    return max(mF, mG)
end

# Checks an ideal/nadir pair against dimension `m` (0 = any).
function _checkbounds(ideal::AbstractVector{<:Real}, nadir::AbstractVector{<:Real}, m::Int)
    length(ideal) == length(nadir) ||
        throw(DimensionMismatch("ideal has length $(length(ideal)) but nadir has length $(length(nadir))"))
    isempty(ideal) && throw(ArgumentError("ideal and nadir must not be empty"))
    m == 0 || length(ideal) == m ||
        throw(DimensionMismatch("points have $m objectives but ideal and nadir have $(length(ideal))"))
    (all(isfinite, ideal) && all(isfinite, nadir)) ||
        throw(ArgumentError("ideal and nadir must be finite"))
    for j in eachindex(ideal, nadir)
        ideal[j] <= nadir[j] ||
            throw(ArgumentError("ideal[$j] = $(ideal[j]) exceeds nadir[$j] = $(nadir[j])"))
    end
    return nothing
end
