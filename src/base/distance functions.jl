# using Distances
dist_euclidean = Distances.euclidean

dist_cityblock = Distances.cityblock

dist_chebyshev = Distances.chebyshev

dist_cosine = Distances.cosine_dist

dist_hamming = Distances.hamming

dist_correlation = Distances.corr_dist

dist_minkowski(p) = (x, y) -> Distances.minkowski(x, y, p)