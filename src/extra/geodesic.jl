using SparseArrays
using Graphs: dijkstra_shortest_paths, has_edge

"""
    geodesic_distance(X::MetricSpace; k::Int = 5, d = dist_euclidean) -> Matrix{Float64}

Compute the pairwise geodesic-distance matrix for `X` via a k-nearest-neighbor
graph (using distance `d`) and Dijkstra's algorithm.

Returns an `n × n` matrix where entry `(i, j)` is the shortest-path distance from
point `i` to point `j` along the kNN graph. Disconnected components yield `Inf`.

This is the manifold-aware distance underlying Isomap; useful whenever ambient
Euclidean distance doesn't reflect intrinsic geometry (e.g. swiss roll).

# Arguments
- `X::MetricSpace`: input point cloud
- `k::Int = 5`: number of nearest neighbors per point (excluding self)
- `d`: distance function (default `dist_euclidean`)
"""
function geodesic_distance(X::MetricSpace; k::Int=5, d=dist_euclidean)
    n = length(X)
    g = Graph(n)
    W = spzeros(Float64, n, n)
    for i in 1:n
        ids = k_neighbors_ids(X, X[i], k + 1, d)  # +1 because closest is self
        for j in ids
            j == i && continue
            if !has_edge(g, i, j)
                add_edge!(g, i, j)
                w = Float64(d(X[i], X[j]))
                W[i, j] = w
                W[j, i] = w
            end
        end
    end
    D = zeros(Float64, n, n)
    for i in 1:n
        D[i, :] .= dijkstra_shortest_paths(g, i, W).dists
    end
    return D
end
