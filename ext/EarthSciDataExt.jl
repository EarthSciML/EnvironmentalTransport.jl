module EarthSciDataExt
using DocStringExtensions
import EarthSciMLBase
using EarthSciMLBase: param_to_var, ConnectorSystem, CoupledSystem, get_coupletype
using EarthSciData: GEOSFPCoupler
using EnvironmentalTransport: PuffCoupler, AdvectionOperator, Sofiev2012PlumeRiseCoupler, PBLMixingOperator
using EnvironmentalTransport
using ModelingToolkit: ParentScope

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

function EarthSciMLBase.get_needed_vars(
        ::PBLMixingOperator, csys, mtk_sys, domain::EarthSciMLBase.DomainInfo)
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

    s12.H_abl = ParentScope(gfp.A1₊PBLH_itp)(ParentScope(gfp.t_ref),
        ParentScope(gfp.lon), ParentScope(gfp.lat))

    ConnectorSystem([], s12, gfp)
end

end
