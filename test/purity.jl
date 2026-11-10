@testset "purity" begin
    # BPA2004 eq. (7)-(8): denominator is the solver's own front.
    A = [[0.0, 1.0], [0.6, 0.6], [1.0, 0.0]]
    B = [[0.5, 0.5], [0.0, 1.0], [2.0, -1.0]]
    R = nondominated(vcat(A, B))
    @test Set(R) == Set([[0.0, 1.0], [1.0, 0.0], [0.5, 0.5], [2.0, -1.0]])
    @test purity(A, R) == 2 / 3
    @test purity(B, R) == 1.0

    # Equivalent points of A count once.
    @test purity([[0.0, 1.0], [0.0, 1.0], [0.6, 0.6]], R) == 0.5
    @test purity([[0.0, 1.0], [0.0, 1.0 + 1e-12]], R) == 1.0
    @test purity([[0.0, 1.0], [0.0, 1.0 + 1e-12]], R; tol = Tolerance(0)) == 0.5

    # Membership under the tolerance.
    @test purity([[0.0, 1.0 + 1e-10]], R) == 1.0
    @test purity([[0.0, 1.0 + 1e-6]], R) == 0.0

    # No point in R, empty A, empty R.
    @test purity([[3.0, 3.0]], R) == 0.0
    @test isnan(purity(Vector{Float64}[], R))
    @test purity([[1.0, 1.0]], Vector{Float64}[]) == 0.0

    @test purity([[0.0f0, 1.0f0]], [[0.0f0, 1.0f0]]) isa Float32
    @test_throws DimensionMismatch purity([[0.0, 1.0]], [[0.0, 1.0, 2.0]])
end
