@testset "type stability and allocations" begin
    F = [[0.0, 1.0], [0.25, 0.75], [1.0, 0.0]]
    G = [[0.0, 1.0, 0.5], [0.5, 0.5, 0.5], [1.0, 0.0, 0.2]]
    H = [vcat(p, 0.3) for p in G]
    ideal, nadir = [0.0, 0.0], [1.0, 1.0]
    u, v = F[1], F[2]

    @inferred compare(u, v)
    @inferred dominates(u, v)
    @inferred dominates(WeakDominance(), u, v)
    @inferred weakly_dominates(u, v)
    @inferred isequivalent(u, v)
    @inferred nondominated_indices(F)
    @inferred nondominated(F)
    @inferred unique_points(F)
    @inferred ideal_point(F)
    @inferred nadir_point(F)
    @inferred purity(F, F)
    @inferred gamma_spread(F, F)
    @inferred delta_spread(F, ideal, nadir)
    @inferred covering(F, F)
    @inferred covering(F, F; relation = StrictDominance())
    @inferred hypervolume(F, [1.1, 1.1])
    @inferred hypervolume(G, [1.1, 1.1, 1.1])
    @inferred hypervolume(H, [1.1, 1.1, 1.1, 1.1])
    @inferred normalized_hypervolume(F, F)
    @inferred gamma_spread(eachcol(reduce(hcat, F)), F)

    # Pairwise comparisons do not allocate.
    compare(u, v); weakly_dominates(u, v); isequivalent(u, v)
    @test (@allocated compare(u, v)) == 0
    @test (@allocated weakly_dominates(u, v)) == 0
    @test (@allocated isequivalent(u, v)) == 0
    # Spreads allocate one work vector (plus the extremes when R is given).
    delta_spread(F, ideal, nadir)
    @test (@allocated delta_spread(F, ideal, nadir)) <= 256
end
