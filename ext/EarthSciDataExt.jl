module EarthSciDataExt

using DocStringExtensions
import EarthSciMLBase
using EarthSciMLBase: param_to_var, ConnectorSystem, CoupledSystem, get_coupletype,
    operator_compose
using EarthSciData: GEOSFPCoupler, WRFCoupler, Ap, Bp, lev_from_pressure
using EarthSciData: interp_callable
using EnvironmentalTransport: PuffCoupler, GaussianPGBCoupler, GaussianKCCoupler,
    BoundaryLayerMixingKCCoupler, AdvectionOperator,
    Sofiev2012PlumeRiseCoupler, PBLMixingCallback
using ModelingToolkit: ParentScope, initial_conditions, @unpack
using ModelingToolkit: t
using ModelingToolkit: @parameters, @variables, @constants
using DynamicQuantities: @u_str

function EarthSciMLBase.couple2(p::PuffCoupler, g::GEOSFPCoupler)
    p, g = p.sys, g.sys
    p = param_to_var(p, :v_lon, :v_lat, :v_lev, :x_trans, :y_trans, :lev_trans)
    g = param_to_var(g, :lon, :lat, :lev)
    return ConnectorSystem(
        [
            g.lon ~ p.lon
            g.lat ~ p.lat
            g.lev ~ clamp(p.lev, 1, 72)
            p.v_lon ~ g.A3dyn₊U
            p.v_lat ~ g.A3dyn₊V
            p.v_lev ~ g.A3dyn₊OMEGA
            p.x_trans ~ 1 / g.δxδlon
            p.y_trans ~ 1 / g.δyδlat
            p.lev_trans ~ 1 / g.δPδlev
        ],
        p,
        g
    )
end

function EarthSciMLBase.couple2(blm::BoundaryLayerMixingKCCoupler, g::GEOSFPCoupler)
    b, m = blm.sys, g.sys
    b = param_to_var(
        b, :PBLH, :USTAR, :HFLUX, :EFLUX, :PS, :T2M,
        :QV2M, :z_agl, :z2lev, :x_trans, :y_trans
    )

    # Compute Z_agl and dZ/dlev via hypsometric equation using connected BLM
    # parameters (b.PS, b.T2M, b.QV2M) and Ap/Bp coefficients.
    # Avoids raw _itp interpolators which are incompatible with SDE compilation.
    @constants _Rd_blm = 287.05 [
        unit = u"J/(kg*K)", description = "Specific gas constant for dry air",
    ]
    @constants _g_blm = 9.80665 [
        unit = u"m/s^2", description = "Gravitational acceleration",
    ]
    @constants _Pu_blm = 1.0 [unit = u"Pa", description = "Pressure unit"]

    ℓ = ParentScope(m.lev)

    # Surface virtual temperature from already-connected BLM parameters
    Tv_sfc = b.T2M * (1 + 0.61 * b.QV2M)

    # Pressure at edge `ℓ` from Ap/Bp hybrid coefficients.  Matches GEOSFP's
    # edge convention: ℓ=1 is the surface (P=PS), so Z_agl_expr is anchored
    # at zero on the ground.  Tv_sfc is used as the layer-mean stand-in to
    # keep this SDE-safe (no interpolator sampling at integer levels); the
    # approximation is most accurate near the boundary layer, which is what
    # BoundaryLayerMixingKC consumes.
    P_at_lev = _Pu_blm * Ap(ℓ) + Bp(ℓ) * b.PS

    Z_agl_expr = (_Rd_blm * Tv_sfc / _g_blm) * log(b.PS / P_at_lev)

    # dZ/dlev via pressure derivative (centered difference on Ap/Bp)
    Δℓ = 0.5
    P_plus = _Pu_blm * Ap(ℓ + Δℓ) + Bp(ℓ + Δℓ) * b.PS
    P_minus = _Pu_blm * Ap(ℓ - Δℓ) + Bp(ℓ - Δℓ) * b.PS
    dPdlev = (P_plus - P_minus) / (2 * Δℓ)
    dZdlev_expr = -(_Rd_blm * Tv_sfc / _g_blm) * dPdlev / P_at_lev

    return ConnectorSystem(
        [
            b.PBLH ~ m.A1₊PBLH,
            b.USTAR ~ m.A1₊USTAR,
            b.HFLUX ~ m.A1₊HFLUX,
            b.EFLUX ~ m.A1₊EFLUX,
            b.PS ~ m.I3₊PS,
            b.T2M ~ m.A1₊T2M,
            b.QV2M ~ m.A1₊QV2M,
            b.x_trans ~ 1 / m.δxδlon,
            b.y_trans ~ 1 / m.δyδlat,
            b.z_agl ~ Z_agl_expr,
            b.z2lev ~ 1 / dZdlev_expr,
        ],
        b,
        m
    )
end

function EarthSciMLBase.couple2(p::PuffCoupler, b::BoundaryLayerMixingKCCoupler)
    sys_p = p.sys
    sys_b = b.sys
    return operator_compose(sys_p, sys_b)
end

function EarthSciMLBase.couple2(p::PuffCoupler, w::WRFCoupler)
    p, w = p.sys, w.sys
    p = param_to_var(p, :v_lon, :v_lat, :v_lev, :x_trans, :y_trans, :lev_trans)
    w = param_to_var(w, :lon, :lat, :lev)

    @constants c1 = 1.0 [unit = u"kg/m^2/s^2"]
    @constants c2 = 1.0 [unit = u"m^2/kg*s^2"]

    return ConnectorSystem(
        [
            w.lon ~ p.lon,
            w.lat ~ p.lat,
            w.lev ~ clamp(p.lev, 1, 42),
            p.v_lon ~ w.U,
            p.v_lat ~ w.V,
            p.v_lev ~ w.W * c1,
            p.x_trans ~ 1 / w.δxδlon,
            p.y_trans ~ 1 / w.δyδlat,
            p.lev_trans ~ (1 / w.δzδlev) * c2,
        ],
        p,
        w
    )
end

function EarthSciMLBase.get_needed_vars(
        ::AdvectionOperator, csys, mtk_sys, domain::EarthSciMLBase.DomainInfo
    )
    found = 0
    windvars = []
    for sys in csys.systems
        if EarthSciMLBase.get_coupletype(sys) == GEOSFPCoupler
            found += 1
            push!(
                windvars, sys.A3dyn₊U, sys.A3dyn₊V, sys.A3dyn₊OMEGA,
                sys.δxδlon, sys.δyδlat, sys.δPδlev
            )
        end
    end
    if found == 0
        error("Could not find a source of wind data in the coupled system. Valid sources are currently {EarthSciData.GEOSFP}.")
    elseif found > 1
        error("Found multiple sources of wind data in the coupled system. Valid sources are currently {EarthSciData.GEOSFP}")
    end
    return vcat(windvars)
end

function EarthSciMLBase.get_needed_vars(
        ::PBLMixingCallback, csys, mtk_sys, domain::EarthSciMLBase.DomainInfo
    )
    found = 0
    pblvars = []
    for sys in csys.systems
        if EarthSciMLBase.get_coupletype(sys) == GEOSFPCoupler
            found += 1
            # need PBLH: PBL height (m) and area transform factors
            push!(pblvars, sys.A1₊PBLH, sys.δxδlon, sys.δyδlat)
        end
    end
    if found == 0
        error("Could not find a source of PBL data in the coupled system. Valid sources are currently {EarthSciData.GEOSFP}.")
    elseif found > 1
        error("Found multiple sources of PBL data in the coupled system. Valid sources are currently {EarthSciData.GEOSFP}")
    end
    return vcat(pblvars)
end

function EarthSciMLBase.couple2(s12::Sofiev2012PlumeRiseCoupler, gfp::GEOSFPCoupler)
    s12, gfp = s12.sys, gfp.sys

    κ = 287.05 / 1004.67                    # [-]    Poisson exponent Rd/cp (dry air)

    LMIN, LMAX = 1.0, 72.0                  # [-]    valid model-level range

    p0 = 1.0e5                             # [Pa]   reference sea-level pressure

    τ = ParentScope(gfp.t_ref)                # [s]    reference time
    λ = ParentScope(gfp.lon)                  # [rad]  long
    φ = ParentScope(gfp.lat)                  # [rad]  lat

    T_itp    = interp_callable(gfp, :I3₊T;    parent_scope = true)   # [K]
    QV_itp   = interp_callable(gfp, :I3₊QV;   parent_scope = true)   # [kg/kg]
    PS_itp   = interp_callable(gfp, :I3₊PS;   parent_scope = true)   # [Pa]
    T2M_itp  = interp_callable(gfp, :A1₊T2M;  parent_scope = true)   # [K]
    QV2M_itp = interp_callable(gfp, :A1₊QV2M; parent_scope = true)   # [kg/kg]
    PBLH_itp = interp_callable(gfp, :A1₊PBLH; parent_scope = true)   # [m]

    Rd = s12.Rd                            # [J/(kg*K)] dry-air gas constant
    g = s12.g                             # [m s^-2]   gravitational acceleration
    Punit = s12.Punit                         # [Pa]       pressure unit (=1 Pa)

    softclamp = (x, lo, hi) -> ifelse(x < lo, lo, ifelse(x > hi, hi, x))

    # Virtual potential temperature θv(ℓ) evaluated at simulation level ℓ.
    # ℓ is the edge coordinate of the Ap/Bp tables (ℓ=1 is the surface);
    # T/QV are sampled at the same ℓ — for non-integer ℓ this is the linear
    # interpolation across the netCDF layer-center grid.
    θv_at = ℓ -> begin
        T = T_itp(τ + t, λ, φ, ℓ)                           # [K]     temperature at level ℓ
        qv = QV_itp(τ + t, λ, φ, ℓ)                          # [kg/kg] water-vapor mixing ratio at ℓ
        PS = PS_itp(τ + t, λ, φ)                             # [Pa]    surface pressure
        P = Punit * Ap(ℓ) + Bp(ℓ) * PS                       # [Pa]    pressure at edge ℓ
        Tv = T * (1 + 0.61 * qv)                               # [K]     virtual temperature
        Tv * ((p0 * Punit) / P)^κ                            # [K]     virtual potential temperature θv
    end

    # Geopotential height above ground Z(ℓ) via a one-layer hypsometric
    # approximation: Tv̄ ≈ ½(Tv(ℓ) + Tv_sfc) and a single ln(PS/P(ℓ)).  This
    # is the same approximation Sofiev probes use over the lower troposphere
    # — accurate near the PBL, degrading aloft.  Anchored at Z(1)=0 by the
    # edge convention (matches gfp.Z_agl).
    Z_at = ℓ -> begin
        Tv = T_itp(τ + t, λ, φ, ℓ) * (1 + 0.61 * QV_itp(τ + t, λ, φ, ℓ))   # [K]  virtual temp at level ℓ
        Tv2 = T2M_itp(τ + t, λ, φ) * (1 + 0.61 * QV2M_itp(τ + t, λ, φ))   # [K]  virtual temp at 2 m
        Tv̄ = 0.5 * (Tv + Tv2)                                               # [K]  surface-to-ℓ mean Tv
        PS = PS_itp(τ + t, λ, φ)                                          # [Pa] surface pressure
        P = Punit * Ap(ℓ) + Bp(ℓ) * PS                                     # [Pa] pressure at edge ℓ
        (Rd * Tv̄ / g) * log(PS / P)                                        # [m]  hypsometric height AGL
    end

    # Map height H [m] → model level ℓ [-] via the exact GEOS-FP grid
    # inversion: height→pressure is analytic (hypsometric) and pressure→level
    # is the exact piecewise-linear inverse `lev_from_pressure`.  The layer-mean
    # virtual temperature Tv̄ depends weakly on ℓ, so a 2-pass fixed point is
    # used, seeded from the 2-m virtual temperature.  Edge convention: ℓ=1 is
    # the surface, so no half-level shift is applied to the inverted level.
    lev_from_height = H -> begin
        PS = PS_itp(τ + t, λ, φ)                                           # [Pa]
        Tv2 = T2M_itp(τ + t, λ, φ) * (1 + 0.61 * QV2M_itp(τ + t, λ, φ))     # [K] 2-m virtual temp
        # pass 1 — seed Tv̄ with the 2-m virtual temperature
        ℓ1 = softclamp(
            lev_from_pressure(PS * exp(-g * H / (Rd * Tv2)), PS), LMIN, LMAX)
        # pass 2 — refine Tv̄ as the surface-to-ℓ mean virtual temperature
        Tvℓ = T_itp(τ + t, λ, φ, ℓ1) * (1 + 0.61 * QV_itp(τ + t, λ, φ, ℓ1)) # [K]
        Tv̄ = 0.5 * (Tvℓ + Tv2)                                             # [K]
        softclamp(
            lev_from_pressure(PS * exp(-g * H / (Rd * Tv̄)), PS), LMIN, LMAX)
    end

    return ConnectorSystem(
        [
            s12.H_abl ~ PBLH_itp(τ + t, λ, φ),  # [m] atmospheric boundary layer height

            # Free-troposphere buoyancy frequency N(t).  θv is probed on a
            # stencil symmetric in *height* (z_ft ± Δz) rather than in level:
            # a level-symmetric stencil is height-asymmetric over variable
            # layer thicknesses, which biases dθv/dz away from z_ft.  Δz scales
            # with the boundary-layer depth so both probes stay above ground.
            s12.N_ft ~ begin
                z_ft = 2 * s12.H_abl                                # [m] probe height in FT
                Δz = 0.5 * s12.H_abl                                # [m] half-stencil
                ℓp = lev_from_height(z_ft + Δz)                     # [-] upper probe level
                ℓm = lev_from_height(z_ft - Δz)                     # [-] lower probe level
                ℓc = lev_from_height(z_ft)                          # [-] centre level
                dθv_dz = (θv_at(ℓp) - θv_at(ℓm)) / (Z_at(ℓp) - Z_at(ℓm))  # [K m^-1]
                θc = θv_at(ℓc)                                      # [K]
                N2 = (g / θc) * dθv_dz                              # [s^-2]
                sqrt(0.5 * (N2 + abs(N2)))                          # [s^-1] ensure N ≥ 0
            end,
        ],
        s12,
        gfp;
        initialization_equations = [s12.H_p ~ gfp.Z_agl],
    )
end

function EarthSciMLBase.couple2(gd::GaussianPGBCoupler, g::GEOSFPCoupler)
    d, m = gd.sys, g.sys
    d = param_to_var(d, :U10M, :V10M, :SWGDN, :CLDTOT, :T2M, :T10M)

    # Compute Z_agl from GEOSFP interpolators (hypsometric equation)
    @constants _Rd_pgb = 287.05 [
        unit = u"J/(kg*K)", description = "Specific gas constant for dry air",
    ]
    @constants _g_pgb = 9.80665 [
        unit = u"m/s^2", description = "Gravitational acceleration",
    ]
    @constants _Pu_pgb = 1.0 [unit = u"Pa", description = "Pressure unit"]
    τ = ParentScope(m.t_ref)
    λ = ParentScope(m.lon)
    φ = ParentScope(m.lat)
    ℓ = ParentScope(m.lev)
    T_itp    = interp_callable(m, :I3₊T;    parent_scope = true)
    QV_itp   = interp_callable(m, :I3₊QV;   parent_scope = true)
    PS_itp   = interp_callable(m, :I3₊PS;   parent_scope = true)
    T2M_itp  = interp_callable(m, :A1₊T2M;  parent_scope = true)
    QV2M_itp = interp_callable(m, :A1₊QV2M; parent_scope = true)
    Tv = T_itp(τ + t, λ, φ, ℓ) * (1 + 0.61 * QV_itp(τ + t, λ, φ, ℓ))
    Tv2 = T2M_itp(τ + t, λ, φ) * (1 + 0.61 * QV2M_itp(τ + t, λ, φ))
    Tv̄ = 0.5 * (Tv + Tv2)
    PS_v = PS_itp(τ + t, λ, φ)
    # Edge convention (matches gfp.Z_agl): pressure at edge ℓ, ℓ=1 is the
    # surface so Z_agl(1)=0.  Tv̄ kept as the 2-point average.
    P_at_lev = _Pu_pgb * Ap(ℓ) + Bp(ℓ) * PS_v
    Z_agl_expr = (_Rd_pgb * Tv̄ / _g_pgb) * log(PS_v / P_at_lev)

    return ConnectorSystem(
        [
            d.lat ~ m.lat
            d.lon ~ m.lon
            d.U10M ~ m.A1₊U10M
            d.V10M ~ m.A1₊V10M
            d.SWGDN ~ m.A1₊SWGDN
            d.CLDTOT ~ m.A1₊CLDTOT
            d.T2M ~ m.A1₊T2M
            d.T10M ~ m.A1₊T10M
            d.z_agl ~ Z_agl_expr
        ],
        d,
        m
    )
end

function EarthSciMLBase.couple2(b::BoundaryLayerMixingKCCoupler, gk::GaussianKCCoupler)
    b, gk = b.sys, gk.sys

    # z_agl is provided from BLM (which gets it from GEOSFP via param_to_var)
    return ConnectorSystem(
        [
            gk.σu_x ~ b.σu
            gk.σu_y ~ b.σv
            gk.z_agl ~ b.z_agl
        ], b, gk
    )
end

end
