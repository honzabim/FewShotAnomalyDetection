module FewShotAnomalyDetection

using Flux
using NNlib
using Distributions
using SpecialFunctions
using Adapt
using Random
using LinearAlgebra
using FluxExtensions
using EvalCurves
using Pkg

include("KNNmemory.jl")
include("bessel.jl")
include("svae.jl")
include("svaebase.jl")
include("svaetwocaps.jl")
include("svae_vamp.jl")

if in("CuArrays",keys(Pkg.installed()))
    using CuArrays
    include("svae_gpu.jl")
end

export SVAEbase, SVAEtwocaps, SVAEvamp, loss, wloss, pxexpectedz, pz, px, zparams, printing_wloss, mem_wloss

end
