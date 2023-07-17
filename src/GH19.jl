module GH19

using Downloads, TMI, NCDatasets

export explist, pkgdir, datadir, srcdir, download_exp, download_all, TMIversion,
    extract_timeseries

#import Downloads: download

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
    function download_exp(experiment::String;anomaly=false)

# Arguments
- `experiment::String`: name of experiment, use `explist()` to get possible names
- `anomaly::Bool`: true to load θ anomaly, false to load full θ
# Output
- `outputfile`: name of loaded file, found in the `datadir()` directory
"""
function download_exp(experiment::String,anomaly=false;force = false)
    
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
        println("File already downloaded; use `force=true` to re-download")
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
            push!(outputfiles,download_exp(exp::String,anomalyflag))
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

    Faster versions also available.
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

"""
function extract_timeseries(file::String,tracername::String,locs::Vector,γ::TMI.Grid)

extract timeseries at locs. Requires TMI grid, γ.

Refactored version.

return θ,t
"""
function extract_timeseries(file::String,tracername::String,locs::Vector,γ::TMI.Grid)
    t = NCDataset(file)["year"][:]
    nt = length(t)
    nlocs = length(locs)
    θ = Vector{Vector{Float64}}(undef,nlocs) 

    for ll in 1:nlocs
        θ[ll],_ = extract_timeseries(file,tracername,locs[ll],γ)
    end
    return θ,t
end

"""
function extract_timeseries(filename::String,tracername::String,loc::Tuple,γ::TMI.Grid)

return θ,t
"""
function extract_timeseries(filename::String,tracername::String,loc::Tuple,γ::TMI.Grid)

    # extract timeseries for all points with nonzero interpolation weights.
    ww = interpindex(loc,γ)

    # get number of timesteps
    θtmp,t = extract_timeseries(filename,"theta",1,1,1)
    nt = length(θtmp)
    θ = zeros(nt)
    wtotal = 0.0
    for ii = 1:2
        for jj = 1:2
            for kk = 1:2
                # get timeseries at each location, multiply by necessary weight.
                wt = ww[1].weights[ii]*ww[2].weights[jj]*ww[3].weights[kk]
                θtmp,_ = extract_timeseries(filename,"theta",ww[1].istart+ii-1,ww[2].istart+jj-1,ww[3].istart+kk-1)
                if !isnan(θtmp[1])
                    θ += wt* θtmp
                    wtotal += wt
                end
            end
        end
    end

    # if total weight not equal to 1.0, then normalize
    if wtotal ≠ 1.0
        θ ./= wtotal
    end
    return θ,t
end

end
