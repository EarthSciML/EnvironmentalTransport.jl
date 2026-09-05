export AdvectionOperator

"""
An advection kernel for a 4D array, where the first dimension is the state variables
and the next three dimensions are the spatial dimensions.
"""
function advection_kernel_4d(u, stencil, vs, Δs, Δt, idx, p = NullParameters())
    return advection_kernel_4d_dirs(u, stencil, vs, Δs, Δt, idx, (1, 2, 3), p)
end

"""
Same as `advection_kernel_4d`, but only summing the contributions of the spatial
directions listed in `dirs` (1 = x, 2 = y, 3 = z), e.g. `(1, 2)` for the horizontal
tendency only.
"""
function advection_kernel_4d_dirs(u, stencil, vs, Δs, Δt, idx, dirs, p = NullParameters())
    lpad, rpad = stencil_size(stencil)
    offsets = (
        (CartesianIndex(0, lpad, 0, 0), CartesianIndex(0, rpad, 0, 0)),
        (CartesianIndex(0, 0, lpad, 0), CartesianIndex(0, 0, rpad, 0)),
        (CartesianIndex(0, 0, 0, lpad), CartesianIndex(0, 0, 0, rpad)),
    )
    du = zero(eltype(u))
    @inbounds for i in dirs
        v, Δ, (l, r) = vs[i], Δs[i], offsets[i]
        uu = @view u[(idx - l):(idx + r)]
        du += stencil(uu, v, Δt, Δ; p)
    end
    return du
end

"""
$(SIGNATURES)

Inflow Courant number of one grid cell in one direction for a time step `Δt`:
the sum of the face velocities directed INTO the cell, times `Δt`, divided by the
cell width. `v` holds the velocities at the two faces of the cell (left/bottom,
right/top) and `Δ` is the (signed) grid spacing — the vertical spacing is negative
on a pressure-like coordinate, which is handled the same way as in
[`upwind1_stencil`](@ref).

For an explicit upwind update `ϕ_new = ϕ + Δt·dϕ/dt` the coefficient of the cell's
own old value is `1 − courant`, so the update is a convex combination of old values
(monotone, positivity-preserving, no spurious extrema) if and only if
`courant ≤ 1`.
"""
@inline function inflow_courant(v, Δ, Δt)
    sz = sign(Δ)
    z = zero(eltype(v))
    return (max(sz * v[1], z) + max(-sz * v[2], z)) * Δt / abs(Δ)
end

"""
$(SIGNATURES)

Number of vertical sub-steps needed for a column whose per-level vertical inflow
Courant numbers are `courants`: the smallest `n ≥ 1` with `max(courants)/n ≤ 1`,
capped at `max_subcycles`. Non-finite Courant numbers (e.g. from a non-finite
`Δt`) give `n = 1`, i.e. no sub-cycling.
"""
function vertical_subcycles(courants, max_subcycles::Integer)
    cmax = 0.0
    for c in courants
        cmax = max(cmax, c)   # NaN propagates, so a NaN Courant number disables sub-cycling
    end
    isfinite(cmax) || return 1
    cmax >= max_subcycles && return Int(max_subcycles)
    return max(1, ceil(Int, cmax))
end

"""
$(SIGNATURES)

Advance the padded column `colp` (interior levels at indices `lpad+1 … lpad+nz`,
boundary ghost values outside) by `n` explicit sub-steps of `Δt/n` of vertical
advection with `stencil`, using the per-level face velocities `vzs` and grid
spacings `Δzs`. The ghost values are held fixed. `tmp` is a scratch vector of
length `nz`.
"""
function subcycle_column!(colp, tmp, stencil, vzs, Δzs, Δt, n, nz, lpad, rpad, p)
    dts = Δt / n
    @inbounds for _ in 1:n
        for k in 1:nz
            kk = k + lpad
            uu = @view colp[(kk - lpad):(kk + rpad)]
            tmp[k] = colp[kk] + dts * stencil(uu, vzs[k], dts, Δzs[k]; p)
        end
        for k in 1:nz
            colp[k + lpad] = tmp[k]
        end
    end
    return colp
end
function advection_kernel_4d_builder(stencil, v_fs, Δ_fs)
    return function advect_f(u, idx, Δt, t, p = NullParameters())
        vs = get_vs(v_fs, idx, p, t)
        Δs = get_Δs(Δ_fs, idx, p, t)
        return advection_kernel_4d(u, stencil, vs, Δs, Δt, idx, p)
    end
end

function get_vs(v_fs, i, j, k, p, t)
    return (
        (v_fs[1](i, j, k, p, t), v_fs[1](i + 1, j, k, p, t)),
        (v_fs[2](i, j, k, p, t), v_fs[2](i, j + 1, k, p, t)),
        (v_fs[3](i, j, k, p, t), v_fs[3](i, j, k + 1, p, t)),
    )
end
get_vs(v_fs, idx::CartesianIndex{4}, p, t) = get_vs(v_fs, idx[2], idx[3], idx[4], p, t)

function get_Δs(Δ_fs, i, j, k, p, t)
    return (Δ_fs[1](i, j, k, p, t), Δ_fs[2](i, j, k, p, t), Δ_fs[3](i, j, k, p, t))
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
  - `max_subcycles`: upper bound on the number of vertical sub-steps per time step
    (see below).

## Vertical Courant-number sub-cycling

The returned function is the tendency `du/dt` that an explicit outer integrator
(e.g. `SSPRK22` with a fixed step `Δt`) advances with steps of exactly `Δt`.
Explicit upwind advection is only monotone (no spurious extrema, no negative
concentrations) when the inflow Courant number `|v|·Δt/Δ` of every cell is at most
one. Horizontally that is easily satisfied on regional grids, but on a hybrid
pressure grid the layers are thin (≈ 10 hPa near the surface) and resolved
vertical velocities over steep terrain — e.g. 3-hourly GEOS-FP `OMEGA` of
5–7 Pa/s in a lee-side downslope flow — give vertical Courant numbers well above
one at `Δt = 300 s`. In that regime every explicit step overshoots, a positivity
limiter (or `max(u, 0)`) rectifies the undershoots into a net mass GAIN, and the
column blows up: a checkerboard of zeros and 10²–10³-fold inflated values in the
levels with the largest `OMEGA` (observed: CONUS February 2016, Front Range and
Wyoming/Montana ranges, every long-lived species inflated ≈ 100×).

To stay monotone for any vertical Courant number, each column is handled as
follows when the operator's `Δt` is finite:

 1. the vertical inflow Courant number `C_k` of every level is computed from the
    face velocities and layer thickness the stencil itself uses;
 2. if `max_k C_k ≤ 1` the tendency is the usual sum of the three one-dimensional
    stencil tendencies — bit-for-bit the same result as before;
 3. otherwise `n = ceil(max_k C_k)` (at most `max_subcycles`) vertical sub-steps of
    `Δt/n` are taken: the horizontal tendency is applied first as an explicit step,
    `ϕ* = ϕ + Δt·(∂ϕ/∂t)_xy`, then the column `ϕ*` is advected vertically `n` times
    with the same stencil and `Δt/n`, and the tendency returned is
    `(ϕ_end − ϕ)/Δt`, so that `ϕ + Δt·du/dt` is exactly the sub-cycled result.
    Each sub-step has a vertical Courant number at most one, so the whole update is
    a convex combination of the old values (given a horizontal Courant number at
    most one), i.e. monotone and positivity-preserving, at the cost of a little
    extra numerical diffusion in those columns.

The sub-cycling needs to know the outer time step: if `Δt` is not finite (e.g.
`NaN`) it is disabled and the plain tendency is returned everywhere.
"""
function advection_op(
        u_prototype, stencil, v_fs, Δ_fs, Δt, bc_type, alg::MapAlgorithm;
        p = NullParameters(), max_subcycles::Integer = 100
    )
    @assert length(size(u_prototype)) == 4 "Advection operator only supports 4D arrays."
    sz = size(u_prototype)
    T = eltype(u_prototype)
    v_fs = tuple(v_fs...)
    Δ_fs = tuple(Δ_fs...)
    nspec, nx, ny, nz = sz
    lpad, rpad = stencil_size(stencil)
    subcycle = isfinite(Δt)
    # The velocity and grid-spacing accessors depend only on the spatial index
    # and time, not on the species, so iterate over columns in the outer
    # (parallelized) loop, evaluate each level's values once, and reuse them
    # across all species. Working column-wise is also what makes the vertical
    # Courant-number sub-cycling (see the docstring) possible.
    IIcol = CartesianIndices((nx, ny))

    # Face velocities and grid spacings for every level of column (i, j), packed
    # into one 9×nz matrix (rows: x faces 1-2, y faces 3-4, z faces 5-6, Δx, Δy, Δz)
    # so that a column costs a single small allocation.
    function column_winds(i, j, p, t)
        w = Matrix{T}(undef, 9, nz)
        @inbounds for k in 1:nz
            (vx, vy, vz) = get_vs(v_fs, i, j, k, p, t)
            (Δx, Δy, Δz) = get_Δs(Δ_fs, i, j, k, p, t)
            w[1, k], w[2, k] = vx
            w[3, k], w[4, k] = vy
            w[5, k], w[6, k] = vz
            w[7, k], w[8, k], w[9, k] = Δx, Δy, Δz
        end
        return w
    end
    @inline winds_at(w, k) = @inbounds (((w[1, k], w[2, k]), (w[3, k], w[4, k]), (w[5, k], w[6, k])),
        (w[7, k], w[8, k], w[9, k]))

    # Fill `dcol[s, k]` with the tendency of column (i, j) of the BC-wrapped array `u`.
    function column_tendency!(dcol, u, p, t, i, j)
        w = column_winds(i, j, p, t)
        n = 1
        if subcycle
            n = vertical_subcycles(
                (inflow_courant((w[5, k], w[6, k]), w[9, k], Δt) for k in 1:nz),
                max_subcycles)
        end
        if n == 1
            @inbounds for k in 1:nz
                vs, Δs = winds_at(w, k)
                for s in 1:nspec
                    dcol[s, k] = advection_kernel_4d(
                        u, stencil, vs, Δs, Δt, CartesianIndex(s, i, j, k), p)
                end
            end
        else
            colp = Vector{T}(undef, nz + lpad + rpad)
            tmp = Vector{T}(undef, nz)
            vzs = [(w[5, k], w[6, k]) for k in 1:nz]
            Δzs = [w[9, k] for k in 1:nz]
            @inbounds for s in 1:nspec
                # Ghost values below/above the column from the boundary condition.
                for k in (1 - lpad):0
                    colp[k + lpad] = u[s, i, j, k]
                end
                for k in (nz + 1):(nz + rpad)
                    colp[k + lpad] = u[s, i, j, k]
                end
                # Explicit horizontal step, then n vertical sub-steps.
                for k in 1:nz
                    vs, Δs = winds_at(w, k)
                    colp[k + lpad] = u[s, i, j, k] + Δt * advection_kernel_4d_dirs(
                        u, stencil, vs, Δs, Δt, CartesianIndex(s, i, j, k), (1, 2), p)
                end
                subcycle_column!(colp, tmp, stencil, vzs, Δzs, Δt, n, nz, lpad, rpad, p)
                for k in 1:nz
                    dcol[s, k] = (colp[k + lpad] - u[s, i, j, k]) / Δt
                end
            end
        end
        return nothing
    end

    function advection(u, p, t) # Out-of-place
        u = bc_type(reshape(u, sz...))
        function kernelII(IIs)
            i, j = Tuple(IIs)
            dcol = Matrix{T}(undef, nspec, nz)
            column_tendency!(dcol, u, p, t, i, j)
            dcol
        end
        dcols = EarthSciMLBase.map_closure_to_range(kernelII, IIcol, alg)
        du = Array{T}(undef, sz...)
        for (c, IIs) in enumerate(IIcol)
            i, j = Tuple(IIs)
            @views du[:, i, j, :] .= dcols[c]
        end
        return reshape(du, :)
    end
    function advection(du, u, p, t) # In-place
        u = bc_type(reshape(u, sz...))
        du = reshape(du, sz...)
        function kernelII(IIs)
            i, j = Tuple(IIs)
            column_tendency!(view(du, :, i, j, :), u, p, t, i, j)
            nothing
        end
        EarthSciMLBase.map_closure_to_range(kernelII, IIcol, alg)
        return nothing
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
    return data_f(p, t, x1, x2, x3)
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
    return data_f(p, t, x1, x2, x3)
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
    return data_f(p, t, x1, x2, x3) # Staggered grid
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
            vf_x, (data_f, grd[1], grd[2], grd[3], domain.grid_spacing[1])
        )
        return tuplefunc(vf)
    elseif varname ∈ ("lat", "y")
        vf = Base.Fix2(
            vf_y, (data_f, grd[1], grd[2], grd[3], domain.grid_spacing[2])
        )
        return tuplefunc(vf)
    elseif varname == "lev"
        vf = Base.Fix2(
            vf_z, (data_f, grd[1], grd[2], grd[3], domain.grid_spacing[3])
        )
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
    return Δ * tff(p, t, c1, c2, c3)
end

"""
$(SIGNATURES)

Return a function that gets the grid spacing at a given place and time for the given `varname`.
"""
function get_Δ(domain::EarthSciMLBase.DomainInfo, tff, pvaridx)
    grd = EarthSciMLBase.grid(domain)
    return tuplefunc(
        Base.Fix2(
            Δf, (tff, domain.grid_spacing[pvaridx], grd[1], grd[2], grd[3])
        )
    )
end

"""
$(SIGNATURES)

Create an `EarthSciMLBase.Operator` that performs advection.
Advection is performed using the given `stencil` operator
(e.g. `l94_stencil` or `ppm_stencil`).
`p` is an optional parameter set to be used by the stencil operator.
`bc_type` is the boundary condition type, e.g. `ZeroGradBC()`.

`Δt` must be the (fixed) time step of the outer integrator: it is used to keep the
explicit vertical advection monotone where the vertical Courant number exceeds one
by sub-cycling the vertical direction (see [`advection_op`](@ref)); at most
`max_subcycles` sub-steps are taken per step. If `Δt` is not finite the
sub-cycling is disabled.

Wind field data will be added in automatically if available.
Currently the only valid source of wind data is `EarthSciData.GEOSFP`.
"""
mutable struct AdvectionOperator <: EarthSciMLBase.Operator
    Δt::Any
    stencil::Any
    bc_type::Any
    "Upper bound on the number of vertical Courant-number sub-steps per time step."
    max_subcycles::Int

    function AdvectionOperator(Δt, stencil, bc_type; max_subcycles::Integer = 100)
        max_subcycles >= 1 || throw(ArgumentError("max_subcycles must be at least 1"))
        return new(Δt, stencil, bc_type, max_subcycles)
    end
end

function obs_function(mtk_sys, coord_args, v, T)
    obs_f = EarthSciMLBase.build_coord_observed_function(
        mtk_sys, coord_args, [v];
        eval_module = @__MODULE__
    )
    obscache = zeros(T, length(unknowns(mtk_sys))) # Not used for anything (hopefully).
    function data_f(p, t, x1, x2, x3)
        return only(obs_f(obscache, p, t, x1, x2, x3))
    end
    return data_f
end

function get_datafs(op, csys, mtk_sys, coord_args, domain)
    vars = EarthSciMLBase.get_needed_vars(op, csys, mtk_sys, domain)
    @assert length(vars) == 6 # x_wind, y_wind, z_wind, x_ts, y_ts, z_ts
    pvars = EarthSciMLBase.pvars(domain)
    pvarstrs = [String(Symbol(pv)) for pv in pvars]
    v_fs = []
    for i in 1:3
        v = vars[i]
        data_f = obs_function(mtk_sys, coord_args, v, eltype(domain))
        push!(v_fs, get_vf(domain, pvarstrs[i], data_f))
    end
    Δ_fs = []
    for (i, v) in enumerate(vars[4:6])
        data_f = obs_function(mtk_sys, coord_args, v, eltype(domain))
        push!(Δ_fs, get_Δ(domain, data_f, i))
    end
    return v_fs, Δ_fs
end

function EarthSciMLBase.get_odefunction(
        op::AdvectionOperator, csys::CoupledSystem, mtk_sys,
        coord_args, domain::DomainInfo, u0, p, alg::MapAlgorithm
    )
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

    if !isfinite(op.Δt)
        @warn "AdvectionOperator: Δt = $(op.Δt) is not finite, so vertical " *
              "Courant-number sub-cycling is disabled; pass the outer integrator's " *
              "fixed time step to keep the advection monotone where |OMEGA|·Δt exceeds " *
              "the layer thickness." maxlog = 1
    end
    return advection_op(u0, op.stencil, v_fs, Δ_fs, op.Δt, bc_type, alg; p = p,
        max_subcycles = op.max_subcycles)
end

# Actual implementation is in EarthSciDataExt.jl.
function EarthSciMLBase.get_needed_vars(::AdvectionOperator, csys, mtk_sys, domain)
    error("Could not find a source of wind data in the coupled system. Valid sources are currently {EarthSciData.GEOSFP}.")
end
