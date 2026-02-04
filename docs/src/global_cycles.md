# Global Cycles: Sulfur and Carbon

## Overview

This module implements three global-scale atmospheric/Earth system models from Chapter 22 of Seinfeld and Pandis (2006):

 1. **SulfurCycle**: Steady-state atmospheric sulfur cycle model describing SO2 and sulfate residence times
 2. **CarbonCycle**: Six-compartment global carbon cycle model with atmosphere-ocean-biosphere exchange
 3. **FourCompartmentAtmosphere**: Four-box atmospheric transport model for trace species with interhemispheric and troposphere-stratosphere exchange

**Reference**: Seinfeld, J. H. and Pandis, S. N. (2006), *Atmospheric Chemistry and Physics: From Air Pollution to Climate Change*, 2nd Ed., John Wiley & Sons, Chapter 22.

```@docs
SulfurCycle
CarbonCycle
FourCompartmentAtmosphere
```

## Implementation Details

### SulfurCycle

The sulfur cycle model implements Equations 22.6-22.15 from Section 22.1. It describes the residence times of atmospheric sulfur species (SO2 and SO4) based on removal processes:

  - **Dry deposition**: Direct surface uptake
  - **Wet deposition**: Precipitation scavenging
  - **Chemical conversion**: SO2 to SO4 oxidation

The model calculates:

  - Overall SO2 and SO4 residence times
  - Fraction of sulfur converted to SO4 before removal (b)
  - Mean residence time of a sulfur atom (τ_S)
  - Fraction of total sulfur as SO2 (c)

Default parameter values are from Rodhe (1978).

### CarbonCycle

The carbon cycle model implements the six-compartment model from Table 22.1, based on Schmitz (2002). It tracks carbon exchange among:

 1. Atmosphere (M1) - 612 Pg C preindustrial
 2. Warm ocean surface waters (M2) - 730 Pg C
 3. Cool ocean surface waters (M3) - 140 Pg C
 4. Deep ocean (M4) - 37,000 Pg C
 5. Terrestrial biota (M5) - 580 Pg C
 6. Soils and detritus (M6) - 1500 Pg C
 7. Fossil fuels (M7) - 5300 Pg C

Key features:

  - Nonlinear ocean-atmosphere fluxes with carbonate buffer chemistry (Eq. 22.18)
  - Saturating biotic CO2 uptake (Eq. 22.19)
  - Land-use change scaling factor G (Eq. 22.21)
  - External forcing: fossil fuel emissions (Ff), deforestation (Fd), reforestation (Fr)

The model uses dimensionless quantities with time in years and mass in Pg C.

### FourCompartmentAtmosphere

The four-compartment model implements the steady-state atmospheric transport model from Section 22.3 (Equations 22.26-22.41). The four compartments are:

  - NH troposphere
  - SH troposphere
  - NH stratosphere
  - SH stratosphere

Exchange processes include:

  - Interhemispheric exchange (troposphere and stratosphere)
  - Troposphere-stratosphere exchange
  - First-order removal (e.g., OH reaction, photolysis, deposition)

Default exchange rates correspond to the CH3CCl3 example in the text.

## Example Usage

### Sulfur Cycle

```julia
using EnvironmentalTransport
using ModelingToolkit
using NonlinearSolve

sys = SulfurCycle()
sys_c = mtkcompile(sys)

# Solve for steady-state residence times
u0 = Dict(
    sys_c.τ_SO2 => 90000.0,   # initial guess in seconds
    sys_c.τ_SO4 => 240000.0,
    sys_c.b => 0.3,
    sys_c.τ_S => 165000.0,
    sys_c.c => 0.5,
    sys_c.τ_S_d => 432000.0,
    sys_c.τ_S_w => 324000.0
)

prob = NonlinearProblem(sys_c, u0)
sol = solve(prob)

# Convert to hours
τ_SO2_hr = sol[sys_c.τ_SO2] / 3600  # ≈ 25.5 hours
```

### Carbon Cycle

```julia
using EnvironmentalTransport
using ModelingToolkit
using OrdinaryDiffEq

sys = CarbonCycle()
sys_c = mtkcompile(sys)

# Simulate 100 years with fossil fuel emissions of 5 Pg C/yr
tspan = (0.0, 100.0)
prob = ODEProblem(sys_c, merge(Dict(), Dict(sys_c.Ff => 5.0)), tspan)
sol = solve(prob, Tsit5())

# Atmospheric CO2 increases
M1_final = sol[sys_c.M1][end]  # Pg C at year 100
```

## Validation

The implementation has been validated against:

  - Rodhe (1978) residence time values for the sulfur cycle
  - Preindustrial steady-state conditions for the carbon cycle
  - Conservation of total carbon mass during simulations
  - CH3CCl3 atmospheric lifetime (~5 years) for the four-compartment model
