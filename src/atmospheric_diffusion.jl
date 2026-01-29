export AtmosphericDiffusion

struct AtmosphericDiffusionCoupler
    sys::Any
end

"""
$(TYPEDSIGNATURES)

Create a `ModelingToolkit.System` implementing the atmospheric diffusion parameterizations
from Chapter 18 of Seinfeld & Pandis (2006), *Atmospheric Chemistry and Physics*,
2nd Edition.

This system provides:

- **Wind speed profile**: Power-law profile (Eq. 18.118)
- **Vertical eddy diffusivity ``K_{zz}``**: Surface-layer similarity (Eq. 18.119–18.120),
  with full-depth profiles for unstable (Eq. 18.121, Lamb & Duran 1977),
  neutral (Eq. 18.122, Myrup & Ranzieri 1976), and stable (Eq. 18.125, Businger & Arya 1974) conditions.
- **Horizontal eddy diffusivity ``K_{yy}``**: Unstable conditions (Eq. 18.128–18.129).

The stability regime is selected using the Monin–Obukhov length ``L``:
`L < 0` for unstable, `L > 0` for stable, and the limit `|L| → ∞` for neutral conditions.

## Reference

Seinfeld, J. H. and Pandis, S. N.: Atmospheric Chemistry and Physics: From Air Pollution
to Climate Change, 2nd Edition, John Wiley & Sons, 2006, Chapter 18, Section 18.12.
"""
function AtmosphericDiffusion(; name = :AtmDiff)
    @parameters begin
        # Wind profile parameters (Eq. 18.118)
        u_r = 5.0, [unit = u"m/s", description = "Reference wind speed"]
        z_r = 10.0, [unit = u"m", description = "Reference height for wind profile"]
        p_wind = 0.15, [description = "Power-law exponent for wind profile (dimensionless)"]

        # Boundary layer parameters
        z_i = 1000.0, [unit = u"m", description = "Mixed-layer (inversion) height"]
        L_MO = -100.0, [unit = u"m", description = "Monin-Obukhov length"]
        u_star = 0.3, [unit = u"m/s", description = "Friction velocity"]
        f_cor = 1.0e-4, [unit = u"1/s", description = "Coriolis parameter"]

        # Physical constants
        κ = 0.4, [description = "von Karman constant (dimensionless)"]

        # Threshold parameters for stability regime selection
        L_zero = 0.0, [unit = u"m", description = "Zero threshold for L_MO comparison"]
        L_neutral = 10000.0, [unit = u"m", description = "Neutral threshold for L_MO"]
        Kzz_zero = 0.0, [unit = u"m^2/s", description = "Zero diffusivity for above-BL fallback"]
    end

    @variables begin
        z(t), [unit = u"m", description = "Height above ground"]
        u_wind(t), [unit = u"m/s", description = "Mean wind speed at height z (Eq. 18.118)"]
        K_zz(t), [unit = u"m^2/s", description = "Vertical eddy diffusivity"]
        K_yy(t), [unit = u"m^2/s", description = "Horizontal eddy diffusivity"]
    end

    # --- Mean wind speed: power-law profile (Eq. 18.118) ---
    # ū/ū_r = (z/z_r)^p
    u_wind_expr = u_r * (z / z_r)^p_wind

    # --- Vertical eddy diffusivity K_zz ---
    # We implement three regimes based on L_MO and select using ifelse.

    # Convective velocity scale w_star for unstable conditions
    # w_star = u_star * (-z_i / (κ * L_MO))^(1/3)  (standard definition)
    w_star = u_star * (-z_i / (κ * L_MO))^(1 / 3)

    # Normalized height
    zn = z / z_i

    # --- Unstable K_zz (Eq. 18.121, Lamb & Duran 1977) ---
    # Kzz / (w_star * z_i) is a piecewise polynomial in z/z_i
    # Piece 1: 0 ≤ z/z_i < 0.05: 2.5κ(z/z_i)^(4/3) * (1 - 15z/L)^(1/4)
    # Piece 2: 0.05 ≤ z/z_i ≤ 0.6: 0.021 + 0.408(z/z_i) + 1.351(z/z_i)^2 - 4.096(z/z_i)^3 + 2.560(z/z_i)^4
    # Piece 3: 0.6 < z/z_i ≤ 1.1: 0.2 exp[6 - 10(z/z_i)]
    # Piece 4: z/z_i > 1.1: 0.0013
    # Each piece is multiplied by w_star * z_i to give units of m²/s
    wzi = w_star * z_i
    Kzz_unstable_piece1 = wzi * 2.5 * κ * zn^(4 / 3) * (1 - 15 * z / L_MO)^(1 / 4)
    Kzz_unstable_piece2 = wzi * (0.021 + 0.408 * zn + 1.351 * zn^2 - 4.096 * zn^3 + 2.560 * zn^4)
    Kzz_unstable_piece3 = wzi * 0.2 * exp(6 - 10 * zn)
    Kzz_unstable_piece4 = wzi * 0.0013

    Kzz_unstable = ifelse(zn < 0.05, Kzz_unstable_piece1,
        ifelse(zn <= 0.6, Kzz_unstable_piece2,
            ifelse(zn <= 1.1, Kzz_unstable_piece3,
                Kzz_unstable_piece4)))

    # --- Neutral K_zz (Eq. 18.122, Myrup & Ranzieri 1976) ---
    # K_zz = κ u_* z              for z/z_i < 0.1
    # K_zz = κ u_* z (1.1 - z/z_i) for 0.1 ≤ z/z_i ≤ 1.1
    # K_zz = 0                     for z/z_i > 1.1
    Kzz_neutral = ifelse(zn < 0.1, κ * u_star * z,
        ifelse(zn <= 1.1, κ * u_star * z * (1.1 - zn),
            Kzz_zero))

    # --- Stable K_zz (Eq. 18.125, Businger & Arya 1974) ---
    # K_zz = κ u_* z / (0.74 + 4.7 z/L) * exp(-8fz/u_*)
    Kzz_stable = κ * u_star * z / (0.74 + 4.7 * z / L_MO) * exp(-8 * f_cor * z / u_star)

    # Select regime based on L_MO sign
    # L_MO < 0: unstable, L_MO > 0: stable
    # For neutral, |L_MO| is very large; we use a threshold approach:
    # If |L_MO| > 10000 m, treat as neutral (large |L| ≈ neutral)
    K_zz_expr = ifelse(L_MO < L_zero, Kzz_unstable,
        ifelse(L_MO > L_neutral, Kzz_neutral,
            Kzz_stable))

    # --- Horizontal eddy diffusivity K_yy ---
    # Under unstable conditions (Eq. 18.128): K_yy ≈ 0.1 w_* z_i
    # Under neutral/stable conditions, approximate as K_yy = K_zz (common assumption, Sec. 18.12.3)
    K_yy_unstable = 0.1 * w_star * z_i
    K_yy_expr = ifelse(L_MO < L_zero, K_yy_unstable, K_zz_expr)

    eqs = [
        u_wind ~ u_wind_expr,   # Eq. 18.118
        K_zz ~ K_zz_expr,       # Eq. 18.119–18.125
        K_yy ~ K_yy_expr,       # Eq. 18.126–18.129
    ]

    System(eqs, t,
        [z, u_wind, K_zz, K_yy],
        [u_r, z_r, p_wind, z_i, L_MO, u_star, f_cor, κ, L_zero, L_neutral, Kzz_zero];
        name = name,
        metadata = Dict(CoupleType => AtmosphericDiffusionCoupler))
end
