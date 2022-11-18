using GH19
using Test

@testset "GH19.jl" begin
    # Write your tests here.

    using NCDatasets

    experimentlist = explist()

    exp = experimentlist[1]

    anomaly = false
    filename = GH19.download(exp,anomaly)

    ds = NCDataset(filename)
end
