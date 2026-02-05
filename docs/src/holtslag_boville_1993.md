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
using ModelingToolkit: @named
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
| 2.5      | Momentum exchange coefficient: ``C_M = C_N f_m``                                             |
| 2.6      | Heat exchange coefficient: ``C_H = C_N f_h``                                                 |
| 2.7      | Neutral exchange coefficient: ``C_N = k^2/[\ln((z_1+z_{0M})/z_{0M})]^2``                    |
| 2.8      | Bulk Richardson number: ``\text{Ri}_0 = gz_1(\theta_{v1} - \theta_{v0})/(\theta_1|V_1|^2)`` |
| 2.9      | Unstable momentum stability: ``f_m = 1 - 10\text{Ri}_0/(1 + 75C_N[(z_1+z_{0M})/z_{0M}|\text{Ri}_0|]^{1/2})`` |
| 2.10     | Unstable heat stability: ``f_h = 1 - 15\text{Ri}_0/(1 + 75C_N[(z_1+z_{0M})/z_{0M}|\text{Ri}_0|]^{1/2})`` |
| 2.11     | Stable stability function: ``f_m = f_h = 1/(1 + 10\text{Ri}_0(1 + 8\text{Ri}_0))``         |

#### State Variables

```@example holtslag
@named sf = HoltslagBovilleSurfaceFlux()

vars = unknowns(sf)
DataFrame(
    :Name => [string(Symbolics.tosymbol(v, escape = false)) for v in vars],
    :Units => [string(ModelingToolkit.get_unit(v)) for v in vars],
    :Description => [ModelingToolkit.getdescription(v) for v in vars]
)
```

#### Parameters

```@example holtslag
params = parameters(sf)
DataFrame(
    :Name => [string(Symbolics.tosymbol(p, escape = false)) for p in params],
    :Default => [ModelingToolkit.getdefault(p) for p in params],
    :Units => [string(ModelingToolkit.get_unit(p)) for p in params],
    :Description => [ModelingToolkit.getdescription(p) for p in params]
)
```

#### Equations

```@example holtslag
equations(sf)
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
@named ld = HoltslagBovilleLocalDiffusion()

vars_ld = unknowns(ld)
DataFrame(
    :Name => [string(Symbolics.tosymbol(v, escape = false)) for v in vars_ld],
    :Units => [string(ModelingToolkit.get_unit(v)) for v in vars_ld],
    :Description => [ModelingToolkit.getdescription(v) for v in vars_ld]
)
```

#### Parameters

```@example holtslag
params_ld = parameters(ld)
DataFrame(
    :Name => [string(Symbolics.tosymbol(p, escape = false)) for p in params_ld],
    :Default => [ModelingToolkit.getdefault(p) for p in params_ld],
    :Units => [string(ModelingToolkit.get_unit(p)) for p in params_ld],
    :Description => [ModelingToolkit.getdescription(p) for p in params_ld]
)
```

#### Equations

```@example holtslag
equations(ld)
```

### Nonlocal ABL Scheme

The nonlocal scheme determines eddy diffusivity from boundary layer height and turbulent velocity scales, and includes nonlocal transport effects for heat and moisture in unstable conditions.

Key equations:

| Equation | Description                                                                              |
|:-------- |:---------------------------------------------------------------------------------------- |
| 3.8      | Nonlocal flux: ``\overline{w'C'} = -K_c(\partial C/\partial z - \gamma_c)``              |
| 3.9      | Eddy diffusivity profile: ``K_c = \kappa w_t z (1 - z/h)^2``                             |
| 3.10     | Nonlocal transport: ``\gamma_c = a w_* (\overline{w'C'})_0 / (w_m^2 h)``                 |
| A1       | Surface layer eddy diffusivity: ``K = \kappa u_* z / \phi_h(z/L)``                       |
| A2/A4    | Dimensionless wind shear (stable): ``\phi_m = 1 + 5z/L`` / ``\phi_m = 5 + z/L``         |
| A3/A5    | Dimensionless temperature gradient (stable): ``\phi_h = 1 + 5z/L`` / ``\phi_h = 5 + z/L``|
| A6       | Unstable temperature profile: ``\phi_h = (1-15z/L)^{-1/2}``                              |
| A7       | Surface layer momentum velocity scale: ``w_m = u_*/\phi_m``                               |
| A8       | Unstable wind shear profile: ``\phi_m = (1-15z/L)^{-1/3}``                                |
| A11      | Outer-layer momentum velocity scale: ``w_m = (u_*^3 + c_1 w_*^3)^{1/3}``                  |
| A12      | Convective velocity scale: ``w_* = ((g/\theta_{v0})(\overline{w'\theta_v'})_0 h)^{1/3}`` |
| A13      | Turbulent Prandtl number: ``\text{Pr} = \phi_h/\phi_m + a \kappa \varepsilon (w_*/w_m)`` |

#### State Variables

```@example holtslag
@named nl = HoltslagBovilleNonlocalABL()

vars_nl = unknowns(nl)
DataFrame(
    :Name => [string(Symbolics.tosymbol(v, escape = false)) for v in vars_nl],
    :Units => [string(ModelingToolkit.get_unit(v)) for v in vars_nl],
    :Description => [ModelingToolkit.getdescription(v) for v in vars_nl]
)
```

#### Parameters

```@example holtslag
params_nl = parameters(nl)
DataFrame(
    :Name => [string(Symbolics.tosymbol(p, escape = false)) for p in params_nl],
    :Default => [ModelingToolkit.getdefault(p) for p in params_nl],
    :Units => [string(ModelingToolkit.get_unit(p)) for p in params_nl],
    :Description => [ModelingToolkit.getdescription(p) for p in params_nl]
)
```

#### Equations

```@example holtslag
equations(nl)
```

## Analysis

### Stability Function Comparison (Eq. 2.9-2.11)

The stability functions modify the neutral exchange coefficient based on the Richardson number. For unstable conditions (Ri < 0), mixing is enhanced (f > 1), while for stable conditions (Ri > 0), mixing is suppressed (f < 1). In unstable conditions, heat transfer is more enhanced than momentum (fₕ > fₘ) due to the larger coefficient (15 vs 10).

```@example holtslag
sys_sf = mtkcompile(sf)
sys_ld = mtkcompile(ld)
sys_nl = mtkcompile(nl)

Δθv_values = -10.0:0.5:10.0
fM_values = Float64[]
fH_values = Float64[]
Ri_values = Float64[]

for Δθv in Δθv_values
    prob = ODEProblem(sys_sf,
        Dict(
            sys_sf.θᵥ₀ => 300.0,
            sys_sf.θᵥ₁ => 300.0 + Δθv,
            sys_sf.θ₀ => 300.0,
            sys_sf.θ₁ => 300.0 + Δθv,
            sys_sf.u₁ => 5.0,
            sys_sf.v₁ => 0.0,
            sys_sf.z₁ => 10.0,
            sys_sf.z₀ₘ => 0.1
        ),
        (0.0, 1.0))
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
        Dict(
            sys_nl.z => z,
            sys_nl.h => h,
            sys_nl.u_star => 0.3,
            sys_nl.wθᵥ₀ => 0.1,
            sys_nl.wC₀ => 1e-5,
            sys_nl.θᵥ₀ => 300.0,
            sys_nl.L => -100.0
        ),
        (0.0, 1.0))
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
            Dict(
                sys_nl.z => 500.0,
                sys_nl.h => h,
                sys_nl.u_star => 0.3,
                sys_nl.wθᵥ₀ => wθ,
                sys_nl.wC₀ => 1e-5,
                sys_nl.θᵥ₀ => 300.0,
                sys_nl.L => -100.0
            ),
            (0.0, 1.0))
        sol = solve(prob)
        push!(w_star_vals, sol[sys_nl.w_star][end])
    end
    plot!(p, collect(heat_fluxes), w_star_vals, label = "h = $(Int(h)) m", linewidth = 2)
end
p
```

### Local Diffusion: Eddy Diffusivity vs Height (Eq. 3.2, 3.6)

The local scheme's eddy diffusivity depends on the mixing length scale, which varies with height through the asymptotic length scale ``\lambda_c``. Higher heights lead to smaller mixing lengths and different diffusivity profiles depending on stability.

```@example holtslag
heights_local = 10.0:10.0:2000.0
Kc_stable = Float64[]
Kc_unstable = Float64[]

for z in heights_local
    # Stable conditions
    prob_s = ODEProblem(sys_ld,
        Dict(
            sys_ld.z => z,
            sys_ld.θᵥ => 300.0,
            sys_ld.∂θᵥ_∂z => 0.005,
            sys_ld.∂u_∂z => 0.01,
            sys_ld.∂v_∂z => 0.0
        ),
        (0.0, 1.0))
    sol_s = solve(prob_s)
    push!(Kc_stable, sol_s[sys_ld.Kc][end])

    # Unstable conditions
    prob_u = ODEProblem(sys_ld,
        Dict(
            sys_ld.z => z,
            sys_ld.θᵥ => 300.0,
            sys_ld.∂θᵥ_∂z => -0.005,
            sys_ld.∂u_∂z => 0.01,
            sys_ld.∂v_∂z => 0.0
        ),
        (0.0, 1.0))
    sol_u = solve(prob_u)
    push!(Kc_unstable, sol_u[sys_ld.Kc][end])
end

plot(Kc_stable, collect(heights_local), label = "Stable (∂θᵥ/∂z > 0)", linewidth = 2,
    xlabel = "Eddy Diffusivity Kc (m²/s)",
    ylabel = "Height z (m)",
    title = "Local Scheme Eddy Diffusivity Profile (Eq. 3.2)")
plot!(Kc_unstable, collect(heights_local), label = "Unstable (∂θᵥ/∂z < 0)", linewidth = 2,
    linestyle = :dash)
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
| a         | 7.2   | Nonlocal transport constant     |
| c₁        | 0.6   | Velocity scale constant         |
| ε         | 0.1   | Surface layer fraction of h     |
| λc(z=1km) | 300 m | Asymptotic length scale at 1 km |
| λc(z→∞)   | 30 m  | Free atmosphere length scale    |
