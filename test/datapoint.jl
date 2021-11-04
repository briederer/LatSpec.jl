@testset verbose=true "datapoint.jl " begin
    ## Check _to_tuple functions
    @testset "_to_tuple    " begin
        # _to_tuple should distribute real numbers and promote mixed tuples
        @test LatSpec._to_tuple(1)     === (1, 1)        # int   -> tuple{int}
        @test LatSpec._to_tuple(1.5)   === (1.5, 1.5)    # float -> tuple{float}
        @test LatSpec._to_tuple((1,1)) === (1, 1)        # tuple{int} -> tuple{int}
        @test LatSpec._to_tuple(1.5,1) === (1.5, 1.0)    # float,int -> tuple{float}
        @test typeof(LatSpec._to_tuple((1.5,1))) !== typeof((1.5, 1))    # tuple{float, int} -> tuple{float, float}
        @test_throws MethodError LatSpec._to_tuple("test")  # Should not exist
    end

    # Check Constructors
    # Right hand side should always call the base cosntructor
    @testset verbose=true "DataPoint    " begin
        # Default construction
        @test (local D = DataPoint(); all([D.val D.err...] .≈ 0.0)  && typeof(D) === DataPoint{Float64})
        # Check handling of tuples and numbers as input
        @testset "dispatch    " begin
            # no uncertainty passed
            @test DataPoint(1.0)              === DataPoint{Float64}(1.0,(0.0,0.0))
            # uncertainty is a number
            @test DataPoint(1.0, 2.0)         === DataPoint{Float64}(1.0,(2.0,2.0))
            # uncertainty is a tuple
            @test DataPoint(1.0, (2.0,3.0))   === DataPoint{Float64}(1.0,(2.0,3.0))
            # uncertainty is given as separate args
            @test DataPoint(1.0, 2.0, 3.0)    === DataPoint{Float64}(1.0,(2.0,3.0))
            # unertainties passed by keywords
            @test DataPoint(1.0, lower = 3.0) === DataPoint{Float64}(1.0,(3.0,0.0))
            @test DataPoint(1.0, upper = 3.0) === DataPoint{Float64}(1.0,(0.0,3.0))
        end
        # Check promotion of datatypes
        @testset "promotes    " begin
            # promote to highest (float in these cases; more types needed?)
            DF122 = DataPoint{Float64}(1.0,(2.0,2.0))
            DF123 = DataPoint{Float64}(1.0,(2.0,3.0))
            @test DataPoint(1.0, 2  )       === DF122
            @test DataPoint(  1, 2.0)       === DF122
            @test DataPoint(1.0, (  2,3.0)) === DF123
            @test DataPoint(1.0, (2.0,  3)) === DF123
            @test DataPoint(1.0, (  2,  3)) === DF123
            @test DataPoint(  1, (  2,3.0)) === DF123
            @test DataPoint(  1, (2.0,  3)) === DF123
            @test DataPoint(  1, (  2,  3)) !== DF123
        end
        # Conversions between types
        @testset "conversion  " begin
            # Usual conversions
            @test convert(DataPoint{Float32},DataPoint(1.0,2.0)) === DataPoint(1.0f0,2.0f0)
            @test convert(DataPoint{Float64},DataPoint(  1,  2)) === DataPoint(  1.0,  2.0)
            # to integer conversion
            @test convert(DataPoint{Int64},  DataPoint(1.0,2.0)) === DataPoint(    1,    2)
            # to integer conversion with rounding
            @test convert(DataPoint{Int64},  DataPoint(1.0,2.5)) === DataPoint(    1,    3)
            # to integer conversion only works if val is convertible to int
            @test_throws InexactError convert(DataPoint{Int64},DataPoint(1.5,2.5))
        end
        @testset "errors      " begin
            # Negative uncertainties are not permitted
            @test_throws AssertionError DataPoint(1,-2.5)
            # type has to be a <:Number
            @test_throws MethodError DataPoint("test",-2.5)
            # to many args
            @test_throws MethodError DataPoint(1,2,3,4)
        end
    end
    # Check Construction via operator
    @testset "Operator: ±  " begin
        # single operator
        @test 1.0 ± 2.0                        === DataPoint{Float64}(1.0, (2.0,2.0))
        @test 1.0 ± (lower = 2.0,)             === DataPoint{Float64}(1.0, (2.0,0.0))
        @test 1.0 ± (upper = 2.0,)             === DataPoint{Float64}(1.0, (0.0,2.0))
        @test 1.0 ± (lower = 2.0, upper = 3.0) === DataPoint{Float64}(1.0, (2.0,3.0))
        @test 1.0 ± (other = 2.0,)             === DataPoint{Float64}(1.0, (0.0,0.0))
        # new integer cast
        @test 15 ± (1, pi)                     === DataPoint{Float64}(15.0, (1.0, pi))
    end
    @testset "Helper funs. " begin
        D = DataPoint(2.0, 0.1)
        @test value(D)  === 2.0
        @test err(D)    === (0.1,0.1)
        @test relerr(D) === (0.05,0.05)
        @test bounds(D) === (1.9,2.1)
        D = DataPoint(2.0, (0.1,0.12))
        @test err(D)    === (0.1,0.12)
        @test relerr(D) === (0.05,0.06)
        @test bounds(D) === (1.9,2.12)
    end
    @testset "Printing     " begin
        io = IOBuffer()
        D1 = 1.0 ± (2, 3)
        #
        # print(io, D1)
        # @test String(take!(io)) == "DataPoint{Float64}:\nValue → 1.0\tStatistic unc. → (-2.0, 3.0)\tSystematic unc. → (-0.0, 0.0)"
        # print(io, D2)
        # @test String(take!(io)) == "DataPoint{Float64}:\nValue → 1.0\tStatistic unc. → (-2.0, 3.0)\tSystematic unc. → (-4.0, 5.0)"
        # print(io, D3)
        # @test String(take!(io)) == "DataPoint{Float64}:\nValue → 1.0\tStatistic unc. → (-0.0, 0.0)\tSystematic unc. → (-4.0, 5.0)"
        #
        # print(IOContext(io, :compact => true), D1)
        # @test String(take!(io)) == "1.0 ± (2.0, 3.0) ± (0.0, 0.0)"
        # print(IOContext(io, :compact => true), D2)
        # @test String(take!(io)) == "1.0 ± (2.0, 3.0) ± (4.0, 5.0)"
        # print(IOContext(io, :compact => true), D3)
        # @test String(take!(io)) == "1.0 ± (0.0, 0.0) ± (4.0, 5.0)"
        #
        # show(io, MIME("text/plain"), D1)
        # @test String(take!(io)) == "DataPoint{Float64}:\nValue → 1.0\tStatistic unc. → (-2.0, 3.0)"
        # show(io, MIME("text/plain"), D2)
        # @test String(take!(io)) == "DataPoint{Float64}:\nValue → 1.0\tStatistic unc. → (-2.0, 3.0)\tSystematic unc. → (-4.0, 5.0)"
        # show(io, MIME("text/plain"), D3)
        # @test String(take!(io)) == "DataPoint{Float64}:\nValue → 1.0\tSystematic unc. → (-4.0, 5.0)"
    end
end
