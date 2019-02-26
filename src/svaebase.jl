"""
		Implementation of Hyperspherical Variational Auto-Encoders

		Original paper: https://arxiv.org/abs/1804.00891

		SVAEbase(q,g,zdim,hue,μzfromhidden,κzfromhidden)

		q --- encoder - in this case encoder only encodes from input to a hidden
						layer which is then transformed into parameters for the latent
						layer by `μzfromhidden` and `κzfromhidden` functions
		g --- decoder
		zdim --- dimension of the latent space
		hue --- Hyperspherical Uniform Entropy that is part of the KL divergence but depends only on dimensionality so can be computed in constructor
		μzfromhidden --- function that transforms the hidden layer to μ parameter of the latent layer by normalization
		κzfromhidden --- transforms hidden layer to κ parameter of the latent layer using softplus since κ is a positive scalar
"""
struct SVAEbase <: SVAE
	q
	g
	zdim
	hue
	μzfromhidden
	κzfromhidden

	"""
	SVAEbase(q, g, hdim, zdim, T) Constructor of the S-VAE where `zdim > 3` and T determines the floating point type (default Float32)
	"""
	SVAEbase(q, g, hdim::Integer, zdim::Integer, T = Float32) = new(q, g, zdim, convert(T, huentropy(zdim)), Adapt.adapt(T, Chain(Dense(hdim, zdim), x -> normalizecolumns(x))), Adapt.adapt(T, Dense(hdim, 1, softplus)))
end

Flux.@treelike(SVAEbase)

"""
	loss(m::SVAEbase, x)

	Loss function of the S-VAE combining reconstruction error and the KL divergence
"""
function loss(m::SVAEbase, x, β)
	(μz, κz) = zparams(m, x)
	z = samplez(m, μz, κz)
	xgivenz = m.g(z)
	return Flux.mse(x, xgivenz) + β * mean(kldiv(m, κz))
end

function wloss(m::SVAEbase, x, β, d)
	(μz, κz) = zparams(m, x)
	z = samplez(m, μz, κz)
	zp = samplehsuniform(size(z))
	Ω = d(z, zp)
	xgivenz = m.g(z)
	return Flux.mse(x, xgivenz) + β * Ω
end

function pz(m::SVAEbase, x)
	z = Flux.Tracker.data(zparams(m, x)[1])
	priorμ = zeros(size(z, 1))
	priorμ[1] = 1
	log_vmf_c(z, priorμ, 1)
end
