@testsnippet StencilSetup begin
    using EnvironmentalTransport
    c = [0.0, 1, 2, 3, 4, 5]
    v = [10.0, 8, 6, 4, 2, 0, 1]
    Δt = 0.05
    Δz = 0.5
end

# @testset "l94 1" begin
#     c2 = [c[1], c[1], c..., c[end], c[end]]
#     result = [l94_stencil(c2[(i - 2):(i + 2)], v[(i - 2):(i - 1)], Δt, Δz) for i in 3:8]
#     @test max.((0,), c .+ result .* Δt) ≈ [0.0, 0.28, 1.8, 3.24, 4.68, 4.5]
# end

# @testset "ppm 1" begin
#     c2 = [c[1], c[1], c[1], c..., c[end], c[end], c[end], c[end]]
#     result = [ppm_stencil(c2[(i - 3):(i + 4)], v[(i - 3):(i - 2)], Δt, Δz) for i in 4:9]
#     @test c .+ result .* Δt ≈ [0.0, 0.3999999999999999, 1.8, 3.2, 4.6, 4.5]
# end

@testitem "upwind1 1" setup = [StencilSetup] begin
    c2 = [c[1], c..., c[end]]
    result = [upwind1_stencil(c2[(i - 1):(i + 1)], v[(i - 1):i], Δt, Δz) for i in 2:7]
    # Advective form: dϕᵢ/dt = −U_left·(ϕᵢ − ϕᵢ₋₁)/Δz for these non-negative winds,
    # e.g. cell 2: 1 − 0.05·8·(1 − 0)/0.5 = 0.2. (Flux form gave 0.4, 1.8, 3.2, 4.6, 4.5.)
    @test c .+ result .* Δt ≈ [0.0, 0.2, 1.4, 2.6, 3.8, 5.0]
end

# @testset "upwind2 1" begin
#     c2 = [c[1], c[1], c..., c[end], c[end]]
#     result = [upwind2_stencil(c2[(i - 2):(i + 2)], v[(i - 2):(i - 1)], Δt, Δz) for i in 3:8]
#     @test max.((0,), c .+ result .* Δt) ≈ [0.0, 0.0, 1.4, 2.6, 3.8, 5.0]
# end

@testsnippet StencilSetup2 begin
    using EnvironmentalTransport
    c = [6.0, 6, 5, 5, 6, 6]
    v = [2.0, 2, 2, 2, 2, 2, 2]
    Δt = 0.05
    Δz = 0.5
end

# @testset "l94 2" begin
#     c2 = [c[1], c[1], c..., c[end], c[end]]
#     result = [l94_stencil(c2[(i - 2):(i + 2)], v[(i - 2):(i - 1)], Δt, Δz) for i in 3:8]
#     @test max.((0,), c .+ result .* Δt) ≈ [6.0, 6.0, 5.2, 5.0, 5.8, 6.0]
# end

# @testset "ppm 2" begin
#     c2 = [c[1], c[1], c[1], c..., c[end], c[end], c[end], c[end]]
#     result = [ppm_stencil(c2[(i - 3):(i + 4)], v[(i - 3):(i - 2)], Δt, Δz) for i in 4:9]
#     @test c .+ result .* Δt ≈ [6.0, 6.0, 5.2, 5.0, 5.8, 6.0]
# end

@testitem "upwind1 2" setup = [StencilSetup2] begin
    c2 = [c[1], c..., c[end]]
    result = [upwind1_stencil(c2[(i - 1):(i + 1)], v[(i - 1):i], Δt, Δz) for i in 2:7]
    @test c .+ result .* Δt ≈ [6.0, 6.0, 5.2, 5.0, 5.8, 6.0]
end

# @testset "upwind2 2" begin
#     c2 = [c[1], c[1], c..., c[end], c[end]]
#     result = [upwind2_stencil(c2[(i - 2):(i + 2)], v[(i - 2):(i - 1)], Δt, Δz) for i in 3:8]
#     @test max.((0,), c .+ result .* Δt) ≈ [6.0, 6.0, 5.3, 4.9, 5.7, 6.1]
# end

@testitem "Constant Field Preservation" setup = [StencilSetup2] begin
    u0 = ones(10)
    v = 1.0
    Δt = 0.1
    Δz = 0.1

    @testset "Constant wind" begin
        for stencil in [upwind1_stencil] #, upwind2_stencil, l94_stencil, ppm_stencil]
            @testset "$(nameof(stencil))" begin
                lpad, rpad = EnvironmentalTransport.stencil_size(stencil)
                dudt = [
                    stencil(u0[(i - lpad):(i + rpad)], [v, v], Δt, Δz)
                        for i in (1 + lpad):(10 - rpad)
                ]
                @test dudt ≈ zeros(10 - lpad - rpad)
            end
        end
    end

    # The advective form must leave a uniform mixing ratio unchanged even when the
    # face winds do not satisfy discrete continuity (U[2] ≠ U[1]); the flux form
    # would give dϕ/dt = −ϕ·(U[2] − U[1])/Δz here.
    @testset "Divergent wind" begin
        vf = [3.0, -2.0, 5.0, 0.0, -4.0, 1.0, 2.0, -1.0, 6.0, 0.5, -3.0]
        for stencil in [upwind1_stencil]
            @testset "$(nameof(stencil)) Δz=$Δz" for Δz in (0.1, -0.1)
                lpad, rpad = EnvironmentalTransport.stencil_size(stencil)
                dudt = [
                    stencil(u0[(i - lpad):(i + rpad)], vf[i:(i + 1)], Δt, Δz)
                        for i in (1 + lpad):(10 - rpad)
                ]
                @test dudt ≈ zeros(10 - lpad - rpad) atol = 1.0e-12
            end
        end
    end
end

@testitem "Known solution" begin
    using EnvironmentalTransport
    for (dir, u0) in [("up", collect(1.0:10.0)), ("down", collect(10.0:-1:1))]
        @testset "$dir" begin
            v = 1.0
            Δt = 1.0
            # For vertical grid, increasing altitude mean decreasing pressure, so Δz is negative.
            for (Δz, zdir) in [(1.0, "pos Δz"), (-1.0, "neg Δz")]
                @testset "$zdir" begin
                    uu0 = u0 .* sign(Δz)
                    for stencil in [
                            upwind1_stencil,
                        ] #, upwind2_stencil, l94_stencil, ppm_stencil]
                        @testset "$(nameof(stencil))" begin
                            lpad, rpad = EnvironmentalTransport.stencil_size(stencil)
                            dudt = [
                                stencil(uu0[(i - lpad):(i + rpad)], [v, v], Δt, Δz)
                                    for i in (1 + lpad):(10 - rpad)
                            ]
                            if dir == "up"
                                @test dudt ≈ zeros(10 - lpad - rpad) .- 1
                            else
                                @test dudt ≈ zeros(10 - lpad - rpad) .+ 1
                            end
                        end
                    end
                end
            end
        end
    end
end

@testitem "Mass Conservation" begin
    using EnvironmentalTransport
    u0_opts = [("up", 1.0:10.0), ("down", 10.0:-1:1), ("rand", rand(10))]
    for stencil in [upwind1_stencil] #, upwind2_stencil, l94_stencil, ppm_stencil]
        @testset "$(nameof(stencil))" begin
            lpad, rpad = EnvironmentalTransport.stencil_size(stencil)
            N = 10 + lpad * 2 + rpad * 2
            v_opts = [
                ("c", ones(N + 1)), ("up", 1.0:(N + 1)),
                ("down", (N + 1):-1:1.0), ("neg up", -(1.0:(N + 1))),
                ("neg down", -((N + 1):-1:1.0)), ("rand", rand(N + 1) .* 2 .- 1),
            ]
            Δz_opts = [
                ("c", ones(N)), ("up", 1.0:N), ("down", N:-1:1.0), ("neg", (-N):-1.0),
            ]
            for (d1, u0_in) in u0_opts
                @testset "u0 $d1" begin
                    u0 = zeros(N)
                    u0[(1 + lpad * 2):(N - rpad * 2)] .= u0_in
                    for (d2, v) in v_opts
                        @testset "v $d2" begin
                            Δt = 1.0
                            for (d3, Δz) in Δz_opts
                                @testset "Δz $d3" begin
                                    dudt = [
                                        stencil(
                                            u0[(i - lpad):(i + rpad)],
                                            v[i:(i + 1)], Δt,
                                            Δz[i]
                                        )
                                            for i in (1 + lpad):(N - rpad)
                                    ]
                                    # upwind1_stencil is in advective form, so mass is only
                                    # conserved for non-divergent velocity. The face fluxes
                                    # telescope, leaving the divergence correction ϕᵢ(U₊ − U₋).
                                    div_source = sum(
                                        u0[i] * (v[i + 1] - v[i])
                                            for i in (1 + lpad):(N - rpad)
                                    )
                                    @test sum(dudt .* Δz[(1 + lpad):(N - rpad)]) ≈ div_source atol = 1.0e-12
                                    if d2 == "c"
                                        @test div_source == 0.0
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
