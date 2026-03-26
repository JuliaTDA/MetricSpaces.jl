"""
    nerve_1d(C::Vector, edge_condition::Function) -> Graph

Constructs the 1-dimensional nerve (graph) of a given covering `C`.

Each element of the covering corresponds to a node in the graph. An edge is added between nodes `i` and `j` if `edge_condition(C[i], C[j])` returns `true`.

# Arguments
- `C::Vector`: A collection of sets representing the covering.
- `edge_condition::Function`: A function `(a, b) -> Bool` that determines whether an edge should be added between two covering elements.

# Returns
- `Graph`: A graph where nodes represent covering elements and edges are determined by the edge condition.

"""
function nerve_1d(C::Vector, edge_condition::Function)
    n = C |> length
    g = Graph(n)

    for i ∈ 1:n
        for j ∈ (i + 1):n
            if edge_condition(C[i], C[j])
                add_edge!(g, i, j)
            end
        end
    end

    return g
end

"""
    nerve_1d(C::Vector) -> Graph

Constructs the 1-dimensional nerve (graph) of a given covering `C`.

Each element of the covering corresponds to a node in the graph. An edge is added between nodes `i` and `j` if the corresponding sets `C[i]` and `C[j]` are not disjoint (i.e., they have a non-empty intersection).

# Arguments
- `C::Vector`: A collection of sets representing the covering.

# Returns
- `Graph`: A graph where nodes represent covering elements and edges represent non-disjoint intersections between covering sets.

"""
nerve_1d(C::Vector) = nerve_1d(C, (a, b) -> !isdisjoint(a, b))

# Predicate constructors

"""
    min_intersection(n::Int) -> Function

Returns a predicate that checks whether two sets have at least `n` elements in common.

# Example
```julia
nerve_1d(cover, min_intersection(3))
```
"""
function min_intersection(n::Int)
    (a, b) -> begin
        sb = Set(b)
        count(x -> x in sb, a) >= n
    end
end

"""
    percentage_intersection(p::Real; mode::Symbol=:or) -> Function

Returns a predicate that checks whether two sets overlap by at least a fraction `p` of their sizes.

- `mode=:or`: edge if `|A∩B|/|A| >= p` OR `|A∩B|/|B| >= p`
- `mode=:and`: edge if `|A∩B|/|A| >= p` AND `|A∩B|/|B| >= p` (mutual overlap)

# Example
```julia
nerve_1d(cover, percentage_intersection(0.5))              # mode=:or (default)
nerve_1d(cover, percentage_intersection(0.5, mode=:and))   # mutual overlap
```
"""
function percentage_intersection(p::Real; mode::Symbol=:or)
    (a, b) -> begin
        sb = Set(b)
        inter = count(x -> x in sb, a)
        if mode == :or
            inter >= p * length(a) || inter >= p * length(b)
        else
            inter >= p * length(a) && inter >= p * length(b)
        end
    end
end

"""
    jaccard_threshold(t::Real) -> Function

Returns a predicate that checks whether the Jaccard similarity `|A∩B| / |A∪B|` of two sets is at least `t`.

# Example
```julia
nerve_1d(cover, jaccard_threshold(0.3))
```
"""
function jaccard_threshold(t::Real)
    (a, b) -> begin
        sb = Set(b)
        inter = count(x -> x in sb, a)
        union_size = length(a) + length(b) - inter
        union_size == 0 ? false : inter / union_size >= t
    end
end
