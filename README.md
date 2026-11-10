# MultiObjectiveMetrics.jl

[![Docs (dev)](https://img.shields.io/badge/docs-dev-blue.svg)](https://vectoroptimizationgroup.github.io/MultiObjectiveMetrics.jl/dev/)
[![CI](https://github.com/VectorOptimizationGroup/MultiObjectiveMetrics.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/VectorOptimizationGroup/MultiObjectiveMetrics.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/VectorOptimizationGroup/MultiObjectiveMetrics.jl/graph/badge.svg?branch=main)](https://codecov.io/gh/VectorOptimizationGroup/MultiObjectiveMetrics.jl)

Performance indicators for multiobjective optimization: Purity, Γ-spread,
Δ-spread, Covering and exact hypervolume, built on dominance with an explicit
tolerance. Each indicator is implemented from its primary source, with every
edge-case convention documented. Requires Julia 1.10 or later; no runtime
dependencies.

## Installation

The package is not registered. Add it from its GitHub repository:

```julia
import Pkg
Pkg.add(url = "https://github.com/VectorOptimizationGroup/MultiObjectiveMetrics.jl")
```

## Quick Example

```julia
using MultiObjectiveMetrics

A = [[0.0, 1.0], [0.25, 0.75], [0.5, 0.5], [1.0, 0.0]]   # front of solver A
B = [[0.1, 0.8], [0.6, 0.45], [0.7, 0.7]]                # front of solver B

R = nondominated(vcat(nondominated(A), nondominated(B))) # reference front

purity(A, R)                       # fraction of A in R (higher is better)
gamma_spread(A, R)                 # largest gap (lower is better)
delta_spread(A, R)                 # uniformity of the spread (lower is better)
covering(A, B)                     # fraction of B weakly dominated by A
hypervolume(A, [1.1, 1.1])         # exact, explicit reference point
normalized_hypervolume(A, R)       # normalized by ideal and nadir of R
```

Point sets can also be the columns or rows of a matrix: `eachcol(M)`,
`eachrow(M)`. All objectives are minimized.

## Documentation

The [documentation](https://vectoroptimizationgroup.github.io/MultiObjectiveMetrics.jl/dev/)
gives the definition and source of each indicator, the conventions for edge
cases, how to build performance profiles, and the API reference. Instructions
for building it locally are in [`docs/README.md`](docs/README.md).

Run the tests from the package directory:

```sh
julia --project -e 'using Pkg; Pkg.test()'
```

## Acknowledgements

The MetricsRel.jl module of
[MAMBO-paper](https://github.com/lfprudente/MAMBO-paper), by N. Fazzio,
L. F. Prudente and M. L. Schuverdt, motivated this package and served as its
reference implementation; the parity values in the test suite were computed
with it. The code of this package was written independently from the primary
sources.

## Citation

If you use MultiObjectiveMetrics.jl in research, please cite the software
using the metadata in [`CITATION.cff`](CITATION.cff).

## License

MultiObjectiveMetrics.jl is distributed under the [MIT License](LICENSE).
