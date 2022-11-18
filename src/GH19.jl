module GH19

using Downloads

export explist, pkgdir, datadir, srcdir, download, download_all

import Downloads: download

pkgdir() = dirname(dirname(pathof(GH19)))
pkgdir(args...) = joinpath(pkgdir(), args...)

datadir() = joinpath(pkgdir(),"data")
datadir(args...) = joinpath(datadir(), args...)

srcdir() = joinpath(pkgdir(),"src")
srcdir(args...) = joinpath(srcdir(), args...)

"""
    explist -> experiment list
"""
explist() = ("EQ-0015","EQ-1750","OPT-0015")

    file = "https://www.ncei.noaa.gov/pub/data/paleo/gcmoutput/gebbie2019/Theta_anom_OPT-0015.nc"

rooturl() = "https://www.ncei.noaa.gov/pub/data/paleo/gcmoutput/gebbie2019"

rooturl(args...) = joinpath(rooturl(), args...)

"""
    function download(experiment::String;anomaly=false)

# Arguments
- `experiment::String`: name of experiment, use `explist()` to get possible names
- `anomaly::Bool`: true to load θ anomaly, false to load full θ
# Output
- `outputfile`: name of loaded file, found in the `datadir()` directory
"""
function download(experiment::String,anomaly=false)
    
    if anomaly
        filename = "Theta_anom_"*experiment*".nc"
    else
        filename = "Theta_"*experiment*".nc"
    end
    infile = rooturl(filename)
    outfile = datadir(filename)

    !isdir(datadir()) && mkpath(datadir()) 

    Downloads.download(infile,outfile,verbose=true)

end

"""
    function download_all()

    Download output from 6 GH19 experiments totaling about 10 GB of data.
"""
function download_all()

    outputfiles = Vector{String}()
    exps = explist()
    for exp in exps
        for anomalyflag in (true,false)
            println(exp*" "*string(anomalyflag))
            push!(outputfiles,download(exp::String,anomalyflag))
        end
    end
    return outputfiles
end

end
