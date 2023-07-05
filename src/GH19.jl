module GH19

using Downloads, TMI, NCDatasets

export explist, pkgdir, datadir, srcdir, download, download_all, TMIversion,
    extract_timeseries

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

TMIversion() = "modern_180x90x33_GH11_GH12" # all GH19 output uses this TMI version, no underscore = function

"""
    function download(experiment::String;anomaly=false)

# Arguments
- `experiment::String`: name of experiment, use `explist()` to get possible names
- `anomaly::Bool`: true to load θ anomaly, false to load full θ
# Output
- `outputfile`: name of loaded file, found in the `datadir()` directory
"""
function download(experiment::String,anomaly=false;force = false)
    
    if anomaly
        filename = "Theta_anom_"*experiment*".nc"
    else
        filename = "Theta_"*experiment*".nc"
    end
    infile = rooturl(filename)
    outfile = datadir(filename)

    if !isfile(outfile) || force == true
        !isdir(datadir()) && mkpath(datadir()) 
        Downloads.download(infile,outfile,verbose=true)
    else
        println("File already downloaded; use `force=true` to re-downloade")
    end
    return outfile
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

function readtracer_snapshot(file::String,tracername::Union{String,Symbol},time_index::Integer)
    ds = Dataset(file,"r")
    v = ds[tracername]
    # load one snapshot, reverse zyx order to xyz order
    tracer = permutedims(v[time_index,:,:,:],(3,2,1))
    # load an attribute
    units = v.attrib["units"]
    longname = v.attrib["long_name"]
    close(ds)
    return tracer,units,longname
end

"""
    function readfield(file,tracername,γ)
    Read a tracer field from NetCDF but return it 
    as a Field.

    Use NCDatasets so that Unicode is correct

# Arguments
- `file`: TMI NetCDF file name
- `tracername`: name of tracer
- `γ::Grid`, TMI grid specification
# Output
- `c`::Field
"""
function readfield_snapshot(file,tracername,time_index::Integer,γ::TMI.Grid) 

    # The mode "r" stands for read-only. The mode "r" is the default mode and the parameter can be omitted.
    tracer, units, longname = readtracer_snapshot(file,tracername,time_index)
    #TMI.checkgrid!(tracer,γ.wet)
    c = Field(tracer,γ,Symbol(tracername),longname,units)

    return c
end

"""
function extract_timeseries(

    extract a timeseries at a Cartesian point, i,j,k

    return tuple with tracer timeseries θ at times t
    i.e., (θ,t)
"""
function extract_timeseries(file,tracername,i,j,k)
        θijk = NCDataset(file)[tracername][:,k,j,i]
        tijk = NCDataset(file)["year"][:]
    return θijk, tijk
end

"""
    function extract_timeseries(file,tracername,locs,γ)

    extract timeseries at locs. Requires TMI grid, γ.

    readfield_snapshot is very slow.

    Also very slow to recompute interpolation factors each time.

    Need to refactor.
"""
function extract_timeseries(file,tracername,locs,γ)
    t = NCDataset(file)["year"][:]
    nt = length(t)
    nlocs = length(locs)
    θ = Vector{Vector{Float64}}(undef,nt) #NCDataset(file)[tracername][:,k,j,i]

    for time_index in 1:nt
        println(time_index)
        c = GH19.readfield_snapshot(file,tracername,time_index,γ)
        θ[time_index] =  observe(c,locs,γ)
    end
    
    return θ, t
end




end

