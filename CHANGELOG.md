# Changelog

Notable user-visible changes to MultiObjectiveMetrics.jl are documented here.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and releases follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- **Breaking:** package renamed from `MOMetrics` to `MultiObjectiveMetrics`,
  with a new UUID. `nonDominated` and `IsNonDominated` are removed; use
  `nondominated` and `dominates`.

### Added

- `Tolerance`, `compare`, `dominates`, `weakly_dominates`, `isequivalent`:
  dominance with an explicit componentwise tolerance (exact with `Tolerance(0)`).
- `nondominated`, `unique_points`, `ideal_point`, `nadir_point` for point sets
  given as vectors of vectors or matrix columns/rows.
- `purity`, `gamma_spread`, `delta_spread` following Custódio et al. (2011),
  with documented conventions for edge cases.
- `covering` with weak dominance by default and `StrictDominance()` as option.
- `hypervolume` (exact, any number of objectives, explicit reference point),
  `normalize_points` and `normalized_hypervolume`.
- Parity tests against values computed with MetricsRel.jl of MAMBO-paper.

[Unreleased]: https://github.com/VectorOptimizationGroup/MultiObjectiveMetrics.jl/commits/main
