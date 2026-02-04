module EarthSciDataExt

using DocStringExtensions
import EarthSciMLBase
using EarthSciMLBase: param_to_var, ConnectorSystem, CoupledSystem, get_coupltype, operator_compose
using EarthSciData: GEOSFPCoupler, WRFCoupler, Ap, Bp
using EnvironmentalTransport: PuffCoupler, GaussianPGBCoupler, GaussianKCCoupler,
    BoundaryLayerMixingKCCoupler, AdvectionOperator, Sofiev2012PlumeRiseCoupler
using ModelingToolkit: ParentScope, get_defaults, @unpack
using ModelingToolkit: t
using ModelingToolkit: @parameters, @variables, @constants
using DynamicQuantities: @u_str


function EarthSciMLBase.couple2(p::PuffCoupler, g::GEOSFPCoupler)
    p, g = p.sys, g.sys
    p = param_to_var(p, :v_lon, :v_lat, :v_lev, :x_trans, :y_trans, :lev_trans)
    g = param_to_var(g, :lon, :lat, :lev)
    ConnectorSystem(
        [g.lon ~ p.lon
         g.lat ~ p.lat
         g.lev ~ clamp(p.lev, 1, 72)
         p.v_lon ~ g.A3dyn₊U
         p.v_lat ~ g.A3dyn₊V
         p.v_lev ~ g.A3dyn₊OMEGA
         p.x_trans ~ 1 / g.δxδlon
         p.y_trans ~ 1 / g.δyδlat
         p.lev_trans ~ 1 / g.δPδlev],
        p,
        g)
end

function EarthSciMLBase.couple2(blm::BoundaryLayerMixingKCCoupler, g::GEOSFPCoupler)
    t, m = blm.sys, g.sys
    t = param_to_var(t, :PBLH, :USTAR, :HFLUX, :EFLUX, :PS, :T2M, :QV2M, :z_agl, :z2lev, :x_trans, :y_trans)
    
    ConnectorSystem([
        t.PBLH   ~ m.A1₊PBLH,
        t.USTAR  ~ m.A1₊USTAR,
        t.HFLUX  ~ m.A1₊HFLUX,
        t.EFLUX  ~ m.A1₊EFLUX,
        t.PS     ~ m.I3₊PS,
        t.T2M    ~ m.A1₊T2M,
        t.QV2M   ~ m.A1₊QV2M,
        t.x_trans ~ 1 / m.δxδlon,
        t.y_trans ~ 1 / m.δyδlat,
        t.z_agl ~ m.Z_agl,
        t.z2lev ~ 1 / m.δZδlev
    ], t, m)
end

function EarthSciMLBase.couple2(p::PuffCoupler, b::BoundaryLayerMixingKCCoupler)
    sys_p = p.sys
    sys_b = b.sys
    operator_compose(sys_p, sys_b)
end


function EarthSciMLBase.couple2(p::PuffCoupler, w::WRFCoupler)
    p, w = p.sys, w.sys
    p = param_to_var(p, :v_lon, :v_lat, :v_lev, :x_trans, :y_trans, :lev_trans)
    w = param_to_var(w, :lon, :lat, :lev)

    @constants c1 = 1.0 [unit = u"kg/m^2/s^2"]
    @constants c2 = 1.0 [unit = u"m^2/kg*s^2"]

    ConnectorSystem([
        w.lon ~ p.lon,
        w.lat ~ p.lat,
        w.lev ~ clamp(p.lev, 1, 42),
        p.v_lon ~ w.U,
        p.v_lat ~ w.V,
        p.v_lev ~ w.W * c1,
        p.x_trans ~ 1 / w.δxδlon,
        p.y_trans ~ 1 / w.δyδlat,
        p.lev_trans ~ (1 / w.δzδlev) * c2
    ], p, w)
end

function EarthSciMLBase.get_needed_vars(
        ::AdvectionOperator, csys, mtk_sys, domain::EarthSciMLBase.DomainInfo)
    found = 0
    windvars = []
    for sys in csys.systems
        if EarthSciMLBase.get_coupletype(sys) == GEOSFPCoupler
            found += 1
            push!(windvars, sys.A3dyn₊U, sys.A3dyn₊V, sys.A3dyn₊OMEGA,
                sys.δxδlon, sys.δyδlat, sys.δPδlev)
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
        ::PBLMixingCallback, csys, mtk_sys, domain::EarthSciMLBase.DomainInfo)
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
    Δℓ_newton = 0.5                             # [level] Newton step for H↔ℓ mapping (centered)
    Δℓ_grad = 1.0                             # [level] offset for centered dθv/dz

    LMIN, LMAX = 1.0 + Δℓ_newton, 72.0 - Δℓ_newton  # [-]

    p0 = 1.0e5                             # [Pa]   reference sea-level pressure

    τ = ParentScope(gfp.t_ref)                # [s]    reference time
    λ = ParentScope(gfp.lon)                  # [rad]  long
    φ = ParentScope(gfp.lat)                  # [rad]  lat

    T_itp = ParentScope(gfp.I3₊T_itp)      # [K]       temperature
    QV_itp = ParentScope(gfp.I3₊QV_itp)     # [kg/kg]   water vapor mixing ratio
    PS_itp = ParentScope(gfp.I3₊PS_itp)     # [Pa]      surface pressure
    T2M_itp = ParentScope(gfp.A1₊T2M_itp)    # [K]       2-m temperature
    QV2M_itp = ParentScope(gfp.A1₊QV2M_itp)   # [kg/kg]   2-m water vapor mixing ratio

    Rd = s12.Rd                            # [J/(kg*K)] dry-air gas constant
    g = s12.g                             # [m s^-2]   gravitational acceleration
    Punit = s12.Punit                         # [Pa]       pressure unit (=1 Pa)

    softclamp = (x, lo, hi) -> ifelse(x < lo, lo, ifelse(x > hi, hi, x))

    # Virtual potential temperature θv(ℓ) at hybrid mid-level ℓ
    θv_at = ℓ -> begin
        T = T_itp(τ + t, λ, φ, ℓ)                           # [K]     temperature at mid-level ℓ
        qv = QV_itp(τ + t, λ, φ, ℓ)                          # [kg/kg] water-vapor mixing ratio at ℓ
        PS = PS_itp(τ + t, λ, φ)                             # [Pa]    surface pressure
        P = Punit * Ap(ℓ + 0.5) + Bp(ℓ + 0.5) * PS          # [Pa]    hybrid mid-level pressure
        Tv = T * (1 + 0.61*qv)                               # [K]     virtual temperature
        Tv * ((p0 * Punit) / P)^κ                            # [K]     virtual potential temperature θv
    end

    # Geopotential height above ground Z(ℓ) via hypsometric
    Z_at = ℓ -> begin
        Tv = T_itp(τ + t, λ, φ, ℓ) * (1 + 0.61 * QV_itp(τ + t, λ, φ, ℓ))   # [K]  virtual temp at mid-level ℓ
        Tv2 = T2M_itp(τ + t, λ, φ) * (1 + 0.61 * QV2M_itp(τ + t, λ, φ))   # [K]  virtual temp at 2 m
        Tv̄ = 0.5 * (Tv + Tv2)                                               # [K]  layer-mean virtual temperature
        PS = PS_itp(τ + t, λ, φ)                                          # [Pa] surface pressure
        Pmid = Punit * Ap(ℓ + 0.5) + Bp(ℓ + 0.5) * PS                       # [Pa] hybrid mid-level pressure
        (Rd * Tv̄ / g) * log(PS / Pmid)                                      # [m]  hypsometric height AGL
    end

    # Local meters-per-level: dZ/dℓ with a centered difference
    m_per_level_at = ℓ -> (Z_at(ℓ + Δℓ_newton) - Z_at(ℓ - Δℓ_newton)) / (2Δℓ_newton)  # [m level^-1]

    # Map height H [m] → mid-level ℓ [-] with one Newton step
    lev_from_height = H -> begin
        ℓ0 = softclamp(H / s12.h_to_lev, LMIN, LMAX)     # initial guess from linear H→ℓ
        Z0 = Z_at(ℓ0)
        dZdℓ = m_per_level_at(ℓ0)
        softclamp(ℓ0 + (H - Z0) / dZdℓ, LMIN, LMAX)
    end

    ConnectorSystem(
        [
            s12.H_abl ~ ParentScope(gfp.A1₊PBLH_itp)(τ + t, λ, φ),  # [m] atmospheric boundary layer height
            s12.lev_p ~ lev_from_height(s12.H_p),                   # [-]  plume-top level

            # Free-troposphere buoyancy frequency N(t): probe near 2 × PBL height
            s12.N_ft ~ begin
                lev_ft = lev_from_height(2 * s12.H_abl)             # [-] mid-level near FT
                θp = θv_at(lev_ft + Δℓ_grad)                        # [K]
                θm = θv_at(lev_ft - Δℓ_grad)                        # [K]
                Zp = Z_at(lev_ft + Δℓ_grad)                         # [m]
                Zm = Z_at(lev_ft - Δℓ_grad)                         # [m]
                dθv_dz = (θp - θm) / (Zp - Zm)                      # [K m^-1]
                θc = θv_at(lev_ft)                              # [K]
                N2 = (g / θc) * dθv_dz                          # [s^-2]
                sqrt(0.5 * (N2 + abs(N2)))                          # [s^-1] ensure N ≥ 0
            end
        ],
        s12,
        gfp)
end

function EarthSciMLBase.couple2(gd::GaussianPGBCoupler, g::GEOSFPCoupler)
    d, m = gd.sys, g.sys
    d = param_to_var(d, :U10M, :V10M, :SWGDN, :CLDTOT, :T2M, :T10M)

    ConnectorSystem([
        d.lat ~ m.lat
        d.lon ~ m.lon
        d.U10M ~ m.A1₊U10M
        d.V10M  ~ m.A1₊V10M
        d.SWGDN ~ m.A1₊SWGDN
        d.CLDTOT ~ m.A1₊CLDTOT
        d.T2M   ~ m.A1₊T2M
        d.T10M  ~ m.A1₊T10M
        d.z_agl ~ m.Z_agl
    ], d, m)
end

function EarthSciMLBase.couple2(gk::GaussianKCCoupler, g::GEOSFPCoupler)
    d, m = gk.sys, g.sys

    ConnectorSystem([
        d.z_agl ~ m.Z_agl
    ], d, m)
end

function EarthSciMLBase.couple2(b::BoundaryLayerMixingKCCoupler, gk::GaussianKCCoupler)
    b, gk = b.sys, gk.sys

    ConnectorSystem([
        gk.σu_x ~ b.σu
        gk.σu_y ~ b.σv
    ], b, gk)
end

end
