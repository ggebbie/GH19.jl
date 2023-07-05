using Revise
using GH19
using Test

function samplelocs()
    return [(-20.67, 62.76, 0.0),(-20.67, 62.76, 1031.0), (-20.68, 62.75, 1190.0), (-20.64, 62.61, 1310.0), (-21.47, 62.06, 1535.0), (-21.67, 61.76, 1647.0), (-21.73, 61.67, 1711.0), (-21.89, 61.42, 1810.0), (-23.64, 60.4, 1999.0), (-23.94, 60.49, 2103.0), (-23.78, 60.17, 2129.0), (-20.35, 61.35, 2274.0)]
end


end

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

        using TMI,Statistics
        
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
        locs = samplelocs()
        θt,tt = extract_timeseries(filename,"theta",locs,γ)

        # get variance of timeseries
        nl = length(locs)
        θstd = [std([θt[i][ii] for i in 1:length(tt)]) for ii in 1:nl]

        # time_index = 1
        # c = GH19.readfield_snapshot(filename,tracername,time_index,γ)
        # locs = [(-30.0,45.0,100.0),(180.0,45.0,100.0)]
        # cobs =  observe(c,locs,γ)

    end

    # @testset "compare to TMI grid" begin
    #     using TMI
        

    # end
    
end
