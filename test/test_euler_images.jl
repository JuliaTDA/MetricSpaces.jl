using Random
import MLJModelInterface as MMI

@testset "Cubical ECC reference counts" begin
    @test cubical_ecc([0. 1.;1. 0.]).values==[2,1]
    ring=trues(3,3);ring[2,2]=false
    @test cubical_ecc(zeros(3,3);mask=ring).values==[0]
    @test cubical_ecc(zeros(3,3)).values==[1]
    @test cubical_ecc(zeros(3,3);mask=falses(3,3)).values==[0]
    rng=Random.Xoshiro(103)
    for _ in 1:10
        A=rand(rng,0:3,4,5)
        E=cubical_ecc(A;thresholds=0:3)
        for (k,t) in enumerate(0:3)
            M=A .<= t
            V=count(M)
            edges=sum(M[i,j] && M[i+1,j] for i in 1:3,j in 1:5)+sum(M[i,j] && M[i,j+1] for i in 1:4,j in 1:4)
            faces=sum(all(M[i:i+1,j:j+1]) for i in 1:3,j in 1:4)
            @test E.values[k]==V-edges+faces
        end
    end
    @test_throws ArgumentError cubical_ecc([NaN])
    @test_throws ArgumentError cubical_ecc([0,1];thresholds=[1,0])
end

@testset "Directional ECT and exact SECT" begin
    E=ect(reshape([0.,2.],1,2),Tuple[];directions=ones(1,1),thresholds=[-1.,0.,.7,2.,3.])
    @test E.values[:,1]==[0,1,1,2,2]
    @test sect(E).values[:,1]≈[0.,-1.,-1.,-1.,0.]
    @test length(euler_table(E).value)==5
    @test all(abs.(sum(abs2,sample_directions(3;n=10);dims=1).-1).<1e-12)
    @test sample_directions(4;rng=Random.Xoshiro(4))==sample_directions(4;rng=Random.Xoshiro(4))
    shape=trues(3,3);shape[2,2]=false
    R=ect(shape;directions=[1. 0.;0. 1.],thresholds=[-1.,0.,1.,2.,3.])
    @test R.values[end,:]==[0,0]
    @test all(abs.(sect(R).values[[1,end],:]).<1e-12)
    @test_throws ArgumentError ect(shape;directions=zeros(2,1))
    @test_throws ArgumentError ect(shape;spacing=[0.,1.])
end

@testset "Exact anisotropic EDT and image filtrations" begin
    rng=Random.Xoshiro(8)
    M=rand(rng,Bool,5,4);M[1,1]=true;M[end,end]=false
    spacing=[2.,.7]
    for target in (true,false)
        D=euclidean_distance_transform(M;target=target,spacing=spacing)
        sites=findall(==(target),M)
        reference=[minimum(sqrt(sum((spacing[k]*(i[k]-j[k]))^2 for k in 1:2)) for j in sites) for i in CartesianIndices(M)]
        @test D≈reference
    end
    @test all(isinf,dilation_filtration(falses(3,3)))
    @test all(iszero,dilation_filtration(trues(3,3)))
    S=signed_distance_filtration(trues(3,3))
    @test S==[-1. -1. -1.;-1. -2. -1.;-1. -1. -1.]
    @test (signed_distance_filtration(M) .<= 0) == M
    @test erosion_filtration(M)[.!M]==fill(Inf,count(!,M))
    @test height_filtration(trues(2,2);direction=[1.,0.])==[0. 0.;1. 1.]
    @test radial_filtration(trues(3,3))[2,2]==0
    @test ImageFiltration(:dilation)(M)==dilation_filtration(M)
    @test_throws ArgumentError ImageFiltration(:unknown)
    @test_throws ArgumentError euclidean_distance_transform(M;spacing=[-1.,1.])
    if VERSION>=v"1.9" # package extensions are available from Julia 1.9
        model=image_filtration_model(:signed_distance)
        fit,cache,report=MMI.fit(model,0,[M])
        @test only(MMI.transform(model,fit,[M]))==signed_distance_filtration(M)
    end
end
