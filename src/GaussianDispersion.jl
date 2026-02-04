export GaussianDispersion
public GaussianPGB
public GaussianKC

import ModelingToolkit: Differential

struct GaussianPGBCoupler
    sys::Any
end

struct GaussianKCCoupler
    sys::Any
end

"""
GaussianPGB()

Return a `ModelingToolkit.System` implementing a classic Gaussian plume dispersion model, parameterized
with Pasquill-Gifford-Briggs dispersion coefficients, following the formulations described in EPA guidance
402-R-00-004 §12.1.6
(https://19january2017snapshot.epa.gov/sites/production/files/2015-05/documents/402-r-00-004.pdf) and the MMGRMA
document, Table 6-7 (https://www.epa.gov/sites/default/files/2020-10/documents/mmgrma_0.pdf).
Good for: quasi-steady (piecewise-steady) applications where emissions and meteorology can be treated steady over
each model time step; near-field ranges (typically ≤ 50 km); and cases where the effective plume height remains
within the planetary boundary layer.

What this does:

- Stability classification: Uses near-surface meteorology (10 m wind speed,
  downward short-wave radiation, total cloud fraction, and the surface
  temperature lapse) to determine the Pasquill stability class.

- Dispersion coefficients: Maps the stability class to Briggs coefficients
  (A_y, A_z, B_y, B_z) and evaluates the analytic expressions for the
  horizontal (sigma_h ≡ sigma_y) and vertical (sigma_z) dispersion parameters as functions
  of the down-wind distance 'x'.

- Hypsometric height: Computes puff height above ground (z_agl) from pressure,
  temperature, and humidity using the hypsometric equation with a virtual temperature
  layer mean.

- Ground-level concentration: Computes the Gaussian ground-level concentration
  at the puff center for one unit of puff mass:
      C_gl = 1 / ((2π)^{3/2} · σ_h² · σ_z) * exp(-z_agl² / (2 σ_z²)).


Example:

```
using Dates, EarthSciMLBase, EarthSciData, EnvironmentalTransport
using ModelingToolkit, OrdinaryDiffEq

t0 = DateTime(2022, 5, 1)
t1 = DateTime(2022, 5, 2)
Δλ      = deg2rad(5.0)
Δφ      = deg2rad(4.0)

dom = DomainInfo(t0, t1; levrange=1:72,
                    lonrange = deg2rad(-130):Δλ:deg2rad(-60),
                    latrange = deg2rad(25):Δφ:deg2rad(61))

mdl = couple(Puff(dom),
             GEOSFP("4x5", dom; stream=false),
             GaussianPGB())

sys  = convert(System, mdl)
tspan = get_tspan(dom)

u0 = [sys.Puff₊lon => deg2rad(-105),
      sys.Puff₊lat => deg2rad(  38),
      sys.Puff₊lev => 2]

p  = [sys.GaussianPGB₊lon0 => deg2rad(-105),
      sys.GaussianPGB₊lat0 => deg2rad(  38)]

prob = ODEProblem(sys, u0, tspan, p)
sol = solve(prob, Tsit5();)

sigma_h = sol[sys.GaussianPGB₊sigma_h]
sigma_z = sol[sys.GaussianPGB₊sigma_z]
C_gl    = sol[sys.GaussianPGB₊C_gl]

```
"""
function GaussianPGB()
    @parameters begin
        lon0 = 0.0, [unit = u"rad",  description = "Source longitude (radians)"]
        lat0 = 0.0, [unit = u"rad",  description = "Source latitude  (radians)"]
        R    = 6.371e6, [unit = u"m", description = "Earth mean radius"]

        # --- Briggs coefficients ------------------------------------------------
        AY_A = 0.22,  [description="A_y for stability class A"]
        AY_B = 0.16,  [description="A_y for stability class B"]
        AY_C = 0.11,  [description="A_y for stability class C"]
        AY_D = 0.08,  [description="A_y for stability class D"]
        AY_Ep = 0.06, [description="A_y for stability class E"]
        AY_F = 0.04,  [description="A_y for stability class F"]

        AZ_A = 0.20,  [description="A_z for class A"]
        AZ_B = 0.12,  [description="A_z for class B"]
        AZ_C = 0.08,  [description="A_z for class C"]
        AZ_D = 0.06,  [description="A_z for class D"]
        AZ_Ep = 0.03, [description="A_z for class E"]
        AZ_F = 0.016, [description="A_z for class F"]

        by = 1.0e-4,    [unit=u"m^-1",    description = "Briggs B_y (class-independent)"]
        BZ_A = 0.0,     [unit=u"m^-1", description="B_z for class A"]
        BZ_B = 0.0,     [unit=u"m^-1", description="B_z for class B"]
        BZ_C = 0.0002,  [unit=u"m^-1", description="B_z for class C"]
        BZ_D = 0.0015,  [unit=u"m^-1", description="B_z for class D"]
        BZ_Ep = 0.0003, [unit=u"m^-1", description="B_z for class E"]
        BZ_F = 0.0003,  [unit=u"m^-1", description="B_z for class F"]

        # --- Wind‑speed thresholds for Pasquill classes -------------------------
        v2 = 2.0, [unit=u"m/s", description="Wind-speed threshold 2 m.s⁻¹"]
        v3 = 3.0, [unit=u"m/s", description="Wind-speed threshold 3 m.s⁻¹"]
        v5 = 5.0, [unit=u"m/s", description="Wind-speed threshold 5 m.s⁻¹"]
        v6 = 6.0, [unit=u"m/s", description="Wind-speed threshold 6 m.s⁻¹"]

        # --- Solar‑radiation thresholds ---------------------------------------
        solrad_strong = 925.0, [unit=u"W/m^2", description="≥ 925 W.m⁻²: very strong insolation"]
        solrad_moder  = 675.0, [unit=u"W/m^2", description="675-925 W.m⁻²: moderate"]
        solrad_slight = 175.0, [unit=u"W/m^2", description="175-675 W.m⁻²: slight"]
        # 10–175 W/m² is weak/low insolation that defaults to neutral stability class D.
        solrad_night  = 10.0,  [unit=u"W/m^2", description="< 10 W.m⁻²: night"]

        cloudfrac_clear = 0.5, [description="Cloud-fraction threshold for clear skies"]

        inversion_thresh = 0.0, [unit=u"K", description="ΔT (10 m - 2 m) > 0 K indicates surface inversion"]

        U10M =  3.0,    [unit = u"m/s", description = "10 m wind U component"]
        V10M =  0.0,    [unit = u"m/s", description = "10 m wind V component"]
        SWGDN = 700.0,  [unit = u"W/m^2", description = "surface incoming shortwave radiation flux"]
        CLDTOT = 0.3,   [description = "total cloud fraction"]
        T2M = 293.15,   [unit = u"K", description = "2 m air temperature"]
        T10M = 292.65,  [unit = u"K", description = "10 m air temperature"]
    end

    @variables begin
        lon(t),     [unit = u"rad",  description = "longitude", input=true]
        lat(t),     [unit = u"rad",  description = "latitude", input=true]
        sigma_h(t), [unit = u"m",  description = "horizontal dispersion coefficient"]
        sigma_z(t), [unit = u"m",     description = "Vertical dispersion"]
        z_agl(t),   [unit = u"m",     description = "Hypsometric height above ground"]
        C_gl(t),    [unit = u"m^-3", description = "Ground-level concentration at puff center for unit mass (Gaussian)"]
    end

    wind_speed = sqrt(U10M^2 + V10M^2) # Wind speed (m s⁻¹)
    dTsurf = T10M - T2M # 10 m – 2 m temperature difference (K)

    # ------------------------------------------------------------------
    # Stability class (integer 1…6)
    # ------------------------------------------------------------------
    # Based on EPA MMGRMA Table 6‑7:
    # https://www.epa.gov/sites/default/files/2020-10/documents/mmgrma_0.pdf
    #   1 → very unstable (class A)
    #   2 → unstable      (class B)
    #   3 → slightly unstable (class C)
    #   4 → neutral       (class D)
    #   5 → slightly stable   (class E)
    #   6 → stable            (class F)
    stab_cls = ifelse(
        SWGDN .< solrad_night,                                    # night‑time
            ifelse(CLDTOT .<= cloudfrac_clear,                     # clear
                ifelse(dTsurf .> inversion_thresh,                # inversion on?
                    ifelse(wind_speed .< v2, 6, 5),               # F or E
                    4                                             # neutral (D)
                ),
                4                                                 # cloudy night → D
            ),
        ifelse(SWGDN .>= solrad_strong,                           # strong sun
            ifelse(wind_speed .< v3, 1,                           # A
                ifelse(wind_speed .< v5, 2, 3)                    # B or C
            ),
        ifelse(SWGDN .>= solrad_moder,                            # moderate sun
            ifelse(wind_speed .< v2, 1,                           # A
                ifelse(wind_speed .< v5, 2,                       # B
                    ifelse(wind_speed .< v6, 3, 4)                # C or D
                )
            ),
        ifelse(SWGDN .>= solrad_slight,                           # slight sun
            ifelse(wind_speed .< v2, 2,                           # B
                ifelse(wind_speed .< v5, 3, 4)                    # C or D
            ),
            4                                                     # default neutral
        ))))

    # ------------------------------------------------------------------
    # Briggs dispersion‑curve coefficients (unitless unless noted)
    # ------------------------------------------------------------------
    ay = ifelse(stab_cls .== 1, AY_A,   # class A
         ifelse(stab_cls .== 2, AY_B,   # class B
         ifelse(stab_cls .== 3, AY_C,   # class C
         ifelse(stab_cls .== 4, AY_D,   # class D
         ifelse(stab_cls .== 5, AY_Ep,  # class E
                 AY_F)))))              # class F

    az = ifelse(stab_cls .== 1, AZ_A,   # class A
         ifelse(stab_cls .== 2, AZ_B,   # class B
         ifelse(stab_cls .== 3, AZ_C,   # class C
         ifelse(stab_cls .== 4, AZ_D,   # class D
         ifelse(stab_cls .== 5, AZ_Ep,  # class E
                        AZ_F)))))       # class F

    bz = ifelse(stab_cls .== 1, BZ_A,   # class A
         ifelse(stab_cls .== 2, BZ_B,   # class B
         ifelse(stab_cls .== 3, BZ_C,   # class C
         ifelse(stab_cls .== 4, BZ_D,   # class D
         ifelse(stab_cls .== 5, BZ_Ep,  # class E
                       BZ_F)))))        # class F, unit: m⁻¹

        # ------------------------------------------------------------------
    # Down‑wind distance x (m) via haversine great‑circle formula
    # ------------------------------------------------------------------
    delta_lon = lon - lon0
    delta_lat = lat - lat0
    a = sin(delta_lat / 2)^2 + cos(lat0) * cos(lat) * sin(delta_lon / 2)^2
    c = 2 * atan(sqrt(a) / sqrt(1 - a))          # central angle (rad)
    x = R * c                               # arc length (m)

    # ------------------------------------------------------------------
    # Dispersion parameters σ_h, σ_z (metres)
    # ------------------------------------------------------------------
    # σ_h = A_y · x · (1 + B_y x)⁻⁰⋅⁵   (horizontal spread)
    sigma_h_expr = ay * x * (1 + by * x)^(-0.5)

    # σ_z = A_z · x · (1 + B_z x)⁻⁰⋅⁵   (classes A–D: unstable ↔ neutral)
    # σ_z = A_z · x · (1 + B_z x)⁻¹     (classes E–F: stable)
    sigma_z_expr = ifelse(stab_cls .>= 5, az * x / (1 + bz * x),
        az * x * (1 + bz * x)^(-0.5))

    # ------------------------------------------------------------------
    # Ground‑level concentration at puff center for unit mass (Gaussian)
    # C = 1 / ((2π)^(3/2) σ_h^2 σ_z) * exp(-z_agl^2/(2 σ_z^2))
    # ------------------------------------------------------------------
    C_gl_expr = 1 / ((2*pi)^(3/2) * sigma_h^2 * sigma_z) *
                   exp(- (z_agl^2) / (2 * sigma_z^2))

    # ------------------------------------------------------------------
    # Equation set
    # ------------------------------------------------------------------
    eqs = [
        sigma_h ~ sigma_h_expr,
        sigma_z ~ sigma_z_expr,
        C_gl ~ C_gl_expr,
    ]

    System(
        eqs,
        t,
        [
            lon, lat,
            sigma_h, sigma_z,
            z_agl,
            C_gl
        ],
        [
            lon0, lat0, R,
            v2, v3, v5, v6,
            solrad_night, solrad_strong, solrad_moder, solrad_slight,
            cloudfrac_clear, inversion_thresh,
            by,
            AY_A, AY_B, AY_C, AY_D, AY_Ep, AY_F,
            AZ_A, AZ_B, AZ_C, AZ_D, AZ_Ep, AZ_F,
            BZ_A, BZ_B, BZ_C, BZ_D, BZ_Ep, BZ_F,
            U10M, V10M, SWGDN, CLDTOT, T2M, T10M,
        ];
        name = :GaussianPGB,
        metadata = Dict(CoupleType => GaussianPGBCoupler)
    )
end


"""
GaussianKC()

Returns a `ModelingToolkit.System` that calculates the time evolution of horizontal puff dispersion
(sigma_x, sigma_y) based on turbulent velocity fluctuations (σu_x, σu_y).

It also computes the ground-level centerline concentration (C_gl) per unit mass assuming a 
top-hat vertical distribution within the lowest layer. The concentration is evaluated 
only when the puff is within the surface layer (z_agl ≤ Δz); otherwise, it is set to zero.

Note: Must be coupled with `BoundaryLayerMixingKC`.

Example:

```
using Dates, EarthSciMLBase, EarthSciData, EnvironmentalTransport
using ModelingToolkit, StochasticDiffEq

t0 = DateTime(2022, 5, 1)
t1 = DateTime(2022, 5, 2)
Δλ      = deg2rad(5.0)
Δφ      = deg2rad(4.0)

dom = DomainInfo(t0, t1;
                    lonrange = deg2rad(-130):Δλ:deg2rad(-60),
                    latrange = deg2rad(25):Δφ:deg2rad(61)),
                    levrange=1:72

mdl = couple(Puff(dom),
             BoundaryLayerMixingKC(),
             GEOSFP("4x5", dom; stream=false),
             GaussianKC())

sys  = convert(System, mdl)
tspan = get_tspan(dom)

u0 = [sys.Puff₊lon => deg2rad(-105),
      sys.Puff₊lat => deg2rad(  38),
      sys.Puff₊lev => 2,
      sys.GaussianKC₊sigma_x => 0.00001,
      sys.GaussianKC₊sigma_y => 0.00001,
      sys.BoundaryLayerMixingKC₊wprime => 0.0,
      sys.BoundaryLayerMixingKC₊uprime_x => 0.0,
      sys.BoundaryLayerMixingKC₊uprime_y => 0.0]

p = [sys.GaussianKC₊Δz => 100.0]

prob = SDEProblem(sys, u0, tspan, p)
sol = solve(prob, SRIW1(); dt=60.0)

sigma_x = sol[sys.GaussianKC₊sigma_x]
sigma_y = sol[sys.GaussianKC₊sigma_y]
C_gl    = sol[sys.GaussianKC₊C_gl]

```
"""
function GaussianKC()
    @parameters begin
        Δz        = 50.0,           [unit = u"m",           description = "Grid-cell height"]
        C_zero    = 0.0,            [unit = u"m^-3",        description = "Zero concentration"]
    end

    @variables begin
        σu_x(t),    [unit = u"m/s",  description = "Turbulent horizontal velocity std. dev in x", input = true]
        σu_y(t),    [unit = u"m/s",  description = "Turbulent horizontal velocity std. dev in y", input = true]
        sigma_x(t), [unit = u"m",    description = "Horizontal dispersion std dev in x"]
        sigma_y(t), [unit = u"m",    description = "Horizontal dispersion std dev in y"]
        z_agl(t),   [unit = u"m",    description = "Height AGL"]
        C_gl(t),    [unit = u"m^-3", description = "Ground-level concentration at puff center for unit mass (Gaussian)"]
    end

    Dt = Differential(t)
    Dt_sigma_x_expr = sqrt(2) * σu_x
    Dt_sigma_y_expr = sqrt(2) * σu_y

    # # Ground-centerline concentration
    C_expr = 1 / (2 * π * sigma_x * sigma_y * Δz)

    eqs = [
        Dt(sigma_x) ~ Dt_sigma_x_expr,
        Dt(sigma_y) ~ Dt_sigma_y_expr,
        C_gl        ~ ifelse(z_agl <= Δz, C_expr, C_zero),
    ]

    System(
        eqs, t,
        [σu_x, σu_y, sigma_x, sigma_y, z_agl, C_gl],
        [Δz, C_zero,];
        name = :GaussianKC,
        metadata = Dict(CoupleType => GaussianKCCoupler),
    )
end
