module EarthSciDataExt
using DocStringExtensions
import EarthSciMLBase
using EarthSciMLBase: param_to_var, ConnectorSystem, CoupledSystem, get_coupletype
using EarthSciData: GEOSFPCoupler
using EnvironmentalTransport: PuffCoupler, AdvectionOperator
using EnvironmentalTransport

function EarthSciMLBase.couple2(p::PuffCoupler, g::GEOSFPCoupler)
    p, g = p.sys, g.sys
    p = param_to_var(p, :v_lon, :v_lat, :v_lev)
    g = param_to_var(g, :lon, :lat, :lev)
    ConnectorSystem([
        g.lon ~ p.lon
        g.lat ~ p.lat
        g.lev ~ clamp(p.lev, 1, 72)
        p.v_lon ~ g.A3dyn₊U
        p.v_lat ~ g.A3dyn₊V
        p.v_lev ~ g.A3dyn₊OMEGA
    ], p, g)
end

function EarthSciMLBase.get_needed_vars(::AdvectionOperator, csys, mtk_sys, domain::EarthSciMLBase.DomainInfo)
    found = 0
    windvars = []
    for sys in csys.systems
        if EarthSciMLBase.get_coupletype(sys) == GEOSFPCoupler
            found += 1
            push!(windvars, sys.A3dyn₊U, sys.A3dyn₊V, sys.A3dyn₊OMEGA)
        end
    end
    if found == 0
        error("Could not find a source of wind data in the coupled system. Valid sources are currently {EarthSciData.GEOSFP}.")
    elseif found > 1
        error("Found multiple sources of wind data in the coupled system. Valid sources are currently {EarthSciData.GEOSFP}")
    end
    ts = EarthSciMLBase.partialderivative_transform_vars(mtk_sys, domain)
    return vcat(windvars, ts)
end

end
