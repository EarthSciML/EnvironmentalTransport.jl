# Holtslag & Boville (1993) Boundary Layer Diffusion

## Overview

This module implements boundary layer diffusion schemes from the seminal paper:

**Reference**: Holtslag, A.A.M. and B.A. Boville, 1993: "Local Versus Nonlocal Boundary-Layer Diffusion in a Global Climate Model." *Journal of Climate*, 6, 1825-1842.

The paper compares local and nonlocal diffusion schemes for the atmospheric boundary layer (ABL) within the NCAR Community Climate Model (CCM2). The key finding is that the nonlocal scheme better represents moisture transport in convective conditions by accounting for large-eddy transports.

```@docs
HoltslagBovilleSurfaceFlux
HoltslagBovilleLocalDiffusion
HoltslagBovilleNonlocalABL
```

## Implementation

```@example holtslag
using DataFrames, ModelingToolkit, Symbolics, DynamicQuantities
using EnvironmentalTransport
using OrdinaryDiffEqDefault
using Plots
default(size = (700, 400))
nothing # hide
```

### Surface Fluxes

The surface flux parameterization computes kinematic fluxes of momentum, heat, and moisture using bulk aerodynamic formulas with stability-dependent exchange coefficients.

Key equations from the paper:

| Equation | Description                                                                                 |
|:-------- |:------------------------------------------------------------------------------------------- |
| 2.1      | Surface momentum flux (u): ``(\overline{w'u'})_0 = -C_M|V_1|u_1``                           |
| 2.2      | Surface momentum flux (v): ``(\overline{w'v'})_0 = -C_M|V_1|v_1``                           |
| 2.3      | Surface heat flux: ``(\overline{w'\theta'})_0 = C_H|V_1|(\theta_0 - \theta_1)``             |
| 2.4      | Surface moisture flux: ``(\overline{w'q'})_0 = D_wC_H|V_1|(q_0 - q_1)``                     |
| 2.7      | Neutral exchange coefficient: ``C_N = k^2/[\ln((z_1+z_{0M})/z_{0M})]^2``                    |
| 2.8      | Bulk Richardson number: ``\text{Ri}_0 = gz_1(\theta_{v1} - \theta_{v0})/(\theta_1|V_1|^2)`` |

#### State Variables

```@example holtslag
sf = HoltslagBovilleSurfaceFlux()
sys_sf = mtkcompile(sf)

vars = unknowns(sys_sf)
DataFrame(
    :Name => [string(Symbolics.tosymbol(v, escape = false)) for v in vars],
    :Units => [ModelingToolkit.get_unit(v) for v in vars],
    :Description => [ModelingToolkit.getdescription(v) for v in vars]
)
```

#### Parameters

```@example holtslag
params = parameters(sys_sf)
DataFrame(
    :Name => [string(Symbolics.tosymbol(p, escape = false)) for p in params],
    :Default => [ModelingToolkit.getdefault(p) for p in params],
    :Units => [ModelingToolkit.get_unit(p) for p in params],
    :Description => [ModelingToolkit.getdescription(p) for p in params]
)
```

#### Equations

```@example holtslag
equations(sys_sf)
```

### Local Diffusion Scheme

The local diffusion scheme computes eddy diffusivity based on local gradients of wind and temperature.

Key equations:

| Equation | Description                                                                               |
|:-------- |:----------------------------------------------------------------------------------------- |
| 3.1      | Flux-gradient relation: ``\overline{w'C'} = -K_c \partial C/\partial z``                  |
| 3.2      | Eddy diffusivity: ``K_c = l_c^2 S F_c(\text{Ri})``                                        |
| 3.3      | Local shear: ``S = |\partial V/\partial z|``                                              |
| 3.4      | Mixing length: ``1/l_c = 1/(\kappa z) + 1/\lambda_c``                                     |
| 3.5      | Gradient Richardson number: ``\text{Ri} = (g/\theta_v)(\partial\theta_v/\partial z)/S^2`` |
| 3.6      | Asymptotic length scale: ``\lambda_c = 30 + 270\exp(1 - z/1000)``                         |
| 3.7      | Unstable stability function: ``F_c = (1 - 18\text{Ri})^{1/2}``                            |

#### State Variables

```@example holtslag
ld = HoltslagBovilleLocalDiffusion()
sys_ld = mtkcompile(ld)

vars_ld = unknowns(sys_ld)
DataFrame(
    :Name => [string(Symbolics.tosymbol(v, escape = false)) for v in vars_ld],
    :Units => [ModelingToolkit.get_unit(v) for v in vars_ld],
    :Description => [ModelingToolkit.getdescription(v) for v in vars_ld]
)
```

#### Equations

```@example holtslag
equations(sys_ld)
```

### Nonlocal ABL Scheme

The nonlocal scheme determines eddy diffusivity from boundary layer height and turbulent velocity scales, and includes nonlocal transport effects for heat and moisture in unstable conditions.

Key equations:

| Equation | Description                                                                              |
|:-------- |:---------------------------------------------------------------------------------------- |
| 3.8      | Nonlocal flux: ``\overline{w'C'} = -K_c(\partial C/\partial z - \gamma_c)``              |
| 3.9      | Eddy diffusivity profile: ``K_c = \kappa w_t z (1 - z/h)^2``                             |
| 3.10     | Nonlocal transport: ``\gamma_c = a w_* (\overline{w'C'})_0 / (w_m^2 h)``                 |
| A11      | Momentum velocity scale: ``w_m = (u_*^3 + c_1 w_*^3)^{1/3}``                             |
| A12      | Convective velocity scale: ``w_* = ((g/\theta_{v0})(\overline{w'\theta_v'})_0 h)^{1/3}`` |
| A13      | Turbulent Prandtl number: ``\text{Pr} = w_m/w_t``                                        |

#### State Variables

```@example holtslag
nl = HoltslagBovilleNonlocalABL()
sys_nl = mtkcompile(nl)

vars_nl = unknowns(sys_nl)
DataFrame(
    :Name => [string(Symbolics.tosymbol(v, escape = false)) for v in vars_nl],
    :Units => [ModelingToolkit.get_unit(v) for v in vars_nl],
    :Description => [ModelingToolkit.getdescription(v) for v in vars_nl]
)
```

#### Equations

```@example holtslag
equations(sys_nl)
```

## Analysis

### Stability Function Comparison (Eq. 2.9-2.11)

The stability functions modify the neutral exchange coefficient based on the Richardson number. For unstable conditions (Ri < 0), mixing is enhanced (f > 1), while for stable conditions (Ri > 0), mixing is suppressed (f < 1). In unstable conditions, heat transfer is more enhanced than momentum (fₕ > fₘ) due to the larger coefficient (15 vs 10).

```@example holtslag
Δθv_values = -10.0:0.5:10.0
fM_values = Float64[]
fH_values = Float64[]
Ri_values = Float64[]

for Δθv in Δθv_values
    prob = ODEProblem(sys_sf,
        Dict(),
        (0.0, 1.0),
        Dict(
            sys_sf.θᵥ₀ => 300.0,
            sys_sf.θᵥ₁ => 300.0 + Δθv,
            sys_sf.θ₀ => 300.0,
            sys_sf.θ₁ => 300.0 + Δθv,
            sys_sf.u₁ => 5.0,
            sys_sf.v₁ => 0.0,
            sys_sf.z₁ => 10.0,
            sys_sf.z₀ₘ => 0.1
        ))
    sol = solve(prob)
    push!(fM_values, sol[sys_sf.fₘ][end])
    push!(fH_values, sol[sys_sf.fₕ][end])
    push!(Ri_values, sol[sys_sf.Ri₀][end])
end

plot(Ri_values, fM_values, label = "fM (momentum)", linewidth = 2,
    xlabel = "Bulk Richardson Number Ri₀",
    ylabel = "Stability Function",
    title = "Surface Layer Stability Functions (Eq. 2.9-2.11)")
plot!(Ri_values, fH_values, label = "fH (heat)", linewidth = 2, linestyle = :dash)
```

### Eddy Diffusivity Profile (Eq. 3.9)

The nonlocal scheme produces eddy diffusivity profiles that depend on the boundary layer height and stability. The profile ``K_c = \kappa w_t z (1 - z/h)^2`` is zero at both the surface and the boundary layer top, with a maximum near ``z \approx h/3``.

```@example holtslag
h = 1000.0
heights = 50.0:50.0:950.0

Kc_values = Float64[]
for z in heights
    prob = ODEProblem(sys_nl,
        Dict(),
        (0.0, 1.0),
        Dict(
            sys_nl.z => z,
            sys_nl.h => h,
            sys_nl.u_star => 0.3,
            sys_nl.wθᵥ₀ => 0.1,
            sys_nl.wC₀ => 1e-5,
            sys_nl.θᵥ₀ => 300.0,
            sys_nl.L => -100.0
        ))
    sol = solve(prob)
    push!(Kc_values, sol[sys_nl.Kc][end])
end

plot(Kc_values, collect(heights),
    xlabel = "Eddy Diffusivity Kc (m²/s)",
    ylabel = "Height z (m)",
    title = "Nonlocal ABL Eddy Diffusivity Profile\n(Unstable conditions: h = 1000 m)",
    linewidth = 2, legend = false)
```

### Convective Velocity Scale Dependence (Eq. A12)

The convective velocity scale ``w_*`` increases with surface heat flux and boundary layer height following ``w_* = ((g/\theta_{v0})(\overline{w'\theta_v'})_0 h)^{1/3}``.

```@example holtslag
heat_fluxes = 0.01:0.02:0.2
h_values = [500.0, 1000.0, 1500.0, 2000.0]

p = plot(xlabel = "Surface Heat Flux (K·m/s)",
    ylabel = "Convective Velocity Scale w* (m/s)",
    title = "Convective Velocity Scale (Eq. A12)")

for h in h_values
    w_star_vals = Float64[]
    for wθ in heat_fluxes
        prob = ODEProblem(sys_nl,
            Dict(),
            (0.0, 1.0),
            Dict(
                sys_nl.z => 500.0,
                sys_nl.h => h,
                sys_nl.u_star => 0.3,
                sys_nl.wθᵥ₀ => wθ,
                sys_nl.wC₀ => 1e-5,
                sys_nl.θᵥ₀ => 300.0,
                sys_nl.L => -100.0
            ))
        sol = solve(prob)
        push!(w_star_vals, sol[sys_nl.w_star][end])
    end
    plot!(p, collect(heat_fluxes), w_star_vals, label = "h = $(Int(h)) m", linewidth = 2)
end
p
```

## Physical Interpretation

### Local vs Nonlocal Schemes

The key differences between the schemes are:

 1. **Local scheme**: Eddy diffusivity depends only on local gradients. Heat transport can only occur when there is a local temperature gradient. This fails in convective conditions where the mixed layer has nearly uniform temperature but still transports heat.

 2. **Nonlocal scheme**: Eddy diffusivity depends on boundary layer height and turbulent velocity scales. Includes a countergradient term (γc) that allows heat transport even in well-mixed conditions, representing large-eddy transport.

### Implications for Climate Modeling

From the paper's findings:

  - The nonlocal scheme transports moisture more rapidly and deeply
  - Local scheme tends to saturate lowest model levels unrealistically
  - Nonlocal scheme produces more realistic cloud distributions
  - Temperature differences between schemes are ~1 K, humidity differences ~1 g/kg

## Parameter Summary

| Parameter | Value | Description                     |
|:--------- |:----- |:------------------------------- |
| κ         | 0.4   | von Karman constant             |
| Ri_cr     | 0.5   | Critical bulk Richardson number |
| a         | 7.2   | Nonlocal transport constant     |
| b         | 8.5   | Temperature excess constant     |
| c₁        | 0.6   | Velocity scale constant         |
| λc(z=1km) | 300 m | Asymptotic length scale at 1 km |
| λc(z→∞)   | 30 m  | Free atmosphere length scale    |
