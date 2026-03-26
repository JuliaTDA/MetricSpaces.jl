@testset "Nerve" begin
    @testset "nerve_1d basic functionality" begin
        # Test 1: Disjoint sets (no edges)
        C1 = [[1], [2], [3]]
        g1 = nerve_1d(C1)
        @test nv(g1) == 3
        @test ne(g1) == 0

        # Test 2: All sets overlap (complete graph)
        C2 = [[1, 2], [2, 3], [1, 3]]
        g2 = nerve_1d(C2)
        @test nv(g2) == 3
        @test ne(g2) == 3  # Complete graph K3

        # Test 3: Some overlaps
        C3 = [[1, 2], [2, 3], [4]]
        g3 = nerve_1d(C3)
        @test nv(g3) == 3
        @test has_edge(g3, 1, 2)
        @test !has_edge(g3, 1, 3)
        @test !has_edge(g3, 2, 3)
        @test ne(g3) == 1

        # Test 4: Single set
        C4 = [[1, 2, 3]]
        g4 = nerve_1d(C4)
        @test nv(g4) == 1
        @test ne(g4) == 0

        # Test 5: Empty covering
        C5 = [Int[]]
        g5 = nerve_1d(C5)
        @test nv(g5) == 1
        @test ne(g5) == 0
    end

    # Shared test fixture:
    # C = [[1,2,3], [2,3,4,5], [5,6], [7]]
    # Sets 1 & 2: intersection {2,3}, size 2, Jaccard = 2/5 = 0.4
    # Sets 2 & 3: intersection {5}, size 1, Jaccard = 1/5 = 0.2
    # Sets 1 & 3: disjoint
    # Set 4: isolated
    C = [[1, 2, 3], [2, 3, 4, 5], [5, 6], [7]]

    @testset "nerve_1d with custom predicate" begin
        # Always-true predicate gives complete graph
        g = nerve_1d(C, (a, b) -> true)
        @test ne(g) == 6  # C(4,2) = 6

        # Always-false predicate gives no edges
        g = nerve_1d(C, (a, b) -> false)
        @test ne(g) == 0
    end

    @testset "min_intersection" begin
        # n=1: edges where intersection is non-empty
        g1 = nerve_1d(C, min_intersection(1))
        @test ne(g1) == 2
        @test has_edge(g1, 1, 2)
        @test has_edge(g1, 2, 3)
        @test !has_edge(g1, 1, 3)

        # n=2: only sets 1 & 2 have intersection size >= 2
        g2 = nerve_1d(C, min_intersection(2))
        @test ne(g2) == 1
        @test has_edge(g2, 1, 2)

        # n=3: no intersection has 3+ elements
        g3 = nerve_1d(C, min_intersection(3))
        @test ne(g3) == 0
    end

    @testset "percentage_intersection mode=:or" begin
        # p=0.5: sets 1&2 (2/3 ≈ 0.67 >= 0.5) and sets 2&3 (1/2 = 0.5 >= 0.5)
        g = nerve_1d(C, percentage_intersection(0.5))
        @test ne(g) == 2
        @test has_edge(g, 1, 2)
        @test has_edge(g, 2, 3)

        # p=0.7: only sets 1&2 (2/3 ≈ 0.67 < 0.7? No. 2/3 = 0.666... < 0.7)
        g2 = nerve_1d(C, percentage_intersection(0.7))
        @test ne(g2) == 0
    end

    @testset "percentage_intersection mode=:and" begin
        # p=0.5: sets 1&2 (2/3 >= 0.5 AND 2/4 = 0.5 >= 0.5) ✓
        # sets 2&3: (1/4 = 0.25 < 0.5) ✗
        g = nerve_1d(C, percentage_intersection(0.5, mode=:and))
        @test ne(g) == 1
        @test has_edge(g, 1, 2)
        @test !has_edge(g, 2, 3)
    end

    @testset "jaccard_threshold" begin
        # t=0.3: sets 1&2 Jaccard = 2/5 = 0.4 >= 0.3 ✓; sets 2&3 Jaccard = 1/5 = 0.2 < 0.3
        g1 = nerve_1d(C, jaccard_threshold(0.3))
        @test ne(g1) == 1
        @test has_edge(g1, 1, 2)

        # t=0.5: max Jaccard is 0.4 < 0.5
        g2 = nerve_1d(C, jaccard_threshold(0.5))
        @test ne(g2) == 0

        # t=0.1: both (1,2) and (2,3) qualify
        g3 = nerve_1d(C, jaccard_threshold(0.1))
        @test ne(g3) == 2
        @test has_edge(g3, 1, 2)
        @test has_edge(g3, 2, 3)

        # Edge case: two empty sets
        g_empty = nerve_1d([Int[], Int[]], jaccard_threshold(0.0))
        @test ne(g_empty) == 0  # union_size == 0, returns false
    end
end
