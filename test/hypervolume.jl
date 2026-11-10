normalize3(x) = x ./ sqrt(sum(abs2, x))

# Inclusion-exclusion over all non-empty subsets: exact for small sets.
function hv_inclusion_exclusion(F, r)
    P = [p for p in F if all(p .< r)]
    n = length(P)
    total = 0.0
    for mask in 1:(2^n - 1)
        corner = fill(-Inf, length(r))
        k = 0
        for i in 1:n
            if (mask >> (i - 1)) & 1 == 1
                corner .= max.(corner, P[i])
                k += 1
            end
        end
        total += (-1)^(k + 1) * prod(r .- corner)
    end
    return total
end

@testset "hypervolume" begin
    @testset "small cases by hand" begin
        @test hypervolume([[1.0, 2.0], [2.0, 1.0]], [3.0, 3.0]) == 3.0
        @test hypervolume([[1.0, 1.0, 1.0]], [2.0, 3.0, 4.0]) == 6.0
        @test hypervolume([[1.0, 1.0, 1.0, 1.0]], [2.0, 3.0, 4.0, 5.0]) == 24.0
        @test hypervolume([[1.0], [0.5]], [2.0]) == 1.5
        # Two boxes in 3D overlapping in [1,2]^2 × [2,3].
        @test hypervolume([[0.0, 1.0, 2.0], [1.0, 0.0, 2.0]], [2.0, 2.0, 3.0]) == 3.0
        @test hypervolume(Vector{Float64}[], [1.0, 1.0]) == 0.0
        # Points not strictly better than r in every objective contribute nothing.
        @test hypervolume([[1.0, 3.0], [3.0, 1.0], [4.0, 0.0]], [3.0, 3.0]) == 0.0
        @test hypervolume([[1.0, 3.0], [2.0, 2.0]], [3.0, 3.0]) == 1.0
    end

    @testset "invariances" begin
        F = [[0.1, 0.9, 0.5], [0.5, 0.5, 0.5], [0.9, 0.1, 0.2]]
        r = [1.0, 1.0, 1.0]
        hv = hypervolume(F, r)
        @test hypervolume(vcat(F, F), r) ≈ hv
        @test hypervolume(vcat(F, [[0.6, 0.6, 0.6]]), r) ≈ hv
        @test hypervolume(reverse(F), r) ≈ hv
        # Permuting the objectives does not change the value.
        @test hypervolume([p[[3, 1, 2]] for p in F], r) ≈ hv
    end

    @testset "against inclusion-exclusion, m = $m" for m in 2:5
        rng = MersenneTwister(100 + m)
        for _ in 1:40
            n = rand(rng, 1:9)
            F = [rand(rng, m) for _ in 1:n]
            # Exercise ties and duplicates.
            rand(rng) < 0.3 && push!(F, copy(F[1]))
            rand(rng) < 0.3 && (F[end][1] = F[1][1])
            r = fill(1.0, m) .+ 0.2 .* rand(rng, m)
            @test hypervolume(F, r) ≈ hv_inclusion_exclusion(F, r) atol = 1e-12
        end
    end

    @testset "3D sweep against slicing recursion" begin
        rng = MersenneTwister(42)
        for _ in 1:20
            F = [rand(rng, 3) for _ in 1:60]
            r = [1.0, 1.0, 1.0]
            # Lift to 4D with a constant objective: HV4 = HV3 · (r4 - c).
            G = [vcat(p, 0.0) for p in F]
            @test hypervolume(G, [1.0, 1.0, 1.0, 2.0]) ≈ 2 * hypervolume(F, r) rtol = 1e-12
        end
        # Points on a sphere (all non-dominated).
        F = [normalize3(rand(rng, 3)) for _ in 1:200]
        @test 0 < hypervolume(F, [1.1, 1.1, 1.1]) < 1.1^3
    end

    @testset "input checks and types" begin
        @test_throws ArgumentError hypervolume([[1.0, 1.0]], Float64[])
        @test_throws ArgumentError hypervolume([[1.0, 1.0]], [Inf, 2.0])
        @test_throws DimensionMismatch hypervolume([[1.0, 1.0]], [2.0, 2.0, 2.0])
        @test_throws ArgumentError hypervolume([[NaN, 1.0]], [2.0, 2.0])
        @test hypervolume([Float32[1, 1]], Float32[2, 2]) isa Float32
        @test hypervolume([[1, 1]], [2, 3]) === 2.0
    end
end


@testset "normalization" begin
    @test normalize_points([[1.0, 4.0], [3.0, 2.0]], [1.0, 2.0], [3.0, 4.0]) == [[0.0, 1.0], [1.0, 0.0]]
    # Degenerate objective: divided by eps instead of zero.
    @test normalize_points([[1.0, 2.0]], [1.0, 2.0], [3.0, 2.0]) == [[0.0, 0.0]]
    @test_throws ArgumentError normalize_points([[1.0, 2.0]], [3.0, 2.0], [1.0, 2.0])

    R = [[0.0, 1.0], [1.0, 0.0]]
    # (1.1^2 - 1^2) / 1.1^2: union of two 1.1 × 0.1 strips.
    @test normalized_hypervolume(R, R) ≈ 0.21 / 1.21
    @test normalized_hypervolume(R, [0.0, 0.0], [1.0, 1.0]) == normalized_hypervolume(R, R)
    # Scale invariance.
    S = [[0.0, 10.0], [5.0, 0.0]]
    @test normalized_hypervolume(S, S) ≈ normalized_hypervolume(R, R)
    # Offset and division by offset^m.
    @test normalized_hypervolume(R, R; offset = 2.0) ≈ (4 - 1) / 4
    @test 0 <= normalized_hypervolume([[0.5, 0.5]], R) <= 1
    # Conventions: empty front, all objectives degenerate.
    @test isnan(normalized_hypervolume(Vector{Float64}[], R))
    @test isnan(normalized_hypervolume([[1.0, 1.0]], [1.0, 1.0], [1.0, 1.0]))
    @test_throws ArgumentError normalized_hypervolume(R, R; offset = 0.0)
end
