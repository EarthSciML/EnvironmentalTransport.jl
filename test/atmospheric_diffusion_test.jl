@testsnippet AtmDiffSetup begin
    using ModelingToolkit
    using ModelingToolkit: t
    using DynamicQuantities
    using SciMLBase
    using EnvironmentalTransport

    sys = AtmosphericDiffusion()
    sys_nns = ModelingToolkit.toggle_namespacing(sys, false)
    ssys = mtkcompile(sys; inputs = [sys_nns.z])
    prob = NonlinearProblem(ssys, Dict(ssys.z => 100.0))
end

@testitem "AtmosphericDiffusion Structure" setup=[AtmDiffSetup] tags=[:atmdiff] begin
    sys0 = AtmosphericDiffusion()

    # Check that the system has the expected variables
    vars = Symbol.(unknowns(sys0))
    @test Symbol("z(t)") in vars
    @test Symbol("u_wind(t)") in vars
    @test Symbol("K_zz(t)") in vars
    @test Symbol("K_yy(t)") in vars
    @test length(vars) == 4

    # Check that the system has the expected parameters
    # Note: κ is now a constant, not a parameter
    params = Symbol.(parameters(sys0))
    for p in [:u_r, :z_r, :p_wind, :z_i, :L_MO, :u_star, :f_cor]
        @test p in params
    end

    # Check that the system has the expected number of equations
    @test length(equations(sys0)) == 3
end

@testitem "Wind Profile (Eq. 18.118)" setup=[AtmDiffSetup] tags=[:atmdiff] begin
    # Test: ū/ū_r = (z/z_r)^p
    # With defaults: u_r=5, z_r=10, p_wind=0.15

    # At reference height, wind should equal reference speed
    sol = solve(remake(prob; p = Dict(ssys.z => 10.0)))
    @test sol[ssys.u_wind] ≈ 5.0 rtol = 1e-6

    # At z=100m with p=0.15: u = 5 * (100/10)^0.15 = 5 * 10^0.15
    sol100 = solve(prob)
    @test sol100[ssys.u_wind] ≈ 5.0 * 10.0^0.15 rtol = 1e-6

    # At z=50m: u = 5 * (50/10)^0.15 = 5 * 5^0.15
    sol50 = solve(remake(prob; p = Dict(ssys.z => 50.0)))
    @test sol50[ssys.u_wind] ≈ 5.0 * 5.0^0.15 rtol = 1e-6
end

@testitem "Unstable K_zz (Eq. 18.121)" setup=[AtmDiffSetup] tags=[:atmdiff] begin
    # Under unstable conditions (L_MO < 0), test piecewise K_zz
    # Default: z_i=1000, L_MO=-100, u_star=0.3, κ=0.4
    κ = 0.4
    u_star = 0.3
    z_i = 1000.0
    L_MO = -100.0
    w_star = u_star * (-z_i / (κ * L_MO))^(1 / 3)

    # Piece 1: z/z_i < 0.05, i.e. z < 50m
    # Test at z=30m: z/z_i = 0.03
    z_test = 30.0
    zn = z_test / z_i
    expected_norm = 2.5 * κ * zn^(4 / 3) * (1 - 15 * z_test / L_MO)^(1 / 4)
    expected_Kzz = w_star * z_i * expected_norm

    sol = solve(remake(prob; p = Dict(ssys.z => z_test)))
    @test sol[ssys.K_zz] ≈ expected_Kzz rtol = 1e-4

    # Piece 2: 0.05 ≤ z/z_i ≤ 0.6, test at z=300m (z/z_i = 0.3)
    z_test2 = 300.0
    zn2 = z_test2 / z_i
    expected_norm2 = 0.021 + 0.408 * zn2 + 1.351 * zn2^2 - 4.096 * zn2^3 + 2.560 * zn2^4
    expected_Kzz2 = w_star * z_i * expected_norm2

    sol2 = solve(remake(prob; p = Dict(ssys.z => z_test2)))
    @test sol2[ssys.K_zz] ≈ expected_Kzz2 rtol = 1e-4

    # Piece 3: 0.6 < z/z_i ≤ 1.1, test at z=800m (z/z_i = 0.8)
    z_test3 = 800.0
    zn3 = z_test3 / z_i
    expected_norm3 = 0.2 * exp(6 - 10 * zn3)
    expected_Kzz3 = w_star * z_i * expected_norm3

    sol3 = solve(remake(prob; p = Dict(ssys.z => z_test3)))
    @test sol3[ssys.K_zz] ≈ expected_Kzz3 rtol = 1e-4

    # Piece 4: z/z_i > 1.1, test at z=1200m (z/z_i = 1.2)
    z_test4 = 1200.0
    expected_Kzz4 = w_star * z_i * 0.0013

    sol4 = solve(remake(prob; p = Dict(ssys.z => z_test4)))
    @test sol4[ssys.K_zz] ≈ expected_Kzz4 rtol = 1e-4
end

@testitem "Neutral K_zz (Eq. 18.122)" setup=[AtmDiffSetup] tags=[:atmdiff] begin
    # Under neutral conditions (|L_MO| very large), test K_zz
    κ = 0.4
    u_star = 0.3
    z_i = 1000.0

    # z/z_i < 0.1: K_zz = κ u_* z
    z_test = 50.0
    expected = κ * u_star * z_test

    sol = solve(remake(prob; p = Dict(ssys.z => z_test, ssys.L_MO => 1e6)))
    @test sol[ssys.K_zz] ≈ expected rtol = 1e-4

    # 0.1 ≤ z/z_i ≤ 1.1: K_zz = κ u_* z (1.1 - z/z_i)
    z_test2 = 500.0
    zn2 = z_test2 / z_i
    expected2 = κ * u_star * z_test2 * (1.1 - zn2)

    sol2 = solve(remake(prob; p = Dict(ssys.z => z_test2, ssys.L_MO => 1e6)))
    @test sol2[ssys.K_zz] ≈ expected2 rtol = 1e-4

    # z/z_i > 1.1: K_zz ≈ 0
    sol3 = solve(remake(prob; p = Dict(ssys.z => 1200.0, ssys.L_MO => 1e6)))
    @test sol3[ssys.K_zz] ≈ 0.0 atol = 1e-6
end

@testitem "Stable K_zz (Eq. 18.125)" setup=[AtmDiffSetup] tags=[:atmdiff] begin
    # Under stable conditions (0 < L_MO ≤ 10000)
    # K_zz = κ u_* z / (0.74 + 4.7 z/L) * exp(-8 f z / u_*)
    κ = 0.4
    u_star = 0.3
    f_cor = 1e-4
    L_MO = 200.0

    z_test = 50.0
    expected = κ * u_star * z_test / (0.74 + 4.7 * z_test / L_MO) *
               exp(-8 * f_cor * z_test / u_star)

    sol = solve(remake(prob; p = Dict(ssys.z => z_test, ssys.L_MO => L_MO)))
    @test sol[ssys.K_zz] ≈ expected rtol = 1e-4

    z_test2 = 200.0
    expected2 = κ * u_star * z_test2 / (0.74 + 4.7 * z_test2 / L_MO) *
                exp(-8 * f_cor * z_test2 / u_star)

    sol2 = solve(remake(prob; p = Dict(ssys.z => z_test2, ssys.L_MO => L_MO)))
    @test sol2[ssys.K_zz] ≈ expected2 rtol = 1e-4
end

@testitem "Horizontal Diffusivity K_yy" setup=[AtmDiffSetup] tags=[:atmdiff] begin
    # Under unstable conditions: K_yy = 0.1 * w_star * z_i (Eq. 18.128)
    κ = 0.4
    u_star = 0.3
    z_i = 1000.0
    L_MO = -100.0
    w_star = u_star * (-z_i / (κ * L_MO))^(1 / 3)

    # Unstable: K_yy = 0.1 * w_star * z_i (independent of z)
    expected_Kyy = 0.1 * w_star * z_i

    sol = solve(remake(prob; p = Dict(ssys.z => 200.0)))
    @test sol[ssys.K_yy] ≈ expected_Kyy rtol = 1e-4

    # Under stable conditions, K_yy = K_zz
    sol_stable = solve(remake(prob; p = Dict(ssys.z => 50.0, ssys.L_MO => 200.0)))
    @test sol_stable[ssys.K_yy] ≈ sol_stable[ssys.K_zz] rtol = 1e-6
end

@testitem "Qualitative Properties" setup=[AtmDiffSetup] tags=[:atmdiff] begin
    # Wind speed should increase with height (power-law with p > 0)
    sol_low = solve(remake(prob; p = Dict(ssys.z => 10.0)))
    sol_high = solve(remake(prob; p = Dict(ssys.z => 100.0)))
    @test sol_high[ssys.u_wind] > sol_low[ssys.u_wind]

    # K_zz should be positive at typical heights for all stability regimes
    for L_MO_val in [-100.0, 1e6, 200.0]
        sol = solve(remake(prob; p = Dict(ssys.z => 100.0, ssys.L_MO => L_MO_val)))
        @test sol[ssys.K_zz] > 0
    end

    # K_yy should be positive
    sol = solve(remake(prob; p = Dict(ssys.z => 100.0)))
    @test sol[ssys.K_yy] > 0
end
