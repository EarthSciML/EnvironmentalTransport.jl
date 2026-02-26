# Surface Runoff Model

## Overview

This module implements a surface runoff model based on the Saint-Venant equation
system for surface water movement, coupled with a Heaviside step function boundary
condition for surface-subsurface water flow interaction.

The Saint-Venant equations describe the mass conservation and momentum conservation
of surface water flow along a soil surface slope. The Heaviside boundary condition
enables automatic switching between infiltration and evaporation conditions at the
soil surface based on the soil water pressure head.

The model includes three key processes:
1. Surface water flow along the soil surface (Saint-Venant equations)
2. Friction effects via Manning's roughness equation
3. Automatic surface-subsurface boundary condition switching (Heaviside function)

**Reference**: Wang, Z., Timlin, D., Kouznetsov, M., Fleisher, D., Li, S., Tully, K.,
& Reddy, V. (2020). Coupled model of surface runoff and surface-subsurface
water movement. *Advances in Water Resources*, 137, 103499.
[https://doi.org/10.1016/j.advwatres.2019.103499](https://doi.org/10.1016/j.advwatres.2019.103499)

```@docs
SurfaceRunoff
HeavisideBoundaryCondition
SaintVenantPDE
```

## Soil Properties (Table 1)

The following table lists the soil physics properties and parameters for soil
hydraulic models used in the numerical examples of Wang et al. (2020). Values
are shown in the original paper units with SI equivalents.

| Parameter | Soil A | Soil B | SI Unit |
|:---|:---:|:---:|:---|
| Residual Water Content (``\theta_r``) | 0.02 | 0.02 | m``^3`` m``^{-3}`` |
| Saturated Water Content (``\theta_s``) | 0.33 | 0.52 | m``^3`` m``^{-3}`` |
| van Genuchten Parameter (``\alpha``) | 0.04 (cm``^{-1}``) = 4.0 (m``^{-1}``) | 0.03 (cm``^{-1}``) = 3.0 (m``^{-1}``) | m``^{-1}`` |
| van Genuchten Parameter (``n``) | 2.0 | 1.1 | dimensionless |
| Saturated Hydraulic Conductivity (``k_s``) | 62.4 cm day``^{-1}`` = 7.22``\times 10^{-6}`` m s``^{-1}`` | 1.0 cm day``^{-1}`` = 1.16``\times 10^{-7}`` m s``^{-1}`` | m s``^{-1}`` |
| Soil Bulk Density (``\rho_b``) | 1.51 g cm``^{-3}`` = 1510 kg m``^{-3}`` | 1.2 g cm``^{-3}`` = 1200 kg m``^{-3}`` | kg m``^{-3}`` |
| Mass Fraction of Soil Organic Matter | 0.04 | 0.04 | kg kg``^{-1}`` |
| Mass Fraction of Sand | 0.95 | 0.25 | kg kg``^{-1}`` |
| Mass Fraction of Silt | 0.04 | 0.15 | kg kg``^{-1}`` |

## Implementation

### SurfaceRunoff Component

The `SurfaceRunoff` component implements the Saint-Venant equation system (Eq. 1
from Wang et al., 2020) at a single surface computing node.

#### State Variables

```@example surface_runoff
using DataFrames, ModelingToolkit, Symbolics, DynamicQuantities
using EnvironmentalTransport

sys = SurfaceRunoff()
vars = unknowns(sys)
DataFrame(
    :Name => [string(Symbolics.tosymbol(v, escape = false)) for v in vars],
    :Units => [string(dimension(ModelingToolkit.get_unit(v))) for v in vars],
    :Description => [ModelingToolkit.getdescription(v) for v in vars]
)
```

#### Parameters

```@example surface_runoff
params = parameters(sys)
DataFrame(
    :Name => [string(Symbolics.tosymbol(p, escape = false)) for p in params],
    :Units => [try string(dimension(ModelingToolkit.get_unit(p))) catch; "dimensionless" end for p in params],
    :Description => [ModelingToolkit.getdescription(p) for p in params]
)
```

#### Equations

```@example surface_runoff
eqs = equations(sys)
```

### HeavisideBoundaryCondition Component

The `HeavisideBoundaryCondition` component implements the smoothed Heaviside
step function (Eq. 5) and the surface boundary condition (Eq. 3) for coupling
surface and subsurface water flow.

#### State Variables

```@example surface_runoff
hbc = HeavisideBoundaryCondition()
vars_hbc = unknowns(hbc)
DataFrame(
    :Name => [string(Symbolics.tosymbol(v, escape = false)) for v in vars_hbc],
    :Units => [try string(dimension(ModelingToolkit.get_unit(v))) catch; "dimensionless" end for v in vars_hbc],
    :Description => [ModelingToolkit.getdescription(v) for v in vars_hbc]
)
```

#### Parameters

```@example surface_runoff
params_hbc = parameters(hbc)
DataFrame(
    :Name => [string(Symbolics.tosymbol(p, escape = false)) for p in params_hbc],
    :Units => [try string(dimension(ModelingToolkit.get_unit(p))) catch; "dimensionless" end for p in params_hbc],
    :Description => [ModelingToolkit.getdescription(p) for p in params_hbc]
)
```

#### Equations

```@example surface_runoff
eqs_hbc = equations(hbc)
```

## Analysis

### Smoothed Heaviside Step Function (Eq. 5)

The smoothed Heaviside function ``\eta_\omega(h)`` transitions from 0 to 1 around
``h = 0``, with the sharpness controlled by the parameter ``\omega``. Smaller values
of ``\omega`` produce a sharper transition, approaching the true Heaviside step function.

```@example surface_runoff
using OrdinaryDiffEqDefault
using Plots

# Evaluate η_ω for different ω values
h_range = range(-0.01, 0.01, length=500)

p = plot(xlabel="Soil water pressure head h (m)",
         ylabel="η_ω(h)",
         title="Smoothed Heaviside Step Function (Eq. 5)")

for ω_val in [1e-2, 1e-3, 1e-4]
    η_vals = [(1/π) * atan(h / ω_val) + 0.5 for h in h_range]
    plot!(p, h_range, η_vals, label="ω = $ω_val m", linewidth=2)
end

p
```

### Smoothed Dirac Delta Function (Eq. 5)

The smoothed Dirac delta function ``\delta_\omega(h)`` is the derivative of the
smoothed Heaviside function. It peaks at ``h = 0`` with amplitude ``1/(\pi\omega)``.

```@example surface_runoff
p2 = plot(xlabel="Soil water pressure head h (m)",
          ylabel="δ_ω(h) (1/m)",
          title="Smoothed Dirac Delta Function (Eq. 5)")

for ω_val in [1e-2, 1e-3, 1e-4]
    δ_vals = [(1/π) * ω_val / (ω_val^2 + h^2) for h in h_range]
    plot!(p2, h_range, δ_vals, label="ω = $ω_val m", linewidth=2)
end

p2
```

### Boundary Condition Transition: Unsaturated to Ponding

This example demonstrates the automatic switching behavior of the Heaviside
boundary condition (Eq. 3). Starting from an unsaturated state (``h < 0``),
precipitation drives the soil water pressure head toward positive values,
transitioning from unsaturated to ponded conditions.

```@example surface_runoff
hbc = HeavisideBoundaryCondition()
chbc = mtkcompile(hbc)

# Scenario: Start unsaturated, apply precipitation with partial infiltration
prob = ODEProblem(chbc,
    merge(
        Dict(chbc.h => -0.05),
        Dict(chbc.P => 1e-5, chbc.I_infil => 0.0, chbc.ω => 1e-3)
    ),
    (0.0, 20000.0))
sol = solve(prob)

p3 = plot(sol.t, sol[chbc.h] .* 100,
     xlabel="Time (s)", ylabel="Pressure head h (cm)",
     title="Boundary Condition Transition (Eq. 3)",
     label="h(t)", linewidth=2, legend=:bottomright)
hline!(p3, [0.0], linestyle=:dash, color=:red, label="h = 0 (ponding threshold)")

p3
```

### Manning's Friction Effect on Surface Runoff

This example shows how Manning's roughness coefficient affects the friction slope
and thus the momentum balance in the Saint-Venant equations (Eq. 1). Higher
roughness produces greater friction, reducing flow velocity. Note that this
single-node model demonstrates the local momentum response; in a full spatial
simulation, the spatial flux terms would transport momentum downstream.

```@example surface_runoff
sys_sr = SurfaceRunoff()
csys = mtkcompile(sys_sr)

# Compare different Manning coefficients with steady precipitation
# Using a short time window to observe the initial momentum response
p4 = plot(xlabel="Time (s)", ylabel="Runoff flux q (m²/s)",
          title="Effect of Manning's Roughness on Runoff (Eq. 1)",
          legend=:topleft)

for (n_val, label) in [(0.01, "n=0.01 (smooth)"),
                        (0.03, "n=0.03 (bare soil)"),
                        (0.10, "n=0.10 (dense grass)")]
    prob_sr = ODEProblem(csys,
        merge(
            Dict(csys.h̃ => 1e-3, csys.q => 0.0),
            Dict(
                csys.P => 2e-5,
                csys.I_infil => 1e-5,
                csys.S_0 => 0.01,
                csys.n_mann => n_val,
                csys.h̃_0 => 1e-5,
                csys.dqdl => 0.0,
                csys.dFdl => 0.0,
            )
        ),
        (0.0, 5.0))
    sol_sr = solve(prob_sr)
    plot!(p4, sol_sr.t, sol_sr[csys.q], label=label, linewidth=2)
end

p4
```

### Water Depth Accumulation Under Different Precipitation-Infiltration Regimes

This example demonstrates the mass conservation equation (Eq. 1a) under different
net water input scenarios, showing how the balance between precipitation and
infiltration controls ponded water depth.

```@example surface_runoff
p5 = plot(xlabel="Time (s)", ylabel="Flow depth h̃ (m)",
          title="Water Depth vs. Net Water Input (Eq. 1a)",
          legend=:topleft)

for (P_val, I_val, label) in [
    (3e-5, 1e-5, "P=3e-5, I=1e-5 (net gain)"),
    (2e-5, 2e-5, "P=2e-5, I=2e-5 (balanced)"),
    (1e-5, 2e-5, "P=1e-5, I=2e-5 (net loss)")]
    prob_acc = ODEProblem(csys,
        merge(
            Dict(csys.h̃ => 0.005, csys.q => 0.0),
            Dict(
                csys.P => P_val,
                csys.I_infil => I_val,
                csys.S_0 => 0.0,
                csys.n_mann => 0.03,
                csys.h̃_0 => 1e-5,
                csys.dqdl => 0.0,
                csys.dFdl => 0.0,
            )
        ),
        (0.0, 200.0))
    sol_acc = solve(prob_acc)
    plot!(p5, sol_acc.t, sol_acc[csys.h̃], label=label, linewidth=2)
end

p5
```

### PDE Spatial Solution with MethodOfLines.jl

The full Saint-Venant equations (Eq. 1 from Wang et al., 2020) can be solved
as a PDE system using [MethodOfLines.jl](https://github.com/SciML/MethodOfLines.jl)
for spatial discretization via the method of lines (finite differences).

The `SaintVenantPDE` function creates a `PDESystem` with proper SI units
that can be directly discretized with MethodOfLines.jl. All variables and
parameters carry SI unit annotations, and unit consistency is verified
during system construction.

```@example surface_runoff
using ModelingToolkit: t
using DomainSets
using MethodOfLines

# Create the Saint-Venant PDE system with 70 mm/hr rainfall on a 0.5 m domain
pde = SaintVenantPDE(0.5, 60.0;
    P_val = 70.0 / 1000 / 3600,  # 70 mm/hr in m/s
    S_0_val = 0.01,
    n_manning_val = 0.03,
    h_init_val = 1e-3,
    q_init_val = 0.0)

# Discretize using method of lines (finite differences)
l = pde.ivs[2]
dl = 0.1
discretization = MOLFiniteDifference([l => dl], t, approx_order = 2)
prob = discretize(pde, discretization; checks = false)

# Solve the discretized ODE system
sol = solve(prob)

h_tilde = pde.dvs[1]
q_flux = pde.dvs[2]
disc_l = sol[l]
h_vals = sol[h_tilde]

# Plot spatial profiles of water depth at different times
p6 = plot(xlabel="Distance along slope l (m)",
          ylabel="Flow depth h̃ (m)",
          title="Saint-Venant PDE: Water Depth Evolution (Eq. 1)",
          legend=:topleft)

for (i, ti) in enumerate(sol.t)
    label_str = "t = $(round(ti, digits=1)) s"
    plot!(p6, disc_l, h_vals[i, :], label=label_str, linewidth=2)
end

p6
```

```@example surface_runoff
println("ODEProblem created with $(length(prob.u0)) unknowns")
println("Time span: $(prob.tspan)")
println("Solution time steps: $(length(sol.t))")
```

## Limitations

The current implementation provides:
- **Single-node ODE components** (`SurfaceRunoff`, `HeavisideBoundaryCondition`)
  suitable for coupling with the EarthSciML framework
- **PDE spatial solution** (`SaintVenantPDE`) via MethodOfLines.jl discretization
  of the Saint-Venant equations (Eq. 1) with full SI unit support

The following features from Wang et al. (2020) are not yet implemented:
- Richards equation for subsurface flow (Eq. 2) — requires a separate subsurface
  flow component
- Coupled surface-subsurface simulations (Figs. 3-6) — requires both surface and
  subsurface models
- Ridge-furrow water harvesting application (Figs. 7-8) — requires the full coupled
  model with complex topography
