@testset "nondominated" begin
    F = [[1.0, 3.0], [2.0, 2.0], [2.0, 4.0], [1.0, 3.0], [3.0, 1.0], [3.0, 3.0]]
    @test nondominated_indices(F) == [1, 2, 4, 5]
    @test nondominated(F) == [[1.0, 3.0], [2.0, 2.0], [1.0, 3.0], [3.0, 1.0]]
    @test nondominated_indices(Vector{Float64}[]) == Int[]
    @test nondominated([[1.0, 2.0]]) == [[1.0, 2.0]]

    # Independent of the order of the input.
    rng = MersenneTwister(11)
    for _ in 1:50
        G = [rand(rng, 3) for _ in 1:30]
        perm = randperm(rng, length(G))
        @test sort(nondominated(G)) == sort(nondominated(G[perm]))
        # Exact definition: kept iff no other point dominates it.
        kept = Set(nondominated_indices(G; tol = Tolerance(0)))
        for i in eachindex(G)
            dominated = any(j -> j != i && all(G[j] .<= G[i]) && any(G[j] .< G[i]), eachindex(G))
            @test (i in kept) == !dominated
        end
    end

    # Tolerance: a point worse by less than ε is not dominated.
    @test nondominated_indices([[1.0, 1.0], [1.0 + 1e-10, 1.0]]) == [1, 2]
    @test nondominated_indices([[1.0, 1.0], [1.0 + 1e-10, 1.0]]; tol = Tolerance(0)) == [1]
end

@testset "unique_points" begin
    F = [[1.0, 2.0], [1.0 + 1e-12, 2.0], [0.0, 3.0], [1.0, 2.0]]
    @test unique_indices(F) == [1, 3]
    @test unique_points(F) == [[1.0, 2.0], [0.0, 3.0]]
    @test unique_indices(F; tol = Tolerance(0)) == [1, 2, 3]
    @test unique_points(Vector{Float64}[]) == Vector{Float64}[]
end

@testset "ideal_point and nadir_point" begin
    F = [[1.0, 3.0, 0.0], [2.0, 2.0, 5.0], [0.5, 4.0, 1.0]]
    @test ideal_point(F) == [0.5, 2.0, 0.0]
    @test nadir_point(F) == [2.0, 4.0, 5.0]
    @test ideal_point([[1, 2]]) == [1.0, 2.0]
    @test eltype(ideal_point([[1, 2]])) == Float64
    @test_throws ArgumentError ideal_point(Vector{Float64}[])
    @test_throws ArgumentError nadir_point(Vector{Float64}[])
end
