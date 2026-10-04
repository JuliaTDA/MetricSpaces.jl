# Changelog

Notable changes to MetricSpaces are recorded here.

## Unreleased

- Add vertex-cubical ECC, simplicial/cubical ECT, exact centered SECT integrals,
  direction sampling and stable-order Euler tables.
- Add exact anisotropic Euclidean distance transforms and binary-image height,
  radial, dilation, erosion and signed-distance filtrations, with an optional MLJ adapter.

- Prepare the package for its first General registry release.
- Add complete dependency compatibility bounds and Aqua quality checks.
- Restore testing on the minimum supported Julia version.
- Remove the unused OhMyThreads dependency, whose bound made Julia 1.8
  resolution impossible.
- Replace uses of Julia 1.9's `stack` with equivalent Julia 1.8-compatible
  matrix construction.
- Record the existing `EuclideanSpace` alias constructors as expected Aqua
  piracy failures pending a future container-type redesign.

## 0.2.0

- Add geometric datasets, density estimators, sampling, transformations, and
  neighborhood constructions.
- Add geodesic distances and two-dimensional nerve construction.

## 0.1.0

- Initial public release of metric-space types and distance utilities.
