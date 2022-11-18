module GH19

using Downloads

export explist, pkgdir, datadir, srcdir, download

import Downloads: download

#bc_file = datadir("Theta_anom_OPT-0015.nc")

#Theta_anom_OPT-00015.nc downloaded from https://www.ncei.noaa.gov/pub/data/paleo/gcmoutput/gebbie2019/

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

bc_file = datadir("Theta_anom_OPT-0015.nc")

"""
    function download(experiment::String;anomaly=false)
"""
function download(experiment::String,anomaly=false)
    
    #Theta_anom_OPT-00015.nc downloaded from https://www.ncei.noaa.gov/pub/data/paleo/gcmoutput/gebbie2019/
    println("inside")
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

end
