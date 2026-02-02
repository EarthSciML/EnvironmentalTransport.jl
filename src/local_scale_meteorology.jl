export LocalScaleMeteorology
export SurfaceLayerProfile
export AtmosphericStability

"""
    AtmosphericStability(; name=:AtmosphericStability)

Returns a `ModelingToolkit.System` that computes atmospheric stability parameters
including potential temperature, dry adiabatic lapse rate, and stability classification.

Based on Chapter 16 "Meteorology of the Local Scale" from Seinfeld & Pandis (2006)
"Atmospheric Chemistry and Physics", 2nd Edition, pp. 720-760.

Key equations implemented:
- Eq. 16.8: Dry adiabatic lapse rate Γ = g/ĉ_p ≈ 9.76 K/km
- Eq. 16.14: Potential temperature θ = T(p₀/p)^(R/ĉ_p)
- Eq. 16.16-16.18: Stability classification based on ∂θ/∂z

The stability parameter S indicates:
- S > 0: Stable atmosphere (∂θ/∂z > 0)
- S = 0: Neutral atmosphere (∂θ/∂z = 0)
- S < 0: Unstable atmosphere (∂θ/∂z < 0)

Example:
```julia
using ModelingToolkit, EnvironmentalTransport

stab = AtmosphericStability()
sys = mtkcompile(stab)
```
"""
function AtmosphericStability(; name=:AtmosphericStability)
    @constants begin
        # Physical constants from Seinfeld & Pandis Ch. 16
        g = 9.807, [description = "Gravitational acceleration", unit = u"m/s^2"]
        ĉ_p = 1005.0, [description = "Specific heat of air at constant pressure", unit = u"J/(kg*K)"]
        R_air = 287.0, [description = "Gas constant for dry air", unit = u"J/(kg*K)"]
        p₀ = 101325.0, [description = "Reference pressure (sea level)", unit = u"Pa"]
        Γ_d = 9.76e-3, [description = "Dry adiabatic lapse rate (Eq. 16.8: g/ĉ_p)", unit = u"K/m"]
    end

    @parameters begin
        T = 288.15, [description = "Air temperature at height z", unit = u"K"]
        T_below = 288.15, [description = "Air temperature at height z - Δz", unit = u"K"]
        p = 101325.0, [description = "Pressure at height z", unit = u"Pa"]
        Δz = 100.0, [description = "Vertical spacing for gradient calculation", unit = u"m"]
    end

    @variables begin
        θ(t), [description = "Potential temperature (Eq. 16.14)", unit = u"K"]
        dT_dz(t), [description = "Actual temperature lapse rate", unit = u"K/m"]
        dθ_dz(t), [description = "Potential temperature gradient", unit = u"K/m"]
        S(t), [description = "Stability parameter (>0 stable, <0 unstable, =0 neutral)", unit = u"K/m"]
    end

    # Exponent for potential temperature: R/ĉ_p ≈ 0.286
    κ_exp = R_air / ĉ_p

    eqs = [
        # Eq. 16.14: Potential temperature
        θ ~ T * (p₀ / p)^κ_exp,

        # Actual lapse rate (negative when temperature decreases with height)
        dT_dz ~ (T - T_below) / Δz,

        # Eq. 16.16-16.18: Stability based on potential temperature gradient
        # dθ/dz ≈ dT/dz + Γ_d (linearized for small changes)
        dθ_dz ~ dT_dz + Γ_d,

        # Stability parameter: positive = stable, negative = unstable
        S ~ dθ_dz,
    ]

    System(eqs, t; name)
end

"""
    SurfaceLayerProfile(; name=:SurfaceLayerProfile)

Returns a `ModelingToolkit.System` implementing Monin-Obukhov similarity theory
for the atmospheric surface layer, including logarithmic wind profiles and
stability corrections.

Based on Chapter 16 "Meteorology of the Local Scale" from Seinfeld & Pandis (2006)
"Atmospheric Chemistry and Physics", 2nd Edition, pp. 720-760.

Key equations implemented:
- Eq. 16.66: Logarithmic wind profile ū(z) = (u*/κ)ln(z/z₀)
- Eq. 16.70: Monin-Obukhov length L = -ρĉ_p T₀ u*³/(κg q̄_z)
- Eq. 16.75: Businger-Dyer stability functions φ_m, φ_h
- Eq. 16.78-16.79: Integrated stability functions ψ_m, ψ_h

The system computes:
- Mean wind speed at height z with stability corrections
- Friction velocity u*
- Sensible heat flux
- Stability-corrected profiles for momentum and heat

Example:
```julia
using ModelingToolkit, EnvironmentalTransport

surf = SurfaceLayerProfile()
sys = mtkcompile(surf)
```
"""
function SurfaceLayerProfile(; name=:SurfaceLayerProfile)
    @constants begin
        # Physical constants
        g = 9.807, [description = "Gravitational acceleration", unit = u"m/s^2"]
        κ = 0.4, [description = "von Karman constant (dimensionless)", unit = u"1"]
        ĉ_p = 1005.0, [description = "Specific heat of air at constant pressure", unit = u"J/(kg*K)"]
        # Small value to prevent division by zero when heat flux is near zero
        ε_q = 1e-10, [description = "Small regularization for heat flux", unit = u"W/m^2"]
    end

    @parameters begin
        z = 10.0, [description = "Height above ground", unit = u"m"]
        z₀ = 0.1, [description = "Roughness length (Table 16.1)", unit = u"m"]
        T₀ = 288.15, [description = "Reference temperature (surface)", unit = u"K"]
        ρ = 1.225, [description = "Air density", unit = u"kg/m^3"]
        u_star = 0.3, [description = "Friction velocity", unit = u"m/s"]
        q_z = 0.0, [description = "Surface sensible heat flux (positive upward)", unit = u"W/m^2"]
    end

    @variables begin
        L(t), [description = "Monin-Obukhov length (Eq. 16.70)", unit = u"m"]
        ζ(t), [description = "Stability parameter z/L (dimensionless)", unit = u"1"]
        φ_m(t), [description = "Momentum stability function (Eq. 16.75) (dimensionless)", unit = u"1"]
        φ_h(t), [description = "Heat stability function (Eq. 16.75) (dimensionless)", unit = u"1"]
        ψ_m(t), [description = "Integrated momentum stability function (dimensionless)", unit = u"1"]
        ψ_h(t), [description = "Integrated heat stability function (dimensionless)", unit = u"1"]
        ū(t), [description = "Mean wind speed at height z (Eq. 16.66 with stability)", unit = u"m/s"]
    end

    eqs = [
        # Eq. 16.70: Monin-Obukhov length
        # L = -ρĉ_p T₀ u*³ / (κ g q̄_z)
        # Positive L: stable; Negative L: unstable; |L| → ∞: neutral
        L ~ -ρ * ĉ_p * T₀ * u_star^3 / (κ * g * (q_z + ε_q)),

        # Dimensionless stability parameter
        ζ ~ z / L,

        # Eq. 16.75: Businger-Dyer stability functions (Businger et al. 1971)
        # For unstable conditions (ζ < 0): φ_m = (1 - 15ζ)^(-1/4), φ_h = (1 - 15ζ)^(-1/2)
        # For stable conditions (ζ > 0): φ_m = φ_h = 1 + 4.7ζ
        # For neutral (ζ ≈ 0): φ_m = φ_h = 1
        φ_m ~ ifelse(ζ < 0,
            (1 - 15 * ζ)^(-0.25),
            1 + 4.7 * ζ),

        φ_h ~ ifelse(ζ < 0,
            (1 - 15 * ζ)^(-0.5),
            1 + 4.7 * ζ),

        # Eq. 16.78-16.79: Integrated stability functions for profiles
        # For unstable (ζ < 0):
        #   ψ_m = 2ln((1+x)/2) + ln((1+x²)/2) - 2atan(x) + π/2, where x = (1-15ζ)^(1/4)
        #   ψ_h = 2ln((1+x²)/2), where x = (1-15ζ)^(1/4)
        # For stable (ζ > 0): ψ_m = ψ_h = -4.7ζ
        ψ_m ~ ifelse(ζ < 0,
            begin
                x = (1 - 15 * ζ)^0.25
                2 * log((1 + x) / 2) + log((1 + x^2) / 2) - 2 * atan(x) + π / 2
            end,
            -4.7 * ζ),

        ψ_h ~ ifelse(ζ < 0,
            begin
                x = (1 - 15 * ζ)^0.25
                2 * log((1 + x^2) / 2)
            end,
            -4.7 * ζ),

        # Eq. 16.66 with stability correction (Eq. 16.77):
        # ū(z) = (u*/κ)[ln(z/z₀) - ψ_m(ζ)]
        ū ~ (u_star / κ) * (log(z / z₀) - ψ_m),
    ]

    System(eqs, t; name)
end

"""
    LocalScaleMeteorology(; name=:LocalScaleMeteorology)

Returns a `ModelingToolkit.System` combining atmospheric stability analysis
with surface layer Monin-Obukhov similarity theory for comprehensive
local-scale meteorological calculations.

Based on Chapter 16 "Meteorology of the Local Scale" from Seinfeld & Pandis (2006)
"Atmospheric Chemistry and Physics", 2nd Edition, pp. 720-760.

This composite system includes:
- Potential temperature and stability classification
- Dry adiabatic lapse rate
- Monin-Obukhov length and stability parameter
- Stability-corrected wind profiles
- Pasquill stability class estimation (Table 16.4)

Key equations:
- Eq. 16.8: Γ = g/ĉ_p ≈ 9.76 K/km (dry adiabatic lapse rate)
- Eq. 16.14: θ = T(p₀/p)^0.286 (potential temperature)
- Eq. 16.66: ū = (u*/κ)ln(z/z₀) (log wind profile)
- Eq. 16.70: L = -ρĉ_p T₀ u*³/(κg q̄_z) (Monin-Obukhov length)
- Eq. 16.75: φ_m, φ_h (Businger-Dyer stability functions)
- Eq. 16.83: 1/L = a + b·log₁₀(z₀) (Golder correlation for Pasquill classes)

Pasquill Stability Classes (Table 16.4):
- A: Very unstable (strong convection)
- B: Moderately unstable
- C: Slightly unstable
- D: Neutral
- E: Slightly stable
- F: Moderately stable
- G: Very stable (strong inversion)

Example:
```julia
using ModelingToolkit, EnvironmentalTransport

met = LocalScaleMeteorology()
sys = mtkcompile(met)
```
"""
function LocalScaleMeteorology(; name=:LocalScaleMeteorology)
    @constants begin
        # Physical constants
        g = 9.807, [description = "Gravitational acceleration", unit = u"m/s^2"]
        κ = 0.4, [description = "von Karman constant (dimensionless)", unit = u"1"]
        ĉ_p = 1005.0, [description = "Specific heat of air at constant pressure", unit = u"J/(kg*K)"]
        R_air = 287.0, [description = "Gas constant for dry air", unit = u"J/(kg*K)"]
        p₀ = 101325.0, [description = "Reference pressure (sea level)", unit = u"Pa"]
        Γ_d = 9.76e-3, [description = "Dry adiabatic lapse rate (Eq. 16.8)", unit = u"K/m"]
        # Small value to prevent division by zero when heat flux is near zero
        ε_q = 1e-10, [description = "Small regularization for heat flux", unit = u"W/m^2"]
        # Dimensionless unit for log10 calculations
        z₀_ref = 1.0, [description = "Reference length for dimensionless log", unit = u"m"]

        # Golder (1972) correlation coefficients for Pasquill classes (Eq. 16.83)
        # 1/L = a + b·log₁₀(z₀)
        # Values from Table adjacent to Eq. 16.83
        a_A = -0.096, [description = "Golder coefficient a for class A", unit = u"m^-1"]
        b_A = 0.029, [description = "Golder coefficient b for class A", unit = u"m^-1"]
        a_B = -0.037, [description = "Golder coefficient a for class B", unit = u"m^-1"]
        b_B = 0.029, [description = "Golder coefficient b for class B", unit = u"m^-1"]
        a_C = -0.002, [description = "Golder coefficient a for class C", unit = u"m^-1"]
        b_C = 0.018, [description = "Golder coefficient b for class C", unit = u"m^-1"]
        a_D = 0.0, [description = "Golder coefficient a for class D", unit = u"m^-1"]
        b_D = 0.0, [description = "Golder coefficient b for class D", unit = u"m^-1"]
        a_E = 0.004, [description = "Golder coefficient a for class E", unit = u"m^-1"]
        b_E = -0.018, [description = "Golder coefficient b for class E", unit = u"m^-1"]
        a_F = 0.035, [description = "Golder coefficient a for class F", unit = u"m^-1"]
        b_F = -0.036, [description = "Golder coefficient b for class F", unit = u"m^-1"]
    end

    @parameters begin
        # Temperature and pressure
        T = 288.15, [description = "Air temperature at height z", unit = u"K"]
        T_below = 288.15, [description = "Air temperature at height z - Δz", unit = u"K"]
        p = 101325.0, [description = "Pressure at height z", unit = u"Pa"]

        # Surface layer parameters
        z = 10.0, [description = "Height above ground", unit = u"m"]
        z₀ = 0.1, [description = "Roughness length (Table 16.1)", unit = u"m"]
        Δz = 100.0, [description = "Vertical spacing for gradient calculation", unit = u"m"]

        # Turbulence parameters
        T₀ = 288.15, [description = "Reference temperature (surface)", unit = u"K"]
        ρ = 1.225, [description = "Air density", unit = u"kg/m^3"]
        u_star = 0.3, [description = "Friction velocity", unit = u"m/s"]
        q_z = 0.0, [description = "Surface sensible heat flux (positive upward)", unit = u"W/m^2"]
    end

    @variables begin
        # Stability variables
        θ(t), [description = "Potential temperature (Eq. 16.14)", unit = u"K"]
        dT_dz(t), [description = "Actual temperature lapse rate", unit = u"K/m"]
        dθ_dz(t), [description = "Potential temperature gradient", unit = u"K/m"]

        # Monin-Obukhov variables
        L(t), [description = "Monin-Obukhov length (Eq. 16.70)", unit = u"m"]
        ζ(t), [description = "Stability parameter z/L (dimensionless)", unit = u"1"]
        φ_m(t), [description = "Momentum stability function (Eq. 16.75) (dimensionless)", unit = u"1"]
        φ_h(t), [description = "Heat stability function (Eq. 16.75) (dimensionless)", unit = u"1"]
        ψ_m(t), [description = "Integrated momentum stability function (dimensionless)", unit = u"1"]
        ψ_h(t), [description = "Integrated heat stability function (dimensionless)", unit = u"1"]

        # Wind profile
        ū(t), [description = "Mean wind speed at height z (Eq. 16.66)", unit = u"m/s"]

        # Pasquill class estimation (1-6 for A-F)
        L_inv(t), [description = "Inverse Monin-Obukhov length", unit = u"m^-1"]
        pasquill_class(t), [description = "Pasquill stability class (1=A to 6=F) (dimensionless)", unit = u"1"]
    end

    # Exponent for potential temperature
    κ_exp = R_air / ĉ_p

    eqs = [
        # === Potential Temperature and Stability ===
        # Eq. 16.14: θ = T(p₀/p)^(R/ĉ_p)
        θ ~ T * (p₀ / p)^κ_exp,

        # Actual lapse rate
        dT_dz ~ (T - T_below) / Δz,

        # Eq. 16.16-16.18: Stability from potential temperature gradient
        dθ_dz ~ dT_dz + Γ_d,

        # === Monin-Obukhov Similarity ===
        # Eq. 16.70: L = -ρĉ_p T₀ u*³/(κg q̄_z)
        L ~ -ρ * ĉ_p * T₀ * u_star^3 / (κ * g * (q_z + ε_q)),

        # Inverse for Pasquill classification
        L_inv ~ 1 / L,

        # Dimensionless stability parameter
        ζ ~ z / L,

        # Eq. 16.75: Businger-Dyer stability functions (Businger et al. 1971)
        φ_m ~ ifelse(ζ < 0, (1 - 15 * ζ)^(-0.25), 1 + 4.7 * ζ),
        φ_h ~ ifelse(ζ < 0, (1 - 15 * ζ)^(-0.5), 1 + 4.7 * ζ),

        # Eq. 16.78-16.79: Integrated stability functions
        ψ_m ~ ifelse(ζ < 0,
            begin
                x = (1 - 15 * ζ)^0.25
                2 * log((1 + x) / 2) + log((1 + x^2) / 2) - 2 * atan(x) + π / 2
            end,
            -4.7 * ζ),

        ψ_h ~ ifelse(ζ < 0,
            begin
                x = (1 - 15 * ζ)^0.25
                2 * log((1 + x^2) / 2)
            end,
            -4.7 * ζ),

        # Eq. 16.66/16.77: Wind profile with stability correction
        ū ~ (u_star / κ) * (log(z / z₀) - ψ_m),

        # === Pasquill Class from 1/L (Eq. 16.83) ===
        # Using Golder (1972) correlation: 1/L = a + b·log₁₀(z₀)
        # Classes based on comparing actual 1/L with class boundaries
        pasquill_class ~ ifelse(L_inv < (a_A + b_A * log10(z₀ / z₀_ref)), 1,  # Class A (very unstable)
            ifelse(L_inv < (a_B + b_B * log10(z₀ / z₀_ref)), 2,  # Class B
                ifelse(L_inv < (a_C + b_C * log10(z₀ / z₀_ref)), 3,  # Class C
                    ifelse(L_inv < (a_E + b_E * log10(z₀ / z₀_ref)), 4,  # Class D (neutral)
                        ifelse(L_inv < (a_F + b_F * log10(z₀ / z₀_ref)), 5,  # Class E
                            6))))),  # Class F (stable)
    ]

    System(eqs, t; name)
end
