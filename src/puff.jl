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
"""
function Puff(di::DomainInfo; name = :puff)
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
    trans = [lev_trans, lev_trans, lev_trans]
    trans[lon_idx] = x_trans
    trans[lat_idx] = y_trans

    # Create placeholder velocity variables.
    vs = []
    for i in eachindex(coords)
        v_sym = Symbol("v_$(Symbol(pv[i]))")
        vu = get_unit(coords[i]) / get_unit(trans[i]) / get_unit(t)
        v = only(@parameters $(v_sym)=0 [unit = vu description = "$(Symbol(pv[i])) speed"])
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
    push!(eqs, v_vertical ~ eqs[lev_idx].rhs)
    eqs[lev_idx] = let
        eq = eqs[lev_idx]
        c = coords[lev_idx]
        eq.lhs ~ ifelse(c - offset < glo, max(v_zero, v_vertical),
            ifelse(c + offset > ghi, min(v_zero, v_vertical), v_vertical))
    end
    lower_bound = coords[lev_idx] ~ endpts[lev_idx][begin]
    upper_bound = coords[lev_idx] ~ endpts[lev_idx][end]
    vertical_boundary = [lower_bound, upper_bound]
    # Stop simulation if we reach the lateral boundaries.
    affect!(integrator, u, p, ctx) = terminate!(integrator)
    wb = coords[lon_idx] ~ endpts[lon_idx][begin]
    eb = coords[lon_idx] ~ endpts[lon_idx][end]
    sb = coords[lat_idx] ~ endpts[lat_idx][begin]
    nb = coords[lat_idx] ~ endpts[lat_idx][end]
    lateral_boundary = [wb, eb, sb, nb] => (affect!, [], [], [], nothing)
    ODESystem(eqs, EarthSciMLBase.ivar(di); name = name,
        metadata = Dict(:coupletype => PuffCoupler),
        continuous_events = [vertical_boundary, lateral_boundary])
end
