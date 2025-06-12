
# API Reference {#API-Reference}

Complete reference for all exported functions and types in MetricSpaces.jl.

## Core Types {#Core-Types}
<details class='jldocstring custom-block' open>
<summary><a id='MetricSpaces.MetricSpace' href='#MetricSpaces.MetricSpace'><span class="jlbinding">MetricSpaces.MetricSpace</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



The abstract Metric Space type is just an alias for Vector{T}.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/JuliaTDA/MetricSpaces.jl/blob/7c56a69ba6b03a17a348f2b20ec11c61d52b75f5/src/base/types.jl#L4-L7" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='MetricSpaces.EuclideanSpace' href='#MetricSpaces.EuclideanSpace'><span class="jlbinding">MetricSpaces.EuclideanSpace</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



A type to model metric spaces where each element is an array of the same length.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/JuliaTDA/MetricSpaces.jl/blob/7c56a69ba6b03a17a348f2b20ec11c61d52b75f5/src/base/types.jl#L9-L11" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='MetricSpaces.as_matrix' href='#MetricSpaces.as_matrix'><span class="jlbinding">MetricSpaces.as_matrix</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
as_matrix(X::EuclideanSpace)
```


Convert an Euclidean space into a matrix.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/JuliaTDA/MetricSpaces.jl/blob/7c56a69ba6b03a17a348f2b20ec11c61d52b75f5/src/base/types.jl#L78-L82" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='MetricSpaces.SubsetIndex' href='#MetricSpaces.SubsetIndex'><span class="jlbinding">MetricSpaces.SubsetIndex</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



A vector of integers, generally interpreted as  indexes of a metric space.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/JuliaTDA/MetricSpaces.jl/blob/7c56a69ba6b03a17a348f2b20ec11c61d52b75f5/src/base/types.jl#L96-L99" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='MetricSpaces.Covering' href='#MetricSpaces.Covering'><span class="jlbinding">MetricSpaces.Covering</span></a> <Badge type="info" class="jlObjectType jlType" text="Type" /></summary>



A covering is a vector of metric spaces, where each metric space is a subset of the original metric space `X`.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/JuliaTDA/MetricSpaces.jl/blob/7c56a69ba6b03a17a348f2b20ec11c61d52b75f5/src/base/types.jl#L108-L111" target="_blank" rel="noreferrer">source</a></Badge>

</details>


## Distance Functions {#Distance-Functions}
<details class='jldocstring custom-block' open>
<summary><a id='MetricSpaces.pairwise_distance' href='#MetricSpaces.pairwise_distance'><span class="jlbinding">MetricSpaces.pairwise_distance</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
pairwise_distance(M::S, N::S, d) where {S <: MetricSpace{T} where {T}}
```


Compute the pairwise distances between all elements of metric spaces `M` and `N` using the distance function `d`.

**Arguments**
- `M::S`: A metric space of type `S`, where `S` is a subtype of `MetricSpace`.
  
- `N::S`: Another metric space of the same type as `M`.
  
- `d`: A function that computes the distance between two elements.
  

**Returns**
- A matrix of size `length(M) × length(N)` where the entry `(i, j)` contains the distance `d(M[i], N[j])`.
  

**Notes**
- The computation is parallelized across threads for improved performance.
  
- Progress is displayed using a progress bar.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/JuliaTDA/MetricSpaces.jl/blob/7c56a69ba6b03a17a348f2b20ec11c61d52b75f5/src/base/distances.jl#L1-L17" target="_blank" rel="noreferrer">source</a></Badge>



```julia
pairwise_distance(M::S, N::S, d::Metric) where {S <: EuclideanSpace{N, T} where {N, T}}
```


Compute the pairwise distances between all elements in the collections `M` and `N` using the metric `d`.

**Arguments**
- `M::S`: A collection of points in a Euclidean space.
  
- `N::S`: Another collection of points in the same Euclidean space as `M`.
  
- `d::Metric`: A metric function to compute the distance between points.
  

**Returns**
- `s::Matrix{Float64}`: A matrix where the entry `s[i, j]` contains the distance between `M[i]` and `N[j]`.
  

**Notes**
- The computation is parallelized across threads for efficiency.
  
- Progress is displayed using a progress bar.
  
- The function assumes that `M` and `N` are compatible with the provided metric and space type.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/JuliaTDA/MetricSpaces.jl/blob/7c56a69ba6b03a17a348f2b20ec11c61d52b75f5/src/base/distances.jl#L45-L62" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='MetricSpaces.pairwise_distance_summary' href='#MetricSpaces.pairwise_distance_summary'><span class="jlbinding">MetricSpaces.pairwise_distance_summary</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
pairwise_distance_summary(M::S, N::S, d, summary_function = mean) where {S <: MetricSpace{T} where {T}}
```


Compute a summary statistic of pairwise distances between each element of metric space `M` and all elements of metric space `N` using the distance function `d`.

**Arguments**
- `M::S`: A metric space (or collection of points) of type `S`.
  
- `N::S`: Another metric space (or collection of points) of type `S`.
  
- `d`: A function that computes the distance between two points.
  
- `summary_function`: (Optional) A function to summarize the distances for each element of `M` (default is `mean`).
  

**Returns**
- `s`: An array where each entry `s[i]` contains the summary statistic (e.g., mean) of the distances from the `i`-th element of `M` to all elements of `N`.
  

**Notes**
- The computation is parallelized using threads for improved performance.
  
- Progress is displayed using a progress bar.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/JuliaTDA/MetricSpaces.jl/blob/7c56a69ba6b03a17a348f2b20ec11c61d52b75f5/src/base/distances.jl#L79-L96" target="_blank" rel="noreferrer">source</a></Badge>

</details>


## Norm Functions {#Norm-Functions}
<details class='jldocstring custom-block' open>
<summary><a id='MetricSpaces.norm' href='#MetricSpaces.norm'><span class="jlbinding">MetricSpaces.norm</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
Euclidean norm.
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/JuliaTDA/MetricSpaces.jl/blob/7c56a69ba6b03a17a348f2b20ec11c61d52b75f5/src/base/norm.jl#L2-L4" target="_blank" rel="noreferrer">source</a></Badge>

</details>


## Ball Operations {#Ball-Operations}
<details class='jldocstring custom-block' open>
<summary><a id='MetricSpaces.ball' href='#MetricSpaces.ball'><span class="jlbinding">MetricSpaces.ball</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
ball(X::MetricSpace{T}, x::T, ϵ::Number, distance=dist_euclidean) where {T}
```


Extract the subset of points from metric space `X` that are within distance `ϵ` from point `x`.

This function returns the actual points (not just indices) that form the ball  B(x, ϵ) = {y ∈ X : d(x, y) &lt; ϵ} around the center point `x`.

**Arguments**
- `X::MetricSpace{T}`: The metric space containing the points to search
  
- `x::T`: The center point of the ball
  
- `ϵ::Number`: The radius of the ball (must be positive)
  
- `distance`: Distance function to use (default: `dist_euclidean`)
  

**Returns**
- `MetricSpace`: A new metric space containing only the points within the ball
  
- Returns an empty metric space if no points are found within the radius
  

**Examples**

```julia
# Create a 1D Euclidean space
X = EuclideanSpace(reshape([1.0, 2.0, 3.0, 4.0, 5.0], 1, 5))

# Get points within distance 1.5 from [3.0]
subset = ball(X, [3.0], 1.5)  # Contains points [2.0, 3.0, 4.0]

# Using Manhattan distance
subset_l1 = ball(X, [3.0], 1.5, dist_cityblock)

# Check if result is empty
result = ball(X, [10.0], 0.1)
isempty(result)  # true
```


**Implementation Details**
- Internally uses [`ball_ids`](/api#MetricSpaces.ball_ids) to find the relevant indices
  
- Preserves the metric space structure in the returned subset
  
- The distance function should be compatible with the metric space type
  

**Mathematical Definition**

For a metric space (X, d) and point x ∈ X, the open ball of radius ϵ is: B(x, ϵ) = {y ∈ X : d(x, y) &lt; ϵ}

See also: [`ball_ids`](/api#MetricSpaces.ball_ids), [`pairwise_distance`](/api#MetricSpaces.pairwise_distance)


<Badge type="info" class="source-link" text="source"><a href="https://github.com/JuliaTDA/MetricSpaces.jl/blob/7c56a69ba6b03a17a348f2b20ec11c61d52b75f5/src/base/ball.jl#L53-L97" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='MetricSpaces.ball_ids' href='#MetricSpaces.ball_ids'><span class="jlbinding">MetricSpaces.ball_ids</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
ball_ids(X::MetricSpace{T}, x::T, ϵ::Number, distance=dist_euclidean) where {T}
```


Find the indices of points in metric space `X` that are within distance `ϵ` from point `x`.

This function computes the ball B(x, ϵ) = {y ∈ X : d(x, y) &lt; ϵ} and returns the  indices of points in X that belong to this open ball.

**Arguments**
- `X::MetricSpace{T}`: The metric space containing the points to search
  
- `x::T`: The center point of the ball
  
- `ϵ::Number`: The radius of the ball (must be positive)
  
- `distance`: Distance function to use (default: `dist_euclidean`)
  

**Returns**
- `Vector{Int}`: Indices of points in `X` that are within distance `ϵ` from `x`
  

**Examples**

```julia
# Create a 1D Euclidean space
X = EuclideanSpace(reshape([1.0, 2.0, 3.0, 4.0, 5.0], 1, 5))

# Find indices of points within distance 1.5 from point [3.0]
ball_ids(X, [3.0], 1.5)  # Returns [2, 3, 4]

# Using a different distance function
ball_ids(X, [3.0], 1.5, dist_cityblock)
```


**Notes**
- Uses strict inequality (d &lt; ϵ), so points exactly at distance ϵ are excluded
  
- For empty results, returns an empty vector
  
- The distance function should be compatible with the metric space type
  

See also: [`ball`](/api#MetricSpaces.ball), [`pairwise_distance`](/api#MetricSpaces.pairwise_distance)


<Badge type="info" class="source-link" text="source"><a href="https://github.com/JuliaTDA/MetricSpaces.jl/blob/7c56a69ba6b03a17a348f2b20ec11c61d52b75f5/src/base/ball.jl#L1-L36" target="_blank" rel="noreferrer">source</a></Badge>

</details>


## Neighborhood Analysis {#Neighborhood-Analysis}
<details class='jldocstring custom-block' open>
<summary><a id='MetricSpaces.k_neighbors' href='#MetricSpaces.k_neighbors'><span class="jlbinding">MetricSpaces.k_neighbors</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
k_neighbors(X::MetricSpace{T}, x::T, k::Int, d=dist_euclidean) where {T}
```


Finds the `k` nearest neighbors of a given point `x` in the metric space `X`.

**Arguments**
- `X::MetricSpace{T}`: The metric space containing the points.
  
- `x::T`: The query point for which the nearest neighbors are to be found.
  
- `k::Int`: The number of nearest neighbors to retrieve.
  
- `d`: The distance function to use for computing distances. Defaults to `dist_euclidean`.
  

**Returns**
- A collection of the `k` nearest neighbors of `x` in `X`.
  

**Notes**

This function internally uses `k_neighbors_ids` to retrieve the indices of the nearest neighbors and then returns the corresponding elements from `X`.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/JuliaTDA/MetricSpaces.jl/blob/7c56a69ba6b03a17a348f2b20ec11c61d52b75f5/src/extra/neighborhood.jl#L28-L44" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='MetricSpaces.distance_to_measure' href='#MetricSpaces.distance_to_measure'><span class="jlbinding">MetricSpaces.distance_to_measure</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
distance_to_measure(X::S, Y::S; d=dist_euclidean, k::Integer=5, summary_function=maximum) where {S <: MetricSpace{T}}
```


Computes a measure of distance from each point in the metric space `X` to the metric space `Y`. For each point in `X`, the function calculates the distances to the `k` nearest neighbors in `Y` using the provided distance function `d` (default is `dist_euclidean`). The resulting distances are summarized using the specified `summary_function` (default is `maximum`).

**Arguments**
- `X::S`: A metric space of type `S` containing the points to measure distances from.
  
- `Y::S`: A metric space of type `S` containing the points to measure distances to.
  
- `d`: A distance function to compute the distance between points in `X` and `Y`. Defaults to `dist_euclidean`.
  
- `k::Integer`: The number of nearest neighbors in `Y` to consider for each point in `X`. Defaults to `5`.
  
- `summary_function`: A function to summarize the `k` nearest distances. Defaults to `maximum`.
  

**Returns**
- A vector of summarized distances for each point in `X`.
  

**Notes**
- The computation is parallelized using `Threads.@threads` for improved performance.
  
- The function assumes that the input metric spaces `X` and `Y` are compatible with the provided distance function `d`.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/JuliaTDA/MetricSpaces.jl/blob/7c56a69ba6b03a17a348f2b20ec11c61d52b75f5/src/extra/filters.jl#L1-L20" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='MetricSpaces.excentricity' href='#MetricSpaces.excentricity'><span class="jlbinding">MetricSpaces.excentricity</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
excentricity(X::S, Y::S; d=dist_euclidean) where {S <: MetricSpace{T}}
```


Computes the excentricity of the metric space `X` with respect to the metric space `Y`. The excentricity is defined as the mean of the pairwise distances between points in `X` and `Y`, using the provided distance function `d` (default is `dist_euclidean`).

**Arguments**
- `X::S`: A metric space of type `S` containing the points to compute excentricity for.
  
- `Y::S`: A metric space of type `S` containing the points to compute distances to.
  
- `d`: A distance function to compute the distance between points in `X` and `Y`. Defaults to `dist_euclidean`.
  

**Returns**
- A scalar value representing the excentricity of `X` with respect to `Y`.
  

**Notes**
- This function internally uses `pairwise_distance_summary` with the `mean` function to compute the excentricity.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/JuliaTDA/MetricSpaces.jl/blob/7c56a69ba6b03a17a348f2b20ec11c61d52b75f5/src/extra/filters.jl#L39-L54" target="_blank" rel="noreferrer">source</a></Badge>

</details>


## Sampling Methods {#Sampling-Methods}
<details class='jldocstring custom-block' open>
<summary><a id='MetricSpaces.epsilon_net' href='#MetricSpaces.epsilon_net'><span class="jlbinding">MetricSpaces.epsilon_net</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
epsilon_net(X::MetricSpace, ϵ::Number; d = dist_euclidean)
```


Constructs an epsilon-net for a given metric space `X`. An epsilon-net is a subset of points (landmarks) such that every point in `X` is within a distance `ϵ` of at least one landmark.

**Arguments**
- `X::MetricSpace`: The metric space containing the points.
  
- `ϵ::Number`: The radius of the epsilon ball used to cover the points.
  
- `d`: A distance function to compute pairwise distances. Defaults to `dist_euclidean`.
  

**Returns**
- `landmarks::Vector{Int}`: A vector of indices representing the selected landmarks.
  

**Details**

The function iteratively selects points from `X` that are not yet covered by the epsilon balls of previously selected landmarks. It uses a progress meter to track the process and terminates when all points in `X` are covered.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/JuliaTDA/MetricSpaces.jl/blob/7c56a69ba6b03a17a348f2b20ec11c61d52b75f5/src/extra/sampling.jl#L3-L18" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='MetricSpaces.farthest_points_sample' href='#MetricSpaces.farthest_points_sample'><span class="jlbinding">MetricSpaces.farthest_points_sample</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
farthest_points_sample(X::MetricSpace, n::Integer; d = euclidean)
```


Sample `n` points from a metric space `X` using the Farthest Point Sampling (FPS) algorithm.

This method iteratively selects points that are farthest from the already selected points, resulting in a well-distributed subset of points from the original space.

**Arguments**
- `X::MetricSpace`: The input metric space to sample from
  
- `n::Integer`: Number of points to sample
  
- `d`: Distance function to use (defaults to euclidean distance)
  

**Returns**
- A subset of `n` points from `X` that are approximately maximally distant from each other
  

**Examples**

```julia
X = EuclideanSpace(rand(100, 3))
sampled_points = farthest_points_sample(X, 10)
```


**Details**

The algorithm works as follows:
1. Randomly select the first point from `X`.
  
2. For each subsequent point, compute the distance to all previously selected points.
  
3. Select the point that is farthest from the previously selected points.
  
4. Repeat until `n` points are selected.
  

**Complexity**

The algorithm runs in O(kN) time, where k is the number of points to sample and N is the total number of points in `X`.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/JuliaTDA/MetricSpaces.jl/blob/7c56a69ba6b03a17a348f2b20ec11c61d52b75f5/src/extra/sampling.jl#L112-L143" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='MetricSpaces.random_sample' href='#MetricSpaces.random_sample'><span class="jlbinding">MetricSpaces.random_sample</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
random_sample(X::MetricSpace, n = 1000)
```


Randomly sample `n` points from a metric space `X` without replacement.

**Arguments**
- `X::MetricSpace`: The metric space to sample from
  
- `n::Integer = 1000`: The number of points to sample (default: 1000)
  

**Returns**
- `Vector`: A vector containing `min(length(X), n)` randomly sampled points from `X`
  

**Examples**

```julia
X = EuclideanSpace(rand(100, 3))
sampled_points = random_sample(X, 10)
```



<Badge type="info" class="source-link" text="source"><a href="https://github.com/JuliaTDA/MetricSpaces.jl/blob/7c56a69ba6b03a17a348f2b20ec11c61d52b75f5/src/extra/sampling.jl#L149-L166" target="_blank" rel="noreferrer">source</a></Badge>

</details>


## Dataset Generation {#Dataset-Generation}
<details class='jldocstring custom-block' open>
<summary><a id='MetricSpaces.sphere' href='#MetricSpaces.sphere'><span class="jlbinding">MetricSpaces.sphere</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
sphere(num_points::Integer = 100; dim::Integer = 2, radius::Number = 1, noise::Function = zeros)
```


Generates a set of points uniformly distributed on the surface of a sphere in the Euclidean space.

**Arguments**
- `num_points::Integer=100`: The number of points to generate on the sphere.
  
- `dim::Integer=2`: The dimensionality of the sphere.
  
- `radius::Number=1`: The radius of the sphere.
  
- `noise::Function=zeros`: A function that generates noise to be added to each point. The function should accept the dimensionality `dim` as an argument and return a vector of the same size.
  

**Returns**
- An instance of `EuclideanSpace` containing the generated points.
  

**Example**

```
sphere(100, dim=3, radius=2.0, noise=randn)
```


end


<Badge type="info" class="source-link" text="source"><a href="https://github.com/JuliaTDA/MetricSpaces.jl/blob/7c56a69ba6b03a17a348f2b20ec11c61d52b75f5/src/extra/datasets.jl#L1-L18" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='MetricSpaces.torus' href='#MetricSpaces.torus'><span class="jlbinding">MetricSpaces.torus</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
torus(num_points::Integer = 100; r::Number = 1, R::Number = 3)
```


**Arguments**
- `num_points::Integer`: the number of points.
  
- `r::Number`: the inner radius.
  
- `R::Number`: the outer radius.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/JuliaTDA/MetricSpaces.jl/blob/7c56a69ba6b03a17a348f2b20ec11c61d52b75f5/src/extra/datasets.jl#L58-L65" target="_blank" rel="noreferrer">source</a></Badge>

</details>

<details class='jldocstring custom-block' open>
<summary><a id='MetricSpaces.cube' href='#MetricSpaces.cube'><span class="jlbinding">MetricSpaces.cube</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
cube(num_points::Integer = 100; dim::Integer = 2, radius::Number = 1, noise::Function = zeros)

cube(
    num_points::Integer = 100; dim::Integer = 2, 
    radius::Number = 1, 
    noise::Function = zeros
    )
```


Create a cube in R^(`dim`) with `num_points` points and radius `radius`.

**Arguments**
- `num_points::Integer`: the number of points.
  
- `dim::Integer`: the dimension of the cube (that is: in which R^dim it is).
  
- `radius::Number`: the &quot;radius&quot; of the cube, that is, the distance from the center to one of its sides..
  
- `noise::Function`: a function such that `y = noise(dim)` is a `Vector{<:Number}` with `size(y) = (dim;)`.
  


<Badge type="info" class="source-link" text="source"><a href="https://github.com/JuliaTDA/MetricSpaces.jl/blob/7c56a69ba6b03a17a348f2b20ec11c61d52b75f5/src/extra/datasets.jl#L31-L47" target="_blank" rel="noreferrer">source</a></Badge>

</details>


## Nerve Construction {#Nerve-Construction}
<details class='jldocstring custom-block' open>
<summary><a id='MetricSpaces.nerve_1d' href='#MetricSpaces.nerve_1d'><span class="jlbinding">MetricSpaces.nerve_1d</span></a> <Badge type="info" class="jlObjectType jlFunction" text="Function" /></summary>



```julia
nerve_1d(CX::CoveredPointCloud)
```


Given a covered point cloud `CX`, return the adjacency matrix of the 1-skeleton nerve of `CX.covering`.


<Badge type="info" class="source-link" text="source"><a href="https://github.com/JuliaTDA/MetricSpaces.jl/blob/7c56a69ba6b03a17a348f2b20ec11c61d52b75f5/src/extra/nerve.jl#L1-L6" target="_blank" rel="noreferrer">source</a></Badge>

</details>


## Index {#Index}
- [`MetricSpaces.Covering`](#MetricSpaces.Covering)
- [`MetricSpaces.EuclideanSpace`](#MetricSpaces.EuclideanSpace)
- [`MetricSpaces.MetricSpace`](#MetricSpaces.MetricSpace)
- [`MetricSpaces.SubsetIndex`](#MetricSpaces.SubsetIndex)
- [`MetricSpaces.as_matrix`](#MetricSpaces.as_matrix)
- [`MetricSpaces.ball`](#MetricSpaces.ball)
- [`MetricSpaces.ball_ids`](#MetricSpaces.ball_ids)
- [`MetricSpaces.cube`](#MetricSpaces.cube)
- [`MetricSpaces.distance_to_measure`](#MetricSpaces.distance_to_measure)
- [`MetricSpaces.epsilon_net`](#MetricSpaces.epsilon_net)
- [`MetricSpaces.excentricity`](#MetricSpaces.excentricity)
- [`MetricSpaces.farthest_points_sample`](#MetricSpaces.farthest_points_sample)
- [`MetricSpaces.k_neighbors`](#MetricSpaces.k_neighbors)
- [`MetricSpaces.nerve_1d`](#MetricSpaces.nerve_1d)
- [`MetricSpaces.norm`](#MetricSpaces.norm)
- [`MetricSpaces.pairwise_distance`](#MetricSpaces.pairwise_distance)
- [`MetricSpaces.pairwise_distance_summary`](#MetricSpaces.pairwise_distance_summary)
- [`MetricSpaces.random_sample`](#MetricSpaces.random_sample)
- [`MetricSpaces.sphere`](#MetricSpaces.sphere)
- [`MetricSpaces.torus`](#MetricSpaces.torus)

