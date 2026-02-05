export BoundaryLayerMixingKC
public BoundaryLayerMixingKCCoupler

struct BoundaryLayerMixingKCCoupler
    sys::Any
end

"""
    BoundaryLayerMixingKC()

A ModelingToolkit System implementing the Kantha-Clayson & Garratt turbulence parameterization
for boundary layer mixing, as described in NOAA ARL-224 (https://www.arl.noaa.gov/documents/reports/arl-224.pdf)
and HYSPLIT documentation.
"""
function BoundaryLayerMixingKC(; name = :BoundaryLayerMixingKC)
    @constants κ = 0.40 [unit = u"1", description = "von Kármán constant"]
    @constants one = 1.0 [unit = u"1", description = "Dimensionless 1.0"]
    @constants m0 = 0.0 [unit = u"m", description = "0 in metres"]
    @constants m1 = 1.0 [unit = u"m", description = "1 in metres"]
    @constants ms0 = 0.0 [unit = u"m/s", description = "0 in m/s"]
    @constants kms0 = 0.0 [unit = u"K*m/s", description = "0 kinematic heat flux"]
    @constants kms1e_8 = 1.0e-8 [
        unit = u"K*m/s", description = "Minimum kinematic heat flux"]
    @constants S = 1.0 [unit = u"s", description = "Time unit"]

    @parameters PBLH = 1000.0 [unit = u"m", description = "Planetary boundary layer height"]
    @parameters USTAR = 0.3 [unit = u"m/s", description = "Friction velocity u*"]
    @parameters HFLUX = 0.0 [
        unit = u"W/m^2", description = "Surface sensible heat flux (H)"]
    @parameters EFLUX = 0.0 [unit = u"W/m^2", description = "Surface latent heat flux (LE)"]
    @parameters PS = 101325 [unit = u"Pa", description = "Surface air pressure"]
    @parameters T2M = 293.15 [unit = u"K", description = "2-metre air temperature"]
    @parameters QV2M = 0.009 [unit = u"1", description = "2-metre specific humidity"]
    @parameters z2lev = 0.0 [unit = u"1/m", description = "∂lev/∂z"]
    @parameters TL_h = 10800.0 [
        unit=u"s", description = "Lagrangian time scale for horizontal-velocity"]
    @parameters TL_v_min = 5.0 [
        unit=u"s", description = "Minimum Lagrangian time scale for turbulence"]
    @parameters TL_v_max = 1000.0 [
        unit=u"s", description = "Maximum Lagrangian time scale for turbulence"]
    @parameters Rd = 287.05 [
        unit = u"J/(kg*K)", description = "Specific gas constant for dry air"]
    @parameters cp = 1004.0 [unit = u"J/(kg*K)",
        description = "Specific heat capacity of dry air at constant pressure near 300 K"]
    @parameters Lv = 2.5e6 [
        unit = u"J/kg", description = "Latent heat of vaporization of water"]
    @parameters g = 9.80665 [unit = u"m/s^2", description = "Gravitational acceleration"]
    @parameters R_inv = 0.2 [unit=u"1", description = "Heat-flux ratio at inversion"]
    @parameters KMIX0 = 150.0 [unit = u"m", description = "Minimum mixing depth"]
    @parameters TKEMIN = 0.001 [
        unit = u"m^2/s^2", description = "Minimum turbulent kinetic energy"]
    @parameters x_trans = 0.01 [
        unit = u"1/m", description = "lon radians per meter (1/δxδlon)"]
    @parameters y_trans = 0.01 [
        unit = u"1/m", description = "lat radians per meter (1/δyδlat)"]
    @parameters z_agl = 50.0 [unit = u"m", description = "Height above ground level"]
    @parameters lev_gnd = 1.0 [unit=u"1", description = "Level index of the ground surface"]
    @parameters lev_top = 72.0 [unit=u"1", description = "Top level index of the domain"]
    @parameters w_damp = 1.0 [unit = u"1",
        description = "Fraction of velocity lost on boundary impact (0.0 = perfect bounce, 1.0 = complete Absorption"]
    @constants offset = 0.05 [unit = u"1", description = "Offset for boundary conditions"]

    @variables wprime(t) [
        unit = u"m/s", description = "Turbulent vertical-velocity fluctuation"]
    @variables sigmaw(t) [
        unit = u"m/s", description = "Standard deviation of turbulent vertical velocity"]
    @variables σu(t) [
        unit = u"m/s", description = "Standard deviation of x component of turbulent velocity"]
    @variables σv(t) [
        unit = u"m/s", description = "Standard deviation of y component of turbulent velocity"]
    @variables TL_v(t) [
        unit = u"s", description = "Lagrangian time scale for vertical-velocity"]
    @variables zi(t) [unit = u"m", description = "Planetary boundary layer depth"]
    @variables wprime_ref(t) [
        unit = u"m/s", description = "Reflected turbulent vertical velocity near ground"]
    @variables Tv2m(t) [unit = u"K", description = "2 m virtual temperature"]
    @variables rho(t) [unit = u"kg/m^3", description = "Air density"]
    @variables wth(t) [unit = u"K*m/s", description = "Kinematic sensible heat flux"]
    @variables wq(t) [unit = u"1*m/s", description = "Kinematic moisture flux"]
    @variables wthv(t) [unit = u"K*m/s", description = "Potential temperature flux"]
    @variables wthv_eff(t) [
        unit = u"K*m/s", description = "Effective potential temperature flux"]
    @variables Lmo(t) [unit = u"m", description = "Monin–Obukhov length"]
    @variables wstar(t) [
        unit = u"m/s", description = "Convective velocity scale (Deardorff)"]
    @variables uprime_x(t) [
        unit = u"m/s", description = "Horizontal turbulent velocity in x"]
    @variables uprime_y(t) [
        unit = u"m/s", description = "Horizontal turbulent velocity in y"]
    @variables lon(t) [unit = u"1", description = "Longitude coordinate"]
    @variables lat(t) [unit = u"1", description = "Latitude coordinate"]
    @variables lev(t) [unit = u"1", description = "Height (level) coordinate"]

    @brownians Bw #Bx By

    ζ_clip = max(min(z_agl / max(zi, m1), 1.0), 0.0)       # 0 ≤ ζ ≤ 1
    L_abs = max(abs(Lmo), m1)
    L_eff = sign(Lmo) * L_abs
    one_m3zL = max(one - 3*z_agl / L_eff, 1e-6)              # (1 - 3 z/L) for MOST; guard >0  (ARL-224 Eq. 92)
    is_unst = Lmo < m0                                      # unstable if L<0
    is_sfc = ζ_clip < 0.10                                 # crude surface layer/mixed layer split

    # Minimum vertical velocity variance implied by TKEMIN
    # For isotropic turbulence: u′² ≈ v′² ≈ w′²,
    # so each component variance is: w′² ≈ (2/3) k
    σw2_min = (2.0 / 3.0) * TKEMIN

    # ─────────────────────────────────────────────────────────────
    # Vertical turbulent velocity variance
    # ─────────────────────────────────────────────────────────────

    # Neutral/Stable boundary layer (ARL-224 Eq. 71): w'^2 = 1.7 u*^2 (1 - ζ)^(3/2)
    σw2_NS = 1.7 * USTAR^2 * max(one - ζ_clip, 0.0)^(1.5)

    # Unstable boundary layer (Kantha–Clayson; ARL-224 Eq. 90): w'^2 = w*^2 (ζ)^(2/3) (1 - ζ)^(2/3) (1 + 0.5 R^(2/3))
    σw2_UML = wstar^2 * max(ζ_clip, 1e-6)^(2/3) * max(one - ζ_clip, 1e-6)^(2/3) *
              (one + 0.5*R_inv^(2/3))

    # Unstable surface layer (Hanna 1982; ARL-224 Eq. 92): w'^2 = 1.74 u*^2 (1 - 3 z/L)^(2/3)
    σw2_USL = 1.74 * USTAR^2 * one_m3zL^(2/3)

    # Unstable: Choose between surface-layer and mixed-layer σ_w^2
    #   • Near the surface (ζ < 0.1): use surface-layer form (σw2_USL)
    #   • Above 0.1 zi: use mixed-layer form (σw2_UML)
    σw2_unstable = ifelse(is_sfc, σw2_USL, σw2_UML)

    # Final σ_w^2: unstable vs neutral/stable  (ARL-224 Eq. (71))
    σw2_expr = ifelse(is_unst, σw2_unstable, σw2_NS)

    # Vertical standard deviation:
    σw_expr = sqrt(max(σw2_expr, σw2_min))

    # ─────────────────────────────────────────────────────────────
    # Horizontal turbulent velocity variances
    # ─────────────────────────────────────────────────────────────
    # Stable / neutral (Kantha–Clayson; ARL-224 Eqs. 72–73, 75–76):
    σu2_NS = 4.0 * USTAR^2 * max(one - ζ_clip, 0.0)^(1.5)
    σv2_NS = 5.0 * USTAR^2 * max(one - ζ_clip, 0.0)^(1.5)

    # Unstable (Kantha–Clayson / Garratt; ARL-224 Eqs. 91 & 93):
    σu2_unstable = 0.36 * wstar^2
    σv2_unstable = 0.36 * wstar^2

    # Final horizontal variances:
    σu2_expr = ifelse(is_unst, σu2_unstable, σu2_NS)
    σv2_expr = ifelse(is_unst, σv2_unstable, σv2_NS)

    # ─────────────────────────────────────────────────────────────
    # Lagrangian time scale TL_v (vertical), Hanna (1982)
    # as summarized in ARL-224 Eqs. (63) and (66), with σw interpreted
    # as the standard deviation of w′.
    # ─────────────────────────────────────────────────────────────

    # Unstable (convective) boundary layer:
    #   TL_v = 0.15 · zi / σw · [1 - exp(-5 ζ)]
    #   (Hanna mixed-layer form, ARL-224 Eq. (66))
    TL_v_conv = 0.15 * zi / sigmaw * (one - exp(-5 * ζ_clip))

    # Stable / neutral boundary layer:
    #   TL_v = 0.1 · zi / σw · ζ^0.8
    #   (Hanna stable/neutral form, ARL-224 Eq. (63))
    TL_v_stab_local = 0.1 * zi / sigmaw * ζ_clip^0.8

    TL_v_expr = ifelse(is_unst, TL_v_conv, TL_v_stab_local)
    # ─────────────────────────────────────────────────────────────

    eqs = [
        zi ~ max(PBLH, KMIX0),
        sigmaw ~ σw_expr,
        σu ~ sqrt(σu2_expr),
        σv ~ sqrt(σv2_expr),
        TL_v ~ clamp(TL_v_expr, TL_v_min, TL_v_max),

        # Langevin equation
        # HE: TODO – Replace Bw with Brownian motions Bx, By for u′ and v′
        D(wprime) ~ -(wprime/TL_v) + sqrt(2*sigmaw^2 / TL_v / S) * Bw,
        D(uprime_x) ~ -(uprime_x/TL_h) + sqrt(2*σu2_expr / TL_h / S) * Bw,
        D(uprime_y) ~ -(uprime_y/TL_h) + sqrt(2*σv2_expr / TL_h / S) * Bw,

        # Virtual temperature at 2 m (ARL-224 Eq. 9)
        Tv2m ~ T2M*(1 + 0.61*QV2M),

        # Air density (ARL-224 Eq. 6)
        rho ~ PS/(Rd*Tv2m),

        # Kinematic sensible heat flux (ARL-224 Eq. 27)
        wth ~ HFLUX/(rho*cp),

        # Kinematic moisture flux
        # LE = ρ Lv w′q′  ⇒  w′q′ = LE / (ρ Lv)
        wq ~ EFLUX/(rho*Lv),

        # Virtual temperature flux (w′θ_v′)
        # Derived from the virtual temperature definition and heat / moisture flux relations
        wthv ~ wth*(1 + 0.61*QV2M) + 0.61*T2M*wq,

        # Monin–Obukhov length L
        # L = - T_v u*^3 / (κ g w′θ_v′)
        wthv_eff ~ ifelse(wthv >= kms0, max(wthv, kms1e_8), min(wthv, -kms1e_8)),
        Lmo ~ -USTAR^3 * Tv2m / (κ*g*wthv_eff),

        # Convective velocity scale (Deardorff w*)
        # Written in terms of the virtual-temperature flux using ARL-224 Eq. (9), (27), and (28)
        wstar ~ ifelse(wthv > kms0, ((g/Tv2m) * wthv * zi)^(1/3), ms0),

        # Near-ground reflection of turbulent vertical velocity
        wprime_ref ~ ifelse((lev <= lev_gnd + offset), (one - w_damp) * abs(wprime),
            ifelse((lev >= lev_top - offset), -(one - w_damp) * abs(wprime),
                wprime)), D(lon) ~ uprime_x * x_trans,
        D(lat) ~ uprime_y * y_trans,
        D(lev) ~ wprime_ref * z2lev
    ]

    System(eqs, t,
        [zi, sigmaw, σu, σv, TL_v, wprime, uprime_x, uprime_y, Tv2m, rho,
            wth, wq, wthv, wthv_eff, Lmo, wstar, wprime_ref, lon, lat, lev],
        [κ, one, offset, m0, m1, ms0, kms0, kms1e_8, w_damp, S, PBLH, USTAR,
            HFLUX, EFLUX, PS, T2M, QV2M, z2lev, TL_h, TL_v_min, TL_v_max, Rd, cp,
            Lv, g, R_inv, KMIX0, TKEMIN, x_trans, y_trans, z_agl, lev_gnd, lev_top];
        name = name, metadata = Dict(CoupleType => BoundaryLayerMixingKCCoupler)
    )
end
