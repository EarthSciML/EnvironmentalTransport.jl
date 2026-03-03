# Soil Vapor Transfer

## Overview

This module implements the coupled soil water, heat, and vapor transfer model from Wang et al. (2022), which provides a modularized, partially-coupled approach for including vapor phase water and heat redistribution in soil simulations.

The model builds on the Philip and de Vries (1957) framework, separating the full coupled water-heat-vapor system into:
- **M_prel** (Eq. 1): Preliminary water and heat transfer without vapor
- **M_simp** (Eq. 2'): Simplified formulation including vapor transfer
- **M_comb** (Eq. 1 + 3 + 4): Combined approach solving M_prel first, then adding vapor corrections

**Reference**: Wang, Z., Timlin, D., Fleisher, D., Sun, W., Beegum, S., Li, S., Chen, Y., Reddy, V.R., Tully, K., & Horton, R. (2022). Modeling vapor transfer in soil water and heat simulations: A modularized, partially-coupled approach. *Journal of Hydrology*, 608, 127541.

```@docs
SoilVaporTransfer
```

```@docs
SoilVaporTransferPDE
```

## Implementation

The `SoilVaporTransfer` component implements 15 algebraic equations for the constitutive relations needed by the coupled water-heat-vapor system. These include the Campbell water retention model, hydraulic conductivity with temperature-dependent viscosity, thermal conductivity (Lu et al., 2014), vapor diffusion coefficients, and the liquid thermal diffusion coefficient from Eq. A3.

### State Variables

```@example vapor
using DataFrames, ModelingToolkit, DynamicQuantities
using EnvironmentalTransport

sys = SoilVaporTransfer()
vars = ModelingToolkit.unknowns(sys)
DataFrame(
    :Name => [string(Symbolics.tosymbol(v, escape=false)) for v in vars],
    :Units => [string(ModelingToolkit.get_unit(v)) for v in vars],
    :Description => [ModelingToolkit.getdescription(v) for v in vars]
)
```

### Parameters

```@example vapor
params = ModelingToolkit.parameters(sys)
# Show only the soil parameters (exclude unit constants)
soil_params = filter(p -> !startswith(string(p), "one_") &&
    !in(Symbol(p), [:c_l, :c_v, :ρ_l, :L_0, :g_acc, :M_w, :R_gas, :T_ref_visc, :c_s, :one_Pa]), params)
DataFrame(
    :Name => [string(p) for p in soil_params],
    :Default => [ModelingToolkit.getdefault(p) for p in soil_params],
    :Units => [string(ModelingToolkit.get_unit(p)) for p in soil_params],
    :Description => [ModelingToolkit.getdescription(p) for p in soil_params]
)
```

### Equations

```@example vapor
equations(sys)
```

## Analysis

### Constitutive Relations for Ida Soil (Table 1)

The following plots show the constitutive relations evaluated across a range of matric potentials for the Ida soil parameters from Table 1 of Wang et al. (2022).

```@example vapor
using Plots
using EnvironmentalTransport: _vt_theta, _vt_C_theta, _vt_K, _vt_lambda,
    _vt_Cv, _vt_Dmv, _vt_DTv, _vt_Dtl

# Ida soil parameters (Table 1)
θ_s = 0.547; h_a = -0.13; b = 6.53
K_s = 3.80e-7; p_K = 10.06
f_sand = 0.022; f_clay = 0.249; ρ_b = 1200.0
S_a = 2.44e8; G_a = 6.0; T = 298.15

# Range of matric potentials (unsaturated zone)
h_range = range(-10.0, -0.15, length=200)

# Compute constitutive relations
θ_vals = [_vt_theta(h, h_a, θ_s, b) for h in h_range]
K_vals = [_vt_K(h, T, h_a, θ_s, b, K_s, p_K) for h in h_range]
λ_vals = [_vt_lambda(h, h_a, θ_s, b, f_sand, f_clay, ρ_b) for h in h_range]
Dmv_vals = [_vt_Dmv(h, T, h_a, θ_s, b) for h in h_range]
DTv_vals = [_vt_DTv(h, T, h_a, θ_s, b) for h in h_range]

p1 = plot(collect(h_range), θ_vals,
    xlabel="h (m)", ylabel="θ (m³/m³)",
    title="Water Retention (Campbell)", legend=false)

p2 = plot(collect(h_range), K_vals,
    xlabel="h (m)", ylabel="K (m/s)",
    title="Hydraulic Conductivity", yscale=:log10, legend=false)

p3 = plot(collect(h_range), λ_vals,
    xlabel="h (m)", ylabel="λ (W/(m·K))",
    title="Thermal Conductivity", legend=false)

p4 = plot(collect(h_range), Dmv_vals,
    xlabel="h (m)", ylabel="Coefficient",
    title="Vapor Diffusion Coefficients", yscale=:log10, label="D_mv (m/s)")
plot!(p4, collect(h_range), DTv_vals, label="D_Tv (m²/(s·K))")

plot(p1, p2, p3, p4, layout=(2,2), size=(900, 600))
```

### Temperature Dependence of Hydraulic Conductivity

The viscosity ratio ``\mu(T_0)/\mu(T)`` increases with temperature, leading to higher hydraulic conductivity at warmer temperatures.

```@example vapor
T_range = range(273.15, 323.15, length=50)
h_test = -1.0
K_T = [_vt_K(h_test, T_val, h_a, θ_s, b, K_s, p_K) for T_val in T_range]

plot(collect(T_range), K_T,
    xlabel="Temperature (K)", ylabel="K (m/s)",
    title="K(h=-1m) vs Temperature", legend=false, size=(500, 350))
```
