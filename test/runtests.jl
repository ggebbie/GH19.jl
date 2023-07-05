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
        
        experimentlist = explist()
        expno = rand(1:length(experimentlist))
        exp = experimentlist[1]
        anomaly = false
        filename = GH19.download(exp,anomaly)

        @test isfile(filename)
        
        ds = NCDataset(filename)
    end

    @testset "compare to TMI grid" begin
        using TMI
        

    end
    
end
