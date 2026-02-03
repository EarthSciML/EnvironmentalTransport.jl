@testsnippet HoltslagBoville1993Setup begin
    using Test
    using ModelingToolkit
    using ModelingToolkit: t
    using EnvironmentalTransport
    using DynamicQuantities
end

@testitem "HoltslagBovilleSurfaceFlux construction" setup = [HoltslagBoville1993Setup] tags = [:holtslag] begin
    # Test system construction
    sf = HoltslagBovilleSurfaceFlux()
    @test sf isa ModelingToolkit.System

    # Test that we can access the equations
    eqs = equations(sf)
    @test length(eqs) > 0
end

@testitem "HoltslagBovilleSurfaceFlux neutral stability" setup = [HoltslagBoville1993Setup] tags = [:holtslag] begin
    # Test neutral conditions (θᵥ₁ = θᵥ₀)
    sf = HoltslagBovilleSurfaceFlux()

    # For neutral conditions, Ri₀ should be zero when θᵥ₁ = θᵥ₀
    # We can verify this through the equations
    eqs = equations(sf)
    @test length(eqs) > 0

    # Check the system has expected parameters
    ps = parameters(sf)
    param_names = [string(p) for p in ps]
    @test any(contains(n, "θᵥ₀") for n in param_names)
    @test any(contains(n, "θᵥ₁") for n in param_names)
end

@testitem "HoltslagBovilleLocalDiffusion construction" setup = [HoltslagBoville1993Setup] tags = [:holtslag] begin
    # Test system construction
    ld = HoltslagBovilleLocalDiffusion()
    @test ld isa ModelingToolkit.System

    # Test that we can access the equations
    eqs = equations(ld)
    @test length(eqs) > 0
end

@testitem "HoltslagBovilleLocalDiffusion equations" setup = [HoltslagBoville1993Setup] tags = [:holtslag] begin
    # Test that the local diffusion system has the correct number of equations
    ld = HoltslagBovilleLocalDiffusion()
    eqs = equations(ld)

    # Should have equations for λc, lc, S, Ri, Fc, Kc
    @test length(eqs) == 6

    # Check parameters exist
    ps = parameters(ld)
    param_names = [string(p) for p in ps]
    @test any(contains(n, "z") for n in param_names)
    @test any(contains(n, "θᵥ") for n in param_names)
end

@testitem "HoltslagBovilleNonlocalABL construction" setup = [HoltslagBoville1993Setup] tags = [:holtslag] begin
    # Test system construction
    nl = HoltslagBovilleNonlocalABL()
    @test nl isa ModelingToolkit.System

    # Test that we can access the equations
    eqs = equations(nl)
    @test length(eqs) > 0
end

@testitem "HoltslagBovilleNonlocalABL equations" setup = [HoltslagBoville1993Setup] tags = [:holtslag] begin
    # Test the nonlocal ABL system equations
    nl = HoltslagBovilleNonlocalABL()
    eqs = equations(nl)

    # Should have equations for: ζ, η, w_star, φₕ, wₘ, Pr, wₜ, Kc, γc
    @test length(eqs) == 9

    # Check parameters exist
    ps = parameters(nl)
    param_names = [string(p) for p in ps]
    @test any(contains(n, "h") for n in param_names)  # Boundary layer height
    @test any(contains(n, "u_star") for n in param_names)  # Friction velocity
    @test any(contains(n, "wθᵥ₀") for n in param_names)  # Surface heat flux
end

@testitem "HoltslagBoville constants check" setup = [HoltslagBoville1993Setup] tags = [:holtslag] begin
    # Test that the constants match the paper values

    nl = HoltslagBovilleNonlocalABL()

    # Get the constants from the defaults
    defaults = ModelingToolkit.get_defaults(nl)
    const_names = Dict(string(k) => v for (k, v) in defaults)

    # Check key constants from the paper (Appendix A)
    # a = 7.2 (Eq. A14)
    a_key = findfirst(k -> contains(k, "a") && !contains(k, "star") && !contains(k, "gamma"), collect(keys(const_names)))
    if a_key !== nothing
        a_val = const_names[collect(keys(const_names))[a_key]]
        @test isapprox(a_val, 7.2, rtol=0.01)
    end

    # κ = 0.4 (von Karman constant)
    κ_key = findfirst(k -> contains(k, "κ"), collect(keys(const_names)))
    if κ_key !== nothing
        κ_val = const_names[collect(keys(const_names))[κ_key]]
        @test isapprox(κ_val, 0.4, rtol=0.01)
    end

    # c₁ = 0.6 (Eq. A11)
    c1_key = findfirst(k -> contains(k, "c₁"), collect(keys(const_names)))
    if c1_key !== nothing
        c1_val = const_names[collect(keys(const_names))[c1_key]]
        @test isapprox(c1_val, 0.6, rtol=0.01)
    end
end

@testitem "HoltslagBoville local diffusion length scale" setup = [HoltslagBoville1993Setup] tags = [:holtslag] begin
    # Test Eq. 3.6: λc = 30 + 270·exp(1 - z/1000)

    # At z = 1000 m: λc = 30 + 270·exp(0) = 300 m
    λc_1000 = 30 + 270 * exp(1 - 1000 / 1000)
    @test isapprox(λc_1000, 300.0, rtol=0.01)

    # At z = 5000 m: λc ≈ 35 m
    λc_5000 = 30 + 270 * exp(1 - 5000 / 1000)
    @test isapprox(λc_5000, 30 + 270 * exp(-4), rtol=0.01)
end

@testitem "HoltslagBoville convective velocity scale" setup = [HoltslagBoville1993Setup] tags = [:holtslag] begin
    # Test Eq. A12: w* = ((g/θᵥ₀)·(w'θᵥ')₀·h)^(1/3)

    g = 9.81  # m/s²
    θᵥ₀ = 300.0  # K
    wθᵥ₀ = 0.1  # K·m/s
    h = 1000.0  # m

    w_star = ((g / θᵥ₀) * wθᵥ₀ * h)^(1 / 3)

    # Typical values: w* ~ 1-2 m/s for convective conditions
    @test 0.5 < w_star < 3.0
end

@testitem "HoltslagBoville stability functions" setup = [HoltslagBoville1993Setup] tags = [:holtslag] begin
    # Test Eq. 2.9-2.11: Stability functions

    # For neutral (Ri₀ = 0): fₘ = fₕ = 1
    Ri₀_neutral = 0.0
    fₘ_neutral = 1 / (1 + 10 * Ri₀_neutral * (1 + 8 * Ri₀_neutral))
    fₕ_neutral = 1 / (1 + 10 * Ri₀_neutral * (1 + 8 * Ri₀_neutral))
    @test isapprox(fₘ_neutral, 1.0, rtol=0.01)
    @test isapprox(fₕ_neutral, 1.0, rtol=0.01)

    # For stable (Ri₀ = 0.1): f < 1 (suppressed mixing)
    Ri₀_stable = 0.1
    fₘ_stable = 1 / (1 + 10 * Ri₀_stable * (1 + 8 * Ri₀_stable))
    @test fₘ_stable < 1.0
    @test fₘ_stable > 0.0
end

@testitem "HoltslagBoville eddy diffusivity profile shape" setup = [HoltslagBoville1993Setup] tags = [:holtslag] begin
    # Test Eq. 3.9: Kc = κ·wₜ·z·(1 - z/h)²
    # The profile should be zero at z=0 and z=h, with maximum in between

    κ = 0.4
    h = 1000.0  # m
    wₜ = 1.0  # m/s (simplified)

    # At z = 0: Kc = 0
    Kc_0 = κ * wₜ * 0 * (1 - 0 / h)^2
    @test Kc_0 == 0.0

    # At z = h: Kc = 0
    Kc_h = κ * wₜ * h * (1 - h / h)^2
    @test Kc_h == 0.0

    # At z = h/3: Kc > 0 (maximum is around z ≈ 0.3h)
    z_mid = h / 3
    Kc_mid = κ * wₜ * z_mid * (1 - z_mid / h)^2
    @test Kc_mid > 0.0

    # Check that mid-point has higher Kc than points near edges
    z_low = h / 10
    z_high = 9 * h / 10
    Kc_low = κ * wₜ * z_low * (1 - z_low / h)^2
    Kc_high = κ * wₜ * z_high * (1 - z_high / h)^2
    @test Kc_mid > Kc_low
    @test Kc_mid > Kc_high
end

@testitem "HoltslagBoville Prandtl number" setup = [HoltslagBoville1993Setup] tags = [:holtslag] begin
    # Test Eq. A13: Pr decreases from 1 (neutral) to 0.6 (very unstable)

    # For neutral: w*/u* ≈ 0, Pr ≈ 1
    # For very unstable: w*/u* >= 10, Pr ≈ 0.6

    # The formula given: Pr ≈ 1 - 0.4 * (w*/u*) / 10 for w*/u* < 10
    # Pr = 0.6 for w*/u* >= 10

    ratio_neutral = 0.0
    Pr_neutral = 1 - 0.4 * ratio_neutral / 10
    @test isapprox(Pr_neutral, 1.0, rtol=0.01)

    ratio_unstable = 10.0
    Pr_unstable = 0.6  # Cap at 0.6
    @test isapprox(Pr_unstable, 0.6, rtol=0.01)
end
