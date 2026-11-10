using Test
using Random
using MultiObjectiveMetrics

@testset "MultiObjectiveMetrics.jl" begin
    include("dominance.jl")
    include("sets.jl")
    include("purity.jl")
    include("spread.jl")
    include("covering.jl")
    include("hypervolume.jl")
    include("inputs.jl")
    include("inference.jl")
    include("parity_mambo.jl")
    include("aqua.jl")
end
