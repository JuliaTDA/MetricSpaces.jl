# Euler transforms and image filtrations

Euler curves count alternating numbers of vertices, edges, squares, and higher cells throughout a filtration. Directional Euler transforms repeat this count from several viewpoints. Image filtrations assign numerical values to a binary shape so you can study its sublevels with Euler curves or persistent homology.

## Begin with a ring

```@example metric_euler
using MetricSpaces
mask = trues(5, 5)
mask[2:4, 2:4] .= false
curve = cubical_ecc(zeros(5, 5); mask=mask)
@assert curve.values[end] == 0  # One component minus one hole.
(; thresholds=curve.thresholds, values=curve.values)
```

Masks select **vertices** of a cubical grid. A cell exists only when all of its corner vertices are included. A k-cell enters at the largest value of its corners and contributes `(-1)^k`. This is the vertex lower-star convention used by TDARipserer.Cubical; it is not the topology of a union of closed pixel boxes. In particular, two diagonally adjacent foreground vertices do not automatically form an edge.

`cubical_ecc(A; mask, thresholds)` counts sublevels of finite values on included vertices. Its thresholds must be finite and strictly increasing. With no thresholds supplied it uses distinct cell-event values. If your filtration has `Inf` at excluded background vertices, pass a mask that excludes them.

## Look from several directions

```@example metric_euler
D = sample_directions(2; n=8)
t = collect(range(-6.0, 6.0; length=25))
E = ect(mask; directions=D, thresholds=t)
S = sect(E)
@assert size(E.values) == (length(t), size(D, 2))
@assert all(isapprox.(S.values[1, :], 0.0; atol=1e-10))
@assert all(isapprox.(S.values[end, :], 0.0; atol=1e-10))
table = euler_table(S)
(; matrix_shape=size(S.values), first_rows=(table.direction[1:3], table.threshold[1:3]))
```

`D` has one normalized direction per **column**. Transform values have thresholds in rows and directions in columns. `euler_table` emits all thresholds for direction 1, then direction 2, and so on. This ordering stays consistent when flattening into a feature vector.

The default direction sampler uses equally spaced angles in 2D, a Fibonacci sphere in 3D, and seeded Gaussian directions in higher dimensions. One-dimensional input returns the two directions ±1 regardless of `n`. More directions give more viewpoints, while more thresholds give finer samples of each curve; both enlarge feature size and computation.

`sect` integrates each Euler step function after subtracting its average over the chosen threshold interval. It uses exact jump events, not trapezoidal interpolation of sampled values. Both endpoints are zero up to roundoff. The centering interval depends on the first and last thresholds, so changing that interval changes every integrated value.

## A simplicial shape

```@example metric_simplicial_euler
using MetricSpaces
points = [0.0 1.0 0.0; 0.0 0.0 1.0]  # Three coordinate columns.
E = ect(points, [[1, 2, 3]]; directions=sample_directions(2; n=4),
        thresholds=collect(-2.0:0.25:2.0))
@assert all(E.values[end, :] .== 1)  # A filled triangle is contractible.
size(E.values)
```

`ect(points, simplices)` includes all input vertices and completes the faces of maximal simplices. Omitting the triangle and supplying only its three edges would represent a loop. Duplicate vertices within a simplex, nonfinite coordinates, and invalid vertex indices are rejected.

## Five binary-image transforms

Threshold a grayscale image explicitly to obtain a Boolean array. The transforms do not learn an intensity threshold or interpret arbitrary real-valued images as masks.

| Kind / function | Sublevel interpretation |
|---|---|
| `:height` / `height_filtration` | Foreground projection along a normalized direction |
| `:radial` / `radial_filtration` | Foreground distance from a physical center |
| `:dilation` / `dilation_filtration` | Distance to foreground; sublevel `r` dilates by `r` |
| `:erosion` / `erosion_filtration` | Negative distance to background on foreground; sublevel `-r` retains depth at least `r` |
| `:signed_distance` / `signed_distance_filtration` | Negative inside, positive outside; sublevel 0 recovers the mask |

```@example metric_images
using MetricSpaces
mask = falses(5, 5)
mask[2:4, 2:4] .= true
height = height_filtration(mask; direction=[1.0, 0.0])
radial = radial_filtration(mask; center=[2.0, 2.0])
dilation = dilation_filtration(mask)
erosion = erosion_filtration(mask)
signed = ImageFiltration(:signed_distance)(mask)
@assert (signed .<= 0) == mask
@assert all(height[mask] .>= 1)
(; center_depth=signed[3, 3], dilated_vertices=count(dilation .<= 1.0),
   eroded_vertices=count(erosion .<= -2.0))
```

`ImageFiltration(kind; kwargs...)` is a callable object storing the selected transform and geometric parameters. The exact Euclidean distance transform measures distances between grid vertices and is separable across axes. No target vertices give `Inf`. Signed distance and erosion include one exterior layer of background by default; use `exterior=false` when only background within the array should count.

## Physical spacing, orientation, and comparison

Grid coordinates are `origin[k] + spacing[k] * (index[k] - 1)`. Supply one positive finite spacing and one finite origin per array dimension. The first array axis is the first coordinate axis; there is no implicit image-display row/column reversal. The radial default center is the physical center of the grid.

```@example metric_images
anisotropic = signed_distance_filtration(mask; spacing=[2.0, 1.0])
physical_height = height_filtration(mask; direction=[1.0, 0.0],
    spacing=[2.0, 1.0], origin=[-4.0, 0.0])
(; center_distance=anisotropic[3, 3], center_height=physical_height[3, 3])
```

For comparisons, use the same directions, physical coordinate convention, and threshold grid for every shape. Default threshold ranges are derived from each input, so their sample positions can differ. Center, align, and scale shapes explicitly when invariance is desired; these steps are not implicit in ECT/SECT. A common threshold range should include the geometric extent you intend to compare.

The cubical cell enumeration is guarded by `max_cells=10_000_000`; even a moderately sized high-dimensional grid can contain many cells. Direction count multiplies this workload. Begin with a coarse threshold grid and a modest direction count, then check whether features change when refining them.

## Persistent homology and MLJ

Height, radial, and erosion transforms mark excluded background with `Inf`. Use a finite cubical persistence threshold to omit those vertices, or JuliaTDA's `TDARipserer.image_persistence`, which chooses a finite threshold. The array has the same vertex interpretation throughout.

On Julia 1.9+, load MLJModelInterface or MLJBase to activate `image_filtration_model(:signed_distance)`. It transforms a vector of binary masks into filtration arrays and can precede a cubical persistent-homology model in an MLJ pipeline. The transformer does not fit an intensity threshold from the full dataset. Choose any intensity threshold and preprocessing from training data when evaluating a prediction task.

The [API Reference](@ref) contains the full Euler and image signatures. The source implements the centered-integral convention described in the SECT reference by Meng et al. (2022), linked in the `sect` docstring.
