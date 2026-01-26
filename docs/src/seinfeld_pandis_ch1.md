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

## Reference

> Seinfeld, J.H. and Pandis, S.N. (2006). *Atmospheric Chemistry and Physics: From Air Pollution to Climate Change*, 2nd Edition, Chapter 1: The Atmosphere. John Wiley & Sons, Inc.

## Package Contents

This module provides the following equation system implementations:

| Component | Equations | Description |
|:----------|:----------|:------------|
| [`IdealGasLaw`](@ref) | Eq. 1.2 | Air density from pressure and temperature |
| [`ScaleHeight`](@ref) | Eq. 1.4 | Atmospheric scale height |
| [`AtmosphericPressureProfile`](@ref) | Eq. 1.1, 1.3, 1.5 | Complete atmospheric pressure profile |
| [`BarometricFormula`](@ref) | Eq. 1.5 | Standalone barometric formula |
| [`TotalMolarConcentration`](@ref) | Eq. 1.7 | Total molar concentration of air |
| [`MixingRatio`](@ref) | Eq. 1.6 | Volume mixing ratio definition |
| [`PartialPressureMixingRatio`](@ref) | Eq. 1.8 | Mixing ratio from partial pressure |
| [`SaturationVaporPressure`](@ref) | Eq. 1.10 | Saturation vapor pressure of water |
| [`RelativeHumidity`](@ref) | Eq. 1.9 | Relative humidity calculation |
| [`AtmosphericThermodynamics`](@ref) | Eq. 1.2, 1.4, 1.5, 1.7 | Composite atmospheric system |
| [`WaterVaporThermodynamics`](@ref) | Eq. 1.9, 1.10 | Composite water vapor system |

## Physical Constants

The module uses the following physical constants from Appendix A:

| Constant | Symbol | Value | Units |
|:---------|:-------|:------|:------|
| Universal gas constant | R | 8.314 | J/(mol K) |
| Molecular weight of dry air | M_air | 0.02897 | kg/mol |
| Gravitational acceleration | g | 9.807 | m/s^2 |
| Standard sea level pressure | p_0 | 101325 | Pa |
| Standard temperature | T_0 | 273.15 | K |
| Boiling point of water | T_boil | 373.15 | K |

---

# Equation Systems

This section provides detailed documentation of each equation system implemented in the module, including state variables, parameters, and the governing equations.

## Ideal Gas Law (Eq. 1.2)

The ideal gas law relates air density to pressure and temperature:

```math
\rho = \frac{M_{air} \cdot p}{R \cdot T}
```

where:
- ``\rho`` is air density (kg/m^3)
- ``M_{air} = 0.02897`` kg/mol is the molecular weight of dry air
- ``p`` is atmospheric pressure (Pa)
- ``R = 8.314`` J/(mol K) is the universal gas constant
- ``T`` is temperature (K)

### State Variables

```@example ideal_gas
using DataFrames, ModelingToolkit, Symbolics, DynamicQuantities

include("../../src/seinfeld_pandis_ch1.jl")
using .SeinfeldPandisChapter1

@named sys = IdealGasLaw()
vars = unknowns(sys)
DataFrame(
    :Name => [string(Symbolics.tosymbol(v, escape = false)) for v in vars],
    :Units => [string(ModelingToolkit.get_unit(v)) for v in vars],
    :Description => [ModelingToolkit.getdescription(v) for v in vars]
)
```

### Equations

```@example ideal_gas
equations(sys)
```

---

## Scale Height (Eq. 1.4)

The scale height represents the altitude increase over which pressure decreases by a factor of e (~2.718):

```math
H = \frac{R \cdot T}{M_{air} \cdot g}
```

Typical values:
- At T = 253 K: H = 7.4 km
- At T = 288 K (sea level): H = 8.4 km

### State Variables

```@example scale_height
using DataFrames, ModelingToolkit, Symbolics, DynamicQuantities

include("../../src/seinfeld_pandis_ch1.jl")
using .SeinfeldPandisChapter1

@named sys = ScaleHeight()
vars = unknowns(sys)
DataFrame(
    :Name => [string(Symbolics.tosymbol(v, escape = false)) for v in vars],
    :Units => [string(ModelingToolkit.get_unit(v)) for v in vars],
    :Description => [ModelingToolkit.getdescription(v) for v in vars]
)
```

### Equations

```@example scale_height
equations(sys)
```

---

## Atmospheric Pressure Profile (Eq. 1.1, 1.3, 1.5)

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

### State Variables

```@example atm_profile
using DataFrames, ModelingToolkit, Symbolics, DynamicQuantities

include("../../src/seinfeld_pandis_ch1.jl")
using .SeinfeldPandisChapter1

@named sys = AtmosphericPressureProfile()
vars = unknowns(sys)
DataFrame(
    :Name => [string(Symbolics.tosymbol(v, escape = false)) for v in vars],
    :Units => [string(ModelingToolkit.get_unit(v)) for v in vars],
    :Description => [ModelingToolkit.getdescription(v) for v in vars]
)
```

### Parameters

```@example atm_profile
params = parameters(sys)
DataFrame(
    :Name => [string(Symbolics.tosymbol(p, escape = false)) for p in params],
    :Units => [string(ModelingToolkit.get_unit(p)) for p in params],
    :Description => [ModelingToolkit.getdescription(p) for p in params]
)
```

### Equations

```@example atm_profile
equations(sys)
```

---

## Total Molar Concentration (Eq. 1.7)

The total molar concentration of air can be calculated from pressure and temperature:

```math
c_{total} = \frac{N}{V} = \frac{p}{R \cdot T}
```

Standard values:
- At STP (T = 273.15 K, p = 101325 Pa): c_total = 44.6 mol/m^3
- At T = 298 K, p = 101325 Pa: c_total = 40.9 mol/m^3

### State Variables

```@example molar_conc
using DataFrames, ModelingToolkit, Symbolics, DynamicQuantities

include("../../src/seinfeld_pandis_ch1.jl")
using .SeinfeldPandisChapter1

@named sys = TotalMolarConcentration()
vars = unknowns(sys)
DataFrame(
    :Name => [string(Symbolics.tosymbol(v, escape = false)) for v in vars],
    :Units => [string(ModelingToolkit.get_unit(v)) for v in vars],
    :Description => [ModelingToolkit.getdescription(v) for v in vars]
)
```

### Equations

```@example molar_conc
equations(sys)
```

---

## Mixing Ratio (Eq. 1.6)

The volume (mole) mixing ratio of species i is the ratio of its molar concentration to the total molar concentration:

```math
\xi_i = \frac{c_i}{c_{total}}
```

The mixing ratio is dimensionless and typically expressed in ppm, ppb, or ppt.

### State Variables

```@example mixing_ratio
using DataFrames, ModelingToolkit, Symbolics, DynamicQuantities

include("../../src/seinfeld_pandis_ch1.jl")
using .SeinfeldPandisChapter1

@named sys = MixingRatio()
vars = unknowns(sys)
DataFrame(
    :Name => [string(Symbolics.tosymbol(v, escape = false)) for v in vars],
    :Units => [string(ModelingToolkit.get_unit(v)) for v in vars],
    :Description => [ModelingToolkit.getdescription(v) for v in vars]
)
```

### Equations

```@example mixing_ratio
equations(sys)
```

---

## Partial Pressure Mixing Ratio (Eq. 1.8)

The mixing ratio equals the ratio of partial pressure to total pressure:

```math
\xi_i = \frac{p_i}{p}
```

### State Variables

```@example partial_pressure
using DataFrames, ModelingToolkit, Symbolics, DynamicQuantities

include("../../src/seinfeld_pandis_ch1.jl")
using .SeinfeldPandisChapter1

@named sys = PartialPressureMixingRatio()
vars = unknowns(sys)
DataFrame(
    :Name => [string(Symbolics.tosymbol(v, escape = false)) for v in vars],
    :Units => [string(ModelingToolkit.get_unit(v)) for v in vars],
    :Description => [ModelingToolkit.getdescription(v) for v in vars]
)
```

### Equations

```@example partial_pressure
equations(sys)
```

---

## Saturation Vapor Pressure (Eq. 1.10)

The saturation vapor pressure of water as a function of temperature is given by the empirical formula:

```math
p_{H_2O,sat}(T) = p_{std} \cdot \exp(13.3185a - 1.9760a^2 - 0.6445a^3 - 0.1299a^4)
```

where:
```math
a = 1 - \frac{373.15}{T}
```

This formula is valid for liquid water (T > 273 K).

Reference values:
- At T = 273 K: p_sat = 611 Pa (6.1 mbar)
- At T = 298 K: p_sat = 3170 Pa (31.7 mbar)
- At T = 373 K: p_sat = 101325 Pa (1013.25 mbar, boiling point)

### State Variables

```@example sat_vapor
using DataFrames, ModelingToolkit, Symbolics, DynamicQuantities

include("../../src/seinfeld_pandis_ch1.jl")
using .SeinfeldPandisChapter1

@named sys = SaturationVaporPressure()
vars = unknowns(sys)
DataFrame(
    :Name => [string(Symbolics.tosymbol(v, escape = false)) for v in vars],
    :Units => [string(ModelingToolkit.get_unit(v)) for v in vars],
    :Description => [ModelingToolkit.getdescription(v) for v in vars]
)
```

### Equations

```@example sat_vapor
equations(sys)
```

---

## Relative Humidity (Eq. 1.9)

Relative humidity is the ratio (expressed as percentage) of the actual water vapor partial pressure to the saturation vapor pressure at the same temperature:

```math
RH = 100 \cdot \frac{p_{H_2O}}{p_{H_2O,sat}}
```

### State Variables

```@example rel_humidity
using DataFrames, ModelingToolkit, Symbolics, DynamicQuantities

include("../../src/seinfeld_pandis_ch1.jl")
using .SeinfeldPandisChapter1

@named sys = RelativeHumidity()
vars = unknowns(sys)
DataFrame(
    :Name => [string(Symbolics.tosymbol(v, escape = false)) for v in vars],
    :Units => [string(ModelingToolkit.get_unit(v)) for v in vars],
    :Description => [ModelingToolkit.getdescription(v) for v in vars]
)
```

### Equations

```@example rel_humidity
equations(sys)
```

---

## Composite: Atmospheric Thermodynamics

The `AtmosphericThermodynamics` component combines Equations 1.2, 1.4, 1.5, and 1.7 to provide a complete description of atmospheric thermodynamic properties at a given altitude and temperature.

### State Variables

```@example atm_thermo
using DataFrames, ModelingToolkit, Symbolics, DynamicQuantities

include("../../src/seinfeld_pandis_ch1.jl")
using .SeinfeldPandisChapter1

@named sys = AtmosphericThermodynamics()
vars = unknowns(sys)
DataFrame(
    :Name => [string(Symbolics.tosymbol(v, escape = false)) for v in vars],
    :Units => [string(ModelingToolkit.get_unit(v)) for v in vars],
    :Description => [ModelingToolkit.getdescription(v) for v in vars]
)
```

### Parameters

```@example atm_thermo
params = parameters(sys)
DataFrame(
    :Name => [string(Symbolics.tosymbol(p, escape = false)) for p in params],
    :Units => [string(ModelingToolkit.get_unit(p)) for p in params],
    :Description => [ModelingToolkit.getdescription(p) for p in params]
)
```

### Equations

```@example atm_thermo
equations(sys)
```

---

## Composite: Water Vapor Thermodynamics

The `WaterVaporThermodynamics` component combines the saturation vapor pressure (Eq. 1.10) and relative humidity (Eq. 1.9) systems to calculate relative humidity given temperature and water vapor partial pressure.

### State Variables

```@example water_thermo
using DataFrames, ModelingToolkit, Symbolics, DynamicQuantities

include("../../src/seinfeld_pandis_ch1.jl")
using .SeinfeldPandisChapter1

@named sys = WaterVaporThermodynamics()
vars = unknowns(sys)
DataFrame(
    :Name => [string(Symbolics.tosymbol(v, escape = false)) for v in vars],
    :Units => [string(ModelingToolkit.get_unit(v)) for v in vars],
    :Description => [ModelingToolkit.getdescription(v) for v in vars]
)
```

### Equations

```@example water_thermo
equations(sys)
```

---

# Analysis

This section validates the implementation by reproducing key results from Seinfeld and Pandis (2006) Chapter 1.

## U.S. Standard Atmosphere Validation (Table 1.4)

Table 1.4 in the textbook provides properties of the U.S. Standard Atmosphere at various altitudes. We validate the barometric formula and ideal gas law by comparing calculated values with the reference data.

Note that the U.S. Standard Atmosphere uses a lapse rate model (temperature decreases with altitude in the troposphere), while our implementation assumes an isothermal atmosphere for the barometric formula. Therefore, we expect some deviation from the reference values.

```@example validation
using DataFrames, Plots

# Physical constants
const R = 8.314          # J/(mol*K)
const M_air = 0.02897    # kg/mol
const g = 9.807          # m/s^2
const p_0 = 101325.0     # Pa

# U.S. Standard Atmosphere data (Table 1.4)
us_std_atm = DataFrame(
    :Altitude_km => [0, 5, 10, 15, 20, 25, 30, 40, 50],
    :Temperature_K => [288.2, 255.7, 223.3, 216.7, 216.7, 221.6, 226.5, 250.4, 270.7],
    :Pressure_mbar => [1013.0, 540.5, 265.0, 121.1, 55.29, 25.49, 11.97, 2.871, 0.798],
    :Density_kg_m3 => [1.225, 0.736, 0.414, 0.195, 0.0889, 0.0401, 0.0184, 0.00400, 0.00103]
)
us_std_atm
```

### Pressure Profile Comparison

```@example validation
# Calculate pressure using barometric formula with local scale height
function calc_pressure_variable_H(z_km, T_K)
    z = z_km * 1000.0  # Convert to meters
    H = R * T_K / (M_air * g)
    # Use average temperature for scale height calculation
    return p_0 * exp(-z / H) / 100  # Convert to mbar
end

# Calculate with variable scale height based on actual temperature profile
calculated_p = [calc_pressure_variable_H(z, T) for (z, T) in
               zip(us_std_atm.Altitude_km, us_std_atm.Temperature_K)]

# Add to dataframe for comparison
comparison = DataFrame(
    :Altitude_km => us_std_atm.Altitude_km,
    :Ref_Pressure_mbar => us_std_atm.Pressure_mbar,
    :Calc_Pressure_mbar => round.(calculated_p, digits=2),
    :Error_percent => round.(100 .* (calculated_p .- us_std_atm.Pressure_mbar) ./ us_std_atm.Pressure_mbar, digits=1)
)
comparison
```

### Density Profile Comparison

```@example validation
# Calculate density using ideal gas law
function calc_density(p_mbar, T_K)
    p_Pa = p_mbar * 100  # Convert to Pa
    return M_air * p_Pa / (R * T_K)
end

# Calculate density from reference pressure and temperature
calculated_rho = [calc_density(p, T) for (p, T) in
                 zip(us_std_atm.Pressure_mbar, us_std_atm.Temperature_K)]

density_comparison = DataFrame(
    :Altitude_km => us_std_atm.Altitude_km,
    :Ref_Density_kg_m3 => us_std_atm.Density_kg_m3,
    :Calc_Density_kg_m3 => round.(calculated_rho, digits=4),
    :Error_percent => round.(100 .* (calculated_rho .- us_std_atm.Density_kg_m3) ./ us_std_atm.Density_kg_m3, digits=1)
)
density_comparison
```

The density calculation matches Table 1.4 values within 1%, validating the ideal gas law implementation (Eq. 1.2).

---

## Pressure-Altitude Profile

This figure shows the exponential decrease of atmospheric pressure with altitude, comparing the isothermal barometric formula with U.S. Standard Atmosphere data.

```@example pressure_altitude
using Plots

# Physical constants
const R = 8.314
const M_air = 0.02897
const g = 9.807
const p_0 = 101325.0

# U.S. Standard Atmosphere data
altitudes_km = [0, 5, 10, 15, 20, 25, 30, 40, 50]
pressures_mbar = [1013.0, 540.5, 265.0, 121.1, 55.29, 25.49, 11.97, 2.871, 0.798]

# Generate smooth curves for different scale heights
z_range = 0:0.5:50  # km

# Isothermal atmosphere at T = 253 K (H = 7.4 km)
H_253 = R * 253 / (M_air * g)
p_253 = [p_0 * exp(-z * 1000 / H_253) / 100 for z in z_range]

# Isothermal atmosphere at T = 288 K (H = 8.4 km)
H_288 = R * 288 / (M_air * g)
p_288 = [p_0 * exp(-z * 1000 / H_288) / 100 for z in z_range]

# Create plot
p1 = plot(
    xlabel = "Altitude (km)",
    ylabel = "Pressure (mbar)",
    title = "Atmospheric Pressure vs Altitude",
    legend = :topright,
    yscale = :log10,
    ylims = (0.1, 2000),
    size = (700, 500),
    grid = true
)

# Plot model curves
plot!(p1, z_range, p_253,
    label = "Isothermal T = 253 K (H = 7.4 km)",
    linewidth = 2,
    color = :blue,
    linestyle = :dash)

plot!(p1, z_range, p_288,
    label = "Isothermal T = 288 K (H = 8.4 km)",
    linewidth = 2,
    color = :red,
    linestyle = :dash)

# Plot U.S. Standard Atmosphere data
scatter!(p1, altitudes_km, pressures_mbar,
    label = "U.S. Standard Atmosphere",
    markersize = 8,
    color = :black)

savefig(p1, "pressure_altitude.png")
p1
```

The U.S. Standard Atmosphere data falls between the two isothermal curves because the real atmosphere has a temperature profile that varies with altitude (approximately 288 K at sea level decreasing to about 217 K at the tropopause).

---

## Scale Height Variation

The scale height depends on temperature and determines how quickly pressure decreases with altitude.

```@example scale_height_plot
using Plots

# Physical constants
const R = 8.314
const M_air = 0.02897
const g = 9.807

# Temperature range
T_range = 200:5:320

# Calculate scale height
H_values = [R * T / (M_air * g) / 1000 for T in T_range]  # km

p2 = plot(
    T_range, H_values,
    xlabel = "Temperature (K)",
    ylabel = "Scale Height (km)",
    title = "Atmospheric Scale Height vs Temperature (Eq. 1.4)",
    legend = false,
    linewidth = 2,
    color = :blue,
    size = (600, 400),
    grid = true
)

# Mark typical atmospheric temperatures
scatter!(p2, [253, 288, 216.7], [R * 253 / (M_air * g) / 1000,
                                  R * 288 / (M_air * g) / 1000,
                                  R * 216.7 / (M_air * g) / 1000],
    markersize = 10,
    color = :red,
    label = nothing)

annotate!(p2, 253, 7.0, text("Troposphere\n(253 K)", 8, :center))
annotate!(p2, 288, 9.0, text("Sea level\n(288 K)", 8, :center))
annotate!(p2, 216.7, 8.0, text("Tropopause\n(217 K)", 8, :center))

savefig(p2, "scale_height.png")
p2
```

---

## Saturation Vapor Pressure of Water

This figure reproduces the saturation vapor pressure curve from Equation 1.10.

```@example sat_vapor_plot
using Plots

# Constants
const T_boil = 373.15
const p_std = 101325.0  # Pa

# Temperature range (liquid water)
T_range = 273:1:373

# Calculate saturation vapor pressure
function calc_p_sat(T)
    a = 1 - T_boil / T
    return p_std * exp(13.3185*a - 1.9760*a^2 - 0.6445*a^3 - 0.1299*a^4)
end

p_sat_values = [calc_p_sat(T) for T in T_range]

# Reference values from Table 1.4 and common data
T_ref = [273.15, 283.15, 293.15, 298.15, 303.15, 313.15, 323.15, 373.15]
p_sat_ref = [611, 1228, 2338, 3168, 4245, 7378, 12349, 101325]  # Pa

p3 = plot(
    T_range, p_sat_values ./ 1000,
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

scatter!(p3, T_ref, p_sat_ref ./ 1000,
    markersize = 8,
    color = :red,
    label = "Reference values")

# Add temperature scale in Celsius
T_celsius = [0, 25, 50, 75, 100]
T_kelvin = T_celsius .+ 273.15

savefig(p3, "saturation_vapor_pressure.png")
p3
```

### Saturation Vapor Pressure Table

```@example sat_vapor_table
using DataFrames

const T_boil = 373.15
const p_std = 101325.0

function calc_p_sat(T)
    a = 1 - T_boil / T
    return p_std * exp(13.3185*a - 1.9760*a^2 - 0.6445*a^3 - 0.1299*a^4)
end

T_values = [273.15, 278.15, 283.15, 288.15, 293.15, 298.15, 303.15, 308.15, 313.15, 373.15]
T_celsius = T_values .- 273.15
p_sat_calc = [calc_p_sat(T) for T in T_values]

DataFrame(
    :T_Celsius => round.(T_celsius, digits=1),
    :T_Kelvin => round.(T_values, digits=2),
    :p_sat_Pa => round.(p_sat_calc, digits=1),
    :p_sat_mbar => round.(p_sat_calc ./ 100, digits=2)
)
```

---

## Total Molar Concentration

The total molar concentration depends on pressure and temperature through the ideal gas law.

```@example molar_conc_plot
using Plots, DataFrames

const R = 8.314

# At standard pressure, varying temperature
p_std = 101325.0  # Pa
T_range = 250:5:320

c_total = [p_std / (R * T) for T in T_range]

p4 = plot(
    T_range, c_total,
    xlabel = "Temperature (K)",
    ylabel = "Total Molar Concentration (mol/m^3)",
    title = "Total Molar Concentration at p = 101325 Pa (Eq. 1.7)",
    legend = false,
    linewidth = 2,
    color = :blue,
    size = (600, 400),
    grid = true
)

# Mark STP and room temperature
scatter!(p4, [273.15, 298.15], [p_std / (R * 273.15), p_std / (R * 298.15)],
    markersize = 10,
    color = :red)

annotate!(p4, 273.15, 46.5, text("STP\n(44.6 mol/m^3)", 8, :center))
annotate!(p4, 298.15, 39.0, text("Room temp\n(40.9 mol/m^3)", 8, :center))

savefig(p4, "molar_concentration.png")
p4
```

---

## Atmospheric Profile Summary

This figure summarizes the vertical structure of the atmosphere using data from Table 1.4.

```@example atm_summary
using Plots

# U.S. Standard Atmosphere data
altitudes = [0, 5, 10, 15, 20, 25, 30, 40, 50]
temperatures = [288.2, 255.7, 223.3, 216.7, 216.7, 221.6, 226.5, 250.4, 270.7]
pressures = [1013.0, 540.5, 265.0, 121.1, 55.29, 25.49, 11.97, 2.871, 0.798]
densities = [1.225, 0.736, 0.414, 0.195, 0.0889, 0.0401, 0.0184, 0.00400, 0.00103]

# Create subplots
l = @layout [a b c]

p_temp = plot(temperatures, altitudes,
    xlabel = "Temperature (K)",
    ylabel = "Altitude (km)",
    title = "Temperature",
    linewidth = 2,
    marker = :circle,
    color = :red,
    legend = false,
    xlims = (200, 300))

# Add atmospheric layer annotations
hline!(p_temp, [11], color = :gray, linestyle = :dash, label = nothing)
annotate!(p_temp, 250, 5, text("Troposphere", 8, :center))
annotate!(p_temp, 250, 25, text("Stratosphere", 8, :center))

p_press = plot(pressures, altitudes,
    xlabel = "Pressure (mbar)",
    ylabel = "Altitude (km)",
    title = "Pressure",
    linewidth = 2,
    marker = :circle,
    color = :blue,
    xscale = :log10,
    legend = false)

p_dens = plot(densities, altitudes,
    xlabel = "Density (kg/m^3)",
    ylabel = "Altitude (km)",
    title = "Density",
    linewidth = 2,
    marker = :circle,
    color = :green,
    xscale = :log10,
    legend = false)

p_summary = plot(p_temp, p_press, p_dens,
    layout = l,
    size = (900, 400),
    plot_title = "U.S. Standard Atmosphere (Table 1.4)")

savefig(p_summary, "atmosphere_summary.png")
p_summary
```

---

# API Reference

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
