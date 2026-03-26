using Downloads
using DelimitedFiles

const MAMMOTH_URL = "https://raw.githubusercontent.com/MNoichl/UMAP-examples-mammoth/master/mammoth_a.csv"

"""
    mammoth(; cache_dir = nothing)

Download and return the woolly mammoth 3D point cloud (~20k points).
Original dataset by Maximilian Noichl, 3D scan from the Smithsonian.

The file is cached locally after the first download.

# Arguments
- `cache_dir`: directory to cache the downloaded file. Defaults to a temporary directory.
"""
function mammoth(; cache_dir=nothing)
    if cache_dir === nothing
        cache_dir = mktempdir()
    end

    filepath = joinpath(cache_dir, "mammoth_a.csv")

    if !isfile(filepath)
        mkpath(cache_dir)
        Downloads.download(MAMMOTH_URL, filepath)
    end

    data = readdlm(filepath, ',', Float64; skipstart=1)
    # data is N x 3 matrix, we need 3 x N for EuclideanSpace
    EuclideanSpace(permutedims(data, [2, 1]))
end
