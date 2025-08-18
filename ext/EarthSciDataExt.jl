module EarthSciDataExt
using DocStringExtensions
import EarthSciMLBase
using EarthSciMLBase: param_to_var, ConnectorSystem, CoupledSystem, get_coupletype
using EarthSciData: GEOSFPCoupler, Ap, Bp
using EnvironmentalTransport: PuffCoupler, GaussianPGBCoupler, GaussianSDCoupler, AdvectionOperator, Sofiev2012PlumeRiseCoupler
using EnvironmentalTransport
using ModelingToolkit: ParentScope
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

    εZ_m  = 1e-6 * s12.h_to_lev                     # [m]  use to keep (Zp - Zm) away from zero
    εmlev = 1e-12 * s12.h_to_lev                    # [m]  use to keep dZ/dℓ away from zero
    κ    = 287.05 / 1004.67                         # [-]  Poisson exponent Rd/cp
    Δℓ_newton = 0.5                                 # half-step for mapping H↔ℓ
    Δℓ_grad   = 1.0                                 # one full level for dθᵥ/dz at mid-level
    LMIN, LMAX = 1.0 + Δℓ_newton, 72.0 - Δℓ_newton  # [-]  valid mid-level range
    εPfac = 1e-9                                    # [-]  tiny factor
    p0    = 1.0e5                                   # [Pa] reference sea-level pressure

    τ = ParentScope(gfp.t_ref)                  # [s]   reference time
    λ = ParentScope(gfp.lon)                    # [rad] longitude
    φ = ParentScope(gfp.lat)                    # [rad] latitude

    T_itp    = ParentScope(gfp.I3₊T_itp)        # [K]     temperature
    QV_itp   = ParentScope(gfp.I3₊QV_itp)       # [kg/kg] water vapor mixing ratio
    PS_itp   = ParentScope(gfp.I3₊PS_itp)       # [Pa]    surface pressure
    T2M_itp  = ParentScope(gfp.A1₊T2M_itp)      # [K]     2-m temperature
    QV2M_itp = ParentScope(gfp.A1₊QV2M_itp)     # [kg/kg] 2-m water vapor mixing ratio

    Rd     = ParentScope(gfp.Rd_v)            # [J/(kg*K)] dry-air gas constant
    g      = ParentScope(gfp.g_v)             # [m/s^2]    gravity
    P_unit = ParentScope(gfp.P_unit_v)        # [Pa]       pressure unit (1 Pa)

    softclamp = (x, lo, hi) -> ifelse(x < lo, lo, ifelse(x > hi, hi, x))

    # Virtual potential temperature at hybrid mid-level ℓ
    θv_at = ℓ -> begin
        T  = T_itp(τ, λ, φ, ℓ)                      # [K]
        qv = QV_itp(τ, λ, φ, ℓ)                     # [kg/kg]
        PS = PS_itp(τ, λ, φ)                        # [Pa]
        P = P_unit*Ap(ℓ + 0.5) + Bp(ℓ + 0.5)*PS     # [Pa] mid-level pressure
        Tv = T * (1 + 0.61*qv)                      # [K]  virtual temperature
        Tv * ((p0*P_unit) / (P + εPfac*PS))^κ       # [K]  virtual potential temperature
    end

    # Geopotential height AGL at level edge ℓ±1/2 via hypsometric
    Z_at = ℓ -> begin
        Tv  = T_itp(τ, λ, φ, ℓ) * (1 + 0.61*QV_itp(τ, λ, φ, ℓ))     # [K]
        Tv2 = T2M_itp(τ, λ, φ) * (1 + 0.61*QV2M_itp(τ, λ, φ))       # [K]
        Tv̄ = 0.5*(Tv + Tv2)                                         # [K] layer-mean virtual T
        PS   = PS_itp(τ, λ, φ)                                      # [Pa]
        Pmid = P_unit*Ap(ℓ + 0.5) + Bp(ℓ + 0.5)*PS                  # [Pa] mid-level pressure
        (Rd * Tv̄ / g) * log(PS / (Pmid + εPfac*PS))                 # [m]  height AGL
    end

    # Local meters-per-level using a centered difference
    m_per_level_at = ℓ -> (Z_at(ℓ + Δℓ_newton) - Z_at(ℓ - Δℓ_newton)) / (2Δℓ_newton)  # [m/level]


    # One Newton step from height to level, clamped to the valid range.
    # Add more iterations for higher accuracy.
    lev_from_height = H -> begin                            # H: [m]
        ℓ0 = softclamp(H / s12.h_to_lev, LMIN, LMAX)        # [-]
        Z0 = Z_at(ℓ0)                                       # [m]
        dZdℓ = m_per_level_at(ℓ0) + εmlev                   # [m/level]
        softclamp(ℓ0 + (H - Z0)/dZdℓ, LMIN, LMAX)           # [-]
    end

    # Evaluate near the free troposphere (~2 × PBL height)
    lev_ft = lev_from_height(2 * s12.H_abl)                 # [-]

    # Centered vertical gradient of θv at lev_ft
    θp = θv_at(lev_ft + Δℓ_grad); θm = θv_at(lev_ft - Δℓ_grad)      # [K]
    Zp = Z_at(lev_ft + Δℓ_grad);  Zm = Z_at(lev_ft - Δℓ_grad)       # [m]
    dθv_dz = (θp - θm) / ((Zp - Zm) + εZ_m)                         # [K/m]

    θc = θv_at(lev_ft)                                      # [K]
    N2 = (g / θc) * dθv_dz                                  # [1/s^2]
    N  = sqrt(0.5 * (N2 + abs(N2)))                         # [1/s]

    ConnectorSystem([
        s12.H_abl ~ ParentScope(gfp.A1₊PBLH_itp)(τ, λ, φ),  # [m]
        s12.lev_p    ~ lev_from_height(s12.H_p),
        s12.N_ft  ~ N,                                      # [1/s]
    ], s12, gfp)
end

function EarthSciMLBase.couple2(gd::GaussianPGBCoupler, g::GEOSFPCoupler)
    d, m = gd.sys, g.sys
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

function EarthSciMLBase.couple2(
        gd::GaussianPGBCoupler,
        puff::PuffCoupler,
)
    g, p = gd.sys, puff.sys

    ConnectorSystem(
        [
            g.lon ~ p.lon,
            g.lat ~ p.lat,
        ],
        g, p
    )
end

function EarthSciMLBase.couple2(gd::GaussianSDCoupler, g::GEOSFPCoupler)
    d, m = gd.sys, g.sys
    ConnectorSystem([
        d.lat ~ m.lat
        d.lon ~ m.lon
        d.lev ~ m.lev
        d.U ~ m.A3dyn₊U
        d.UE  ~ ParentScope(m.A3dyn₊U_itp)(ParentScope(m.t_ref) + t, ParentScope(m.lon) + d.Δλ/2, ParentScope(m.lat), ParentScope(m.lev))
        d.UW  ~ ParentScope(m.A3dyn₊U_itp)(ParentScope(m.t_ref) + t, ParentScope(m.lon) - d.Δλ/2, ParentScope(m.lat), ParentScope(m.lev))
        d.UN  ~ ParentScope(m.A3dyn₊U_itp)(ParentScope(m.t_ref) + t, ParentScope(m.lon), ParentScope(m.lat) + d.Δφ/2, ParentScope(m.lev))
        d.US  ~ ParentScope(m.A3dyn₊U_itp)(ParentScope(m.t_ref) + t, ParentScope(m.lon), ParentScope(m.lat) - d.Δφ/2, ParentScope(m.lev))
        d.V ~ m.A3dyn₊V
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

function EarthSciMLBase.couple2(
        gd::GaussianSDCoupler,
        puff::PuffCoupler,
)
    g, p = gd.sys, puff.sys

    ConnectorSystem(
        [
            g.lon ~ p.lon,
            g.lat ~ p.lat,
        ],
        g, p
    )
end

end
