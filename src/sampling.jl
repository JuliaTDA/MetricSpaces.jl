using Random

"""
    epsilon_net(X, ϵ; d)

Cover the PointCloud X with balls of radius ϵ.
Returns the vector of indexes of X that are the ball's centers.

## Details

We start by covering the first point of X with an ϵ-ball. Then we search for the next
point of X that is not covered by this ball. We repeat the process, until
all points are inside some ball.
"""
function epsilon_net(X::MetricSpace, ϵ::Number; d = dist_euclidean)

    covered = repeat([0], length(X))
    landmarks = Int[]
    
    prog = ProgressUnknown("Searching neighborhood of point number")

    while true

        # select the first non-covered index
        id_center = findfirst(==(0), covered)

        # add it to the landmarks set
        push!(landmarks, id_center)

        # get the elements currently covered by the epsilon ball around the current_center
        currently_covered = ball(X, id_center, ϵ) #findall(<(ϵ), pairwise_distance([x], X, d)[1, :]) 
        
        # update the covered indexes
        covered[currently_covered] .= 1

        # change the progress meter
        ProgressMeter.update!(prog, id_center)

        # if all points are covered, get out of the while loop
        findmin(covered)[1] > 0 && break
    end

    ProgressMeter.finish!(prog);

    return landmarks
end

"""
    farthest_points_sample(
        X::PointCloud, n::Integer; 
        metric = Euclidean()
        ) 

Given `X` and an integer `n`, return a subset of `X` such that
its points are the most distant possible from each other.

## Details

Let `X` be a metric space with `k` points. Select
a random point `x_1` ∈ `X`. Select then `x_2` as the point
most distant from `x_1` in relation to the given metric.
After that, choose `x_3` as the point most distant to
both `x_1` and `x_2` at the same time. Keep
choosing points like this until we have `n` points.
"""
function farthest_points_sample(X::MetricSpace, n::Integer; d = euclidean)
    length(X) < n && return [1:length(X);]

    ids = zeros(Int, n)
    ids[1] = rand(1:n)

    n == 1 && return ids    

    p_0 = X[ids[1]]

    commom_max_distance = pairwise_distance([p_0], X, d)[1, :]

    @showprogress for i in 2:n
        p_i = X[ids[i-1]]
        
        d_i = pairwise_distance([p_i], X, d)[1, :] #colwise(metric, X[:, ids[i-1]], X)

        commom_max_distance = mapslices(minimum, [commom_max_distance d_i], dims = 2)[:, 1]
        
        ids[i] = findmax(commom_max_distance)[2]
    end

    return ids
end

"""
    random_sample(X::MetricSpace, n = 1000)

Given `X` and an integer `n`, return a subset of `X` with `n` points 
chosen randomly.
"""
function random_sample(X::MetricSpace, n = 1000)
    shuffle(X)[1:min(length(X), n)]
end