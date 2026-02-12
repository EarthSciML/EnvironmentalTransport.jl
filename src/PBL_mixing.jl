export PBLMixingCallback

# Physical constants
const SCALE_HEIGHT = 8000.0  # m, atmospheric scale height
const G0 = 9.80665           # m/s², gravitational acceleration

# GEOS-FP hybrid grid parameters (73 levels)
# Source: https://wiki.seas.harvard.edu/geos-chem/index.php/GEOS-Chem_vertical_grids
const Ap = SVector{73}(
    [
        0.0e+0, 4.804826e-2, 6.593752e+0, 1.31348e+1, 1.961311e+1,
        2.609201e+1, 3.257081e+1, 3.898201e+1, 4.533901e+1, 5.169611e+1,
        5.805321e+1, 6.436264e+1, 7.062198e+1, 7.883422e+1, 8.909992e+1,
        9.936521e+1, 1.091817e+2, 1.189586e+2, 1.286959e+2, 1.4291e+2,
        1.5626e+2, 1.69609e+2, 1.81619e+2, 1.93097e+2, 2.03259e+2,
        2.1215e+2, 2.18776e+2, 2.23898e+2, 2.24363e+2, 2.16865e+2,
        2.01192e+2, 1.7693e+2, 1.50393e+2, 1.27837e+2, 1.08663e+2,
        9.236572e+1, 7.851231e+1, 6.660341e+1, 5.638791e+1, 4.764391e+1,
        4.017541e+1, 3.381001e+1, 2.836781e+1, 2.373041e+1, 1.97916e+1,
        1.64571e+1, 1.36434e+1, 1.12769e+1, 9.292942e+0, 7.619842e+0,
        6.216801e+0, 5.046801e+0, 4.076571e+0, 3.276431e+0, 2.620211e+0,
        2.08497e+0, 1.65079e+0, 1.30051e+0, 1.01944e+0, 7.951341e-1,
        6.167791e-1, 4.758061e-1, 3.650411e-1, 2.785261e-1, 2.11349e-1,
        1.59495e-1, 1.19703e-1, 8.934502e-2, 6.600001e-2, 4.758501e-2,
        3.27e-2, 2.0e-2, 1.0e-2,
    ] .* 100
) # Pa

const Bp = SVector{73}(
    [
        1.0e+0, 9.84952e-1, 9.63406e-1, 9.41865e-1, 9.20387e-1,
        8.98908e-1, 8.77429e-1, 8.56018e-1, 8.346609e-1, 8.133039e-1,
        7.919469e-1, 7.706375e-1, 7.493782e-1, 7.21166e-1, 6.858999e-1,
        6.506349e-1, 6.158184e-1, 5.810415e-1, 5.463042e-1, 4.945902e-1,
        4.437402e-1, 3.928911e-1, 3.433811e-1, 2.944031e-1, 2.467411e-1,
        2.003501e-1, 1.562241e-1, 1.136021e-1, 6.372006e-2, 2.801004e-2,
        6.960025e-3, 8.175413e-9, 0.0e+0, 0.0e+0, 0.0e+0,
        0.0e+0, 0.0e+0, 0.0e+0, 0.0e+0, 0.0e+0,
        0.0e+0, 0.0e+0, 0.0e+0, 0.0e+0, 0.0e+0,
        0.0e+0, 0.0e+0, 0.0e+0, 0.0e+0, 0.0e+0,
        0.0e+0, 0.0e+0, 0.0e+0, 0.0e+0, 0.0e+0,
        0.0e+0, 0.0e+0, 0.0e+0, 0.0e+0, 0.0e+0,
        0.0e+0, 0.0e+0, 0.0e+0, 0.0e+0, 0.0e+0,
        0.0e+0, 0.0e+0, 0.0e+0, 0.0e+0, 0.0e+0,
        0.0e+0, 0.0e+0, 0.0e+0,
    ]
)

# Pre-computed pressure edges at standard surface pressure (1013.25 hPa)
const pedges_73 = (Ap + Bp .* 101325.0) ./ 100.0  # Convert to hPa

"""
Extract domain-specific pressure edges from the pre-computed 73-level GEOS-FP grid.
"""
function extract_domain_pressure_edges(domain_levels::AbstractRange)
    max_level = Int(maximum(domain_levels))
    min_level = Int(minimum(domain_levels))

    # Extract edges from min_level to max_level+1 (need n+1 edges for n layers)
    pedge_domain = Vector{Float64}(undef, length(domain_levels) + 1)
    for (i, edge_idx) in enumerate(min_level:(max_level + 1))
        edge_idx = clamp(edge_idx, 1, 73)  # Ensure valid index
        pedge_domain[i] = pedges_73[edge_idx]
    end
    return pedge_domain
end

"""
Compute PBL mixing parameters based on domain levels.
"""
function compute_imix_fpbl(pedge_domain::Vector{Float64}, pblh_m::Float64)
    nz = length(pedge_domain) - 1
    p0 = pedge_domain[1]  # Top pressure of domain (hPa)
    bltop = p0 * exp(-pblh_m / SCALE_HEIGHT)  # PBL top pressure (hPa)

    # Find which domain level contains the PBL top
    ltop = 0
    for l in 1:nz
        if bltop > pedge_domain[l + 1]
            ltop = l
            break
        end
    end

    if ltop == 0
        # Check if PBL top is above the entire column
        if bltop < pedge_domain[end]
            # PBL top is above the entire column; all layers are within PBL
            return (nz, 1.0)
        else
            # PBL shallower than first layer top; everything below surface edge
            return (
                1,
                clamp((pedge_domain[1] - bltop) / (pedge_domain[1] - pedge_domain[2]), 0.0, 1.0),
            )
        end
    end

    # Calculate fraction of ltop-th layer below PBL top
    fpbl = 1.0 -
        (bltop - pedge_domain[ltop + 1]) / (pedge_domain[ltop] - pedge_domain[ltop + 1])
    return (ltop, clamp(fpbl, 0.0, 1.0))
end

"""
Compute air mass for each layer from pressure edges and grid area.
"""
function air_mass_from_pressure(pedge::Vector{Float64}, area_m2::Float64)
    nz = length(pedge) - 1
    ad = similar(pedge, nz)
    for l in 1:nz
        ΔP_Pa = (pedge[l] - pedge[l + 1]) * 100.0  # Convert hPa to Pa
        ad[l] = ΔP_Pa * area_m2 / G0
    end
    return ad
end

"""
Apply full PBL mixing to tracer concentrations (GEOS-Chem TURBDAY algorithm).
"""
function pbl_full_mix!(tc::Array{Float64, 2}, ad::Vector{Float64}, imix::Int, fpbl::Float64)
    nz, nspec = size(tc)
    if imix < 1 || imix > nz
        return
    end

    # Calculate total air mass in PBL
    aa = 0.0
    for l in 1:(imix - 1)
        aa += ad[l]
    end
    aa += ad[imix] * fpbl

    if aa <= 0
        return
    end

    # Mix each species
    for n in 1:nspec
        # Calculate total mass of species in PBL
        cc = 0.0
        for l in 1:(imix - 1)
            cc += ad[l] * tc[l, n]
        end
        cc += ad[imix] * tc[imix, n] * fpbl

        # Calculate new mixing ratio (mass-weighted mean)
        cc_aa = cc / aa

        # Apply mixing
        for l in 1:(imix - 1)
            tc[l, n] = cc_aa  # Fully mixed layers
        end
        # Partially mixed top layer
        tc[imix, n] = tc[imix, n] * (1.0 - fpbl) + cc_aa * fpbl
    end
    return
end

# ---- PBL Mixing Implementation ----

"""
    pbl_obs_function(mtk_sys, coord_args, v, T)

Create an observed function for extracting data from the ModelingToolkit system.
"""
function pbl_obs_function(mtk_sys, coord_args, v, T)
    obs_f = EarthSciMLBase.build_coord_observed_function(
        mtk_sys, coord_args, v;
        eval_module = @__MODULE__
    )
    obscache = zeros(T, length(unknowns(mtk_sys)))
    return (p, t, x1, x2, x3) -> only(obs_f(obscache, p, t, x1, x2, x3))
end

"""
    PBLMixingCallback <: EarthSciMLBase.Operator

A callback that applies planetary boundary layer (PBL) mixing to tracer fields at periodic intervals.
PBL mixing is a discrete process that redistributes tracers vertically within each grid column.
"""
mutable struct PBLMixingCallback
    interval::Float64  # Time interval between mixing events (seconds)
    every_step::Bool   # If true, apply at every solver step regardless of interval

    function PBLMixingCallback(interval::Float64 = 3600.0; every_step::Bool = false)
        return new(interval, every_step)
    end
end

"""
    EarthSciMLBase.init_callback(cb::PBLMixingCallback, csys::CoupledSystem, sys_mtk, coord_args, domain::DomainInfo, alg)

Initialize the PBL mixing callback.
"""
function EarthSciMLBase.init_callback(
        cb::PBLMixingCallback, csys::CoupledSystem,
        sys_mtk, coord_args, domain::DomainInfo, alg
    )

    # Get data accessor functions
    vars = EarthSciMLBase.get_needed_vars(cb, csys, sys_mtk, domain)
    @assert length(vars) == 3 # PBLH, δxδlon, δyδlat

    T = eltype(domain)
    grd = EarthSciMLBase.grid(domain)

    # Create data accessor functions
    pblh_data_f = pbl_obs_function(sys_mtk, coord_args, vars[1], T)
    δxδlon_data_f = pbl_obs_function(sys_mtk, coord_args, vars[2], T)
    δyδlat_data_f = pbl_obs_function(sys_mtk, coord_args, vars[3], T)

    # Get the domain level range and pre-compute pressure edges
    domain_levels = EarthSciMLBase.grid(domain)[3]
    pedge_domain = extract_domain_pressure_edges(domain_levels)

    # Get grid spacing for area calculation
    dx = domain.grid_spacing[1]  # longitude/x spacing (radians)
    dy = domain.grid_spacing[2]  # latitude/y spacing (radians)

    # Get number of species from the system unknowns
    nspec = length(unknowns(sys_mtk))

    # Create the mixing function
    function apply_pbl_mixing!(integrator)
        u = integrator.u
        p = integrator.p
        t = integrator.t

        # Get the expected dimensions from the domain
        nx = length(grd[1])
        ny = length(grd[2])
        nz = length(grd[3])

        # Reshape to (nspec, nx, ny, nz) - same as NetCDF outputter
        u_reshaped = reshape(u, nspec, nx, ny, nz)

        # Loop over horizontal grid points
        for i in 1:nx, j in 1:ny
            # Get meteorological data for this column
            x1 = grd[1][i]
            x2 = grd[2][j]
            x3 = grd[3][1]  # Use first level for 2D fields

            pblh_val = pblh_data_f(p, t, x1, x2, x3)
            δxδlon_val = δxδlon_data_f(p, t, x1, x2, x3)
            δyδlat_val = δyδlat_data_f(p, t, x1, x2, x3)

            # Calculate grid area (m²)
            area = dx * dy * δxδlon_val * δyδlat_val

            # Extract column data as (nz, nspec) for mixing algorithm
            col = permutedims(view(u_reshaped, :, i, j, :), (2, 1))

            # Apply PBL mixing
            imix, fpbl = compute_imix_fpbl(pedge_domain, pblh_val)
            ad = air_mass_from_pressure(pedge_domain, area)
            pbl_full_mix!(col, ad, imix, fpbl)

            # Write back to main array
            @inbounds @views u_reshaped[:, i, j, :] .= permutedims(col, (2, 1))
        end

        # Update the integrator state
        return integrator.u .= u_reshaped[:]
    end

    # Return appropriate callback based on settings
    return if cb.every_step
        # Use DiscreteCallback to apply at every solver step
        DiscreteCallback((u, t, integrator) -> true, apply_pbl_mixing!)
    else
        # Use PeriodicCallback to apply at specified intervals
        PeriodicCallback(apply_pbl_mixing!, cb.interval)
    end
end
