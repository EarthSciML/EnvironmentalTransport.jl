module EarthSciDataExt
using DocStringExtensions
import EarthSciMLBase
using EarthSciMLBase: param_to_var, ConnectorSystem, CoupledSystem, get_coupletype
using EarthSciData: GEOSFPCoupler
using EnvironmentalTransport: PuffCoupler, AdvectionOperator

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

"""
$(SIGNATURES)

Couple the advection operator into the CoupledSystem.
This function mutates the operator to add the windfield variables.
There must already be a source of wind data in the coupled system for this to work.
Currently the only valid source of wind data is `EarthSciData.GEOSFP`.
"""
function EarthSciMLBase.couple(c::CoupledSystem, op::AdvectionOperator)::CoupledSystem
    found = 0
    for sys in c.systems
        if EarthSciMLBase.get_coupletype(sys) == GEOSFPCoupler
            found += 1
            op.vardict = Dict(
                "lon" => sys.A3dyn₊U,
                "lat" => sys.A3dyn₊V,
                "lev" => sys.A3dyn₊OMEGA
            )
        end
    end
    if found == 0
        error("Could not find a source of wind data in the coupled system. Valid sources are currently {EarthSciData.GEOSFP}.")
    elseif found > 1
        error("Found multiple sources of wind data in the coupled system. Valid sources are currently {EarthSciData.GEOSFP}")
    end
    push!(c.ops, op)
    c
end

end
