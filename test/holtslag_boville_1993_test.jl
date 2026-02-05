@testsnippet HoltslagBoville1993Setup begin
    using Test
    using ModelingToolkit
    using ModelingToolkit: t, mtkcompile
    using EnvironmentalTransport
    using OrdinaryDiffEqDefault
    using DynamicQuantities
end

# =============================================================================
# Structural Tests
# =============================================================================

@testitem "SurfaceFlux structure" setup=[HoltslagBoville1993Setup] tags=[:holtslag] begin
    sf=HoltslagBovilleSurfaceFlux()
    @test sf isa ModelingToolkit.System

    eqs=equations(sf)
    @test length(eqs) == 11

    var_names=Symbol.(unknowns(sf))
    @test Symbol("V₁(t)") in var_names
    @test Symbol("Ri₀(t)") in var_names
    @test Symbol("Cₙ(t)") in var_names
    @test Symbol("fₘ(t)") in var_names
    @test Symbol("fₕ(t)") in var_names
    @test Symbol("Cₘ(t)") in var_names
    @test Symbol("Cₕ(t)") in var_names
    @test Symbol("wu₀(t)") in var_names
    @test Symbol("wv₀(t)") in var_names
    @test Symbol("wθ₀(t)") in var_names
    @test Symbol("wq₀(t)") in var_names

    param_names=Symbol.(parameters(sf))
    @test :z₁ in param_names
    @test :z₀ₘ in param_names
    @test :u₁ in param_names
    @test :v₁ in param_names
    @test :θ₀ in param_names
    @test :θ₁ in param_names
    @test :θᵥ₀ in param_names
    @test :θᵥ₁ in param_names
end

@testitem "LocalDiffusion structure" setup=[HoltslagBoville1993Setup] tags=[:holtslag] begin
    ld=HoltslagBovilleLocalDiffusion()
    @test ld isa ModelingToolkit.System

    eqs=equations(ld)
    @test length(eqs) == 6

    var_names=Symbol.(unknowns(ld))
    @test Symbol("λc(t)") in var_names
    @test Symbol("lc(t)") in var_names
    @test Symbol("S(t)") in var_names
    @test Symbol("Ri(t)") in var_names
    @test Symbol("Fc(t)") in var_names
    @test Symbol("Kc(t)") in var_names

    param_names=Symbol.(parameters(ld))
    @test :z in param_names
    @test :θᵥ in param_names
    @test :∂θᵥ_∂z in param_names
    @test :∂u_∂z in param_names
    @test :∂v_∂z in param_names
end

@testitem "NonlocalABL structure" setup=[HoltslagBoville1993Setup] tags=[:holtslag] begin
    nl=HoltslagBovilleNonlocalABL()
    @test nl isa ModelingToolkit.System

    eqs=equations(nl)
    @test length(eqs) == 12

    var_names=Symbol.(unknowns(nl))
    @test Symbol("w_star(t)") in var_names
    @test Symbol("φₕ(t)") in var_names
    @test Symbol("φₘ(t)") in var_names
    @test Symbol("φₕ_local(t)") in var_names
    @test Symbol("wₘ(t)") in var_names
    @test Symbol("Pr(t)") in var_names
    @test Symbol("wₜ(t)") in var_names
    @test Symbol("Kc(t)") in var_names
    @test Symbol("γc(t)") in var_names
    @test Symbol("ζ(t)") in var_names
    @test Symbol("η(t)") in var_names
    @test Symbol("ζ_ε(t)") in var_names

    param_names=Symbol.(parameters(nl))
    @test :z in param_names
    @test :h in param_names
    @test :u_star in param_names
    @test :wθᵥ₀ in param_names
    @test :wC₀ in param_names
    @test :θᵥ₀ in param_names
    @test :L in param_names
end

# =============================================================================
# Surface Flux Equation Verification
# =============================================================================

@testitem "SurfaceFlux neutral conditions" setup=[HoltslagBoville1993Setup] tags=[:holtslag] begin
    # Under neutral conditions (θᵥ₁ = θᵥ₀), Ri₀ = 0, so fₘ = fₕ = 1
    sf=HoltslagBovilleSurfaceFlux()
    csys=mtkcompile(sf)

    prob=ODEProblem(csys,
        Dict(
            csys.θᵥ₀=>300.0,
            csys.θᵥ₁=>300.0,
            csys.θ₀=>300.0,
            csys.θ₁=>300.0,
            csys.u₁=>5.0,
            csys.v₁=>0.0,
            csys.z₁=>10.0,
            csys.z₀ₘ=>0.1
        ),
        (0.0, 1.0))
    sol=solve(prob)

    # Ri₀ should be zero for neutral
    @test isapprox(sol[csys.Ri₀][end], 0.0, atol = 1e-10)

    # Stability functions should be 1 for neutral
    @test isapprox(sol[csys.fₘ][end], 1.0, rtol = 1e-6)
    @test isapprox(sol[csys.fₕ][end], 1.0, rtol = 1e-6)

    # Exchange coefficients should equal neutral value
    Cₙ=sol[csys.Cₙ][end]
    @test isapprox(sol[csys.Cₘ][end], Cₙ, rtol = 1e-6)
    @test isapprox(sol[csys.Cₕ][end], Cₙ, rtol = 1e-6)

    # Eq. 2.7: Verify neutral exchange coefficient
    # Cₙ = κ²/[ln((z₁+z₀ₘ)/z₀ₘ)]² = 0.4²/[ln(10.1/0.1)]² = 0.16/[4.615]² ≈ 0.00751
    z_ratio=(10.0+0.1)/0.1
    Cₙ_expected=0.4^2/(log(z_ratio))^2
    @test isapprox(Cₙ, Cₙ_expected, rtol = 1e-6)
end

@testitem "SurfaceFlux stable conditions" setup=[HoltslagBoville1993Setup] tags=[:holtslag] begin
    # Stable: θᵥ₁ > θᵥ₀ (warm air above cold surface), Ri₀ > 0
    sf=HoltslagBovilleSurfaceFlux()
    csys=mtkcompile(sf)

    prob=ODEProblem(csys,
        Dict(
            csys.θᵥ₀=>290.0,
            csys.θᵥ₁=>295.0,
            csys.θ₀=>290.0,
            csys.θ₁=>295.0,
            csys.u₁=>5.0,
            csys.v₁=>0.0,
            csys.z₁=>10.0,
            csys.z₀ₘ=>0.1
        ),
        (0.0, 1.0))
    sol=solve(prob)

    # Ri₀ > 0 for stable
    @test sol[csys.Ri₀][end] > 0

    # Stability functions < 1 for stable (suppressed mixing)
    @test sol[csys.fₘ][end] < 1.0
    @test sol[csys.fₕ][end] < 1.0
    @test sol[csys.fₘ][end] > 0.0
    @test sol[csys.fₕ][end] > 0.0

    # Eq. 2.11: fₘ = fₕ for stable conditions
    @test isapprox(sol[csys.fₘ][end], sol[csys.fₕ][end], rtol = 1e-6)

    # Surface heat flux should be negative (downward) for stable
    @test sol[csys.wθ₀][end] < 0
end

@testitem "SurfaceFlux unstable conditions" setup=[HoltslagBoville1993Setup] tags=[:holtslag] begin
    # Unstable: θᵥ₁ < θᵥ₀ (cold air above warm surface), Ri₀ < 0
    sf=HoltslagBovilleSurfaceFlux()
    csys=mtkcompile(sf)

    prob=ODEProblem(csys,
        Dict(
            csys.θᵥ₀=>305.0,
            csys.θᵥ₁=>300.0,
            csys.θ₀=>305.0,
            csys.θ₁=>300.0,
            csys.u₁=>5.0,
            csys.v₁=>0.0,
            csys.z₁=>10.0,
            csys.z₀ₘ=>0.1
        ),
        (0.0, 1.0))
    sol=solve(prob)

    # Ri₀ < 0 for unstable
    @test sol[csys.Ri₀][end] < 0

    # Stability functions > 1 for unstable (enhanced mixing)
    @test sol[csys.fₘ][end] > 1.0
    @test sol[csys.fₕ][end] > 1.0

    # Eq. 2.9-2.10: fₕ > fₘ for unstable (coefficient 15 > 10)
    @test sol[csys.fₕ][end] > sol[csys.fₘ][end]

    # Surface heat flux positive (upward) for unstable (warm surface)
    @test sol[csys.wθ₀][end] > 0
end

@testitem "SurfaceFlux momentum flux direction" setup=[HoltslagBoville1993Setup] tags=[:holtslag] begin
    # Eq. 2.1-2.2: Momentum flux opposes wind direction
    sf=HoltslagBovilleSurfaceFlux()
    csys=mtkcompile(sf)

    prob=ODEProblem(csys,
        Dict(
            csys.θᵥ₀=>300.0,
            csys.θᵥ₁=>300.0,
            csys.θ₀=>300.0,
            csys.θ₁=>300.0,
            csys.u₁=>5.0,
            csys.v₁=>3.0,
            csys.z₁=>10.0,
            csys.z₀ₘ=>0.1
        ),
        (0.0, 1.0))
    sol=solve(prob)

    # wu₀ should be negative (opposing positive u₁)
    @test sol[csys.wu₀][end] < 0
    # wv₀ should be negative (opposing positive v₁)
    @test sol[csys.wv₀][end] < 0
end

# =============================================================================
# Local Diffusion Equation Verification
# =============================================================================

@testitem "LocalDiffusion length scale Eq. 3.6" setup=[HoltslagBoville1993Setup] tags=[:holtslag] begin
    ld=HoltslagBovilleLocalDiffusion()
    csys=mtkcompile(ld)

    # At z = 1000 m: λc = 30 + 270·exp(0) = 300 m (paper states λc ≈ 300 m for z ≤ 1 km)
    prob=ODEProblem(csys,
        Dict(
            csys.z=>1000.0,
            csys.θᵥ=>300.0,
            csys.∂θᵥ_∂z=>0.003,
            csys.∂u_∂z=>0.01,
            csys.∂v_∂z=>0.0
        ),
        (0.0, 1.0))
    sol=solve(prob)
    @test isapprox(sol[csys.λc][end], 300.0, rtol = 0.01)

    # At z = 5000 m: λc = 30 + 270·exp(-4) ≈ 34.9 m (approaches 30 m)
    prob2=ODEProblem(csys,
        Dict(
            csys.z=>5000.0,
            csys.θᵥ=>300.0,
            csys.∂θᵥ_∂z=>0.003,
            csys.∂u_∂z=>0.01,
            csys.∂v_∂z=>0.0
        ),
        (0.0, 1.0))
    sol2=solve(prob2)
    λc_expected=30+270*exp(-4)
    @test isapprox(sol2[csys.λc][end], λc_expected, rtol = 0.01)
end

@testitem "LocalDiffusion mixing length Eq. 3.4" setup=[HoltslagBoville1993Setup] tags=[:holtslag] begin
    ld=HoltslagBovilleLocalDiffusion()
    csys=mtkcompile(ld)

    # At z = 1000 m with λc ≈ 300: lc = 1/(1/(0.4*1000) + 1/300) ≈ 1/(0.0025 + 0.00333)
    # = 1/0.00583 ≈ 171.4 m. Paper states lc reaches max ~290 m near z = 1 km.
    prob=ODEProblem(csys,
        Dict(
            csys.z=>1000.0,
            csys.θᵥ=>300.0,
            csys.∂θᵥ_∂z=>0.003,
            csys.∂u_∂z=>0.01,
            csys.∂v_∂z=>0.0
        ),
        (0.0, 1.0))
    sol=solve(prob)

    κ=0.4
    λc=sol[csys.λc][end]
    lc_expected=1/(1/(κ*1000)+1/λc)
    @test isapprox(sol[csys.lc][end], lc_expected, rtol = 1e-6)
    @test sol[csys.lc][end] > 0
end

@testitem "LocalDiffusion stable vs unstable" setup=[HoltslagBoville1993Setup] tags=[:holtslag] begin
    ld=HoltslagBovilleLocalDiffusion()
    csys=mtkcompile(ld)

    # Stable: positive ∂θᵥ/∂z gives positive Ri, Fc < 1
    prob_stable=ODEProblem(csys,
        Dict(
            csys.z=>500.0,
            csys.θᵥ=>300.0,
            csys.∂θᵥ_∂z=>0.01,
            csys.∂u_∂z=>0.01,
            csys.∂v_∂z=>0.0
        ),
        (0.0, 1.0))
    sol_stable=solve(prob_stable)
    @test sol_stable[csys.Ri][end] > 0
    @test sol_stable[csys.Fc][end] < 1.0
    @test sol_stable[csys.Fc][end] > 0.0
    @test sol_stable[csys.Kc][end] > 0.0

    # Unstable: negative ∂θᵥ/∂z gives negative Ri, Fc > 1 (Eq. 3.7)
    prob_unstable=ODEProblem(csys,
        Dict(
            csys.z=>500.0,
            csys.θᵥ=>300.0,
            csys.∂θᵥ_∂z=>-0.01,
            csys.∂u_∂z=>0.01,
            csys.∂v_∂z=>0.0
        ),
        (0.0, 1.0))
    sol_unstable=solve(prob_unstable)
    @test sol_unstable[csys.Ri][end] < 0
    @test sol_unstable[csys.Fc][end] > 1.0

    # Unstable Kc should be larger than stable Kc
    @test sol_unstable[csys.Kc][end] > sol_stable[csys.Kc][end]
end

# =============================================================================
# Nonlocal ABL Equation Verification
# =============================================================================

@testitem "NonlocalABL convective velocity scale Eq. A12" setup=[HoltslagBoville1993Setup] tags=[:holtslag] begin
    nl=HoltslagBovilleNonlocalABL()
    csys=mtkcompile(nl)

    # Typical unstable conditions: wθᵥ₀ = 0.1 K·m/s, h = 1000 m
    # w* = ((9.81/300)*0.1*1000)^(1/3) = (3.27)^(1/3) ≈ 1.485 m/s
    prob=ODEProblem(csys,
        Dict(
            csys.z=>500.0,
            csys.h=>1000.0,
            csys.u_star=>0.3,
            csys.wθᵥ₀=>0.1,
            csys.wC₀=>1e-5,
            csys.θᵥ₀=>300.0,
            csys.L=>-100.0
        ),
        (0.0, 1.0))
    sol=solve(prob)

    w_star_expected=((9.81/300.0)*0.1*1000.0)^(1/3)
    @test isapprox(sol[csys.w_star][end], w_star_expected, rtol = 0.01)
    @test 1.0 < sol[csys.w_star][end] < 2.0
end

@testitem "NonlocalABL momentum velocity scale Eq. A11" setup=[HoltslagBoville1993Setup] tags=[:holtslag] begin
    nl=HoltslagBovilleNonlocalABL()
    csys=mtkcompile(nl)

    prob=ODEProblem(csys,
        Dict(
            csys.z=>500.0,
            csys.h=>1000.0,
            csys.u_star=>0.3,
            csys.wθᵥ₀=>0.1,
            csys.wC₀=>1e-5,
            csys.θᵥ₀=>300.0,
            csys.L=>-100.0
        ),
        (0.0, 1.0))
    sol=solve(prob)

    # Eq. A11: wₘ = (u*³ + c₁·w*³)^(1/3)
    w_star=sol[csys.w_star][end]
    wₘ_expected=(0.3^3+0.6*w_star^3)^(1/3)
    @test isapprox(sol[csys.wₘ][end], wₘ_expected, rtol = 0.01)

    # wₘ ≥ u* always
    @test sol[csys.wₘ][end] >= 0.3
end

@testitem "NonlocalABL eddy diffusivity profile Eq. 3.9" setup=[HoltslagBoville1993Setup] tags=[:holtslag] begin
    nl=HoltslagBovilleNonlocalABL()
    csys=mtkcompile(nl)

    h=1000.0

    # Test profile shape: Kc = κ·wₜ·z·(1-z/h)²
    # Should be zero at z=0 and z=h, with maximum around z ≈ h/3

    # Near the surface
    prob_low=ODEProblem(csys,
        Dict(
            csys.z=>50.0,
            csys.h=>h,
            csys.u_star=>0.3,
            csys.wθᵥ₀=>0.1,
            csys.wC₀=>1e-5,
            csys.θᵥ₀=>300.0,
            csys.L=>-100.0
        ),
        (0.0, 1.0))
    sol_low=solve(prob_low)

    # Mid-height (z ≈ h/3)
    prob_mid=ODEProblem(csys,
        Dict(
            csys.z=>333.0,
            csys.h=>h,
            csys.u_star=>0.3,
            csys.wθᵥ₀=>0.1,
            csys.wC₀=>1e-5,
            csys.θᵥ₀=>300.0,
            csys.L=>-100.0
        ),
        (0.0, 1.0))
    sol_mid=solve(prob_mid)

    # Near the top
    prob_high=ODEProblem(csys,
        Dict(
            csys.z=>900.0,
            csys.h=>h,
            csys.u_star=>0.3,
            csys.wθᵥ₀=>0.1,
            csys.wC₀=>1e-5,
            csys.θᵥ₀=>300.0,
            csys.L=>-100.0
        ),
        (0.0, 1.0))
    sol_high=solve(prob_high)

    # Mid-height should have highest Kc
    @test sol_mid[csys.Kc][end] > sol_low[csys.Kc][end]
    @test sol_mid[csys.Kc][end] > sol_high[csys.Kc][end]

    # All Kc values should be positive
    @test sol_low[csys.Kc][end] > 0
    @test sol_mid[csys.Kc][end] > 0
    @test sol_high[csys.Kc][end] > 0

    # Paper Fig 8: typical max Kc ≈ 30-60 m²/s for h = 1000 m
    @test 5.0 < sol_mid[csys.Kc][end] < 200.0
end

@testitem "NonlocalABL Prandtl number Eq. A13" setup=[HoltslagBoville1993Setup] tags=[:holtslag] begin
    nl=HoltslagBovilleNonlocalABL()
    csys=mtkcompile(nl)

    # Eq. A13: Pr = φₕ(ε)/φₘ(ε) + a·κ·ε·(w*/wₘ)
    # where ε = 0.1h/L (evaluated at surface layer top)

    # Near-neutral conditions: small heat flux, w* ≈ 0, so Pr ≈ φₕ/φₘ ≈ 1
    prob_neutral=ODEProblem(csys,
        Dict(
            csys.z=>500.0,
            csys.h=>1000.0,
            csys.u_star=>1.0,
            csys.wθᵥ₀=>0.001,
            csys.wC₀=>1e-5,
            csys.θᵥ₀=>300.0,
            csys.L=>-10000.0
        ),
        (0.0, 1.0))
    sol_neutral=solve(prob_neutral)
    # For large negative L, ε = 0.1*1000/(-10000) = -0.01 → φₕ/φₘ ≈ 1
    # w* is very small → second term ≈ 0 → Pr ≈ 1
    @test isapprox(sol_neutral[csys.Pr][end], 1.0, atol = 0.15)

    # Verify Pr > 0 (physical requirement)
    @test sol_neutral[csys.Pr][end] > 0

    # Unstable conditions: Pr should include convective contribution
    prob_unstable=ODEProblem(csys,
        Dict(
            csys.z=>500.0,
            csys.h=>1000.0,
            csys.u_star=>0.3,
            csys.wθᵥ₀=>0.1,
            csys.wC₀=>1e-5,
            csys.θᵥ₀=>300.0,
            csys.L=>-100.0
        ),
        (0.0, 1.0))
    sol_unstable=solve(prob_unstable)

    # Verify Prandtl number matches Eq. A13 formula
    w_star=sol_unstable[csys.w_star][end]
    wₘ=sol_unstable[csys.wₘ][end]
    φₕ_val=sol_unstable[csys.φₕ][end]
    φₘ_val=sol_unstable[csys.φₘ][end]
    Pr_expected=φₕ_val/φₘ_val + 7.2*0.4*0.1*(w_star/wₘ)
    @test isapprox(sol_unstable[csys.Pr][end], Pr_expected, rtol = 0.01)
    @test sol_unstable[csys.Pr][end] > 0
end

@testitem "NonlocalABL nonlocal transport term Eq. 3.10" setup=[HoltslagBoville1993Setup] tags=[:holtslag] begin
    nl=HoltslagBovilleNonlocalABL()
    csys=mtkcompile(nl)

    # Unstable: γc should be positive when wC₀ > 0
    prob_unstable=ODEProblem(csys,
        Dict(
            csys.z=>500.0,
            csys.h=>1000.0,
            csys.u_star=>0.3,
            csys.wθᵥ₀=>0.1,
            csys.wC₀=>1e-4,
            csys.θᵥ₀=>300.0,
            csys.L=>-100.0
        ),
        (0.0, 1.0))
    sol_unstable=solve(prob_unstable)
    @test sol_unstable[csys.γc][end] > 0

    # Stable: γc should be zero
    prob_stable=ODEProblem(csys,
        Dict(
            csys.z=>500.0,
            csys.h=>1000.0,
            csys.u_star=>0.3,
            csys.wθᵥ₀=>-0.05,
            csys.wC₀=>1e-4,
            csys.θᵥ₀=>300.0,
            csys.L=>100.0
        ),
        (0.0, 1.0))
    sol_stable=solve(prob_stable)
    @test isapprox(sol_stable[csys.γc][end], 0.0, atol = 1e-10)
end

@testitem "NonlocalABL phi_h and phi_m Eq. A2-A6" setup=[HoltslagBoville1993Setup] tags=[:holtslag] begin
    nl=HoltslagBovilleNonlocalABL()
    csys=mtkcompile(nl)

    # φₕ and φₘ are now evaluated at ζ_ε = εh/L where ε = 0.1
    # Stable case: L = 100, h = 1000 → ζ_ε = 0.1*1000/100 = 1.0
    # At ζ_ε = 1: φₕ = 1 + 5*1.0 = 6.0 (Eq. A3)
    # φₘ = 1 + 5*1.0 = 6.0 (Eq. A2)
    prob=ODEProblem(csys,
        Dict(
            csys.z=>50.0,
            csys.h=>1000.0,
            csys.u_star=>0.3,
            csys.wθᵥ₀=>-0.05,
            csys.wC₀=>1e-5,
            csys.θᵥ₀=>300.0,
            csys.L=>100.0
        ),
        (0.0, 1.0))
    sol=solve(prob)
    @test isapprox(sol[csys.φₕ][end], 6.0, rtol = 0.01)
    @test isapprox(sol[csys.φₘ][end], 6.0, rtol = 0.01)

    # Very stable: L = 50, h = 1000 → ζ_ε = 0.1*1000/50 = 2.0 > 1
    # φₕ = 5 + 2.0 = 7.0 (Eq. A5)
    # φₘ = 5 + 2.0 = 7.0 (Eq. A4)
    prob2=ODEProblem(csys,
        Dict(
            csys.z=>50.0,
            csys.h=>1000.0,
            csys.u_star=>0.3,
            csys.wθᵥ₀=>-0.05,
            csys.wC₀=>1e-5,
            csys.θᵥ₀=>300.0,
            csys.L=>50.0
        ),
        (0.0, 1.0))
    sol2=solve(prob2)
    @test isapprox(sol2[csys.φₕ][end], 7.0, rtol = 0.01)
    @test isapprox(sol2[csys.φₘ][end], 7.0, rtol = 0.01)

    # Unstable case: L = -100, h = 1000 → ζ_ε = 0.1*1000/(-100) = -1.0
    # φₕ = (1 - 15*(-1.0))^(-1/2) = (16)^(-1/2) = 0.25 (Eq. A6)
    # φₘ = (1 - 15*(-1.0))^(-1/4) = (16)^(-1/4) = 0.5 (Eq. A6)
    prob3=ODEProblem(csys,
        Dict(
            csys.z=>50.0,
            csys.h=>1000.0,
            csys.u_star=>0.3,
            csys.wθᵥ₀=>0.1,
            csys.wC₀=>1e-5,
            csys.θᵥ₀=>300.0,
            csys.L=>-100.0
        ),
        (0.0, 1.0))
    sol3=solve(prob3)
    @test isapprox(sol3[csys.φₕ][end], 0.25, rtol = 0.01)
    @test isapprox(sol3[csys.φₘ][end], 0.5, rtol = 0.01)
end

@testitem "NonlocalABL phi_h_local vs phi_h Eq. A1" setup=[HoltslagBoville1993Setup] tags=[:holtslag] begin
    nl=HoltslagBovilleNonlocalABL()
    csys=mtkcompile(nl)

    # φₕ is evaluated at ζ_ε = εh/L (surface layer top), for use in Prandtl number (Eq. A13)
    # φₕ_local is evaluated at ζ = z/L (local height), for use in surface layer wₜ (Eq. A1)
    # When z ≠ εh, they should differ

    # Unstable: L = -200, h = 1000, z = 50
    # ζ_ε = 0.1*1000/(-200) = -0.5 → φₕ = (1 - 15*(-0.5))^(-1/2) = (8.5)^(-0.5)
    # ζ = 50/(-200) = -0.25 → φₕ_local = (1 - 15*(-0.25))^(-1/2) = (4.75)^(-0.5)
    prob=ODEProblem(csys,
        Dict(
            csys.z=>50.0,
            csys.h=>1000.0,
            csys.u_star=>0.3,
            csys.wθᵥ₀=>0.1,
            csys.wC₀=>1e-5,
            csys.θᵥ₀=>300.0,
            csys.L=>-200.0
        ),
        (0.0, 1.0))
    sol=solve(prob)

    φₕ_at_ε_expected = 1 / sqrt(1 - 15 * (-0.5))
    φₕ_local_expected = 1 / sqrt(1 - 15 * (-0.25))
    @test isapprox(sol[csys.φₕ][end], φₕ_at_ε_expected, rtol = 0.01)
    @test isapprox(sol[csys.φₕ_local][end], φₕ_local_expected, rtol = 0.01)

    # They should differ because z ≠ εh
    @test !isapprox(sol[csys.φₕ][end], sol[csys.φₕ_local][end], rtol = 0.01)
end

@testitem "NonlocalABL constants match paper" setup=[HoltslagBoville1993Setup] tags=[:holtslag] begin
    nl=HoltslagBovilleNonlocalABL()

    defaults=ModelingToolkit.get_defaults(nl)
    const_names=Dict(string(k)=>v for (k, v) in defaults)

    # κ = 0.4 (von Karman constant)
    κ_key=findfirst(k->contains(k, "κ"), collect(keys(const_names)))
    @test κ_key !== nothing
    @test isapprox(const_names[collect(keys(const_names))[κ_key]], 0.4, rtol = 0.01)

    # c₁ = 0.6 (Eq. A11)
    c1_key=findfirst(k->contains(k, "c₁"), collect(keys(const_names)))
    @test c1_key !== nothing
    @test isapprox(const_names[collect(keys(const_names))[c1_key]], 0.6, rtol = 0.01)

    # a_coeff = 7.2 (Eq. A14)
    a_key=findfirst(k->contains(k, "a_coeff"), collect(keys(const_names)))
    @test a_key !== nothing
    @test isapprox(const_names[collect(keys(const_names))[a_key]], 7.2, rtol = 0.01)

    # ε_sl = 0.1 (surface layer fraction)
    ε_key=findfirst(k->contains(k, "ε_sl"), collect(keys(const_names)))
    @test ε_key !== nothing
    @test isapprox(const_names[collect(keys(const_names))[ε_key]], 0.1, rtol = 0.01)
end
