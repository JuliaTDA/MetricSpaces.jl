@testset "Interval" begin
    @testset "Construction" begin
        i = Interval(1.0, 2.0)
        @test i.a == 1.0
        @test i.b == 2.0
        @test i isa Interval{Float64}

        i2 = Interval(1, 5)
        @test i2 isa Interval{Int}

        # Mixed types promote
        i3 = Interval(1, 2.0)
        @test i3 isa Interval{Float64}
        @test i3.a === 1.0
    end

    @testset "Validation" begin
        @test_throws ArgumentError Interval(3.0, 1.0)
        @test_throws ArgumentError Interval(5, 2)
        # Equal endpoints are allowed
        i = Interval(1.0, 1.0)
        @test i.a == i.b
    end

    @testset "Membership (in)" begin
        i = Interval(1.0, 3.0)
        @test 2.0 ∈ i
        @test 1.0 ∈ i   # closed interval
        @test 3.0 ∈ i   # closed interval
        @test !(0.5 ∈ i)
        @test !(3.5 ∈ i)
    end

    @testset "is_not_disjoint" begin
        i1 = Interval(1.0, 3.0)
        i2 = Interval(2.0, 4.0)
        @test is_not_disjoint(i1, i2)
        @test is_not_disjoint(i2, i1)

        # Touching at a single point
        i3 = Interval(3.0, 5.0)
        @test is_not_disjoint(i1, i3)

        # Disjoint
        i4 = Interval(4.0, 6.0)
        @test !is_not_disjoint(i1, i4)
    end
end

@testset "IntervalCovering" begin
    intervals = [Interval(0.0, 1.0), Interval(0.5, 1.5), Interval(1.0, 2.0)]
    @test intervals isa IntervalCovering{Float64}
    @test length(intervals) == 3
end
