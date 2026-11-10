@testset "input formats" begin
    points = [[0.0, 1.0], [0.25, 0.75], [1.0, 0.0], [0.5, 0.9]]
    columns = reduce(hcat, points)            # one point per column
    rows = permutedims(columns)               # one point per row
    R = nondominated(points)

    for F in (eachcol(columns), eachrow(rows))
        @test nondominated_indices(F) == nondominated_indices(points)
        @test purity(F, R) == purity(points, R)
        @test gamma_spread(F, R) == gamma_spread(points, R)
        @test delta_spread(F, R) == delta_spread(points, R)
        @test covering(F, R) == covering(points, R)
        @test hypervolume(F, [1.1, 1.1]) == hypervolume(points, [1.1, 1.1])
        @test normalized_hypervolume(F, R) == normalized_hypervolume(points, R)
        @test ideal_point(F) == ideal_point(points)
    end
    # Mixed: matrix columns against a vector of vectors.
    @test purity(eachcol(columns), points) == 1.0

    @testset "malformed sets" begin
        @test_throws DimensionMismatch nondominated([[1.0, 2.0], [1.0]])
        @test_throws ArgumentError nondominated([Float64[]])
        @test_throws ArgumentError purity([[Inf, 1.0]], points)
        @test_throws ArgumentError covering(points, [[NaN, 1.0]])
    end
end
