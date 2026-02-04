# Local Scale Meteorology

## Overview

This module implements equations for local-scale atmospheric boundary layer meteorology, including:

  - Atmospheric stability classification based on potential temperature
  - Monin-Obukhov similarity theory for the surface layer
  - Logarithmic wind profiles with stability corrections
  - Pasquill stability class estimation

These equations are essential for understanding pollutant dispersion in the atmospheric boundary layer, where turbulent mixing is driven by mechanical (wind shear) and thermal (buoyancy) effects.

**Reference**: Seinfeld, J.H. and Pandis, S.N. (2006) *Atmospheric Chemistry and Physics: From Air Pollution to Climate Change*, 2nd Edition, Chapter 16: "Meteorology of the Local Scale", pp. 720-760. John Wiley & Sons.

```@docs
LocalScaleMeteorology
AtmosphericStability
SurfaceLayerProfile
```

## Implementation

The implementation consists of three main systems:

 1. **`AtmosphericStability`**: Computes potential temperature and vertical stability based on temperature gradients
 2. **`SurfaceLayerProfile`**: Implements Monin-Obukhov similarity theory for wind profiles
 3. **`LocalScaleMeteorology`**: A comprehensive system combining both stability and wind profile calculations

### State Variables

```@example local_met
using DataFrames, ModelingToolkit, Symbolics, DynamicQuantities
using EnvironmentalTransport

sys = LocalScaleMeteorology()
vars = unknowns(sys)

DataFrame(
    :Name => [string(Symbolics.tosymbol(v, escape = false)) for v in vars],
    :Units => [ModelingToolkit.get_unit(v) for v in vars],
    :Description => [ModelingToolkit.getdescription(v) for v in vars]
)
```

### Parameters

```@example local_met
params = parameters(sys)

DataFrame(
    :Name => [string(Symbolics.tosymbol(p, escape = false)) for p in params],
    :Default => [ModelingToolkit.getdefault(p) for p in params],
    :Units => [ModelingToolkit.get_unit(p) for p in params],
    :Description => [ModelingToolkit.getdescription(p) for p in params]
)
```

### Equations

```@example local_met
eqs = equations(sys)
```

## Analysis

### Dry Adiabatic Lapse Rate (Eq. 16.8)

A key result from the first law of thermodynamics applied to an adiabatically rising air parcel is the dry adiabatic lapse rate:

```math
\Gamma = \frac{g}{\hat{c}_{p,\text{air}}} = \frac{9.807 \text{ m/s}^2}{1005 \text{ J/(kg·K)}} \approx 9.76 \text{ K/km}
```

This represents the rate at which an unsaturated air parcel cools as it rises adiabatically.

```@example local_met
# Verify the dry adiabatic lapse rate calculation
g = 9.807  # m/s²
ĉ_p = 1005.0  # J/(kg·K)
Γ = g / ĉ_p * 1000  # Convert to K/km
println("Dry adiabatic lapse rate: Γ = $(round(Γ, digits=2)) K/km")
```

### Potential Temperature (Eq. 16.14)

Potential temperature is the temperature an air parcel would have if brought adiabatically to a reference pressure (typically sea level):

```math
\theta = T \left(\frac{p_0}{p}\right)^{R/(c_p M_{\text{air}})} = T \left(\frac{p_0}{p}\right)^{0.286}
```

```@example local_met
using OrdinaryDiffEqDefault, Plots
default(size = (700, 400))

sys = LocalScaleMeteorology()
csys = mtkcompile(sys)

# Calculate potential temperature at different pressure levels
pressures = range(101325, 50000, length = 20)  # Pa
T_ambient = 288.15 .- 0.0065 .* (1 .- pressures ./ 101325) .* 8500  # Approximate T profile

θ_values = Float64[]
for (p, T) in zip(pressures, T_ambient)
    prob = ODEProblem(csys, Dict(), (0.0, 1.0), Dict(csys.T => T, csys.p => p))
    sol = solve(prob)
    push!(θ_values, sol[csys.θ][end])
end

plot(θ_values, pressures ./ 100,
    xlabel = "Potential Temperature (K)",
    ylabel = "Pressure (hPa)",
    yflip = true,
    label = "θ",
    linewidth = 2,
    title = "Potential Temperature Profile")
```

### Atmospheric Stability Classification

Atmospheric stability determines the tendency of vertically displaced air parcels to return to equilibrium or continue moving. The stability is characterized by the potential temperature gradient:

  - **Stable** (``\partial\theta/\partial z > 0``): Displaced parcels return to original position
  - **Neutral** (``\partial\theta/\partial z = 0``): Displaced parcels remain at new position
  - **Unstable** (``\partial\theta/\partial z < 0``): Displaced parcels accelerate away

```@example local_met
sys = AtmosphericStability()
csys = mtkcompile(sys)

T_surface = 288.15  # K
Δz = 100.0  # m

# Three stability cases
cases = [
    ("Stable (weak lapse)", T_surface - 0.005 * Δz),      # 0.5 K/100m
    ("Neutral (adiabatic)", T_surface - 0.00976 * Δz),    # ~9.76 K/km
    ("Unstable (superadiabatic)", T_surface - 0.015 * Δz)  # 1.5 K/100m
]

results = []
for (label, T_above) in cases
    prob = ODEProblem(csys, Dict(), (0.0, 1.0),
        Dict(csys.T => T_above, csys.T_below => T_surface, csys.Δz => Δz))
    sol = solve(prob)
    push!(results, (label = label, S = sol[csys.S][end] * 1000))  # K/km
end

DataFrame(results)
```

### Monin-Obukhov Similarity Theory

The Monin-Obukhov length ``L`` is a fundamental scaling parameter that characterizes the relative importance of mechanical and thermal turbulence production:

```math
L = -\frac{\rho \hat{c}_p T_0 u_*^3}{\kappa g \bar{q}_z}
```

where:

  - ``u_*`` is the friction velocity
  - ``\bar{q}_z`` is the surface sensible heat flux
  - ``\kappa = 0.4`` is the von Karman constant

```@example local_met
sys = SurfaceLayerProfile()
csys = mtkcompile(sys)

# Calculate Monin-Obukhov length for different heat flux conditions
heat_fluxes = range(-100, 200, length = 50)  # W/m²
L_values = Float64[]

for q in heat_fluxes
    if abs(q) < 1e-6
        push!(L_values, NaN)  # Avoid singularity
        continue
    end
    prob = ODEProblem(csys, Dict(), (0.0, 1.0),
        Dict(csys.u_star => 0.3, csys.q_z => q))
    sol = solve(prob)
    L_val = sol[csys.L][end]
    push!(L_values, clamp(L_val, -500, 500))  # Clamp for visualization
end

plot(heat_fluxes, L_values,
    xlabel = "Surface Heat Flux (W/m²)",
    ylabel = "Monin-Obukhov Length L (m)",
    label = "L",
    linewidth = 2,
    title = "Monin-Obukhov Length vs Heat Flux\n(u* = 0.3 m/s)",
    ylims = (-500, 500))
hline!([0], linestyle = :dash, color = :gray, label = "")
vline!([0], linestyle = :dash, color = :gray, label = "")
annotate!([(100, -200, text("Unstable\n(L < 0)", 8)),
    (-50, 200, text("Stable\n(L > 0)", 8))])
```

### Businger-Dyer Stability Functions (Eq. 16.75)

The universal functions ``\phi_m(\zeta)`` and ``\phi_h(\zeta)`` describe how momentum and heat transfer deviate from neutral conditions:

**Unstable** (``\zeta < 0``):

```math
\phi_m = (1 - 15\zeta)^{-1/4}, \quad \phi_h = (1 - 15\zeta)^{-1/2}
```

**Stable** (``\zeta > 0``):

```math
\phi_m = \phi_h = 1 + 4.7\zeta
```

```@example local_met
# Plot stability functions
ζ_unstable = range(-2, 0, length = 50)
ζ_stable = range(0, 2, length = 50)
ζ_all = vcat(ζ_unstable, ζ_stable)

φ_m_unstable = (1 .- 15 .* ζ_unstable) .^ (-0.25)
φ_m_stable = 1 .+ 4.7 .* ζ_stable
φ_m_all = vcat(φ_m_unstable, φ_m_stable)

φ_h_unstable = (1 .- 15 .* ζ_unstable) .^ (-0.5)
φ_h_stable = 1 .+ 4.7 .* ζ_stable
φ_h_all = vcat(φ_h_unstable, φ_h_stable)

plot(ζ_all, φ_m_all, label = "φ_m (momentum)", linewidth = 2)
plot!(ζ_all, φ_h_all, label = "φ_h (heat)", linewidth = 2)
xlabel!("ζ = z/L")
ylabel!("φ")
title!("Businger-Dyer Stability Functions (Eq. 16.75)")
hline!([1], linestyle = :dash, color = :gray, label = "Neutral")
vline!([0], linestyle = :dash, color = :gray, label = "")
```

### Logarithmic Wind Profile (Eq. 16.66)

The wind velocity in the surface layer follows a logarithmic profile with stability corrections:

```math
\bar{u}(z) = \frac{u_*}{\kappa}\left[\ln\left(\frac{z}{z_0}\right) - \psi_m(\zeta)\right]
```

where ``\psi_m`` is the integrated stability function.

```@example local_met
sys = SurfaceLayerProfile()
csys = mtkcompile(sys)

# Wind profiles for different stability conditions
heights = range(1, 50, length = 30)  # m
z₀ = 0.1  # m
u_star = 0.4  # m/s

# Neutral, stable, and unstable profiles
stabilities = [
    ("Neutral", 1e-8),
    ("Stable", -50.0),  # Negative flux = downward = stable
    ("Unstable", 100.0)  # Positive flux = upward = unstable
]

p = plot(
    title = "Wind Profiles for Different Stability Conditions\n(u* = 0.4 m/s, z₀ = 0.1 m)",
    xlabel = "Wind Speed (m/s)", ylabel = "Height (m)")

for (label, q_z) in stabilities
    u_values = Float64[]
    for z in heights
        prob = ODEProblem(csys, Dict(), (0.0, 1.0),
            Dict(csys.z => z, csys.z₀ => z₀, csys.u_star => u_star, csys.q_z => q_z))
        sol = solve(prob)
        push!(u_values, sol[csys.ū][end])
    end
    plot!(p, u_values, heights, label = label, linewidth = 2)
end
p
```

### Pasquill Stability Classes (Table 16.4)

The Pasquill-Gifford stability classification provides a practical way to categorize atmospheric stability based on observable meteorological conditions:

| Class | Description         | Conditions                             |
|:-----:|:------------------- |:-------------------------------------- |
| A     | Very unstable       | Strong daytime insolation, light winds |
| B     | Moderately unstable | Moderate daytime insolation            |
| C     | Slightly unstable   | Weak daytime insolation                |
| D     | Neutral             | Overcast or high winds                 |
| E     | Slightly stable     | Night, partial cloud cover             |
| F     | Moderately stable   | Night, clear skies, light winds        |

The Golder (1972) correlation relates Pasquill classes to Monin-Obukhov length via:

```math
\frac{1}{L} = a + b \cdot \log_{10}(z_0)
```

```@example local_met
# Golder correlation coefficients
golder_params = [
    ("A", -0.096, 0.029),
    ("B", -0.037, 0.029),
    ("C", -0.002, 0.018),
    ("D", 0.000, 0.000),
    ("E", 0.004, -0.018),
    ("F", 0.035, -0.036)
]

z0_range = 10 .^ range(-4, 1, length = 100)  # m

p = plot(
    title = "Monin-Obukhov Length vs Roughness Length\nfor Pasquill Stability Classes (Eq. 16.83)",
    xlabel = "Roughness Length z₀ (m)", ylabel = "1/L (m⁻¹)",
    xscale = :log10, legend = :topright)

for (class, a, b) in golder_params
    L_inv = a .+ b .* log10.(z0_range)
    plot!(p, z0_range, L_inv, label = "Class $class", linewidth = 2)
end
hline!([0], linestyle = :dash, color = :gray, label = "Neutral")
ylims!(-0.15, 0.1)
p
```

### Example: Complete Boundary Layer Analysis

```@example local_met
sys = LocalScaleMeteorology()
csys = mtkcompile(sys)

# Summer afternoon conditions
conditions = Dict(
    csys.T => 298.15,        # 25°C at 10m
    csys.T_below => 300.15,  # 27°C at surface (superadiabatic)
    csys.p => 100000.0,      # ~sea level
    csys.z => 10.0,          # 10m measurement height
    csys.z₀ => 0.1,          # Grassland
    csys.Δz => 10.0,         # 10m vertical spacing
    csys.T₀ => 300.15,       # Surface temperature
    csys.ρ => 1.18,          # Air density
    csys.u_star => 0.35,     # Moderate friction
    csys.q_z => 150.0        # Strong upward heat flux (sunny afternoon)
)

prob = ODEProblem(csys, Dict(), (0.0, 1.0), conditions)
sol = solve(prob)

println("=== Summer Afternoon Boundary Layer Analysis ===\n")
println("Potential temperature: θ = $(round(sol[csys.θ][end], digits=1)) K")
println("Stability (dθ/dz): $(round(sol[csys.dθ_dz][end] * 1000, digits=2)) K/km")
println("Monin-Obukhov length: L = $(round(sol[csys.L][end], digits=1)) m")
println("Stability parameter: ζ = $(round(sol[csys.ζ][end], digits=3))")
println("Wind speed at 10m: ū = $(round(sol[csys.ū][end], digits=2)) m/s")
println("Pasquill class: $(Int(round(sol[csys.pasquill_class][end]))) (1=A to 6=F)")

# Interpret the results
L_val = sol[csys.L][end]
stability = L_val < 0 ? "UNSTABLE" : (L_val > 0 ? "STABLE" : "NEUTRAL")
println("\nInterpretation: Atmosphere is $stability (typical for sunny afternoon)")
```

## Roughness Length Reference (Table 16.1)

The roughness length ``z_0`` depends on surface characteristics:

| Surface Type                   | z₀ (m) |
|:------------------------------ |:------:|
| Very smooth (ice, mud flats)   | 10⁻⁵   |
| Snow, smooth sea, level desert | 10⁻³   |
| Lawn                           | 10⁻²   |
| Uncut grass                    | 0.05   |
| Full-grown root crops          | 0.1    |
| Tree-covered terrain           | 1      |
| Low-density residential        | 2      |
| Central business district      | 5-10   |
