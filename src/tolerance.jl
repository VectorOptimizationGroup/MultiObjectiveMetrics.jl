"""
    Tolerance(atol, rtol)
    Tolerance(tol)
    Tolerance()

Componentwise tolerance used to compare objective values. For components `a`
and `b`, the tolerance is

    ε = max(atol, rtol * max(|a|, |b|))

`Tolerance(tol)` sets `atol = rtol = tol`, which gives
`ε = tol * max(1, |a|, |b|)`, the rule of [FPS2025](@cite).
`Tolerance()` uses `tol = √eps(Float64) ≈ 1.49e-8`, and `Tolerance(0)` compares
exactly. Both values must be finite and nonnegative.

# Examples

```jldoctest
julia> isequivalent([1.0, 2.0], [1.0 + 1e-10, 2.0])
true

julia> isequivalent([1.0, 2.0], [1.0 + 1e-10, 2.0]; tol = Tolerance(0))
false
```
"""
struct Tolerance{T<:Real}
    atol::T
    rtol::T
    function Tolerance{T}(atol::Real, rtol::Real) where {T<:Real}
        (isfinite(atol) && isfinite(rtol) && atol >= 0 && rtol >= 0) ||
            throw(ArgumentError("tolerances must be finite and nonnegative, got atol = $atol, rtol = $rtol"))
        return new{T}(atol, rtol)
    end
end

Tolerance(atol::Real, rtol::Real) = Tolerance{promote_type(typeof(atol), typeof(rtol))}(atol, rtol)
Tolerance(tol::Real) = Tolerance(tol, tol)
Tolerance() = Tolerance(sqrt(eps(Float64)))

# Tolerance for one pair of components.
@inline _componenttol(tol::Tolerance, a::Real, b::Real) = max(tol.atol, tol.rtol * max(abs(a), abs(b)))

# Scalar equivalence under the tolerance.
@inline _close(tol::Tolerance, a::Real, b::Real) = abs(a - b) <= _componenttol(tol, a, b)
