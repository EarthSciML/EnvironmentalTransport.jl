export AdvectionOperator

"""
An advection kernel for a 4D array, where the first dimension is the state variables
and the next three dimensions are the spatial dimensions.
"""
function advection_kernel_4d(u, stencil, vs, Δs, Δt, idx, p = NullParameters())
    lpad, rpad = stencil_size(stencil)
    offsets = ((CartesianIndex(0, lpad, 0, 0), CartesianIndex(0, rpad, 0, 0)),
        (CartesianIndex(0, 0, lpad, 0), CartesianIndex(0, 0, rpad, 0)),
        (CartesianIndex(0, 0, 0, lpad), CartesianIndex(0, 0, 0, rpad))
    )
    du = zero(eltype(u))
    @inbounds for i in eachindex(vs, Δs, offsets)
        v, Δ, (l, r) = vs[i], Δs[i], offsets[i]
        uu = @view u[(idx - l):(idx + r)]
        du += stencil(uu, v, Δt, Δ; p)
    end
    du
end
function advection_kernel_4d_builder(stencil, v_fs, Δ_fs)
    function advect_f(u, idx, Δt, t, p = NullParameters())
        vs = get_vs(v_fs, idx, p, t)
        Δs = get_Δs(Δ_fs, idx, p, t)
        advection_kernel_4d(u, stencil, vs, Δs, Δt, idx, p)
    end
end

function get_vs(v_fs, i, j, k, p, t)
    (
        (v_fs[1](i, j, k, p, t), v_fs[1](i + 1, j, k, p, t)),
        (v_fs[2](i, j, k, p, t), v_fs[2](i, j + 1, k, p, t)),
        (v_fs[3](i, j, k, p, t), v_fs[3](i, j, k + 1, p, t))
    )
end
get_vs(v_fs, idx::CartesianIndex{4}, p, t) = get_vs(v_fs, idx[2], idx[3], idx[4], p, t)

function get_Δs(Δ_fs, i, j, k, p, t)
    (Δ_fs[1](i, j, k, p, t), Δ_fs[2](i, j, k, p, t), Δ_fs[3](i, j, k, p, t))
end
get_Δs(Δ_fs, idx::CartesianIndex{4}, p, t) = get_Δs(Δ_fs, idx[2], idx[3], idx[4], p, t)

"""
A function to create an advection operator for a 4D array,

Arguments:

  - `u_prototype`: A prototype array of the same size and type as the input array.
  - `stencil`: The stencil operator, e.g. `l94_stencil` or `ppm_stencil`.
  - `v_fs`: A vector of functions to get the wind velocity at a given place and time.
    The function signature should be `v_fs(i, j, k, t)`.
  - `Δ_fs`: A vector of functions to get the grid spacing at a given place and time.
    The function signature should be `Δ_fs(i, j, k, t)`.
  - `Δt`: The time step size, which is assumed to be fixed.
  - `bc_type`: The boundary condition type, e.g. `ZeroGradBC()`.
"""
function advection_op(u_prototype, stencil, v_fs, Δ_fs, Δt, bc_type, alg::MapAlgorithm;
        p = NullParameters())
    @assert length(size(u_prototype)) == 4 "Advection operator only supports 4D arrays."
    sz = size(u_prototype)
    v_fs = tuple(v_fs...)
    Δ_fs = tuple(Δ_fs...)
    II = CartesianIndices(u_prototype)
    adv_kernel = advection_kernel_4d_builder(stencil, v_fs, Δ_fs)
    function advection(u, p, t) # Out-of-place
        u = bc_type(reshape(u, sz...))
        kernelII(II) = adv_kernel(u, II, Δt, t, p)
        du = EarthSciMLBase.map_closure_to_range(kernelII, II, alg)
        reshape(du, :)
    end
    function advection(du, u, p, t) # In-place
        u = bc_type(reshape(u, sz...))
        du = reshape(du, sz...)
        kernelII(II) = du[II] = adv_kernel(u, II, Δt, t, p)
        EarthSciMLBase.map_closure_to_range(kernelII, II, alg)
        nothing
    end
    return advection
end

"""
Get a value from the x-direction velocity field.
"""
function vf_x(args1, args2)
    i, j, k, p, t = args1
    data_f, grid1, grid2, grid3, Δ = args2
    x1 = grid1[min(i, length(grid1))] - Δ / 2 # Staggered grid
    x2 = grid2[j]
    x3 = grid3[k]
    data_f(p, t, x1, x2, x3)
end

"""
Get a value from the y-direction velocity field.
"""
function vf_y(args1, args2)
    i, j, k, p, t = args1
    data_f, grid1, grid2, grid3, Δ = args2
    x1 = grid1[i]
    x2 = grid2[min(j, length(grid2))] - Δ / 2 # Staggered grid
    x3 = grid3[k]
    data_f(p, t, x1, x2, x3)
end

"""
Get a value from the z-direction velocity field.
"""
function vf_z(args1, args2)
    i, j, k, p, t = args1
    data_f, grid1, grid2, grid3, Δ = args2
    x1 = grid1[i]
    x2 = grid2[j]
    x3 = k > 1 ? grid3[min(k, length(grid3))] - Δ / 2 : grid3[k]
    data_f(p, t, x1, x2, x3) # Staggered grid
end
tuplefunc(vf) = (i, j, k, p, t) -> vf((i, j, k, p, t))

"""
$(SIGNATURES)

Return a function that gets the wind velocity at a given place and time for the given `varname`.
`data_f` should be a function that takes a time and three spatial coordinates and returns the value of
the wind speed in the direction indicated by `varname`.
"""
function get_vf(domain, varname::AbstractString, data_f)
    grd = EarthSciMLBase.grid(domain)
    if varname ∈ ("lon", "x")
        vf = Base.Fix2(
            vf_x, (data_f, grd[1], grd[2], grd[3], domain.grid_spacing[1]))
        return tuplefunc(vf)
    elseif varname ∈ ("lat", "y")
        vf = Base.Fix2(
            vf_y, (data_f, grd[1], grd[2], grd[3], domain.grid_spacing[2]))
        return tuplefunc(vf)
    elseif varname == "lev"
        vf = Base.Fix2(
            vf_z, (data_f, grd[1], grd[2], grd[3], domain.grid_spacing[3]))
        return tuplefunc(vf)
    else
        error("Invalid variable name $(varname).")
    end
end

"""
function to get grid deltas.
"""
function Δf(args1, args2)
    i, j, k, p, t = args1
    tff, Δ, grid1, grid2, grid3 = args2
    c1, c2, c3 = grid1[i], grid2[j], grid3[k]
    Δ * tff(p, t, c1, c2, c3)
end

"""
$(SIGNATURES)

Return a function that gets the grid spacing at a given place and time for the given `varname`.
"""
function get_Δ(domain::EarthSciMLBase.DomainInfo, tff, pvaridx)
    grd = EarthSciMLBase.grid(domain)
    tuplefunc(Base.Fix2(
        Δf, (tff, domain.grid_spacing[pvaridx], grd[1], grd[2], grd[3])))
end

"""
$(SIGNATURES)

Create an `EarthSciMLBase.Operator` that performs advection.
Advection is performed using the given `stencil` operator
(e.g. `l94_stencil` or `ppm_stencil`).
`p` is an optional parameter set to be used by the stencil operator.
`bc_type` is the boundary condition type, e.g. `ZeroGradBC()`.

Wind field data will be added in automatically if available.
Currently the only valid source of wind data is `EarthSciData.GEOSFP`.
"""
mutable struct AdvectionOperator <: EarthSciMLBase.Operator
    Δt::Any
    stencil::Any
    bc_type::Any

    function AdvectionOperator(Δt, stencil, bc_type)
        new(Δt, stencil, bc_type)
    end
end

function obs_function(mtk_sys, coord_args, v, T)
    obs_f = EarthSciMLBase.build_coord_observed_function(mtk_sys, coord_args, v;
        eval_module = @__MODULE__)
    obscache = zeros(T, length(unknowns(mtk_sys))) # Not used for anything (hopefully).
    function data_f(p, t, x1, x2, x3)
        only(obs_f(obscache, p, t, x1, x2, x3))
    end
    data_f
end

function get_datafs(op, csys, mtk_sys, coord_args, domain)
    vars = EarthSciMLBase.get_needed_vars(op, csys, mtk_sys, domain)
    @assert length(vars) == 6 # x_wind, y_wind, z_wind, x_ts, y_ts, z_ts
    pvars = EarthSciMLBase.pvars(domain)
    pvarstrs = [String(Symbol(pv)) for pv in pvars]
    v_fs = []
    for i in 1:3
        v = vars[i]
        data_f = obs_function(mtk_sys, coord_args, v, EarthSciMLBase.dtype(domain))
        push!(v_fs, get_vf(domain, pvarstrs[i], data_f))
    end
    Δ_fs = []
    for (i, v) in enumerate(vars[4:6])
        data_f = obs_function(mtk_sys, coord_args, v, EarthSciMLBase.dtype(domain))
        push!(Δ_fs, get_Δ(domain, data_f, i))
    end
    v_fs, Δ_fs
end

function EarthSciMLBase.get_odefunction(
        op::AdvectionOperator, csys::CoupledSystem, mtk_sys,
        coord_args, domain::DomainInfo, u0, p, alg::MapAlgorithm)
    u0 = reshape(u0, :, length.(EarthSciMLBase.grid(EarthSciMLBase.domain(csys)))...)
    v_fs, Δ_fs = get_datafs(op, csys, mtk_sys, coord_args, domain)
    # Handle SpeciesConstantBC specially to resolve species names
    bc_type = op.bc_type
    if isa(bc_type, SpeciesConstantBC)
        # Get species variables from the system
        species_vars = unknowns(mtk_sys)
        # Create a closure that applies the species-specific boundary condition
        bc_type = (x) -> resolve_species_bc(op.bc_type, x, species_vars)
    end

    return advection_op(u0, op.stencil, v_fs, Δ_fs, op.Δt, bc_type, alg, p = p)
end

# Actual implementation is in EarthSciDataExt.jl.
function EarthSciMLBase.get_needed_vars(::AdvectionOperator, csys, mtk_sys, domain)
    error("Could not find a source of wind data in the coupled system. Valid sources are currently {EarthSciData.GEOSFP}.")
end
