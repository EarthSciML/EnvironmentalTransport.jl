module EarthSciDataExt
using DocStringExtensions
import EarthSciMLBase
using EarthSciMLBase: param_to_var, ConnectorSystem, CoupledSystem, get_coupletype
using EarthSciData: GEOSFPCoupler, Ap, Bp
using EnvironmentalTransport: PuffCoupler, GaussianPGBCoupler, GaussianSDCoupler, AdvectionOperator, Sofiev2012PlumeRiseCoupler
using EnvironmentalTransport
using ModelingToolkit: ParentScope, get_defaults, @unpack
using ModelingToolkit: t

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

function EarthSciMLBase.couple2(s12::Sofiev2012PlumeRiseCoupler, gfp::GEOSFPCoupler)
    s12, gfp = s12.sys, gfp.sys

    κ     = 287.05 / 1004.67                    # [-]    Poisson exponent Rd/cp (dry air)
    Δℓ_newton = 0.5                             # [level] Newton step for H↔ℓ mapping (centered)
    Δℓ_grad   = 1.0                             # [level] offset for centered dθv/dz

    LMIN, LMAX = 1.0 + Δℓ_newton, 72.0 - Δℓ_newton  # [-]
    
    p0    = 1.0e5                             # [Pa]   reference sea-level pressure

    τ = ParentScope(gfp.t_ref)                # [s]    reference time
    λ = ParentScope(gfp.lon)                  # [rad]  long
    φ = ParentScope(gfp.lat)                  # [rad]  lat

    T_itp    = ParentScope(gfp.I3₊T_itp)      # [K]       temperature
    QV_itp   = ParentScope(gfp.I3₊QV_itp)     # [kg/kg]   water vapor mixing ratio
    PS_itp   = ParentScope(gfp.I3₊PS_itp)     # [Pa]      surface pressure
    T2M_itp  = ParentScope(gfp.A1₊T2M_itp)    # [K]       2-m temperature
    QV2M_itp = ParentScope(gfp.A1₊QV2M_itp)   # [kg/kg]   2-m water vapor mixing ratio

    Rd    = s12.Rd                            # [J/(kg*K)] dry-air gas constant
    g     = s12.g                             # [m s^-2]   gravitational acceleration
    Punit = s12.Punit                         # [Pa]       pressure unit (=1 Pa)

    softclamp = (x, lo, hi) -> ifelse(x < lo, lo, ifelse(x > hi, hi, x))

    # Virtual potential temperature θv(ℓ) at hybrid mid-level ℓ
    θv_at = ℓ -> begin
        T  = T_itp(τ + t, λ, φ, ℓ)                           # [K]     temperature at mid-level ℓ
        qv = QV_itp(τ + t, λ, φ, ℓ)                          # [kg/kg] water-vapor mixing ratio at ℓ
        PS = PS_itp(τ + t, λ, φ)                             # [Pa]    surface pressure
        P  = Punit * Ap(ℓ + 0.5) + Bp(ℓ + 0.5) * PS          # [Pa]    hybrid mid-level pressure
        Tv = T * (1 + 0.61*qv)                               # [K]     virtual temperature
        Tv * ((p0 * Punit) / P)^κ                            # [K]     virtual potential temperature θv
    end

    # Geopotential height above ground Z(ℓ) via hypsometric
    Z_at = ℓ -> begin
        Tv  = T_itp(τ + t, λ, φ, ℓ) * (1 + 0.61 * QV_itp(τ + t, λ, φ, ℓ))   # [K]  virtual temp at mid-level ℓ
        Tv2 = T2M_itp(τ + t, λ, φ)   * (1 + 0.61 * QV2M_itp(τ + t, λ, φ))   # [K]  virtual temp at 2 m
        Tv̄ = 0.5 * (Tv + Tv2)                                               # [K]  layer-mean virtual temperature
        PS   = PS_itp(τ + t, λ, φ)                                          # [Pa] surface pressure
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

    ConnectorSystem([
        s12.H_abl ~ ParentScope(gfp.A1₊PBLH_itp)(τ + t, λ, φ),  # [m] atmospheric boundary layer height

        s12.lev_p ~ lev_from_height(s12.H_p),                   # [-]  plume-top level

        # Free-troposphere buoyancy frequency N(t): probe near 2 × PBL height
        s12.N_ft  ~ begin
            lev_ft = lev_from_height(2 * s12.H_abl)             # [-] mid-level near FT
            θp = θv_at(lev_ft + Δℓ_grad)                        # [K]
            θm = θv_at(lev_ft - Δℓ_grad)                        # [K]
            Zp = Z_at(lev_ft + Δℓ_grad)                         # [m]
            Zm = Z_at(lev_ft - Δℓ_grad)                         # [m]
            dθv_dz = (θp - θm) / (Zp - Zm)                      # [K m^-1]
            θc     = θv_at(lev_ft)                              # [K]
            N2     = (g / θc) * dθv_dz                          # [s^-2]
            sqrt(0.5 * (N2 + abs(N2)))                          # [s^-1] ensure N ≥ 0
        end
    ], s12, gfp)
end

function EarthSciMLBase.couple2(gd::GaussianPGBCoupler, g::GEOSFPCoupler)
    d, m = gd.sys, g.sys
    d = param_to_var(d, :U10M, :V10M, :SWGDN, :CLDTOT, :QV2M, :T2M, :T10M, :T, :P, :PS, :QV)

    ConnectorSystem([
        d.lat ~ m.lat
        d.lon ~ m.lon
        d.U10M ~ m.A1₊U10M
        d.V10M  ~ m.A1₊V10M
        d.SWGDN ~ m.A1₊SWGDN
        d.CLDTOT ~ m.A1₊CLDTOT
        d.QV2M ~ m.A1₊QV2M
        d.T2M   ~ m.A1₊T2M
        d.T10M  ~ m.A1₊T10M
        d.T  ~ m.I3₊T
        d.P  ~ m.P
        d.PS  ~ m.I3₊PS
        d.QV  ~ m.I3₊QV
    ], d, m)
end

function EarthSciMLBase.couple2(gd::GaussianSDCoupler, g::GEOSFPCoupler)
    d, m = gd.sys, g.sys
    d = param_to_var(d, :UE, :UW, :UN, :US, :VE, :VW, :VN, :VS, :QV2M, :T2M, :T, :P, :PS, :QV)

    ConnectorSystem([
        d.lat ~ m.lat
        d.UE  ~ ParentScope(m.A3dyn₊U_itp)(ParentScope(m.t_ref) + t, ParentScope(m.lon) + d.Δλ/2, ParentScope(m.lat), ParentScope(m.lev))
        d.UW  ~ ParentScope(m.A3dyn₊U_itp)(ParentScope(m.t_ref) + t, ParentScope(m.lon) - d.Δλ/2, ParentScope(m.lat), ParentScope(m.lev))
        d.UN  ~ ParentScope(m.A3dyn₊U_itp)(ParentScope(m.t_ref) + t, ParentScope(m.lon), ParentScope(m.lat) + d.Δφ/2, ParentScope(m.lev))
        d.US  ~ ParentScope(m.A3dyn₊U_itp)(ParentScope(m.t_ref) + t, ParentScope(m.lon), ParentScope(m.lat) - d.Δφ/2, ParentScope(m.lev))
        d.VE  ~ ParentScope(m.A3dyn₊V_itp)(ParentScope(m.t_ref) + t, ParentScope(m.lon) + d.Δλ/2, ParentScope(m.lat), ParentScope(m.lev))
        d.VW  ~ ParentScope(m.A3dyn₊V_itp)(ParentScope(m.t_ref) + t, ParentScope(m.lon) - d.Δλ/2, ParentScope(m.lat), ParentScope(m.lev))
        d.VN  ~ ParentScope(m.A3dyn₊V_itp)(ParentScope(m.t_ref) + t, ParentScope(m.lon), ParentScope(m.lat) + d.Δφ/2, ParentScope(m.lev))
        d.VS  ~ ParentScope(m.A3dyn₊V_itp)(ParentScope(m.t_ref) + t, ParentScope(m.lon), ParentScope(m.lat) - d.Δφ/2, ParentScope(m.lev))
        d.QV2M ~ m.A1₊QV2M
        d.T2M   ~ m.A1₊T2M
        d.T  ~ m.I3₊T
        d.P  ~ m.P
        d.PS  ~ m.I3₊PS
        d.QV  ~ m.I3₊QV
    ], d, m)
end

end
