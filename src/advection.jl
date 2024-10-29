export AdvectionOperator

#=
An advection kernel for a 4D array, where the first dimension is the state variables
and the next three dimensions are the spatial dimensions.
=#
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
        vs = get_vs(v_fs, idx, t)
        Δs = get_Δs(Δ_fs, idx, t)
        advection_kernel_4d(u, stencil, vs, Δs, Δt, idx, p)
    end
end

function get_vs(v_fs, i, j, k, t)
    (
        (v_fs[1](i, j, k, t), v_fs[1](i + 1, j, k, t)),
        (v_fs[2](i, j, k, t), v_fs[2](i, j + 1, k, t)),
        (v_fs[3](i, j, k, t), v_fs[3](i, j, k + 1, t))
    )
end
get_vs(v_fs, idx::CartesianIndex{4}, t) = get_vs(v_fs, idx[2], idx[3], idx[4], t)

get_Δs(Δ_fs, i, j, k, t) = (Δ_fs[1](i, j, k, t), Δ_fs[2](i, j, k, t), Δ_fs[3](i, j, k, t))
get_Δs(Δ_fs, idx::CartesianIndex{4}, t) = get_Δs(Δ_fs, idx[2], idx[3], idx[4], t)

#=
A function to create an advection operator for a 4D array,

Arguments:
    * `u_prototype`: A prototype array of the same size and type as the input array.
    * `stencil`: The stencil operator, e.g. `l94_stencil` or `ppm_stencil`.
    * `v_fs`: A vector of functions to get the wind velocity at a given place and time.
            The function signature should be `v_fs(i, j, k, t)`.
    * `Δ_fs`: A vector of functions to get the grid spacing at a given place and time.
            The function signature should be `Δ_fs(i, j, k, t)`.
    * `Δt`: The time step size, which is assumed to be fixed.
    * `bc_type`: The boundary condition type, e.g. `ZeroGradBC()`.
=#
function advection_op(u_prototype, stencil, v_fs, Δ_fs, Δt, bc_type;
        p = NullParameters())
    sz = size(u_prototype)
    v_fs = tuple(v_fs...)
    Δ_fs = tuple(Δ_fs...)
    adv_kernel = advection_kernel_4d_builder(stencil, v_fs, Δ_fs)
    function advection(u, p, t) # Out-of-place
        u = bc_type(reshape(u, sz...))
        du = adv_kernel.((u,), CartesianIndices(u), (Δt,), (t,), (p,))
        reshape(du, :)
    end
    function advection(du, u, p, t) # In-place
        u = bc_type(reshape(u, sz...))
        du = reshape(du, sz...)
        du .= adv_kernel.((u,), CartesianIndices(u), (Δt,), (t,), (p,))
    end
    FunctionOperator(advection, reshape(u_prototype, :), p = p)
end

"Get a value from the x-direction velocity field."
function vf_x(args1, args2)
    i, j, k, t = args1
    data_f, grid1, grid2, grid3, Δ = args2
    x1 = grid1[min(i, length(grid1))] - Δ / 2 # Staggered grid
    x2 = grid2[j]
    x3 = grid3[k]
    data_f(t, x1, x2, x3)
end

"Get a value from the y-direction velocity field."
function vf_y(args1, args2)
    i, j, k, t = args1
    data_f, grid1, grid2, grid3, Δ = args2
    x1 = grid1[i]
    x2 = grid2[min(j, length(grid2))] - Δ / 2 # Staggered grid
    x3 = grid3[k]
    data_f(t, x1, x2, x3)
end

"Get a value from the z-direction velocity field."
function vf_z(args1, args2)
    i, j, k, t = args1
    data_f, grid1, grid2, grid3, Δ = args2
    x1 = grid1[i]
    x2 = grid2[j]
    x3 = k > 1 ? grid3[min(k, length(grid3))] - Δ / 2 : grid3[k]
    data_f(t, x1, x2, x3) # Staggered grid
end
tuplefunc(vf) = (i, j, k, t) -> vf((i, j, k, t))

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

"function to get grid deltas."
function Δf(args1, args2)
    i, j, k, t = args1
    tff, Δ, grid1, grid2, grid3 = args2
    c1, c2, c3 = grid1[i], grid2[j], grid3[k]
    Δ / tff(t, c1, c2, c3)
end

"""
$(SIGNATURES)

Return a function that gets the grid spacing at a given place and time for the given `varname`.
"""
function get_Δ(domain::EarthSciMLBase.DomainInfo,
        coordinate_transform_functions, varname::AbstractString)
    pvaridx = findfirst(
        isequal(varname), String.(Symbol.(EarthSciMLBase.pvars(domain))))
    tff = coordinate_transform_functions[pvaridx]
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

function EarthSciMLBase.get_scimlop(op::AdvectionOperator, csys::CoupledSystem, mtk_sys,
        domain::DomainInfo, obs_functions, coordinate_transform_functions, u0, p)
    pvars = EarthSciMLBase.pvars(domain)
    pvarstrs = [String(Symbol(pv)) for pv in pvars]

    v_fs = []
    Δ_fs = []
    wind_func_dict = get_wind_funcs(csys, op)
    for varname in pvarstrs
        data_f = obs_functions(wind_func_dict[varname])
        push!(v_fs, get_vf(domain, varname, data_f))
        push!(Δ_fs, get_Δ(domain, coordinate_transform_functions, varname))
    end
    scimlop = advection_op(u0, op.stencil, v_fs, Δ_fs, op.Δt, op.bc_type, p = p)
    cache_operator(scimlop, u0[:])
end

# Actual implementation is in EarthSciDataExt.jl.
function get_wind_funcs(::Any, ::Any)
    error("Could not find a source of wind data in the coupled system. Valid sources are currently {EarthSciData.GEOSFP}.")
end
