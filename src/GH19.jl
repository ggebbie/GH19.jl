module GH19

using Downloads, Interpolations, DrWatson, NCDatasets, NetCDF, TMI


export explist, pkgdir, datadir, srcdir, download, download_all, read4Dfield, 
random_observations

"""
    projectdir()
Return the directory of the currently active project.
```julia
projectdir(args...) = joinpath(projectdir(), args...)
```
Join the path of the currently active project with `args`
(typically other subfolders).
"""
function projectdir()
    if is_standard_julia_project()
        @warn "Using the standard Julia project."
    end
    dirname(Base.active_project())
end

# pkgdir() = dirname()
# pkgdir(args...) = joinpath(pkgdir(), args...)

# datadir() = joinpath(pkgdir(),"data")
# datadir(args...) = joinpath(datadir(), args...)

# srcdir() = joinpath(pkgdir(),"src")
# srcdir(args...) = joinpath(srcdir(), args...)


include("/home/ameza/GH19.jl/src/GH19_config.jl")

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

"""
    function read4Dfield(file,tracername,γ)
    Read a tracer field from NetCDF but return it 
    as a Field. 
# Arguments
- `file`: TMI NetCDF file name
- `tracername`: name of tracer
- `γ::Grid`, TMI grid specification
# Output
- `c`::Field
"""
function read4Dfield(file,tracername,γ::Grid)
    tracer = ncread(file,tracername)
    tracer = permutedims(tracer, (1, 4, 3, 2)) #change to t-x-y-z
    cs = Field[]
    for i = 1:400
        # if sum(isnan.(tracer[i, :, :, :][γ.wet])) > 0
        #     println("readfield warning: NaN on grid")
        # end
        c = Field(tracer[i, :, :, :],γ)
        push!(cs, c)
    end
    return cs
end


""" 
    function random_observations(GH19Version,variable,locs)
    Random observations 
    This version: observations with random (uniform) spatial sampling
# Arguments
- `GH19Version::String`: version of GH19
- `variable::String`: variable name to use as template
- `N`: number of observations
# Output
- `ytrue`: uncontaminated observations, 4D field
- `locs`: 3-tuples of locations for observations
- `wis`: weighted indices for interpolation to locs sites
"""
function random_observations(GH19Version,variable,γ,N)
    
    GH19file = datadir(GH19Version)

    @time θtrue = read4Dfield(GH19file, variable, γ)
    nt = length(θtrue)
    [replace!(θtrue[i].tracer,NaN=>0.0) for i = 1:nt]
    
    # get random locations that are wet (ocean)
    locs = Vector{Tuple{Float64,Float64,Float64}}(undef,N)
    [locs[i] = wetlocation(γ) for i in eachindex(locs)]
    
    # get weighted interpolation indices
    N = length(locs)
    wis= Vector{Tuple{Interpolations.WeightedAdjIndex{2, Float64}, Interpolations.WeightedAdjIndex{2, Float64}, Interpolations.WeightedAdjIndex{2, Float64}}}(undef,N)
    [wis[i] = interpindex(locs[i],γ) for i in 1:N]
    ytrue = zeros(nt, N)
    [ ytrue[i, :] .= observe(θtrue[i],wis,γ) for i = 1:nt ]
    
    return ytrue, locs, wis
    
end

end
