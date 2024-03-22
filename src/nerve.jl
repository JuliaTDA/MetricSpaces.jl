"""
    nerve_1d(CX::CoveredPointCloud)

Given a covered point cloud `CX`, return the adjacency
matrix of the 1-skeleton nerve of `CX.covering`.
"""
function nerve_1d(cv::Covering)
    n = length(cv)
    g = Graph(n)
    
    @threads for i ∈ 1:n
        for j ∈ i:n
            i == j && continue
            if !isdisjoint(cv[i], cv[j])
                add_edge!(g, i, j)
            end
        end
    end

    return g
end