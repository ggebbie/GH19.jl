
include("helperfuncs.jl")

using Revise, DrWatson,
NCDatasets, ECCOonPoseidon, Distances
import PyPlot as plt

ds_EQ  = NCDataset("/home/ameza/GH19.jl/data/Theta_EQ-0015.nc")
ds_OPT = NCDataset("/home/ameza/GH19.jl/data/Theta_OPT-0015.nc")

#get coordinates from nc files 
year  = reverse(ds_OPT["year"][:]); nt = length(year)
lon = ds_OPT["longitude"][:]; lat = ds_OPT["latitude"][:]
depth = ds_OPT["depth"][:]; nz = length(depth)
volumes = GH19_cell_volumes(depth, lon, lat)

#make time go from pos to neg 
theta_OPT = reverse(ds_OPT["theta"][:, :, :, :], dims =1) 
theta_EQ = reverse(ds_EQ["theta"][:, :, :, :], dims =1)

#check to see if I am plotting things correctly 
fig, ax = plt.subplots()
ax.contourf(lon, lat, theta_OPT[1, 1, :, :])
fig
wet_mask = (!isnan).(theta_OPT[1, :, :, :])

#coordinate meshgrid
LONS = lon' .* ones(length(lat))
LATS = lat .* ones(length(lon))'

#area of interest PAC 
PAC_msk = 0.0 .* LATS
PAC_msk = (-56 .<= LATS .<= 60) .&& (140 .<= LONS .<= 260)

mask_volume = similar(volumes)
[mask_volume[k, :, :] .= volumes[k, :, :] .* PAC_msk .* wet_mask[k, :, :] for k = 1:nz]


#get indices for WOCE and Challenger
WOCE_times = findall(1872 .< year .< 1876)[1]
Challenger_times = findall(1989 .< year .< 2001)[end]
data_labels = ["EQ-0015", "OPT-0015"]

E,F = trend_matrices(year[WOCE_times:Challenger_times])

for (i, data) in enumerate([theta_EQ, theta_OPT])
    weighted_temp = zeros(nt, nz)
    β = zeros(nz)

    #fill NaNs
    filled_data = copy(data)
    filled_data[isnan.(filled_data)] .= 0.0

    #volume weighted average at each depth
    for tt in 1:nt, k in 1:nz
        weighted_temp[tt, k] =  sum(filled_data[tt, k, :, :] .* mask_volume[k, :, :]) / sum(mask_volume[k, :, :])
    end

    #compute trend at each depth 
    for (i, tt) in enumerate(WOCE_times:Challenger_times), k in 1:nz
        β[k] += F[2,i] * weighted_temp[tt, k] 
    end

    push!(ΔTs, deepcopy(β))
end

fig, ax = plt.subplots()
ax.plot(100 * ΔTs[2], depth); 
ax.set_xlabel(L"^\circ" * "C per century")
ax.set_ylabel("Depth [km]")
ax.invert_yaxis()
fig
