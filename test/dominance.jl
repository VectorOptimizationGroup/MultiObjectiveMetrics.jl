@testset "Tolerance" begin
    t = Tolerance()
    @test t.atol == t.rtol == sqrt(eps(Float64))
    @test Tolerance(1e-3) == Tolerance(1e-3, 1e-3)
    @test Tolerance(0).atol == 0
    @test_throws ArgumentError Tolerance(-1.0)
    @test_throws ArgumentError Tolerance(1e-8, NaN)
    @test_throws ArgumentError Tolerance(Inf, 0.0)
end

@testset "compare" begin
    @test compare([1.0, 2.0], [2.0, 3.0]) == Dominates
    @test compare([2.0, 3.0], [1.0, 2.0]) == DominatedBy
    @test compare([1.0, 2.0], [1.0, 3.0]) == Dominates
    @test compare([1.0, 3.0], [2.0, 2.0]) == Incomparable
    @test compare([1.0, 2.0], [1.0, 2.0]) == Equivalent
    @test compare([1, 2], [2, 3]) == Dominates

    # Fazzio2025ActiveSet: ε_i = tol * max(1, |u_i|, |v_i|).
    tol = Tolerance(1e-3)
    @test compare([1.0, 2.0], [1.0005, 2.0]; tol) == Equivalent
    @test compare([1.0, 2.0], [1.002, 2.0]; tol) == Dominates
    @test compare([1000.0], [1000.5]; tol) == Equivalent       # ε = 1.0005 > 0.5
    @test compare([1000.0], [1002.0]; tol) == Dominates
    @test compare([0.0], [5e-4]; tol) == Equivalent            # absolute part near zero
    # Better in one component beyond ε, worse within ε in the other: dominates.
    @test compare([1.0, 2.0005], [1.5, 2.0]; tol) == Dominates

    # Exact comparison.
    @test compare([1.0], [1.0 + eps()]; tol = Tolerance(0)) == Dominates
    @test compare([1.0], [1.0 + eps()]) == Equivalent

    @test_throws DimensionMismatch compare([1.0, 2.0], [1.0])
end

@testset "dominates, weakly_dominates, isequivalent" begin
    @test dominates([1.0, 2.0], [2.0, 2.0])
    @test !dominates([1.0, 2.0], [1.0, 2.0])
    @test weakly_dominates([1.0, 2.0], [1.0, 2.0])
    @test weakly_dominates([1.0, 2.0], [2.0, 2.0])
    @test !weakly_dominates([1.0, 3.0], [2.0, 2.0])
    @test isequivalent([1.0, 2.0], [1.0 + 1e-10, 2.0])
    @test !isequivalent([1.0, 2.0], [1.0 + 1e-10, 2.0]; tol = Tolerance(0))

    # Weak dominance = dominance or equivalence, also with tolerance.
    rng = MersenneTwister(7)
    tol = Tolerance(0.05)
    for _ in 1:2000
        u = round.(rand(rng, 3); digits = 1)
        v = round.(rand(rng, 3); digits = 1)
        rel = compare(u, v; tol)
        @test weakly_dominates(u, v; tol) == (rel == Dominates || rel == Equivalent)
        @test isequivalent(u, v; tol) == (rel == Equivalent)
        @test compare(v, u; tol) == (rel == Dominates ? DominatedBy : rel == DominatedBy ? Dominates : rel)
    end

    @test dominates(WeakDominance(), [1.0, 2.0], [1.0, 2.0])
    @test !dominates(StrictDominance(), [1.0, 2.0], [1.0, 2.0])
    @test dominates(StrictDominance(), [1.0, 2.0], [1.0, 3.0])
end
