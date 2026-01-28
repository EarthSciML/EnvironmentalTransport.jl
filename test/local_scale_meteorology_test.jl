@testsnippet LocalScaleSetup begin
    using EnvironmentalTransport
    using ModelingToolkit
    using ModelingToolkit: t
    using OrdinaryDiffEq
    using DynamicQuantities
    using Test
end

# =============================================================================
# Structural Tests
# =============================================================================

@testitem "AtmosphericStability structure" setup=[LocalScaleSetup] begin
    sys = AtmosphericStability()

    # Check number of equations
    @test length(equations(sys)) == 4

    # Check expected variables exist
    var_names = Symbol.(unknowns(sys))
    @test Symbol("θ(t)") in var_names
    @test Symbol("dT_dz(t)") in var_names
    @test Symbol("dθ_dz(t)") in var_names
    @test Symbol("S(t)") in var_names

    # Check expected parameters exist
    param_names = Symbol.(parameters(sys))
    @test :T in param_names
    @test :T_below in param_names
    @test :p in param_names
    @test :Δz in param_names
end

@testitem "SurfaceLayerProfile structure" setup=[LocalScaleSetup] begin
    sys = SurfaceLayerProfile()

    # Check number of equations
    @test length(equations(sys)) == 7

    # Check expected variables exist
    var_names = Symbol.(unknowns(sys))
    @test Symbol("L(t)") in var_names
    @test Symbol("ζ(t)") in var_names
    @test Symbol("φ_m(t)") in var_names
    @test Symbol("φ_h(t)") in var_names
    @test Symbol("ψ_m(t)") in var_names
    @test Symbol("ψ_h(t)") in var_names
    @test Symbol("ū(t)") in var_names

    # Check expected parameters exist
    param_names = Symbol.(parameters(sys))
    @test :z in param_names
    @test :z₀ in param_names
    @test :u_star in param_names
    @test :q_z in param_names
end

@testitem "LocalScaleMeteorology structure" setup=[LocalScaleSetup] begin
    sys = LocalScaleMeteorology()

    # Check number of equations
    @test length(equations(sys)) == 12

    # Check expected variables exist
    var_names = Symbol.(unknowns(sys))
    @test Symbol("θ(t)") in var_names
    @test Symbol("L(t)") in var_names
    @test Symbol("ū(t)") in var_names
    @test Symbol("pasquill_class(t)") in var_names

    # Check expected parameters exist
    param_names = Symbol.(parameters(sys))
    @test :T in param_names
    @test :z in param_names
    @test :z₀ in param_names
    @test :u_star in param_names
end

# =============================================================================
# Equation Verification Tests - Dry Adiabatic Lapse Rate (Eq. 16.8)
# =============================================================================

@testitem "Dry adiabatic lapse rate" setup=[LocalScaleSetup] begin
    # From Seinfeld & Pandis p.724: Γ = g/ĉ_p = 9.807/1005 = 9.76 K/km
    g = 9.807  # m/s²
    ĉ_p = 1005.0  # J/(kg·K)
    Γ_expected = g / ĉ_p  # K/m

    # Convert to K/km for comparison with textbook
    Γ_km = Γ_expected * 1000  # K/km
    @test isapprox(Γ_km, 9.76, rtol=0.01)

    # Test in AtmosphericStability system
    sys = AtmosphericStability()
    csys = mtkcompile(sys)

    # When actual lapse rate equals dry adiabatic, stability should be ~0
    # dT/dz = -Γ_d means neutral atmosphere
    T_surface = 288.15  # K
    Δz = 100.0  # m
    T_above = T_surface - Γ_expected * Δz  # Temperature at height Δz above

    prob = ODEProblem(csys, Dict(), (0.0, 1.0), Dict(
        csys.T => T_above,
        csys.T_below => T_surface,
        csys.Δz => Δz,
        csys.p => 101325.0
    ))
    sol = solve(prob)

    # Stability parameter S = dθ/dz should be approximately 0 for neutral atmosphere
    @test isapprox(sol[csys.S][end], 0.0, atol=1e-5)
end

# =============================================================================
# Equation Verification Tests - Potential Temperature (Eq. 16.14)
# =============================================================================

@testitem "Potential temperature" setup=[LocalScaleSetup] begin
    # From Seinfeld & Pandis Eq. 16.14: θ = T(p₀/p)^0.286
    # At sea level (p = p₀), θ = T

    sys = LocalScaleMeteorology()
    csys = mtkcompile(sys)

    T = 288.15  # K
    p₀ = 101325.0  # Pa

    # Test 1: At sea level, θ = T
    prob = ODEProblem(csys, Dict(), (0.0, 1.0), Dict(
        csys.T => T,
        csys.p => p₀
    ))
    sol = solve(prob)
    @test isapprox(sol[csys.θ][end], T, rtol=1e-6)

    # Test 2: At lower pressure, θ > T
    # At 850 hPa, with T = 280 K
    p_850 = 85000.0  # Pa
    T_850 = 280.0  # K
    θ_expected = T_850 * (p₀ / p_850)^0.286

    prob2 = ODEProblem(csys, Dict(), (0.0, 1.0), Dict(
        csys.T => T_850,
        csys.p => p_850
    ))
    sol2 = solve(prob2)
    @test isapprox(sol2[csys.θ][end], θ_expected, rtol=0.01)

    # θ should be greater than T at lower pressure
    @test sol2[csys.θ][end] > T_850
end

# =============================================================================
# Stability Classification Tests
# =============================================================================

@testitem "Atmospheric stability classification" setup=[LocalScaleSetup] begin
    sys = AtmosphericStability()
    csys = mtkcompile(sys)

    T_surface = 288.15  # K
    Δz = 100.0  # m

    # Test 1: Stable atmosphere - temperature decreases less than adiabatic
    # (or even increases with height - inversion)
    T_stable = T_surface - 0.005 * Δz  # 0.5 K/100m, less than 0.976 K/100m
    prob_stable = ODEProblem(csys, Dict(), (0.0, 1.0), Dict(
        csys.T => T_stable,
        csys.T_below => T_surface,
        csys.Δz => Δz,
        csys.p => 101325.0
    ))
    sol_stable = solve(prob_stable)
    # S > 0 for stable (dθ/dz > 0)
    @test sol_stable[csys.S][end] > 0

    # Test 2: Unstable atmosphere - temperature decreases more than adiabatic (superadiabatic)
    T_unstable = T_surface - 0.015 * Δz  # 1.5 K/100m, more than 0.976 K/100m
    prob_unstable = ODEProblem(csys, Dict(), (0.0, 1.0), Dict(
        csys.T => T_unstable,
        csys.T_below => T_surface,
        csys.Δz => Δz,
        csys.p => 101325.0
    ))
    sol_unstable = solve(prob_unstable)
    # S < 0 for unstable (dθ/dz < 0)
    @test sol_unstable[csys.S][end] < 0
end

# =============================================================================
# Monin-Obukhov Length Tests (Eq. 16.70)
# =============================================================================

@testitem "Monin-Obukhov length" setup=[LocalScaleSetup] begin
    # From Seinfeld & Pandis p.751: Example calculation gives L ≈ -15 m for given conditions
    # L = -ρĉ_p T₀ u*³ / (κ g q̄_z)

    sys = SurfaceLayerProfile()
    csys = mtkcompile(sys)

    # Test 1: Neutral conditions (very small heat flux)
    # When q_z ≈ 0, |L| should be very large
    prob_neutral = ODEProblem(csys, Dict(), (0.0, 1.0), Dict(
        csys.u_star => 0.3,
        csys.q_z => 1e-6,  # Nearly zero heat flux
        csys.T₀ => 288.15,
        csys.ρ => 1.225
    ))
    sol_neutral = solve(prob_neutral)
    @test abs(sol_neutral[csys.L][end]) > 1e6  # Very large |L| for neutral

    # Test 2: Unstable conditions (positive heat flux - surface heating)
    # L should be negative
    prob_unstable = ODEProblem(csys, Dict(), (0.0, 1.0), Dict(
        csys.u_star => 0.4,
        csys.q_z => 100.0,  # Positive upward heat flux
        csys.T₀ => 288.15,
        csys.ρ => 1.225
    ))
    sol_unstable = solve(prob_unstable)
    @test sol_unstable[csys.L][end] < 0  # Negative L for unstable

    # Test 3: Stable conditions (negative heat flux - surface cooling)
    # L should be positive
    prob_stable = ODEProblem(csys, Dict(), (0.0, 1.0), Dict(
        csys.u_star => 0.3,
        csys.q_z => -50.0,  # Negative (downward) heat flux
        csys.T₀ => 288.15,
        csys.ρ => 1.225
    ))
    sol_stable = solve(prob_stable)
    @test sol_stable[csys.L][end] > 0  # Positive L for stable
end

# =============================================================================
# Businger-Dyer Stability Functions Tests (Eq. 16.75)
# =============================================================================

@testitem "Businger-Dyer stability functions" setup=[LocalScaleSetup] begin
    sys = SurfaceLayerProfile()
    csys = mtkcompile(sys)

    # Test 1: Neutral conditions (ζ ≈ 0)
    # φ_m = φ_h = 1
    prob_neutral = ODEProblem(csys, Dict(), (0.0, 1.0), Dict(
        csys.u_star => 0.3,
        csys.q_z => 1e-8,  # Nearly zero heat flux gives large |L|
        csys.z => 10.0,
        csys.T₀ => 288.15,
        csys.ρ => 1.225
    ))
    sol_neutral = solve(prob_neutral)
    @test isapprox(sol_neutral[csys.ζ][end], 0.0, atol=1e-4)
    @test isapprox(sol_neutral[csys.φ_m][end], 1.0, rtol=0.1)
    @test isapprox(sol_neutral[csys.φ_h][end], 1.0, rtol=0.1)

    # Test 2: Stable conditions (ζ > 0)
    # φ_m = φ_h = 1 + 4.7ζ (Businger et al. 1971, Eq. 16.75)
    prob_stable = ODEProblem(csys, Dict(), (0.0, 1.0), Dict(
        csys.u_star => 0.2,
        csys.q_z => -50.0,
        csys.z => 10.0,
        csys.T₀ => 288.15,
        csys.ρ => 1.225
    ))
    sol_stable = solve(prob_stable)
    ζ_stable = sol_stable[csys.ζ][end]
    @test ζ_stable > 0  # Positive ζ for stable
    expected_φ = 1 + 4.7 * ζ_stable
    @test isapprox(sol_stable[csys.φ_m][end], expected_φ, rtol=0.01)
    @test isapprox(sol_stable[csys.φ_h][end], expected_φ, rtol=0.01)

    # Test 3: Unstable conditions (ζ < 0)
    # φ_m = (1 - 15ζ)^(-1/4) (Businger et al. 1971, Eq. 16.75)
    # φ_h = (1 - 15ζ)^(-1/2)
    prob_unstable = ODEProblem(csys, Dict(), (0.0, 1.0), Dict(
        csys.u_star => 0.3,
        csys.q_z => 100.0,
        csys.z => 10.0,
        csys.T₀ => 288.15,
        csys.ρ => 1.225
    ))
    sol_unstable = solve(prob_unstable)
    ζ_unstable = sol_unstable[csys.ζ][end]
    @test ζ_unstable < 0  # Negative ζ for unstable
    expected_φm = (1 - 15 * ζ_unstable)^(-0.25)
    expected_φh = (1 - 15 * ζ_unstable)^(-0.5)
    @test isapprox(sol_unstable[csys.φ_m][end], expected_φm, rtol=0.01)
    @test isapprox(sol_unstable[csys.φ_h][end], expected_φh, rtol=0.01)
end

# =============================================================================
# Logarithmic Wind Profile Tests (Eq. 16.66)
# =============================================================================

@testitem "Logarithmic wind profile" setup=[LocalScaleSetup] begin
    # From Seinfeld & Pandis Eq. 16.66: ū(z) = (u*/κ)ln(z/z₀)

    sys = SurfaceLayerProfile()
    csys = mtkcompile(sys)

    # Test with neutral conditions (ψ_m ≈ 0)
    κ = 0.4  # von Karman constant
    u_star = 0.4  # m/s
    z₀ = 0.1  # m
    z = 10.0  # m

    # Expected neutral wind speed
    ū_expected = (u_star / κ) * log(z / z₀)

    prob = ODEProblem(csys, Dict(), (0.0, 1.0), Dict(
        csys.u_star => u_star,
        csys.z₀ => z₀,
        csys.z => z,
        csys.q_z => 1e-8,  # Nearly neutral
        csys.T₀ => 288.15,
        csys.ρ => 1.225
    ))
    sol = solve(prob)

    @test isapprox(sol[csys.ū][end], ū_expected, rtol=0.05)

    # Test with Wangara experiment values (p.745)
    # z₀ = 0.0015 m, u* = 0.4 m/s
    z₀_wangara = 0.0015  # m
    u_star_wangara = 0.4  # m/s
    z_test = 10.0  # m
    ū_wangara_expected = (u_star_wangara / κ) * log(z_test / z₀_wangara)

    prob_wangara = ODEProblem(csys, Dict(), (0.0, 1.0), Dict(
        csys.u_star => u_star_wangara,
        csys.z₀ => z₀_wangara,
        csys.z => z_test,
        csys.q_z => 1e-8,  # Neutral
        csys.T₀ => 288.15,
        csys.ρ => 1.225
    ))
    sol_wangara = solve(prob_wangara)
    @test isapprox(sol_wangara[csys.ū][end], ū_wangara_expected, rtol=0.05)
end

# =============================================================================
# Pasquill Stability Class Tests
# =============================================================================

@testitem "Pasquill stability classification" setup=[LocalScaleSetup] begin
    # Test that Pasquill classes are ordered correctly
    # Class A (most unstable, L negative large magnitude)
    # Class F (most stable, L positive)

    sys = LocalScaleMeteorology()
    csys = mtkcompile(sys)

    # Test 1: Very unstable conditions should give class near 1 (A)
    prob_A = ODEProblem(csys, Dict(), (0.0, 1.0), Dict(
        csys.u_star => 0.5,
        csys.q_z => 300.0,  # Strong upward heat flux
        csys.z₀ => 0.1,
        csys.T₀ => 300.0,
        csys.ρ => 1.225
    ))
    sol_A = solve(prob_A)
    @test sol_A[csys.L][end] < 0  # Unstable has negative L
    @test sol_A[csys.pasquill_class][end] <= 3  # Should be A, B, or C (1-3)

    # Test 2: Very stable conditions should give class near 6 (F)
    prob_F = ODEProblem(csys, Dict(), (0.0, 1.0), Dict(
        csys.u_star => 0.2,
        csys.q_z => -100.0,  # Strong downward heat flux
        csys.z₀ => 0.1,
        csys.T₀ => 280.0,
        csys.ρ => 1.225
    ))
    sol_F = solve(prob_F)
    @test sol_F[csys.L][end] > 0  # Stable has positive L
    @test sol_F[csys.pasquill_class][end] >= 4  # Should be D, E, or F (4-6)
end

# =============================================================================
# Limiting Behavior Tests
# =============================================================================

@testitem "Limiting behaviors" setup=[LocalScaleSetup] begin
    sys = SurfaceLayerProfile()
    csys = mtkcompile(sys)

    # Test 1: As |L| → ∞ (neutral), ψ_m → 0
    # Wind profile becomes purely logarithmic
    prob_neutral = ODEProblem(csys, Dict(), (0.0, 1.0), Dict(
        csys.u_star => 0.3,
        csys.q_z => 1e-10,  # Essentially zero heat flux
        csys.z => 10.0,
        csys.z₀ => 0.1,
        csys.T₀ => 288.15,
        csys.ρ => 1.225
    ))
    sol_neutral = solve(prob_neutral)
    @test isapprox(sol_neutral[csys.ψ_m][end], 0.0, atol=0.1)

    # Test 2: Wind speed increases with height
    z_low = 5.0
    z_high = 20.0

    prob_low = ODEProblem(csys, Dict(), (0.0, 1.0), Dict(
        csys.u_star => 0.3,
        csys.q_z => 1e-8,
        csys.z => z_low,
        csys.z₀ => 0.1,
        csys.T₀ => 288.15,
        csys.ρ => 1.225
    ))
    sol_low = solve(prob_low)

    prob_high = ODEProblem(csys, Dict(), (0.0, 1.0), Dict(
        csys.u_star => 0.3,
        csys.q_z => 1e-8,
        csys.z => z_high,
        csys.z₀ => 0.1,
        csys.T₀ => 288.15,
        csys.ρ => 1.225
    ))
    sol_high = solve(prob_high)

    @test sol_high[csys.ū][end] > sol_low[csys.ū][end]
end

# =============================================================================
# Physical Constraints Tests
# =============================================================================

@testitem "Physical constraints" setup=[LocalScaleSetup] begin
    sys = LocalScaleMeteorology()
    csys = mtkcompile(sys)

    # Test 1: Potential temperature is always positive
    prob = ODEProblem(csys, Dict(), (0.0, 1.0), Dict(
        csys.T => 200.0,  # Cold temperature
        csys.p => 50000.0  # Low pressure
    ))
    sol = solve(prob)
    @test sol[csys.θ][end] > 0

    # Test 2: Wind speed should be non-negative for typical conditions
    prob2 = ODEProblem(csys, Dict(), (0.0, 1.0), Dict(
        csys.u_star => 0.5,
        csys.z => 10.0,
        csys.z₀ => 0.1,
        csys.q_z => 50.0,
        csys.T₀ => 288.15,
        csys.ρ => 1.225
    ))
    sol2 = solve(prob2)
    @test sol2[csys.ū][end] > 0

    # Test 3: Stability functions φ should be positive
    sys_surf = SurfaceLayerProfile()
    csys_surf = mtkcompile(sys_surf)

    prob3 = ODEProblem(csys_surf, Dict(), (0.0, 1.0), Dict(
        csys_surf.u_star => 0.3,
        csys_surf.z => 10.0,
        csys_surf.q_z => 100.0,
        csys_surf.T₀ => 288.15,
        csys_surf.ρ => 1.225
    ))
    sol3 = solve(prob3)
    @test sol3[csys_surf.φ_m][end] > 0
    @test sol3[csys_surf.φ_h][end] > 0
end

# =============================================================================
# Unit Verification Tests
# =============================================================================

@testitem "Unit consistency" setup=[LocalScaleSetup] begin
    using ModelingToolkit: get_unit

    sys = LocalScaleMeteorology()
    vars = unknowns(sys)

    # Find specific variables and check their units
    for v in vars
        name = string(Symbol(v))
        unit = get_unit(v)

        # Check specific variables by exact name match
        if name == "θ(t)"
            @test unit == u"K"
        elseif name == "L(t)"
            @test unit == u"m"
        elseif name == "ū(t)"
            @test unit == u"m/s"
        elseif name == "dT_dz(t)" || name == "dθ_dz(t)"
            @test unit == u"K/m"
        elseif name == "L_inv(t)"
            @test unit == u"m^-1"
        end
    end
end
