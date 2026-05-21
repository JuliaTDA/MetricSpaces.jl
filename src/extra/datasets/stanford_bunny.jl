const STANFORD_BUNNY_URL = "https://raw.githubusercontent.com/FreeCAD/Examples/master/Point_cloud_ExampleFiles/PointCloud-Data_Stanford-Bunny.asc"

"""
    stanford_bunny(; cache_dir = nothing)

Download and return the Stanford bunny 3D point cloud.

Source: FreeCAD/Examples on GitHub (a reduced sampling of the Stanford Computer
Graphics Laboratory's original bunny scan; ~400 points). The file is cached
locally after the first download.

# Arguments
- `cache_dir`: directory to cache the downloaded file. Defaults to a temporary directory.
"""
function stanford_bunny(; cache_dir=nothing)
    if cache_dir === nothing
        cache_dir = mktempdir()
    end

    filepath = joinpath(cache_dir, "stanford_bunny.asc")

    if !isfile(filepath)
        mkpath(cache_dir)
        Downloads.download(STANFORD_BUNNY_URL, filepath)
    end

    data = readdlm(filepath, ' ', Float64)
    EuclideanSpace(permutedims(data, [2, 1]))
end
