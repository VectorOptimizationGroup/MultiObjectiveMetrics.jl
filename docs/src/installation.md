# Installation

MultiObjectiveMetrics.jl requires Julia 1.10 or later and has no runtime
dependencies. It is not registered yet; add it from its GitHub repository:

```julia
import Pkg
Pkg.add(url = "https://github.com/VectorOptimizationGroup/MultiObjectiveMetrics.jl")
```

To work on a local checkout, develop it into your environment instead:

```julia
Pkg.develop(path = "/path/to/MultiObjectiveMetrics.jl")
```

Run the tests from the package directory:

```sh
julia --project -e 'using Pkg; Pkg.test()'
```
