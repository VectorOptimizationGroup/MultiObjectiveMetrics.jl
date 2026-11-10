@testset "covering" begin
    A = [[0.0, 1.0], [1.0, 0.0]]
    B = [[0.0, 1.0], [2.0, 0.5]]

    # Zit1999 Def. 9: weak dominance counts equal points.
    @test covering(A, B) == 1.0
    @test covering(A, B; relation = WeakDominance()) == 1.0
    # Strict dominance does not.
    @test covering(A, B; relation = StrictDominance()) == 0.5
    # Not symmetric.
    @test covering(B, A) == 0.5
    @test covering(A, A) == 1.0
    @test covering(A, A; relation = StrictDominance()) == 0.0

    # Dominated and repeated points of B are removed before counting.
    B2 = [[0.0, 1.0], [0.0, 1.0], [3.0, 3.0], [2.0, 0.5]]
    @test covering(A, B2) == covering(A, B)
    # Equivalence under the tolerance.
    @test covering([[0.0, 1.0 + 1e-10]], [[0.0, 1.0]]) == 1.0
    @test covering([[0.0, 1.0 + 1e-10]], [[0.0, 1.0]]; tol = Tolerance(0)) == 0.0

    # Hand count: B has 4 non-dominated points; A covers 3 of them, one by equality.
    A = [[0.0, 2.0], [1.0, 1.0], [2.0, 0.0]]
    B = [[0.0, 2.0], [1.5, 1.5], [2.5, 0.5], [3.0, -1.0]]
    @test covering(A, B) == 0.75
    @test covering(A, B; relation = StrictDominance()) == 0.5

    @test isnan(covering(A, Vector{Float64}[]))
    @test covering(Vector{Float64}[], B) == 0.0
end
