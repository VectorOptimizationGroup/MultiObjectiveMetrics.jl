# Parity with MetricsRel.jl of MAMBO-paper (Fazzio, Prudente, Schuverdt).
# The reference values in data/mambo_parity.toml were computed by running
# that code outside this package; see the [provenance] table of the file.
# Expected differences, all documented in docs/src/guides/conventions.md:
#
# - Covering: MAMBO counts strict dominance; the package default is weak
#   dominance (Zitzler 1999, Def. 9). With StrictDominance() they must agree.
# - Γ and Δ: the package clips the front to [ideal, nadir] (DEC-001 #1);
#   values are compared with MAMBO applied to the clipped front, which equals
#   MAMBO itself when the front lies inside the box.
# - Δ: MAMBO skips an objective whose mean gap is zero; the package follows
#   eq. (5.2), which gives Δ_j = 1 there (case "collapsed_objective").

using TOML

const PARITY = TOML.parsefile(joinpath(@__DIR__, "data", "mambo_parity.toml"))

points(x) = Vector{Float64}[Float64.(p) for p in x]
same(a, b) = (isnan(a) && isnan(b)) || isapprox(a, b; rtol = 1e-12, atol = 1e-14)

@testset "parity with MAMBO MetricsRel.jl ($(PARITY["provenance"]["mambo_commit"]))" begin
    @test length(PARITY["cases"]) >= 10
    @testset "$(case["name"])" for case in PARITY["cases"]
        A, B = points(case["A"]), points(case["B"])
        And, Bnd = nondominated(A), nondominated(B)
        R = nondominated(vcat(And, Bnd))

        @test sort(And) == sort(points(case["A_nd"]))
        @test sort(Bnd) == sort(points(case["B_nd"]))
        @test sort(R) == sort(points(case["R"]))
        ideal, nadir = ideal_point(R), nadir_point(R)
        @test ideal == case["ideal"]
        @test nadir == case["nadir"]

        @test same(purity(And, R), case["purity_A"])
        @test same(purity(Bnd, R), case["purity_B"])

        for (front, key) in ((And, "A"), (Bnd, "B"))
            @test same(gamma_spread(front, R), case["gamma_$(key)_clipped"])
            mambo_delta = case["delta_$(key)_clipped"]
            if case["name"] == "collapsed_objective" && key == "A"
                @test delta_spread(front, R) == max(mambo_delta, 1.0)
                @test mambo_delta < 1.0      # the divergence is real
            else
                @test same(delta_spread(front, R), mambo_delta)
            end
            @test same(normalized_hypervolume(front, R), case["hv_$(key)"])
        end

        @test same(covering(A, B; relation = StrictDominance()), case["covering_AB"])
        @test same(covering(B, A; relation = StrictDominance()), case["covering_BA"])
        @test covering(A, B) >= covering(A, B; relation = StrictDominance())
        @test covering(B, A) >= covering(B, A; relation = StrictDominance())
    end

    cases = Dict(c["name"] => c for c in PARITY["cases"])
    @testset "documented divergences" begin
        # Unclipped MAMBO Δ is negative when the front goes far beyond the nadir.
        @test cases["beyond_nadir_negative_delta"]["delta_A"] < 0
        @test delta_spread(points(cases["beyond_nadir_negative_delta"]["A_nd"]),
                           points(cases["beyond_nadir_negative_delta"]["R"])) >= 0
        # Weak and strict covering differ when the fronts share points.
        c = cases["covering_shared_points"]
        @test covering(points(c["A"]), points(c["B"])) == 0.75
        @test c["covering_AB"] == 0.5
    end
end
