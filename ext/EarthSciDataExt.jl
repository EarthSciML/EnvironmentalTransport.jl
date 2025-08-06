module EarthSciDataExt
using DocStringExtensions
import EarthSciMLBase
using EarthSciMLBase: param_to_var, ConnectorSystem, CoupledSystem, get_coupletype
using EarthSciData: GEOSFPCoupler
using EnvironmentalTransport: PuffCoupler, GaussianPGBCoupler, GaussianHCoupler, AdvectionOperator, Sofiev2012PlumeRiseCoupler
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

    s12.H_abl = ParentScope(gfp.A1₊PBLH_itp)(ParentScope(gfp.t_ref),
        ParentScope(gfp.lon), ParentScope(gfp.lat))

    ConnectorSystem([], s12, gfp)
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

function EarthSciMLBase.couple2(gd::GaussianHCoupler, g::GEOSFPCoupler)
    d, m = gd.sys, g.sys
    Δλ = deg2rad(5.0)
    Δφ = deg2rad(4.0)
    ConnectorSystem([
        d.lat ~ m.lat
        d.lon ~ m.lon
        d.lev ~ m.lev
        d.U ~ m.A3dyn₊U
        d.UE  ~ ParentScope(m.A3dyn₊U_itp)(t, ParentScope(m.lon) + Δλ/2, ParentScope(m.lat), ParentScope(m.lev))
        d.UW  ~ ParentScope(m.A3dyn₊U_itp)(t, ParentScope(m.lon) - Δλ/2, ParentScope(m.lat), ParentScope(m.lev))
        d.UN  ~ ParentScope(m.A3dyn₊U_itp)(t, ParentScope(m.lon), ParentScope(m.lat) + Δφ/2, ParentScope(m.lev))
        d.US  ~ ParentScope(m.A3dyn₊U_itp)(t, ParentScope(m.lon), ParentScope(m.lat) - Δφ/2, ParentScope(m.lev))
        d.V ~ m.A3dyn₊V
        d.VE  ~ ParentScope(m.A3dyn₊V_itp)(t, ParentScope(m.lon) + Δλ/2, ParentScope(m.lat), ParentScope(m.lev))
        d.VW  ~ ParentScope(m.A3dyn₊V_itp)(t, ParentScope(m.lon) - Δλ/2, ParentScope(m.lat), ParentScope(m.lev))
        d.VN  ~ ParentScope(m.A3dyn₊V_itp)(t, ParentScope(m.lon), ParentScope(m.lat) + Δφ/2, ParentScope(m.lev))
        d.VS  ~ ParentScope(m.A3dyn₊V_itp)(t, ParentScope(m.lon), ParentScope(m.lat) - Δφ/2, ParentScope(m.lev))
        d.QV2M ~ m.A1₊QV2M
        d.T2M   ~ m.A1₊T2M
        d.T  ~ m.I3₊T
        d.P  ~ m.P
        d.PS  ~ m.I3₊PS
        d.QV  ~ m.I3₊QV
    ], d, m)
end

function EarthSciMLBase.couple2(
        gd::GaussianHCoupler,
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
