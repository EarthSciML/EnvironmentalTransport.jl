export Puff

struct PuffCoupler
    sys::Any
end

"""
$(TYPEDSIGNATURES)

Create a Lagrangian transport model which advects a "puff" or particle of matter
within a fluid velocity field.

Model boundaries are set by the DomainInfo argument.
The model sets boundaries at the ground and model bottom and top,
preventing the puff from crossing those boundaries. If the
puff reaches one of the horizontal boundaries, the simulation is stopped.

The model includes boundary-layer turbulent mixing following HYSPLIT (NOAA Tech. Memo ERL ARL-224)
https://www.arl.noaa.gov/documents/reports/arl-224.pdf

## Keyword arguments

  - buffer_cells: The distance (expressed in a number of DomainInfo grid cells) to use as a buffer
    around the horizontal edge of the domain to avoid data loader interpolation errors. The
    effective size of the domain will be reduce by 2× this amount (default = 1)
"""
function Puff(di::DomainInfo; buffer_cells = 1, name = :Puff)
    @constants κ        = 0.40    [unit = u"1",     description = "von Kármán constant"]
    @constants one      = 1.0     [unit = u"1",     description = "Dimensionless 1.0"]
    @constants m0       = 0.0     [unit = u"m",     description = "0 in metres"]
    @constants m1       = 1.0     [unit = u"m",     description = "1 in metres"]
    @constants ms0      = 0.0     [unit = u"m/s",   description = "0 in m/s"]
    @constants kms0     = 0.0     [unit = u"K*m/s", description = "0 kinematic heat flux"]
    @constants kms1e_8  = 1.0e-8  [unit = u"K*m/s", description = "Tiny positive kinematic heat-flux floor to avoid divide-by-zero in L"]
    @constants z_eps    = 0.5     [unit = u"m",     description = "Small height to keep particles off the ground"]
    @constants w_damp   = 0.0     [unit = u"1",     description = "Optional damping (0=no damping) on bounce"]
    @constants S        = 1.0     [unit = u"s",     description = "Time unit used in OU noise scaling"]


    pv = EarthSciMLBase.pvars(di)
    coords = []
    for p in pv
        n = Symbol(p)
        v = EarthSciMLBase.add_metadata(only(@variables $n(t) = getdefault(p)), p)
        push!(coords, v)
    end
    @assert length(coords)==3 "DomainInfo must have 3 coordinates for puff model but currently has $(length(coords)): $coords"

    lev_idx = only(findall(v -> string(Symbol(v)) in ["lev(t)", "z(t)"], coords))
    lon_idx = only(findall(v -> string(Symbol(v)) in ["lon(t)", "x(t)"], coords))
    lat_idx = only(findall(v -> string(Symbol(v)) in ["lat(t)", "y(t)"], coords))
    endpts = EarthSciMLBase.endpoints(di)

    # Get transforms for e.g. longitude to meters.
    @parameters x_trans=1 [unit = get_unit(coords[lon_idx]) / 1u"m",
        description = "x-coordinate to meters transform"]
    @parameters y_trans=1 [unit = get_unit(coords[lat_idx]) / 1u"m",
        description = "y-coordinate to meters transform"]
    @parameters lev_trans=1 [unit = get_unit(coords[lev_idx]) / 1u"Pa",
        description = "level to pressure transform"]

    @parameters PBLH        = 1000.0        [unit = u"m",           description = "Planetary boundary layer height"]
    @parameters USTAR       = 0.3           [unit = u"m/s",         description = "Friction velocity u*"]
    @parameters HFLUX       = 0.0           [unit = u"W/m^2",       description = "Surface sensible heat flux (H)"]
    @parameters EFLUX       = 0.0           [unit = u"W/m^2",       description = "Surface latent heat flux (LE)"]
    @parameters PS          = 101325        [unit = u"Pa",          description = "Surface air pressure at the site"]
    @parameters T2M         = 293.15        [unit = u"K",           description = "2-metre air temperature"]
    @parameters QV2M        = 0.009         [unit = u"1",           description = "2-metre specific humidity"]
    @parameters z2lev       = 0.0           [unit = u"1/m",         description = "∂lev/∂z"]
    @parameters TL_min      = 5.0           [unit=u"s",             description = "Minimum Lagrangian time scale for turbulence"]
    @parameters TL_max      = 1000.0        [unit=u"s",             description = "Maximum Lagrangian time scale for turbulence"]
    @parameters Rd          = 287.05        [unit = u"J/(kg*K)",    description = "Specific gas constant for dry air"]
    @parameters cp          = 1004.0        [unit = u"J/(kg*K)",    description = "Specific heat capacity of dry air at constant pressure near 300 K"]
    @parameters Lv          = 2.5e6         [unit = u"J/kg",        description = "Latent heat of vaporization of water"]
    @parameters g           = 9.80665       [unit = u"m/s^2",       description = "Gravitational acceleration"]
    @parameters R_inv       = 0.2           [unit=u"1",             description = "Heat-flux ratio at inversion"]
    @parameters KMIX0       = 150.0         [unit = u"m",           description = "Minimum mixing depth"]
    @parameters TKEMIN      = 0.001         [unit = u"m^2/s^2",     description = "Minimum turbulent kinetic energy"]


    trans = [lev_trans, lev_trans, lev_trans]
    trans[lon_idx] = x_trans
    trans[lat_idx] = y_trans

    # Create placeholder velocity variables.
    vs = []
    for i in eachindex(coords)
        v_sym = Symbol("v_$(Symbol(pv[i]))")
        vu = get_unit(coords[i]) / get_unit(trans[i]) / get_unit(t)
        v = only(@parameters $(v_sym)=0.0 [unit = vu description = "$(Symbol(pv[i])) speed"])
        push!(vs, v)
    end
    eqs = D.(coords) .~ vs .* trans

    # Boundary condition at the ground and model top.
    uc = get_unit(coords[lev_idx])
    
    @constants(offset=0.05, [unit=uc, description="Offset for boundary conditions"],
        glo=endpts[lev_idx][begin], [unit=uc, description="lower bound"],
        ghi=endpts[lev_idx][end], [unit=uc, description="upper bound"],
        v_zero=0, [unit=get_unit(eqs[lev_idx].rhs)],)

    @variables v_vertical(t) [unit = get_unit(eqs[lev_idx].rhs)]
    @variables wprime(t)     [unit = u"m/s",    description = "Turbulent vertical-velocity fluctuation"]
    @variables z_agl(t)      [unit = u"m",      description = "Height above ground level"]
    @variables sigmaw(t)     [unit = u"m/s",    description = "Standard deviation of turbulent vertical velocity"]
    @variables TL(t)         [unit = u"s",      description = "Lagrangian time scale for vertical-velocity"]
    @variables zi(t)         [unit = u"m",      description = "Planetary boundary layer depth"]
    @variables wprime_ref(t) [unit = u"m/s",    description = "Reflected turbulent vertical velocity near ground"]
    @variables Tv2m(t)       [unit = u"K",      description = "2 m virtual temperature"]
    @variables rho(t)        [unit = u"kg/m^3", description = "Air density"]
    @variables wth(t)        [unit = u"K*m/s",  description = "Kinematic sensible heat flux"]
    @variables wq(t)         [unit = u"1*m/s",  description = "Kinematic moisture flux"]
    @variables wthv(t)       [unit = u"K*m/s",  description = "Potential temperature flux"]
    @variables Lmo(t)        [unit = u"m",      description = "Monin–Obukhov length"]
    @variables wstar(t)      [unit = u"m/s",    description = "Convective velocity scale (Deardorff)"]
    @variables uprime_x(t)   [unit = u"m/s",    description = "Horizontal turbulent velocity in x"]
    @variables uprime_y(t)   [unit = u"m/s",    description = "Horizontal turbulent velocity in y"]
    
    @brownians Bw #Bx By

    ζ_clip   = max(min(z_agl / max(zi, m1), 1.0), 0.0)       # 0 ≤ ζ ≤ 1
    one_m3zL = max(one - 3*z_agl / max(Lmo, m1), 1e-6)       # (1 - 3 z/L) for MOST; guard >0  (ARL-224 Eq. 92)
    is_unst  = Lmo < m0                                      # unstable if L<0
    is_sfc   = ζ_clip < 0.10                                 # crude surface layer/mixed layer split

    # Minimum vertical velocity variance implied by TKEMIN
    # For isotropic turbulence: u′² ≈ v′² ≈ w′²,
    # so each component variance is: w′² ≈ (2/3) k
    σw2_min = (2.0 / 3.0) * TKEMIN

    # ─────────────────────────────────────────────────────────────
    # Vertical turbulent velocity variance
    # ─────────────────────────────────────────────────────────────

    # Neutral/Stable boundary layer (ARL-224 Eq. 71): w'^2 = 1.7 u*^2 (1 - ζ)^(3/2)
    σw2_NS   = 1.7 * USTAR^2 * max(one - ζ_clip, 0.0)^(1.5)

    # Unstable boundary layer (Kantha–Clayson; ARL-224 Eq. 90): w'^2 = w*^2 (ζ)^(2/3) (1 - ζ)^(2/3) (1 + 0.5 R^(2/3))
    σw2_UML  = wstar^2 * max(ζ_clip, 1e-6)^(2/3) * max(one - ζ_clip, 1e-6)^(2/3) * (one + 0.5*R_inv^(2/3))

    # Unstable surface layer (Hanna 1982; ARL-224 Eq. 92): w'^2 = 1.74 u*^2 (1 - 3 z/L)^(2/3)
    σw2_USL  = 1.74 * USTAR^2 * one_m3zL^(2/3)

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
    # Lagrangian time scale TL (vertical), Hanna (1982)
    # as summarized in ARL-224 Eqs. (63) and (66), with σw interpreted
    # as the standard deviation of w′.
    # ─────────────────────────────────────────────────────────────

    # Unstable (convective) boundary layer:
    #   TL = 0.15 · zi / σw · [1 - exp(-5 ζ)]
    #   (Hanna mixed-layer form, ARL-224 Eq. (66))
    TL_conv = 0.15 * zi / sigmaw * (one - exp(-5 * ζ_clip))

    # Stable / neutral boundary layer:
    #   TL = 0.1 · zi / σw · ζ^0.8
    #   (Hanna stable/neutral form, ARL-224 Eq. (63))
    TL_stab_local = 0.1 * zi / sigmaw * ζ_clip^0.8

    TL_expr = ifelse(is_unst, TL_conv, TL_stab_local)
    # ─────────────────────────────────────────────────────────────

    push!(eqs, zi ~ max(PBLH, KMIX0))
    push!(eqs, sigmaw ~ σw_expr)
    push!(eqs, TL ~ clamp(TL_expr, TL_min, TL_max))

    # Langevin equation
    # HE: TODO – Replace Bw with Brownian motions Bx, By for u′ and v′
    push!(eqs, D(wprime) ~ -(wprime/TL) + sqrt(2*sigmaw^2 / TL / S) * Bw)
    push!(eqs, D(uprime_x) ~ -(uprime_x/TL) +
                          sqrt(2*σu2_expr / TL / S) * Bw)
    push!(eqs, D(uprime_y) ~ -(uprime_y/TL) +
                          sqrt(2*σv2_expr / TL / S) * Bw)
    
    # Virtual temperature at 2 m (ARL-224 Eq. 9)
    push!(eqs, Tv2m  ~ T2M*(1 + 0.61*QV2M))
    
    # Air density (ARL-224 Eq. 6)
    push!(eqs, rho   ~ PS/(Rd*Tv2m))
    
    # Kinematic sensible heat flux (ARL-224 Eq. 27)
    push!(eqs, wth   ~ HFLUX/(rho*cp))

    # Kinematic moisture flux
    # LE = ρ Lv w′q′  ⇒  w′q′ = LE / (ρ Lv)
    push!(eqs, wq    ~ EFLUX/(rho*Lv))

    # Virtual temperature flux (w′θ_v′)
    # Derived from the virtual temperature definition and heat / moisture flux relations
    push!(eqs, wthv  ~ wth*(1 + 0.61*QV2M) + 0.61*T2M*wq)
    
    # Monin–Obukhov length L
    # L = - T_v u*^3 / (κ g w′θ_v′)
    push!(eqs, Lmo   ~ -USTAR^3 * Tv2m / (κ*g*max(wthv, kms1e_8)))
    
    # Convective velocity scale (Deardorff w*)
    # Written in terms of the virtual-temperature flux using ARL-224 Eq. (9), (27), and (28)
    push!(eqs, wstar ~ ifelse(
        wthv > kms0,
        ((g/Tv2m) * wthv * zi)^(1/3),
        ms0
    ))

    # Near-ground reflection of turbulent vertical velocity
    push!(eqs, wprime_ref ~ ifelse(z_agl <= z_eps, (one - w_damp) * abs(wprime), wprime))
    
    push!(eqs, v_vertical ~ eqs[lev_idx].rhs)

    is_lev_coord = string(Symbol(coords[lev_idx])) == "lev(t)"
    wprime_ref_e = ifelse(is_lev_coord, wprime_ref * z2lev, wprime_ref)

    eqs[lon_idx] = let eq = eqs[lon_idx]
        eq.lhs ~ eq.rhs + uprime_x * x_trans
    end

    eqs[lat_idx] = let eq = eqs[lat_idx]
        eq.lhs ~ eq.rhs + uprime_y * y_trans
    end

    eqs[lev_idx] = let
        eq = eqs[lev_idx]
        c = coords[lev_idx]
        eq.lhs ~ ifelse(c - offset < glo, max(v_zero, v_vertical + wprime_ref_e),
            ifelse(c + offset > ghi, min(v_zero, v_vertical + wprime_ref_e), v_vertical + wprime_ref_e))
    end

    lower_bound = coords[lev_idx] ~ endpts[lev_idx][begin]
    upper_bound = coords[lev_idx] ~ endpts[lev_idx][end]
    
    vertical_boundary = [lower_bound, upper_bound]
    # Stop simulation if we reach the lateral boundaries.
    function stop!(modified, observed, ctx, integrator)
        terminate!(integrator)
        NamedTuple()
    end
    wb = coords[lon_idx] ~ endpts[lon_idx][begin] + di.grid_spacing[lon_idx] * buffer_cells
    eb = coords[lon_idx] ~ endpts[lon_idx][end] - di.grid_spacing[lon_idx] * buffer_cells
    sb = coords[lat_idx] ~ endpts[lat_idx][begin] + di.grid_spacing[lat_idx] * buffer_cells
    nb = coords[lat_idx] ~ endpts[lat_idx][end] - di.grid_spacing[lat_idx] * buffer_cells
    lateral_boundary = [wb, eb, sb, nb] => (f=stop!,)
    System(eqs, EarthSciMLBase.ivar(di); name = name,
        metadata = Dict(CoupleType => PuffCoupler),
        continuous_events = [vertical_boundary, lateral_boundary])
end