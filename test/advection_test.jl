using EnvironmentalTransport: advection_op
using EnvironmentalTransport
using EarthSciMLBase: MapBroadcast
using Test
using LinearAlgebra
using SciMLOperators
using SciMLBase: NullParameters

c = zeros(3, 6, 6, 6)
c[2, :, 3, 4] = [0.0, 1, 2, 3, 4, 5]
c[2, 3, :, 4] = [0.0, 1, 2, 3, 4, 5]
c[2, 3, 4, :] = [0.0, 1, 2, 3, 4, 5]
const v = [10.0, 8, 6, 4, 2, 0, 1]
const Δt = 0.05
const Δz = 0.5

v_fs = ((i, j, k, p, t) -> v[i], (i, j, k, p, t) -> v[j], (i, j, k, p, t) -> v[k])
Δ_fs = ((i, j, k, p, t) -> Δz, (i, j, k, p, t) -> Δz, (i, j, k, p, t) -> Δz)

@testset "4d advection op" begin
    adv_op = advection_op(c, upwind1_stencil, v_fs, Δ_fs, Δt, ZeroGradBC(), MapBroadcast())
    adv_op = cache_operator(adv_op, c)

    result_oop = adv_op(c[:], NullParameters(), 0.0)
    result_iip = similar(result_oop)
    adv_op(result_iip, c[:], NullParameters(), 0.0)
    for (s, result) in (("in-place", result_iip), ("out-of-place", result_oop))
        @testset "$s" begin
            result = reshape(result, size(c))
            @test result[2, :, 3, 4] ≈ [0.0, -24.0, -16.0, -32.0, -36.0, -70.0]
            @test result[2, 3, :, 4] ≈ [0.0, -24.0, -16.0, -16.0, -36.0, -70.0]
            @test result[2, 3, 4, :] ≈ [0.0, -24.0, -28.0, -16.0, -36.0, -70.0]
            @test all(result[1, :, :, :] .≈ 0.0)
            @test all(result[3, :, :, :] .≈ 0.0)
        end
    end
end
