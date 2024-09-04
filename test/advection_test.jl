using EnvironmentalTransport: advection_op
using EnvironmentalTransport
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

v_fs = ((i, j, k, t) -> v[i], (i, j, k, t) -> v[j], (i, j, k, t) -> v[k])
Δ_fs = ((i, j, k, t) -> Δz, (i, j, k, t) -> Δz, (i, j, k, t) -> Δz)

@testset "4d advection op" begin
    adv_op = advection_op(c, upwind1_stencil, v_fs, Δ_fs, Δt, ZeroGradBCArray)
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

mul_stencil(ϕ, U, Δt, Δz; p = 0.0) = p
EnvironmentalTransport.stencil_size(s::typeof(mul_stencil)) = (0, 0)

@testset "parameters" begin
    adv_op = advection_op(c, mul_stencil, v_fs, Δ_fs, Δt, ZeroGradBCArray, p = 0.0)
    adv_op = cache_operator(adv_op, c)

    result_oop = adv_op(c[:], 2.0, 0.0)
    result_iip = similar(result_oop)
    adv_op(result_iip, c[:], 2.0, 0.0)
    @test all(result_iip .== 6.0)
    @test all(result_oop .== 6.0)
end
