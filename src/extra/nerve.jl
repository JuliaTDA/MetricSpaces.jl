"""
    nerve_1d(C::Covering) -> Graph

Constructs the 1-dimensional nerve (graph) of a given covering `C`.

Each element of the covering corresponds to a node in the graph. An edge is added between nodes `i` and `j` if the corresponding sets `C[i]` and `C[j]` are not disjoint (i.e., they have a non-empty intersection).

# Arguments
- `C::Covering`: A collection of sets representing the covering.

# Returns
- `Graph`: A graph where nodes represent covering elements and edges represent non-disjoint intersections between covering sets.

"""
function nerve_1d(C::Vector)
    n = C |> length
    g = Graph(n)
    
    for i ∈ 1:n
        for j ∈ (i + 1):n
            if !isdisjoint(C[i], C[j])
                add_edge!(g, i, j)
            end
        end
    end

    return g
end
