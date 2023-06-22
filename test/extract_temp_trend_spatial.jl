using Revise, DrWatson,
NCDatasets, DataFrames, LaTeXStrings, Distances, 
ECCOonPoseidon, ECCOtour, JLD2

include("helperfuncs.jl")

ds_OPT = NCDataset("/home/ameza/GH19.jl/data/Theta_OPT-0015.nc")

year  = reverse(ds_OPT["year"][:]); nt = length(year)
lon = ds_OPT["longitude"][:]; lat = ds_OPT["latitude"][:]
depth = ds_OPT["depth"][:]; nz = length(depth)
zlevs = findall(2000 .<= depth .<= 3000)


#get indices for WOCE and Challenger
WOCE_times = findall(1872 .< year .< 1876)[1]
Challenger_times = findall(1989 .< year .< 2001)[end]

#make time go from pos to neg and keep relevant levels
theta_OPT = reverse(ds_OPT["theta"][:, zlevs, :, :], dims =1) 
depth = depth[zlevs]; nz = length(depth)

#only keep Challenger -> WOCE times 
theta_OPT = theta_OPT[WOCE_times:Challenger_times, :, :, :]
year_CH_WC = year[WOCE_times:Challenger_times]

#get trend matrices
E,F = trend_matrices(year_CH_WC); nt = length(year_CH_WC)
vert_avg_temp = zeros(nt, 90, 180)

#depth weighted average 
for tt = 1:nt, k in 1:nz
    vert_avg_temp[tt, :, :] .+=  theta_OPT[tt, k, :, :]./ nz
end

#compute the trends on the depth weighted average
β = zeros(90, 180)
for tt = 1:nt
    β .+= F[2,tt] .* vert_avg_temp[tt, :, :]
end

#coordinate meshgrid
LONS = lon' .* ones(length(lat))
LATS = lat .* ones(length(lon))'

fname = "modern_OPT-0015_θ_trends_2to3km.jld2"
jldsave(datadir(fname), β = β, λ = LONS, ϕ = LATS, years = year_CH_WC)
