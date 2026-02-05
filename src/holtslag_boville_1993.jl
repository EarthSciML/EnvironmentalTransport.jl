export HoltslagBovilleSurfaceFlux
export HoltslagBovilleLocalDiffusion
export HoltslagBovilleNonlocalABL

"""
    HoltslagBovilleSurfaceFlux(; name=:HoltslagBovilleSurfaceFlux)

Returns a `ModelingToolkit.System` that computes parameterized surface fluxes
for the atmospheric boundary layer following Holtslag & Boville (1993).

Based on "Local Versus Nonlocal Boundary-Layer Diffusion in a Global Climate Model"
by A.A.M. Holtslag and B.A. Boville, Journal of Climate, Volume 6, October 1993,
pp. 1825-1842.

Key equations implemented:

  - Eq. 2.1: Surface momentum flux for u: (w'u')₀ = -Cₘ|V₁|u₁
  - Eq. 2.2: Surface momentum flux for v: (w'v')₀ = -Cₘ|V₁|v₁
  - Eq. 2.3: Surface heat flux: (w'θ')₀ = Cₕ|V₁|(θ₀ - θ₁)
  - Eq. 2.4: Surface moisture flux: (w'q')₀ = DwCₕ|V₁|(q₀ - q₁)
  - Eq. 2.5-2.6: Exchange coefficients with stability functions
  - Eq. 2.7: Neutral exchange coefficient Cₙ
  - Eq. 2.8: Surface bulk Richardson number
  - Eq. 2.9-2.11: Stability functions fₘ and fₕ

Example:

```julia
using ModelingToolkit, EnvironmentalTransport

sf = HoltslagBovilleSurfaceFlux()
sys = mtkcompile(sf)
```
"""
@component function HoltslagBovilleSurfaceFlux(; name = :HoltslagBovilleSurfaceFlux)
    @constants begin
        g = 9.81, [description = "Gravitational acceleration", unit = u"m/s^2"]
        κ = 0.4, [description = "von Karman constant (dimensionless)", unit = u"1"]
        V_min_sq = 1.0, [description = "Minimum wind speed squared", unit = u"m^2/s^2"]
        zero_Ri = 0.0, [description = "Zero Richardson number for comparison", unit = u"1"]
    end

    @parameters begin
        z₁ = 10.0, [description = "Height of the lowest model level", unit = u"m"]
        z₀ₘ = 1e-4, [description = "Roughness length for momentum", unit = u"m"]
        u₁ = 1.0, [description = "Zonal wind at lowest level", unit = u"m/s"]
        v₁ = 0.0, [description = "Meridional wind at lowest level", unit = u"m/s"]
        θ₀ = 300.0, [description = "Potential temperature at surface", unit = u"K"]
        θ₁ = 299.0, [description = "Potential temperature at lowest level", unit = u"K"]
        θᵥ₀ = 300.0,
        [description = "Virtual potential temperature at surface", unit = u"K"]
        θᵥ₁ = 299.0,
        [description = "Virtual potential temperature at lowest level", unit = u"K"]
        q₀ = 0.01,
        [description = "Specific humidity at surface (dimensionless)", unit = u"1"]
        q₁ = 0.008,
        [description = "Specific humidity at lowest level (dimensionless)", unit = u"1"]
        Dw = 1.0,
        [description = "Water availability factor (dimensionless)", unit = u"1"]
    end

    @variables begin
        V₁(t), [description = "Horizontal wind speed at lowest level", unit = u"m/s"]
        Ri₀(t),
        [description = "Surface bulk Richardson number (Eq. 2.8) (dimensionless)",
            unit = u"1"]
        Cₙ(t),
        [description = "Neutral exchange coefficient (Eq. 2.7) (dimensionless)",
            unit = u"1"]
        fₘ(t),
        [description = "Momentum stability function (Eq. 2.9/2.11) (dimensionless)",
            unit = u"1"]
        fₕ(t),
        [description = "Heat stability function (Eq. 2.10/2.11) (dimensionless)",
            unit = u"1"]
        Cₘ(t),
        [description = "Momentum exchange coefficient (Eq. 2.5) (dimensionless)",
            unit = u"1"]
        Cₕ(t),
        [description = "Heat exchange coefficient (Eq. 2.6) (dimensionless)",
            unit = u"1"]
        wu₀(t),
        [description = "Surface momentum flux u-component (Eq. 2.1)",
            unit = u"m^2/s^2"]
        wv₀(t),
        [description = "Surface momentum flux v-component (Eq. 2.2)",
            unit = u"m^2/s^2"]
        wθ₀(t), [description = "Surface heat flux (Eq. 2.3)", unit = u"K*m/s"]
        wq₀(t), [description = "Surface moisture flux (Eq. 2.4)", unit = u"m/s"]
    end

    z_ratio = (z₁ + z₀ₘ) / z₀ₘ

    eqs = [
        # Wind magnitude with minimum threshold to prevent division by zero
        V₁ ~ sqrt(u₁^2 + v₁^2 + V_min_sq),

        # Eq. 2.7: Neutral exchange coefficient
        # Cₙ = κ²/[ln((z₁+z₀ₘ)/z₀ₘ)]²
        Cₙ ~ κ^2 / (log(z_ratio))^2,

        # Eq. 2.8: Surface bulk Richardson number
        # Ri₀ = gz₁(θᵥ₁ - θᵥ₀)/(θ₁|V₁|²)
        Ri₀ ~ g * z₁ * (θᵥ₁ - θᵥ₀) / (θ₁ * V₁^2),

        # Stability functions (Eq. 2.9-2.11)
        # Unstable (Ri₀ < 0): Eq. 2.9 from Louis et al. (1982)
        # fₘ = 1 - 10Ri₀ / {1 + 75Cₙ[(z₁+z₀ₘ)/z₀ₘ |Ri₀|]^(1/2)}
        # Stable (Ri₀ ≥ 0): Eq. 2.11 from Holtslag and Beljaars (1989)
        # fₘ = fₕ = 1 / (1 + 10Ri₀(1 + 8Ri₀))
        fₘ ~ ifelse(Ri₀ < zero_Ri,
            1 - 10 * Ri₀ / (1 + 75 * Cₙ * sqrt(z_ratio * abs(Ri₀))),
            1 / (1 + 10 * Ri₀ * (1 + 8 * Ri₀))),

        # Eq. 2.10: Heat stability function (unstable)
        # fₕ = 1 - 15Ri₀ / {1 + 75Cₙ[(z₁+z₀ₘ)/z₀ₘ |Ri₀|]^(1/2)}
        fₕ ~ ifelse(Ri₀ < zero_Ri,
            1 - 15 * Ri₀ / (1 + 75 * Cₙ * sqrt(z_ratio * abs(Ri₀))),
            1 / (1 + 10 * Ri₀ * (1 + 8 * Ri₀))),

        # Eq. 2.5-2.6: Exchange coefficients
        Cₘ ~ Cₙ * fₘ,
        Cₕ ~ Cₙ * fₕ,

        # Eq. 2.1-2.4: Surface fluxes (kinematic)
        wu₀ ~ -Cₘ * V₁ * u₁,
        wv₀ ~ -Cₘ * V₁ * v₁,
        wθ₀ ~ Cₕ * V₁ * (θ₀ - θ₁),
        wq₀ ~ Dw * Cₕ * V₁ * (q₀ - q₁)
    ]

    return System(eqs, t; name)
end

"""
    HoltslagBovilleLocalDiffusion(; name=:HoltslagBovilleLocalDiffusion)

Returns a `ModelingToolkit.System` implementing the local diffusion scheme
for the atmospheric boundary layer following Holtslag & Boville (1993).

Based on "Local Versus Nonlocal Boundary-Layer Diffusion in a Global Climate Model"
by A.A.M. Holtslag and B.A. Boville, Journal of Climate, Volume 6, October 1993,
pp. 1825-1842.

Key equations implemented:

  - Eq. 3.1: Local flux-gradient relation w'C' = -Kc ∂C/∂z
  - Eq. 3.2: Eddy diffusivity Kc = lc² S Fc(Ri)
  - Eq. 3.3: Local shear S = |∂V/∂z|
  - Eq. 3.4: Mixing length scale 1/lc = 1/(κz) + 1/λc
  - Eq. 3.5: Gradient Richardson number Ri = (g/θᵥ)(∂θᵥ/∂z)/S²
  - Eq. 3.6: Asymptotic length scale λc = 30 + 270·exp(1 - z/1000)
  - Eq. 3.7: Stability function for unstable: Fc = (1 - 18Ri)^(1/2)

Example:

```julia
using ModelingToolkit, EnvironmentalTransport

ld = HoltslagBovilleLocalDiffusion()
sys = mtkcompile(ld)
```
"""
@component function HoltslagBovilleLocalDiffusion(; name = :HoltslagBovilleLocalDiffusion)
    @constants begin
        g = 9.81, [description = "Gravitational acceleration", unit = u"m/s^2"]
        κ = 0.4, [description = "von Karman constant (dimensionless)", unit = u"1"]
        z_ref = 1000.0,
        [description = "Reference height for λc calculation (Eq. 3.6)", unit = u"m"]
        λ_min = 30.0,
        [description = "Free atmosphere asymptotic length scale (Eq. 3.6)", unit = u"m"]
        λ_range = 270.0,
        [description = "Range of asymptotic length scale (Eq. 3.6)", unit = u"m"]
        S_min = 1e-6, [description = "Minimum shear for regularization", unit = u"1/s"]
        zero_Ri = 0.0,
        [description = "Zero Richardson number for comparison", unit = u"1"]
    end

    @parameters begin
        z = 100.0, [description = "Height above surface", unit = u"m"]
        θᵥ = 300.0, [description = "Virtual potential temperature", unit = u"K"]
        ∂θᵥ_∂z = 0.003,
        [description = "Vertical gradient of virtual potential temperature",
            unit = u"K/m"]
        ∂u_∂z = 0.01,
        [description = "Vertical gradient of zonal wind", unit = u"1/s"]
        ∂v_∂z = 0.0,
        [description = "Vertical gradient of meridional wind", unit = u"1/s"]
    end

    @variables begin
        λc(t), [description = "Asymptotic length scale (Eq. 3.6)", unit = u"m"]
        lc(t), [description = "Mixing length scale (Eq. 3.4)", unit = u"m"]
        S(t), [description = "Local wind shear magnitude (Eq. 3.3)", unit = u"1/s"]
        Ri(t),
        [description = "Gradient Richardson number (Eq. 3.5) (dimensionless)",
            unit = u"1"]
        Fc(t),
        [description = "Stability function (Eq. 3.7/2.11) (dimensionless)", unit = u"1"]
        Kc(t), [description = "Eddy diffusivity (Eq. 3.2)", unit = u"m^2/s"]
    end

    eqs = [
        # Eq. 3.6: Asymptotic length scale
        # λc = 30 + 270·exp(1 - z/1000)
        λc ~ λ_min + λ_range * exp(1 - z / z_ref),

        # Eq. 3.4: Mixing length (harmonic interpolation)
        # 1/lc = 1/(κz) + 1/λc
        lc ~ 1 / (1 / (κ * z) + 1 / λc),

        # Eq. 3.3: Local shear magnitude
        S ~ sqrt(∂u_∂z^2 + ∂v_∂z^2) + S_min,

        # Eq. 3.5: Gradient Richardson number
        # Ri = (g/θᵥ)(∂θᵥ/∂z)/S²
        Ri ~ (g / θᵥ) * ∂θᵥ_∂z / S^2,

        # Stability function:
        # Unstable (Ri < 0): Eq. 3.7: Fc = (1 - 18Ri)^(1/2)
        # Stable (Ri ≥ 0): Eq. 2.11: Fc = 1/(1 + 10Ri(1 + 8Ri))
        Fc ~ ifelse(Ri < zero_Ri,
            sqrt(1 - 18 * Ri),
            1 / (1 + 10 * Ri * (1 + 8 * Ri))),

        # Eq. 3.2: Eddy diffusivity
        Kc ~ lc^2 * S * Fc
    ]

    return System(eqs, t; name)
end

"""
    HoltslagBovilleNonlocalABL(; name=:HoltslagBovilleNonlocalABL)

Returns a `ModelingToolkit.System` implementing the nonlocal atmospheric
boundary layer diffusion scheme following Holtslag & Boville (1993).

Based on "Local Versus Nonlocal Boundary-Layer Diffusion in a Global Climate Model"
by A.A.M. Holtslag and B.A. Boville, Journal of Climate, Volume 6, October 1993,
pp. 1825-1842.

Key equations implemented:

  - Eq. 3.8: Nonlocal flux w'C' = -Kc(∂C/∂z - γc)
  - Eq. 3.9: Eddy diffusivity Kc = κ·wₜ·z·(1 - z/h)²
  - Eq. 3.10: Nonlocal transport term γc = a·w*·(w'C')₀/(wₘ²·h)
  - Appendix A (Eq. A1-A14): Velocity scales wₜ and wₘ, φₘ and φₕ profiles

The nonlocal scheme accounts for transport by large convective eddies
in unstable conditions, which the local scheme cannot represent.

Example:

```julia
using ModelingToolkit, EnvironmentalTransport

nl = HoltslagBovilleNonlocalABL()
sys = mtkcompile(nl)
```
"""
@component function HoltslagBovilleNonlocalABL(; name = :HoltslagBovilleNonlocalABL)
    @constants begin
        g = 9.81, [description = "Gravitational acceleration", unit = u"m/s^2"]
        κ = 0.4, [description = "von Karman constant (dimensionless)", unit = u"1"]
        a_coeff = 7.2,
        [description = "Nonlocal transport constant (Eq. A14: a ≈ 7.2) (dimensionless)",
            unit = u"1"]
        c₁ = 0.6,
        [description = "Velocity scale constant (Eq. A11) (dimensionless)", unit = u"1"]
        ε_sl = 0.1,
        [description = "Surface layer fraction of boundary layer height (dimensionless)",
            unit = u"1"]
        w_ref = 1.0,
        [description = "Reference velocity scale for non-dimensionalization",
            unit = u"m/s"]
        zero_heat_flux = 0.0,
        [description = "Zero heat flux for comparison", unit = u"K*m/s"]
        zero_length = 0.0,
        [description = "Zero length for comparison", unit = u"m"]
        γc_zero = 0.0,
        [description = "Zero nonlocal transport term", unit = u"1/m"]
        zero_velocity = 0.0,
        [description = "Zero velocity for comparison", unit = u"m/s"]
        L_min = 1.0,
        [description = "Minimum absolute Obukhov length for regularization",
            unit = u"m"]
    end

    @parameters begin
        z = 100.0, [description = "Height above surface", unit = u"m"]
        h = 1000.0, [description = "Boundary layer height", unit = u"m"]
        u_star = 0.3, [description = "Friction velocity", unit = u"m/s"]
        wθᵥ₀ = 0.05, [description = "Surface virtual heat flux", unit = u"K*m/s"]
        wC₀ = 1e-5,
        [description = "Surface kinematic flux of scalar C (e.g. mixing ratio)",
            unit = u"m/s"]
        θᵥ₀ = 300.0,
        [description = "Virtual potential temperature at surface", unit = u"K"]
        L = -100.0, [description = "Obukhov length", unit = u"m"]
    end

    @variables begin
        w_star(t),
        [description = "Convective velocity scale (Eq. A12)", unit = u"m/s"]
        φₕ(t),
        [description = "Dimensionless temperature gradient at surface layer top (Eq. A3/A6) (dimensionless)",
            unit = u"1"]
        φₘ(t),
        [description = "Dimensionless wind shear at surface layer top (Eq. A2/A6) (dimensionless)",
            unit = u"1"]
        φₕ_local(t),
        [description = "Dimensionless temperature gradient at local height z (Eq. A3/A6) (dimensionless)",
            unit = u"1"]
        wₘ(t),
        [description = "Velocity scale for momentum (Eq. A11)", unit = u"m/s"]
        Pr(t),
        [description = "Turbulent Prandtl number (Eq. A13) (dimensionless)",
            unit = u"1"]
        wₜ(t),
        [description = "Velocity scale for scalars (Eq. A1/A10)", unit = u"m/s"]
        Kc(t), [description = "Eddy diffusivity (Eq. 3.9)", unit = u"m^2/s"]
        γc(t), [description = "Nonlocal transport term (Eq. 3.10)", unit = u"1/m"]
        ζ(t),
        [description = "Stability parameter z/L (dimensionless)", unit = u"1"]
        η(t), [description = "Relative height z/h (dimensionless)", unit = u"1"]
        ζ_ε(t),
        [description = "Stability parameter at surface layer top εh/L (dimensionless)",
            unit = u"1"]
    end

    eqs = [
        # Stability parameter: z/L (regularized to avoid division by zero)
        ζ ~ ifelse(abs(L) > L_min, z / L, z / (L_min * sign(L) + L_min * (1 - abs(sign(L))))),

        # Relative height: z/h
        η ~ z / h,

        # Stability parameter at surface layer top: εh/L
        ζ_ε ~ ifelse(abs(L) > L_min, ε_sl * h / L,
            ε_sl * h / (L_min * sign(L) + L_min * (1 - abs(sign(L))))),

        # Eq. A12: Convective velocity scale
        # w* = ((g/θᵥ₀)·(w'θᵥ')₀·h)^(1/3)
        # Non-dimensionalize before cube root, then re-dimensionalize
        w_star ~ ifelse(wθᵥ₀ > zero_heat_flux,
            ((g / θᵥ₀) * wθᵥ₀ * h / w_ref^3)^(1 / 3) * w_ref,
            zero_velocity),

        # Eq. A2/A4/A6: Dimensionless wind shear
        # Stable (L > 0): φₘ = 1 + 5z/L for 0 ≤ z/L ≤ 1 (Eq. A2)
        #                 φₘ = 5 + z/L for z/L > 1 (Eq. A4)
        # Unstable (L < 0): φₘ = (1 - 15z/L)^(-1/4) (Eq. A6)
        φₘ ~ ifelse(L > zero_length,
            ifelse(ζ_ε <= 1, 1 + 5 * ζ_ε, 5 + ζ_ε),
            ifelse(L < zero_length,
                1 / (1 - 15 * ζ_ε)^(1 / 4),
                1.0)),

        # Eq. A3/A5/A6: Dimensionless temperature gradient at surface layer top (for Pr, Eq. A13)
        # Stable (L > 0): φₕ = 1 + 5z/L for 0 ≤ z/L ≤ 1 (Eq. A3)
        #                 φₕ = 5 + z/L for z/L > 1 (Eq. A5)
        # Unstable (L < 0): φₕ = (1 - 15z/L)^(-1/2) (Eq. A6)
        φₕ ~ ifelse(L > zero_length,
            ifelse(ζ_ε <= 1, 1 + 5 * ζ_ε, 5 + ζ_ε),
            ifelse(L < zero_length,
                1 / sqrt(1 - 15 * ζ_ε),
                1.0)),

        # Eq. A3/A5/A6: Dimensionless temperature gradient at local height z (for wₜ in surface layer, Eq. A1)
        φₕ_local ~ ifelse(L > zero_length,
            ifelse(ζ <= 1, 1 + 5 * ζ, 5 + ζ),
            ifelse(L < zero_length,
                1 / sqrt(1 - 15 * ζ),
                1.0)),

        # Eq. A11: Momentum velocity scale (outer layer)
        # wₘ = (u*³ + c₁·w*³)^(1/3)
        # Non-dimensionalize before cube root
        wₘ ~ ((u_star / w_ref)^3 + c₁ * (w_star / w_ref)^3)^(1 / 3) * w_ref,

        # Eq. A13: Turbulent Prandtl number
        # Pr = φₕ(ε)/φₘ(ε) + a·κ·ε·(w*/wₘ)
        # where ε = 0.1h/L (evaluated at surface layer top)
        Pr ~ φₕ / φₘ + a_coeff * κ * ε_sl * (w_star / wₘ),

        # Eq. A1/A10: Scalar velocity scale
        # Surface layer (z/h ≤ ε): wₜ = u*/φₕ(z/L) (Eq. A1)
        # Outer layer (z/h > ε): wₜ = wₘ/Pr (Eq. A10)
        wₜ ~ ifelse(η <= ε_sl,
            u_star / φₕ_local,
            wₘ / Pr),

        # Eq. 3.9: Eddy diffusivity profile
        # Kc = κ·wₜ·z·(1 - z/h)²
        Kc ~ κ * wₜ * z * (1 - η)^2,

        # Eq. 3.10: Nonlocal transport term (only for unstable conditions)
        # γc = a·w*·(w'C')₀/(wₘ²·h)
        γc ~ ifelse(wθᵥ₀ > zero_heat_flux,
            a_coeff * w_star * wC₀ / (wₘ^2 * h),
            γc_zero)
    ]

    return System(eqs, t; name)
end
