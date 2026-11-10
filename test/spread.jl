@testset "gamma_spread and delta_spread" begin
    R = [[0.0, 1.0], [0.5, 0.5], [1.0, 0.0]]

    @testset "formulas (Custodio2011Direct eq. 5.1-5.2)" begin
        # Uniform front reaching both extremes.
        @test gamma_spread(R, R) == 0.5
        @test delta_spread(R, R) == 0.0

        # Hand computation, objective 1 values 0, 0.25, 1 (objective 2 mirrored):
        # gaps 0.25, 0.75, mean 0.5, deviations 0.25 + 0.25 → Δ = 0.5 / 1.
        A = [[0.0, 1.0], [0.25, 0.75], [1.0, 0.0]]
        @test gamma_spread(A, R) == 0.75
        @test delta_spread(A, R) == 0.5

        # Extremes missing: values 0.25, 0.5 in [0, 1].
        A = [[0.25, 0.75], [0.5, 0.5]]
        # Γ: gaps 0.25, 0.25, 0.5 (objective 1) → 0.5.
        @test gamma_spread(A, R) == 0.5
        # Δ objective 1: δ0 = 0.25, δN = 0.5, one inner gap 0.25 = mean → 0.75 / 1.
        # Objective 2 values 0.5, 0.75: δ0 = 0.5, δN = 0.25 → 0.75.
        @test delta_spread(A, R) == 0.75

        # Three objectives, maximum over objectives.
        ideal = [0.0, 0.0, 0.0]
        nadir = [1.0, 2.0, 4.0]
        A = [[0.0, 0.0, 1.0], [0.5, 2.0, 0.0], [1.0, 1.0, 4.0]]
        # Objective 3 sorted 0, 1, 4: gaps 1, 3 → Γ = 3.
        @test gamma_spread(A, ideal, nadir) == 3.0
        # Objective 1: gaps 0.5, 0.5 → Δ1 = 0; objective 2: 0, 1, 2 → Δ2 = 0;
        # objective 3: mean 2, deviations 1 + 1 → Δ3 = 2 / 4.
        @test delta_spread(A, ideal, nadir) == 0.5

        # Order of A does not matter.
        @test delta_spread(reverse(A), ideal, nadir) == 0.5
        # Reference front and explicit extremes agree.
        B = [[0.2, 0.9], [0.7, 0.1]]
        @test gamma_spread(B, R[1:2]) == gamma_spread(B, ideal_point(R[1:2]), nadir_point(R[1:2]))
        @test delta_spread(B, R[1:2]) == delta_spread(B, [0.0, 0.5], [0.5, 1.0])
    end

    @testset "points beyond the extremes are clipped (DEC-001)" begin
        # INV-001: every point of A is dominated by R, one lies far beyond the nadir.
        A = [[0.6, 1.2], [1.2, 0.6], [3.0, 0.1]]
        # Clipped objective 1: 0.6, 1, 1 → Γ1 = 0.6, Δ1 = (0.6 + 0 + 0.4) / 1.
        # Clipped objective 2: 0.1, 0.6, 1 → Γ2 = 0.5, Δ2 = (0.1 + 0 + 0.1) / 1.
        @test gamma_spread(A, R) ≈ 0.6
        @test delta_spread(A, R) ≈ 1.0
        # Same as clipping by hand.
        clipped = [clamp.(a, 0.0, 1.0) for a in A]
        @test gamma_spread(A, R) == gamma_spread(clipped, R)
        @test delta_spread(A, R) == delta_spread(clipped, R)
        # Never negative, Γ never beyond the range.
        rng = MersenneTwister(3)
        for _ in 1:200
            B = [3 .* rand(rng, 2) .- 1 for _ in 1:rand(rng, 2:8)]
            @test 0 <= delta_spread(B, R)
            @test 0 <= gamma_spread(B, R) <= 1
        end
    end

    @testset "conventions" begin
        # Empty front, single point.
        @test isnan(gamma_spread(Vector{Float64}[], R))
        @test isnan(delta_spread(Vector{Float64}[], R))
        @test gamma_spread([[0.5, 0.5]], R) == Inf
        @test delta_spread([[0.5, 0.5]], R) == Inf

        # All points coincide in an objective: Δ_j = 1 (DEC-001).
        @test delta_spread([[0.5, 0.5], [0.5, 0.5]], R) == 1.0
        @test gamma_spread([[0.5, 0.5], [0.5, 0.5]], R) == 0.5

        # Degenerate objective (ideal ≈ nadir) is skipped.
        ideal = [0.0, 2.0]
        nadir = [1.0, 2.0]
        A = [[0.0, 2.0], [0.5, 2.0], [1.0, 2.0]]
        @test gamma_spread(A, ideal, nadir) == 0.5
        @test delta_spread(A, ideal, nadir) == 0.0
        @test isnan(gamma_spread(A, [0.0, 2.0], [0.0, 2.0]))
        @test isnan(delta_spread([[0.0, 2.0]], [0.0, 2.0], [0.0, 2.0]))
        @test isnan(gamma_spread(A, [0.0, 2.0], [1e-12, 2.0]))
        # Exact comparison keeps the tiny range [0, 1e-12]; A is clipped to it.
        @test gamma_spread(A, [0.0, 2.0], [1e-12, 2.0]; tol = Tolerance(0)) == 1e-12

        # Empty reference front.
        @test isnan(gamma_spread(Vector{Float64}[], Vector{Float64}[]))
        @test_throws ArgumentError delta_spread([[0.0, 1.0]], Vector{Float64}[])
    end

    @testset "argument checks" begin
        @test_throws ArgumentError gamma_spread(R, [1.0, 0.0], [0.0, 1.0])
        @test_throws DimensionMismatch gamma_spread(R, [0.0, 0.0, 0.0], [1.0, 1.0, 1.0])
        @test_throws DimensionMismatch gamma_spread(R, [0.0], [1.0, 1.0])
        @test_throws ArgumentError delta_spread([[0.0, NaN]], R)
        @test gamma_spread([Float32[0, 1], Float32[1, 0]], R) isa Float64
        @test gamma_spread([Float32[0, 1], Float32[1, 0]], [Float32[0, 1], Float32[1, 0]]) isa Float32
    end
end
