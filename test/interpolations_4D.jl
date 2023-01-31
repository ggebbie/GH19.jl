include("../src/GH19.jl")

using .GH19
using Test
using DrWatson
using NetCDF, TMI

fname = datadir("Theta_EQ-0015.nc")
A, Alu, γ, TMIfile, L, B = config_from_nc("modern_180x90x33_GH11_GH12")

# gets puts netcdf in alist of type "Field"
# Field type could probably be extended to 4D to avoid repitition. 
@time cs = read4Dfield(fname, "theta", γ)

# samples a random (or set of random) points 
N = 2
@time ytrue, locs, wis = random_observations("Theta_EQ-0015.nc","theta",γ,N)