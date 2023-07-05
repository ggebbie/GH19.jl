using GH19
using Test

@testset "GH19.jl" begin
    # Write your tests here.

    using NCDatasets

    @testset "download_all" begin

        outputfiles = download_all()
        for oo in outputfiles
            @test isfile(oo)
        end
        
    end

    @testset "download one" begin

        using TMI
        experimentlist = explist()
        expno = rand(1:length(experimentlist))
        exp = experimentlist[1]
        anomaly = false
        filename = GH19.download(exp,anomaly)

        @test isfile(filename)
        
        ds = NCDataset(filename)

        # extract a timeseries at a Cartesian point
        i = 85; j = 35; k = 10;
        θijk, tijk = extract_timeseries(filename,"theta",i,j,k)

        @test length(θijk) == length(tijk)

        # extract a timeseries at any point
        # 1. Make a field at index tt
        γ = TMI.Grid(TMI.download_ncfile(TMIversion()))
        θt,tt = extract_timeseries(filename,"theta",locs,γ)

        # time_index = 1
        # c = GH19.readfield_snapshot(filename,tracername,time_index,γ)
        # locs = [(-30.0,45.0,100.0),(180.0,45.0,100.0)]
        # cobs =  observe(c,locs,γ)

    end

    # @testset "compare to TMI grid" begin
    #     using TMI
        

    # end
    
end
