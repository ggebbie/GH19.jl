#computes the distances between grid cells
function grid_distance(lon, lat)
    dx = similar(lat)
    for j in eachindex(lat)
        dx[j] = haversine((lon[1],lat[j])
                         ,(lon[2],lat[j]))
    end
    return dx
end

#computes the horizontal area of each grid cell
function cell_area(lon, lat)
    dx = grid_distance(lon, lat)
    dy = haversine((lon[1],lat[1])
                  ,(lon[1],lat[2]))
    dy = repeat([dy], length(lon) )
    area = dx .* dy'
    return area
end

#computes the volume of each grid cell
function cell_volumes(depth, lons, lats)
    nz = length(depth)
    areas = cellarea(lons, lats)
    volumes = zeros(Float32, length(depth), size(areas)[1], size(areas)[2])
    Δd = depth[2:end] .- depth[1:end-1]
    Δd = vcat(Δd, 500)
    for k in 1:nz
        volumes[k, :, :] .= Δd[k] .* areas
    end
    return volumes
end
    