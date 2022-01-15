@testset verbose=true "datapoint.jl " begin
    ## Check _to_tuple functions
    @testset "_to_tuple    " begin
        # _to_tuple should distribute real numbers and promote mixed tuples
        @test LatSpec._to_tuple(1)     == (1, 1)        # int   -> tuple{int}
        @test LatSpec._to_tuple(1.5)   == (1.5, 1.5)    # float -> tuple{float}
        @test LatSpec._to_tuple((1,1)) == (1, 1)        # tuple{int} -> tuple{int}
        @test typeof(LatSpec._to_tuple((1.5,1))) != typeof((1.5, 1))    # tuple{float, int} -> tuple{float, float}
        @test_throws MethodError LatSpec._to_tuple("test")  # Should not exist
    end

    # Check Constructors
    # Right hand side should always call the base cosntructor
    @testset verbose=true "DataPoint    " begin
        @test (local D = DataPoint(); all(isnan.([D.val D.stat_err... D.sys_err...])))
        # Check handling of tuples and numbers as input
        @testset "dispatch    " begin
            # uncertainties are numbers
            @test DataPoint(1.0, 2.0, 3.0) == DataPoint(1.0,(2.0,2.0),(3.0,3.0))
            # uncertainties are tuple+number
            @test DataPoint(1.0, (2.0,3.0), 4.0) == DataPoint(1.0,(2.0,3.0),(4.0,4.0))
            # uncertainties are tuples
            @test DataPoint(1.0, (2.0,3.0), (4.0,5.0)) == DataPoint(1.0,(2.0,3.0),(4.0,5.0))
            # uncertainties are number+tuple
            @test DataPoint(1.0, 2.0, (3.0,4.0)) == DataPoint(1.0,(2.0,2.0),(3.0,4.0))
            # unertainties passed by keywords
            @test DataPoint(1.0, sys = 3.0) == DataPoint(1.0,(0.0,0.0),(3.0,3.0))
            @test DataPoint(1.0, sys = (3.0,4.0)) == DataPoint(1.0,(0.0,0.0),(3.0,4.0))
            @test DataPoint(1.0, stat = (3.0,4.0)) == DataPoint(1.0,(3.0,4.0),(0.0,0.0))
            @test DataPoint(1.0, stat = 3.0) == DataPoint(1.0,(3.0,3.0),(0.0,0.0))
        end
        # Check promotion of datatypes
        @testset "promotes    " begin
            # promote to highest (float)
            @test DataPoint(1.0, 2, 3.0) == DataPoint(1.0,(2.0,2.0),(3.0,3.0))
            @test DataPoint(1.0, (2,3.0), 4.0) == DataPoint(1.0,(2.0,3.0),(4.0,4.0))
            @test DataPoint(1.0, 2.0, 3) == DataPoint(1.0,(2.0,2.0),(3.0,3.0))
            @test DataPoint(1.0, 2.0, (3.0,4)) == DataPoint(1.0,(2.0,2.0),(3.0,4.0))
            # promote to highest (Im)
            @test DataPoint(1.0 - im, 2, 3.0) == DataPoint(1.0 - im,(2.0 + im * 0.0,2.0 + im * 0.0),(3.0 + im * 0.0,3.0 + im * 0.0))
            @test DataPoint(1.0 - im, (2,3.0), 4.0) == DataPoint(1.0 - im,(2.0 + im * 0.0,3.0 + im * 0.0),(4.0 + im * 0.0,4.0 + im * 0.0))
            @test DataPoint(1.0 - im, 2.0, 3) == DataPoint(1.0 - im,(2.0 + im * 0.0,2.0 + im * 0.0),(3.0 + im * 0.0,3.0 + im * 0.0))
            @test DataPoint(1.0 - im, 2.0, (3.0,4)) == DataPoint(1.0 - im,(2.0 + im * 0.0,2.0 + im * 0.0),(3.0 + im * 0.0,4.0 + im * 0.0))
        end
        # Check correct handling when value is of type integer
        # cast all numbers to integer and ceil errors
        @testset "integers    " begin
            # unchanged for all integers
            @test DataPoint(1,2,3) == DataPoint(1,(2,2),(3,3))
            # mixtures (old promotion)
            # @test DataPoint(1,2.5,3) == DataPoint(1,(3,3),(3,3))
            # @test DataPoint(1,(2.5,3.5),3) == DataPoint(1,(3,4),(3,3))
            # @test DataPoint(1,2.5,(3,4)) == DataPoint(1,(3,3),(3,4))
            # @test DataPoint(1,2.5,(3.1,4)) == DataPoint(1,(3,3),(4,4))
            # mixtures (new promotion)
            @test DataPoint(1,2.5,3) == DataPoint(1.0,(2.5,2.5),(3.0,3.0))
            @test DataPoint(1,(2.5,3.5),3) == DataPoint(1.0,(2.5,3.5),(3.0,3.0))
            @test DataPoint(1,2.5,(3,4)) == DataPoint(1.0,(2.5,2.5),(3.0,4.0))
            @test DataPoint(1,2.5,(3.1,4)) == DataPoint(1,(2.5,2.5),(3.1,4.0))
            # unertainties passed by keywords (old promotion)
            # @test DataPoint(1, sys = 2.5) == DataPoint(1,(0,0),(3,3))
            # @test DataPoint(1, stat = 2.5) == DataPoint(1,(3,3),(0,0))
            # unertainties passed by keywords (new promotion)
            @test DataPoint(1, sys = 2.5) == DataPoint(1.0,(0.0,0.0),(2.5,2.5))
            @test DataPoint(1, stat = 2.5) == DataPoint(1.0,(2.5,2.5),(0.0,0.0))
        end
        @testset "conversion  " begin
            # Usual conversions
            @test convert(DataPoint{Float32},DataPoint(1.0,2.0,3.0)) == DataPoint(1.0f0,(2.0f0,2.0f0),(3.0f0,3.0f0))
            @test convert(DataPoint{Float64},DataPoint(1,2,3)) == DataPoint(1.0,(2.0,2.0),(3.0,3.0))
            # to integer conversion
            @test convert(DataPoint{Int64},DataPoint(1.0,2.0,3.0)) == DataPoint(1,(2,2),(3,3))
            # to integer conversion with rounding
            @test convert(DataPoint{Int64},DataPoint(1.0,2.5,3.5)) == DataPoint(1,(3,3),(4,4))
            # to integer conversion only works if val is convertible to int
            @test_throws InexactError convert(DataPoint{Int64},DataPoint(1.5,2.5,3.5))
        end
        @testset "errors      " begin
            @test_throws AssertionError DataPoint(1,-2.5,3)
            @test_throws MethodError DataPoint("test",-2.5,3)
        end
    end
    # Check Construction via operator
    @testset "Operator: ±  " begin
        # single operator
        @test 1.0 ± 2.0 == DataPoint(1.0, (2.0,2.0), (0.0,0.0))
        @test 1.0 ± (sys = 2.0,) == DataPoint(1.0, (0.0,0.0), (2.0,2.0))
        @test 1.0 ± (stat = 2.0,) == DataPoint(1.0, (2.0,2.0), (0.0,0.0))
        @test 1.0 ± (stat = 2.0, sys = 3.0) == DataPoint(1.0, (2.0,2.0), (3.0,3.0))
        @test 1.0 ± (other = 2.0,) == DataPoint(1.0, (0.0,0.0), (0.0,0.0))
        # double operator
        @test 1.0 ± (2.0,3.0) ± (4.0,5.0) == DataPoint(1.0,(2.0,3.0),(4.0,5.0))
        # old integer cast
        # @test 15 ± (1, 2.5) ± pi == DataPoint(15, (1,3), (4, 4))
        # new integer cast
        @test 15 ± (1, 2.5) ± pi == DataPoint(15.0, (1.0,2.5), (pi, pi))
    end
    @testset "Helper functions" begin
        x = DataPoint(1.0, 0.1, 0.2)
        @test value(x) == 1.0
        @test staterr(x) == (0.1,0.1)
        @test syserr(x) == (0.2,0.2)
        x = DataPoint(1.0, (0.1,0.12), (0.2,0.23))
        @test value(x) == 1.0
        @test staterr(x) == (0.1,0.12)
        @test syserr(x) == (0.2,0.23)
    end
    @testset "Printing     " begin
        io = IOBuffer()
        D1 = 1.0 ± (2, 3)
        D2 = 1.0 ± (2, 3) ± (4, 5)
        D3 = DataPoint(1.0, sys = (4,5))

        print(io, D1)
        @test String(take!(io)) == "DataPoint{Float64}:\nValue → 1.0\tStatistic unc. → (2.0, -3.0)\tSystematic unc. → (0.0, -0.0)"
        print(io, D2)
        @test String(take!(io)) == "DataPoint{Float64}:\nValue → 1.0\tStatistic unc. → (2.0, -3.0)\tSystematic unc. → (4.0, -5.0)"
        print(io, D3)
        @test String(take!(io)) == "DataPoint{Float64}:\nValue → 1.0\tStatistic unc. → (0.0, -0.0)\tSystematic unc. → (4.0, -5.0)"

        print(IOContext(io, :compact => true), D1)
        @test String(take!(io)) == "1.0 ± (2.0, 3.0) ± (0.0, 0.0)"
        print(IOContext(io, :compact => true), D2)
        @test String(take!(io)) == "1.0 ± (2.0, 3.0) ± (4.0, 5.0)"
        print(IOContext(io, :compact => true), D3)
        @test String(take!(io)) == "1.0 ± (0.0, 0.0) ± (4.0, 5.0)"

        show(io, MIME("text/plain"), D1)
        @test String(take!(io)) == "DataPoint{Float64}:\nValue → 1.0\tStatistic unc. → (2.0, -3.0)"
        show(io, MIME("text/plain"), D2)
        @test String(take!(io)) == "DataPoint{Float64}:\nValue → 1.0\tStatistic unc. → (2.0, -3.0)\tSystematic unc. → (4.0, -5.0)"
        show(io, MIME("text/plain"), D3)
        @test String(take!(io)) == "DataPoint{Float64}:\nValue → 1.0\tSystematic unc. → (4.0, -5.0)"
    end
end
