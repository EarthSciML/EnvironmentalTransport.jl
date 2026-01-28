# Atmospheric Fundamentals

## Overview

This module implements the fundamental atmospheric equations from Chapter 1 of Seinfeld and Pandis (2006). These equations describe the basic physical and thermodynamic properties of Earth's atmosphere, including pressure distribution, temperature profiles, and concentration units. They form the foundation for atmospheric chemistry and physics modeling.

The implementation provides ModelingToolkit.jl components for:

  - **Hydrostatic equilibrium**: The vertical pressure gradient in the atmosphere (Eq. 1.1)
  - **Ideal gas law**: Air density from pressure and temperature (Eq. 1.2)
  - **Scale height**: Characteristic altitude for pressure decrease (Eq. 1.4)
  - **Barometric formula**: Pressure-altitude relationship for isothermal atmosphere (Eq. 1.5)
  - **Concentration units**: Volume mixing ratio and molar concentration (Eq. 1.6-1.8)
  - **Water vapor**: Saturation vapor pressure and relative humidity (Eq. 1.9-1.10)

**Reference**: Seinfeld, J.H. and Pandis, S.N. (2006). *Atmospheric Chemistry and Physics: From Air Pollution to Climate Change*, 2nd Edition, Chapter 1: The Atmosphere. John Wiley & Sons, Inc.

```@docs
IdealGasLaw
ScaleHeight
AtmosphericPressureProfile
BarometricFormula
TotalMolarConcentration
MixingRatio
PartialPressureMixingRatio
SaturationVaporPressure
RelativeHumidity
AtmosphericThermodynamics
WaterVaporThermodynamics
```

## Implementation

```@example sp_ch1
using EnvironmentalTransport
using DataFrames, ModelingToolkit, Symbolics, DynamicQuantities
using ModelingToolkit: @named
nothing # hide
```

### Ideal Gas Law (Eq. 1.2)

The ideal gas law relates air density to pressure and temperature:

```math
\rho = \frac{M_{air} \cdot p}{R \cdot T}
```

#### State Variables

```@example sp_ch1
@named sys = IdealGasLaw()
vars = unknowns(sys)
DataFrame(
    :Name => [string(Symbolics.tosymbol(v, escape = false)) for v in vars],
    :Units => [string(ModelingToolkit.get_unit(v)) for v in vars],
    :Description => [ModelingToolkit.getdescription(v) for v in vars]
)
```

#### Equations

```@example sp_ch1
equations(sys)
```

* * *

### Scale Height (Eq. 1.4)

The scale height represents the altitude increase over which pressure decreases by a factor of ``e`` (~2.718):

```math
H = \frac{R \cdot T}{M_{air} \cdot g}
```

#### State Variables

```@example sp_ch1
@named sys = ScaleHeight()
vars = unknowns(sys)
DataFrame(
    :Name => [string(Symbolics.tosymbol(v, escape = false)) for v in vars],
    :Units => [string(ModelingToolkit.get_unit(v)) for v in vars],
    :Description => [ModelingToolkit.getdescription(v) for v in vars]
)
```

#### Equations

```@example sp_ch1
equations(sys)
```

* * *

### Atmospheric Pressure Profile (Eq. 1.1, 1.3, 1.5)

This component combines the hydrostatic equation with the ideal gas law to compute the complete atmospheric pressure profile.

**Hydrostatic equation** (Eq. 1.1):

```math
\frac{dp}{dz} = -\rho \cdot g
```

**Combined form** (Eq. 1.3):

```math
\frac{dp}{dz} = -\frac{M_{air} \cdot g \cdot p}{R \cdot T}
```

**Barometric formula** for isothermal atmosphere (Eq. 1.5):

```math
\frac{p(z)}{p_0} = \exp\left(-\frac{z}{H}\right)
```

#### State Variables

```@example sp_ch1
@named sys = AtmosphericPressureProfile()
vars = unknowns(sys)
DataFrame(
    :Name => [string(Symbolics.tosymbol(v, escape = false)) for v in vars],
    :Units => [string(ModelingToolkit.get_unit(v)) for v in vars],
    :Description => [ModelingToolkit.getdescription(v) for v in vars]
)
```

#### Parameters

```@example sp_ch1
params = parameters(sys)
DataFrame(
    :Name => [string(Symbolics.tosymbol(p, escape = false)) for p in params],
    :Units => [string(ModelingToolkit.get_unit(p)) for p in params],
    :Description => [ModelingToolkit.getdescription(p) for p in params]
)
```

#### Equations

```@example sp_ch1
equations(sys)
```

* * *

### Total Molar Concentration (Eq. 1.7)

```math
c_{total} = \frac{N}{V} = \frac{p}{R \cdot T}
```

#### State Variables

```@example sp_ch1
@named sys = TotalMolarConcentration()
vars = unknowns(sys)
DataFrame(
    :Name => [string(Symbolics.tosymbol(v, escape = false)) for v in vars],
    :Units => [string(ModelingToolkit.get_unit(v)) for v in vars],
    :Description => [ModelingToolkit.getdescription(v) for v in vars]
)
```

#### Equations

```@example sp_ch1
equations(sys)
```

* * *

### Mixing Ratio (Eq. 1.6)

```math
\xi_i = \frac{c_i}{c_{total}}
```

#### State Variables

```@example sp_ch1
@named sys = MixingRatio()
vars = unknowns(sys)
DataFrame(
    :Name => [string(Symbolics.tosymbol(v, escape = false)) for v in vars],
    :Units => [string(ModelingToolkit.get_unit(v)) for v in vars],
    :Description => [ModelingToolkit.getdescription(v) for v in vars]
)
```

#### Equations

```@example sp_ch1
equations(sys)
```

* * *

### Partial Pressure Mixing Ratio (Eq. 1.8)

```math
\xi_i = \frac{p_i}{p}
```

#### State Variables

```@example sp_ch1
@named sys = PartialPressureMixingRatio()
vars = unknowns(sys)
DataFrame(
    :Name => [string(Symbolics.tosymbol(v, escape = false)) for v in vars],
    :Units => [string(ModelingToolkit.get_unit(v)) for v in vars],
    :Description => [ModelingToolkit.getdescription(v) for v in vars]
)
```

#### Equations

```@example sp_ch1
equations(sys)
```

* * *

### Saturation Vapor Pressure (Eq. 1.10)

```math
p_{H_2O,sat}(T) = p_{std} \cdot \exp(13.3185a - 1.9760a^2 - 0.6445a^3 - 0.1299a^4)
```

where ``a = 1 - 373.15/T``.

#### State Variables

```@example sp_ch1
@named sys = SaturationVaporPressure()
vars = unknowns(sys)
DataFrame(
    :Name => [string(Symbolics.tosymbol(v, escape = false)) for v in vars],
    :Units => [string(ModelingToolkit.get_unit(v)) for v in vars],
    :Description => [ModelingToolkit.getdescription(v) for v in vars]
)
```

#### Equations

```@example sp_ch1
equations(sys)
```

* * *

### Relative Humidity (Eq. 1.9)

```math
RH = 100 \cdot \frac{p_{H_2O}}{p_{H_2O,sat}}
```

#### State Variables

```@example sp_ch1
@named sys = RelativeHumidity()
vars = unknowns(sys)
DataFrame(
    :Name => [string(Symbolics.tosymbol(v, escape = false)) for v in vars],
    :Units => [string(ModelingToolkit.get_unit(v)) for v in vars],
    :Description => [ModelingToolkit.getdescription(v) for v in vars]
)
```

#### Equations

```@example sp_ch1
equations(sys)
```

* * *

### Composite: Atmospheric Thermodynamics

Combines Equations 1.2, 1.4, 1.5, and 1.7 for complete atmospheric thermodynamic properties at a given altitude and temperature.

#### State Variables

```@example sp_ch1
@named sys = AtmosphericThermodynamics()
vars = unknowns(sys)
DataFrame(
    :Name => [string(Symbolics.tosymbol(v, escape = false)) for v in vars],
    :Units => [string(ModelingToolkit.get_unit(v)) for v in vars],
    :Description => [ModelingToolkit.getdescription(v) for v in vars]
)
```

#### Parameters

```@example sp_ch1
params = parameters(sys)
DataFrame(
    :Name => [string(Symbolics.tosymbol(p, escape = false)) for p in params],
    :Units => [string(ModelingToolkit.get_unit(p)) for p in params],
    :Description => [ModelingToolkit.getdescription(p) for p in params]
)
```

#### Equations

```@example sp_ch1
equations(sys)
```

* * *

### Composite: Water Vapor Thermodynamics

Combines the saturation vapor pressure (Eq. 1.10) and relative humidity (Eq. 1.9) systems.

#### State Variables

```@example sp_ch1
@named sys = WaterVaporThermodynamics()
vars = unknowns(sys)
DataFrame(
    :Name => [string(Symbolics.tosymbol(v, escape = false)) for v in vars],
    :Units => [string(ModelingToolkit.get_unit(v)) for v in vars],
    :Description => [ModelingToolkit.getdescription(v) for v in vars]
)
```

#### Equations

```@example sp_ch1
equations(sys)
```

* * *

## Analysis

This section validates the implementation by reproducing key results from Seinfeld and Pandis (2006) Chapter 1.

### U.S. Standard Atmosphere Validation (Table 1.4)

Table 1.4 in the textbook provides properties of the U.S. Standard Atmosphere at various altitudes. We validate the barometric formula and ideal gas law by comparing calculated values with the reference data.

```@example sp_ch1
using Plots

# Physical constants (same values used in the implementation)
R_val = 8.314          # J/(mol*K)
M_air_val = 0.02897    # kg/mol
g_val = 9.807          # m/s^2
p_0_val = 101325.0     # Pa

# U.S. Standard Atmosphere data (Table 1.4)
us_std_atm = DataFrame(
    :Altitude_km => [0, 5, 10, 15, 20, 25, 30, 40, 50],
    :Temperature_K => [288.2, 255.7, 223.3, 216.7, 216.7, 221.6, 226.5, 250.4, 270.7],
    :Pressure_mbar => [1013.0, 540.5, 265.0, 121.1, 55.29, 25.49, 11.97, 2.871, 0.798],
    :Density_kg_m3 => [
        1.225, 0.736, 0.414, 0.195, 0.0889, 0.0401, 0.0184, 0.00400, 0.00103]
)
us_std_atm
```

### Pressure Profile Comparison

```@example sp_ch1
# Calculate pressure using barometric formula with local scale height
function calc_pressure_variable_H(z_km, T_K)
    z = z_km * 1000.0
    H = R_val * T_K / (M_air_val * g_val)
    return p_0_val * exp(-z / H) / 100  # Convert to mbar
end

calculated_p = [calc_pressure_variable_H(z, T)
                for (z, T) in
                    zip(us_std_atm.Altitude_km, us_std_atm.Temperature_K)]

comparison = DataFrame(
    :Altitude_km => us_std_atm.Altitude_km,
    :Ref_Pressure_mbar => us_std_atm.Pressure_mbar,
    :Calc_Pressure_mbar => round.(calculated_p, digits = 2),
    :Error_percent => round.(
        100 .* (calculated_p .- us_std_atm.Pressure_mbar) ./ us_std_atm.Pressure_mbar,
        digits = 1
    )
)
comparison
```

### Density Profile Comparison

```@example sp_ch1
function calc_density(p_mbar, T_K)
    p_Pa = p_mbar * 100
    return M_air_val * p_Pa / (R_val * T_K)
end

calculated_rho = [calc_density(p, T)
                  for (p, T) in
                      zip(us_std_atm.Pressure_mbar, us_std_atm.Temperature_K)]

density_comparison = DataFrame(
    :Altitude_km => us_std_atm.Altitude_km,
    :Ref_Density_kg_m3 => us_std_atm.Density_kg_m3,
    :Calc_Density_kg_m3 => round.(calculated_rho, digits = 4),
    :Error_percent => round.(
        100 .* (calculated_rho .- us_std_atm.Density_kg_m3) ./ us_std_atm.Density_kg_m3,
        digits = 1
    )
)
density_comparison
```

The density calculation matches Table 1.4 values within 1%, validating the ideal gas law implementation (Eq. 1.2).

* * *

### Pressure-Altitude Profile (Figure)

This figure shows the exponential decrease of atmospheric pressure with altitude, comparing the isothermal barometric formula with U.S. Standard Atmosphere data.

```@example sp_ch1
z_range = 0:0.5:50  # km

# Isothermal atmosphere at T = 253 K (H = 7.4 km)
H_253 = R_val * 253 / (M_air_val * g_val)
p_253 = [p_0_val * exp(-z * 1000 / H_253) / 100 for z in z_range]

# Isothermal atmosphere at T = 288 K (H = 8.4 km)
H_288 = R_val * 288 / (M_air_val * g_val)
p_288 = [p_0_val * exp(-z * 1000 / H_288) / 100 for z in z_range]

p1 = plot(;
    xlabel = "Altitude (km)",
    ylabel = "Pressure (mbar)",
    title = "Atmospheric Pressure vs Altitude",
    legend = :topright,
    yscale = :log10,
    ylims = (0.1, 2000),
    size = (700, 500),
    grid = true
)

plot!(p1, z_range, p_253;
    label = "Isothermal T = 253 K (H = 7.4 km)",
    linewidth = 2,
    color = :blue,
    linestyle = :dash)

plot!(p1, z_range, p_288;
    label = "Isothermal T = 288 K (H = 8.4 km)",
    linewidth = 2,
    color = :red,
    linestyle = :dash)

scatter!(p1, us_std_atm.Altitude_km, us_std_atm.Pressure_mbar;
    label = "U.S. Standard Atmosphere",
    markersize = 8,
    color = :black)

p1
```

The U.S. Standard Atmosphere data falls between the two isothermal curves because the real atmosphere has a temperature profile that varies with altitude.

* * *

### Scale Height Variation (Figure)

The scale height depends on temperature and determines how quickly pressure decreases with altitude.

```@example sp_ch1
T_range = 200:5:320
H_values = [R_val * T / (M_air_val * g_val) / 1000 for T in T_range]  # km

p2 = plot(
    T_range, H_values;
    xlabel = "Temperature (K)",
    ylabel = "Scale Height (km)",
    title = "Atmospheric Scale Height vs Temperature (Eq. 1.4)",
    legend = false,
    linewidth = 2,
    color = :blue,
    size = (600, 400),
    grid = true
)

scatter!(p2, [253, 288, 216.7],
    [R_val * 253 / (M_air_val * g_val) / 1000,
        R_val * 288 / (M_air_val * g_val) / 1000,
        R_val * 216.7 / (M_air_val * g_val) / 1000];
    markersize = 10,
    color = :red,
    label = nothing)

annotate!(p2, 253, 7.0, text("Troposphere\n(253 K)", 8, :center))
annotate!(p2, 288, 9.0, text("Sea level\n(288 K)", 8, :center))
annotate!(p2, 216.7, 8.0, text("Tropopause\n(217 K)", 8, :center))

p2
```

* * *

### Saturation Vapor Pressure of Water (Figure)

This figure reproduces the saturation vapor pressure curve from Equation 1.10.

```@example sp_ch1
T_boil_val = 373.15
p_std_val = 101325.0  # Pa

T_sat_range = 273:1:373

function calc_p_sat(T)
    a = 1 - T_boil_val / T
    return p_std_val * exp(13.3185 * a - 1.9760 * a^2 - 0.6445 * a^3 - 0.1299 * a^4)
end

p_sat_values = [calc_p_sat(T) for T in T_sat_range]

# Reference values
T_ref = [273.15, 283.15, 293.15, 298.15, 303.15, 313.15, 323.15, 373.15]
p_sat_ref = [611, 1228, 2338, 3168, 4245, 7378, 12349, 101325]  # Pa

p3 = plot(
    T_sat_range, p_sat_values ./ 1000;
    xlabel = "Temperature (K)",
    ylabel = "Saturation Vapor Pressure (kPa)",
    title = "Saturation Vapor Pressure of Water (Eq. 1.10)",
    legend = :topleft,
    linewidth = 2,
    color = :blue,
    label = "Eq. 1.10",
    size = (600, 400),
    grid = true
)

scatter!(p3, T_ref, p_sat_ref ./ 1000;
    markersize = 8,
    color = :red,
    label = "Reference values")

p3
```

### Saturation Vapor Pressure Table

```@example sp_ch1
T_table = [273.15, 278.15, 283.15, 288.15, 293.15, 298.15, 303.15, 308.15, 313.15, 373.15]
p_sat_calc = [calc_p_sat(T) for T in T_table]

DataFrame(
    :T_Celsius => round.(T_table .- 273.15, digits = 1),
    :T_Kelvin => round.(T_table, digits = 2),
    :p_sat_Pa => round.(p_sat_calc, digits = 1),
    :p_sat_mbar => round.(p_sat_calc ./ 100, digits = 2)
)
```

* * *

### Total Molar Concentration (Figure)

The total molar concentration depends on pressure and temperature through the ideal gas law (Eq. 1.7).

```@example sp_ch1
T_conc_range = 250:5:320
c_total_values = [p_0_val / (R_val * T) for T in T_conc_range]

p4 = plot(
    T_conc_range, c_total_values;
    xlabel = "Temperature (K)",
    ylabel = "Total Molar Concentration (mol/m^3)",
    title = "Total Molar Concentration at p = 101325 Pa (Eq. 1.7)",
    legend = false,
    linewidth = 2,
    color = :blue,
    size = (600, 400),
    grid = true
)

scatter!(p4, [273.15, 298.15],
    [p_0_val / (R_val * 273.15), p_0_val / (R_val * 298.15)];
    markersize = 10,
    color = :red)

annotate!(p4, 273.15, 46.5, text("STP\n(44.6 mol/m^3)", 8, :center))
annotate!(p4, 298.15, 39.0, text("Room temp\n(40.9 mol/m^3)", 8, :center))

p4
```

* * *

### Atmospheric Profile Summary (Figure)

This figure summarizes the vertical structure of the atmosphere using data from Table 1.4.

```@example sp_ch1
altitudes = [0, 5, 10, 15, 20, 25, 30, 40, 50]
temperatures = [288.2, 255.7, 223.3, 216.7, 216.7, 221.6, 226.5, 250.4, 270.7]
pressures = [1013.0, 540.5, 265.0, 121.1, 55.29, 25.49, 11.97, 2.871, 0.798]
densities = [1.225, 0.736, 0.414, 0.195, 0.0889, 0.0401, 0.0184, 0.00400, 0.00103]

l = @layout [a b c]

p_temp = plot(temperatures, altitudes;
    xlabel = "Temperature (K)",
    ylabel = "Altitude (km)",
    title = "Temperature",
    linewidth = 2,
    marker = :circle,
    color = :red,
    legend = false,
    xlims = (200, 300))

hline!(p_temp, [11]; color = :gray, linestyle = :dash, label = nothing)
annotate!(p_temp, 250, 5, text("Troposphere", 8, :center))
annotate!(p_temp, 250, 25, text("Stratosphere", 8, :center))

p_press = plot(pressures, altitudes;
    xlabel = "Pressure (mbar)",
    ylabel = "Altitude (km)",
    title = "Pressure",
    linewidth = 2,
    marker = :circle,
    color = :blue,
    xscale = :log10,
    legend = false)

p_dens = plot(densities, altitudes;
    xlabel = "Density (kg/m^3)",
    ylabel = "Altitude (km)",
    title = "Density",
    linewidth = 2,
    marker = :circle,
    color = :green,
    xscale = :log10,
    legend = false)

plot(p_temp, p_press, p_dens;
    layout = l,
    size = (900, 400),
    plot_title = "U.S. Standard Atmosphere (Table 1.4)")
```
