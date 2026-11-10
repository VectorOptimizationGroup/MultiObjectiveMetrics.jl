# Quick Start

Each solver returns a set of objective vectors. Reduce each set to its
non-dominated points, build the reference front `R` from the union of all
solvers, and evaluate each front against `R`.

```jldoctest quickstart
julia> using MultiObjectiveMetrics

julia> fronts = Dict(
           "solver A" => [[0.0, 1.0], [0.25, 0.75], [0.5, 0.5], [1.0, 0.0]],
           "solver B" => [[0.1, 0.8], [0.6, 0.45], [0.7, 0.7]],
       );

julia> nd = Dict(name => nondominated(F) for (name, F) in fronts);

julia> R = nondominated(reduce(vcat, values(nd)));

julia> length(nd["solver B"]), length(R)
(2, 6)

julia> purity(nd["solver A"], R), purity(nd["solver B"], R)
(1.0, 1.0)

julia> gamma_spread(nd["solver A"], R)
0.5

julia> round(delta_spread(nd["solver B"], R); digits = 2)
0.65
```

Covering compares two fronts directly, and the hypervolume needs an explicit
reference point:

```jldoctest quickstart
julia> covering(fronts["solver A"], fronts["solver B"])  # no point of B is covered by A
0.0

julia> round(hypervolume(nd["solver A"], [1.1, 1.1]); digits = 4)
0.5225

julia> round(normalized_hypervolume(nd["solver A"], R); digits = 4)
0.4318
```

The metrics compare fronts of different solvers on the same problem. To
summarize many problems, see [Performance profiles](@ref).
