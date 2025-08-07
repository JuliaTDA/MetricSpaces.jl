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
        for j ∈ i:n
            i == j && continue

            if !isdisjoint(C[i], C[j])
                add_edge!(g, i, j)
            end
        end
    end

    return g
end

@testitem "nerve_1d basic functionality" begin
    using Graphs: nv, ne, has_edge
    # Test 1: Disjoint sets (no edges)
    C1 = [[1], [2], [3]]
    g1 = nerve_1d(C1)
    @test nv(g1) == 3
    @test ne(g1) == 0

    # Test 2: All sets overlap (complete graph)
    C2 = [[1,2], [2,3], [1,3]]
    g2 = nerve_1d(C2)
    @test nv(g2) == 3
    @test ne(g2) == 3 # Complete graph K3

    # Test 3: Some overlaps
    C3 = [[1,2], [2,3], [4]]
    g3 = nerve_1d(C3)
    @test nv(g3) == 3
    @test has_edge(g3, 1, 2)
    @test !has_edge(g3, 1, 3)
    @test !has_edge(g3, 2, 3)
    @test ne(g3) == 1

    # Test 4: Single set
    C4 = [[1,2,3]]
    g4 = nerve_1d(C4)
    @test nv(g4) == 1
    @test ne(g4) == 0

    # Test 5: Empty covering
    C5 = [Int[]]
    g5 = nerve_1d(C5)
    @test nv(g5) == 1
    @test ne(g5) == 0
end