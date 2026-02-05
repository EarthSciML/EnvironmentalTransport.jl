# Global Cycles: Sulfur and Carbon

## Overview

This module implements three global-scale atmospheric/Earth system models from Chapter 22 of Seinfeld and Pandis (2006). These models describe the cycling of sulfur and carbon through Earth's atmosphere and surface reservoirs, and provide a framework for understanding atmospheric residence times and the fate of trace species.

The implementation provides ModelingToolkit.jl components for:

  - **SulfurCycle**: Steady-state atmospheric sulfur cycle model (Equations 22.6-22.15) describing SO2 and sulfate residence times based on removal by dry deposition, wet deposition, and chemical conversion
  - **CarbonCycle**: Six-compartment global carbon cycle model (Table 22.1) with atmosphere-ocean-biosphere exchange, based on Schmitz (2002)
  - **FourCompartmentAtmosphere**: Four-box atmospheric transport model (Equations 22.26-22.41) for trace species with interhemispheric and troposphere-stratosphere exchange

**Reference**: Seinfeld, J.H. and Pandis, S.N. (2006). *Atmospheric Chemistry and Physics: From Air Pollution to Climate Change*, 2nd Edition, Chapter 22: Global Cycles: Sulfur and Carbon. John Wiley & Sons, Inc.

```@docs
SulfurCycle
CarbonCycle
FourCompartmentAtmosphere
```

## Implementation

```@example global_cycles
using EnvironmentalTransport
using DataFrames, ModelingToolkit, Symbolics, DynamicQuantities
nothing # hide
```

### Sulfur Cycle (Section 22.1, Equations 22.6-22.15)

The sulfur cycle model describes the residence times of atmospheric sulfur species (SO2 and SO4) based on removal processes. SO2 is removed by dry deposition, wet deposition, and chemical conversion to sulfate. Sulfate is removed by dry and wet deposition.

The key equations are:

  - **Eq. 22.8**: Overall SO2 residence time: ``1/\tau_{SO_2} = 1/\tau_{SO_2,d} + 1/\tau_{SO_2,w} + 1/\tau_{SO_2,c}``
  - **Eq. 22.9**: Overall SO4 residence time: ``1/\tau_{SO_4} = 1/\tau_{SO_4,d} + 1/\tau_{SO_4,w}``
  - **Eq. 22.7**: Fraction converted to sulfate: ``b = \tau_{SO_2}/\tau_{SO_2,c}``
  - **Eq. 22.6**: Mean residence time of a sulfur atom: ``\tau_S = \tau_{SO_2} + b \cdot \tau_{SO_4}``

Default parameter values are from Rodhe (1978):

| Parameter | Value  | Description                            |
|:--------- |:------ |:-------------------------------------- |
| τ\_SO2\_d | 60 hr  | SO2 dry deposition residence time      |
| τ\_SO2\_w | 100 hr | SO2 wet deposition residence time      |
| τ\_SO2\_c | 80 hr  | SO2 chemical conversion residence time |
| τ\_SO4\_d | 400 hr | SO4 dry deposition residence time      |
| τ\_SO4\_w | 80 hr  | SO4 wet deposition residence time      |

#### State Variables

```@example global_cycles
sys = SulfurCycle()
vars = unknowns(sys)
DataFrame(
    :Name => [string(Symbolics.tosymbol(v, escape = false)) for v in vars],
    :Units => [string(ModelingToolkit.get_unit(v)) for v in vars],
    :Description => [ModelingToolkit.getdescription(v) for v in vars]
)
```

#### Parameters

```@example global_cycles
params = parameters(sys)
DataFrame(
    :Name => [string(Symbolics.tosymbol(p, escape = false)) for p in params],
    :Units => [string(ModelingToolkit.get_unit(p)) for p in params],
    :Description => [ModelingToolkit.getdescription(p) for p in params]
)
```

#### Equations

```@example global_cycles
equations(sys)
```

* * *

### Carbon Cycle (Section 22.2, Table 22.1)

The carbon cycle model implements the six-compartment model from Table 22.1, based on Schmitz (2002). It tracks carbon exchange among seven reservoirs:

 1. Atmosphere (M1) - 612 Pg C preindustrial
 2. Warm ocean surface waters (M2) - 730 Pg C
 3. Cool ocean surface waters (M3) - 140 Pg C
 4. Deep ocean (M4) - 37,000 Pg C
 5. Terrestrial biota (M5) - 580 Pg C
 6. Soils and detritus (M6) - 1500 Pg C
 7. Fossil fuels (M7) - 5300 Pg C

**Transfer coefficients** from Table 22.1 (Schmitz, 2002):

| Coefficient | Value (yr⁻¹) | Description                 |
|:----------- |:------------ |:--------------------------- |
| k₁₂         | 0.0931       | Atmosphere → warm ocean     |
| k₁₃         | 0.0311       | Atmosphere → cool ocean     |
| k₂₃         | 0.0781       | Warm ocean → cool ocean     |
| k₂₄         | 0.0164       | Warm ocean → deep ocean     |
| k₃₄         | 0.714        | Cool ocean → deep ocean     |
| k₄₂         | 0.00189      | Deep ocean → warm ocean     |
| k₄₃         | 0.00114      | Deep ocean → cool ocean     |
| k₅₁         | 0.0862       | Biota → atmosphere          |
| k₅₆         | 0.0862       | Biota → soils/detritus      |
| k₆₁         | 0.0333       | Soils/detritus → atmosphere |

**Nonlinear parameters** from Table 22.1:

| Parameter | Value    | Description                            |
|:--------- |:-------- |:-------------------------------------- |
| β₂        | 9.4      | Warm ocean carbonate buffer exponent   |
| β₃        | 10.2     | Cool ocean carbonate buffer exponent   |
| γ         | 62 Pg C  | CO2 uptake threshold for biota         |
| Γ         | 198 Pg C | CO2 saturation parameter for biota     |
| a\_d      | 0.230    | Deforestation land-use change fraction |
| a\_r      | 1.0      | Reforestation land-use change fraction |

Key features:

  - Nonlinear ocean-atmosphere fluxes with carbonate buffer chemistry (Eq. 22.18): ``F_{21} = k_{21} M_2^{\beta_2}``
  - Saturating biotic CO2 uptake (Eq. 22.19): ``F_{15} = k_{15} G (M_1 - \gamma) / (M_1 + \Gamma)``
  - Land-use change scaling factor G (Eq. 22.21): ``dG/dt = -(a_d F_d - a_r F_r) / M_5(0)``
  - External forcing: fossil fuel emissions (Ff), deforestation (Fd), reforestation (Fr)

All mass quantities are in SI units (kg). Time is in seconds. The source material uses Pg C (1 Pg = 10^12 kg) and years (1 yr = 31557600 s).

#### State Variables

```@example global_cycles
sys_carbon = CarbonCycle()
vars = unknowns(sys_carbon)
DataFrame(
    :Name => [string(Symbolics.tosymbol(v, escape = false)) for v in vars],
    :Units => [string(ModelingToolkit.get_unit(v)) for v in vars],
    :Description => [ModelingToolkit.getdescription(v) for v in vars]
)
```

#### Parameters

```@example global_cycles
params = parameters(sys_carbon)
DataFrame(
    :Name => [string(Symbolics.tosymbol(p, escape = false)) for p in params],
    :Units => [string(ModelingToolkit.get_unit(p)) for p in params],
    :Description => [ModelingToolkit.getdescription(p) for p in params]
)
```

#### Equations

```@example global_cycles
equations(sys_carbon)
```

* * *

### Four-Compartment Atmosphere (Section 22.3, Equations 22.26-22.41)

The four-compartment model implements the steady-state atmospheric transport model from Section 22.3. The four compartments are:

  - NH troposphere
  - SH troposphere
  - NH stratosphere
  - SH stratosphere

Exchange processes include:

  - Interhemispheric exchange (troposphere and stratosphere)
  - Troposphere-stratosphere exchange
  - First-order removal (e.g., OH reaction, photolysis, deposition)

The model solves the steady-state mass balance equations (Eqs. 22.26-22.29) for each compartment:

  - **Eq. 22.26** (NH troposphere): ``0 = -(k_{T,NH \rightarrow SH} + k_{NH,T \rightarrow S} + k_{T,NH}) Q_{T,NH} + k_{T,SH \rightarrow NH} Q_{T,SH} + k_{NH,S \rightarrow T} Q_{S,NH} + P_{NH}``
  - **Eq. 22.27** (SH troposphere): ``0 = -(k_{T,SH \rightarrow NH} + k_{SH,T \rightarrow S} + k_{T,SH}) Q_{T,SH} + k_{T,NH \rightarrow SH} Q_{T,NH} + k_{SH,S \rightarrow T} Q_{S,SH} + P_{SH}``
  - **Eq. 22.28** (NH stratosphere): ``0 = -(k_{S,NH \rightarrow SH} + k_{NH,S \rightarrow T} + k_{S,NH}) Q_{S,NH} + k_{S,SH \rightarrow NH} Q_{S,SH} + k_{NH,T \rightarrow S} Q_{T,NH}``
  - **Eq. 22.29** (SH stratosphere): ``0 = -(k_{S,SH \rightarrow NH} + k_{SH,S \rightarrow T} + k_{S,SH}) Q_{S,SH} + k_{S,NH \rightarrow SH} Q_{S,NH} + k_{SH,T \rightarrow S} Q_{T,SH}``

Default exchange rates correspond to the CH3CCl3 example in Section 22.3.

#### State Variables

```@example global_cycles
sys_atm = FourCompartmentAtmosphere()
vars = unknowns(sys_atm)
DataFrame(
    :Name => [string(Symbolics.tosymbol(v, escape = false)) for v in vars],
    :Units => [string(ModelingToolkit.get_unit(v)) for v in vars],
    :Description => [ModelingToolkit.getdescription(v) for v in vars]
)
```

#### Parameters

```@example global_cycles
params = parameters(sys_atm)
DataFrame(
    :Name => [string(Symbolics.tosymbol(p, escape = false)) for p in params],
    :Units => [string(ModelingToolkit.get_unit(p)) for p in params],
    :Description => [ModelingToolkit.getdescription(p) for p in params]
)
```

#### Equations

```@example global_cycles
equations(sys_atm)
```

* * *

## Analysis

This section validates the implementation by reproducing key results from Seinfeld and Pandis (2006) Chapter 22.

### Sulfur Cycle Validation (Table 22.2, Section 22.1)

Table 22.2 in the textbook provides residence times for the atmospheric sulfur cycle based on Rodhe (1978). We validate the implementation by solving for steady-state values and comparing with the reference.

```@example global_cycles
using NonlinearSolve

sys = SulfurCycle()
sys_c = mtkcompile(sys)

# Provide initial guesses for unknowns (in seconds)
u0 = Dict(
    sys_c.τ_SO2 => 90000.0,
    sys_c.τ_SO4 => 240000.0,
    sys_c.b => 0.3,
    sys_c.τ_S => 165000.0,
    sys_c.c => 0.5,
    sys_c.τ_S_d => 432000.0,
    sys_c.τ_S_w => 324000.0
)

prob = NonlinearProblem(sys_c, u0)
sol = solve(prob)

# Convert from seconds to hours for comparison with textbook
s_to_hr = 1 / 3600.0

sulfur_results = DataFrame(
    :Quantity => ["τ_SO2", "τ_SO4", "b", "τ_S", "c"],
    :Calculated => [
        round(sol[sys_c.τ_SO2] * s_to_hr, digits = 1),
        round(sol[sys_c.τ_SO4] * s_to_hr, digits = 1),
        round(sol[sys_c.b], digits = 3),
        round(sol[sys_c.τ_S] * s_to_hr, digits = 1),
        round(sol[sys_c.c], digits = 3)
    ],
    :Reference => ["~25.5 hr", "~66.7 hr", "~0.319", "~46.8 hr", "~0.545"],
    :Description => [
        "Overall SO2 residence time",
        "Overall SO4 residence time",
        "Fraction converted to SO4",
        "Mean sulfur atom residence time",
        "Fraction of sulfur as SO2"
    ]
)
sulfur_results
```

The calculated values match the expected residence times based on Rodhe (1978) parameters.

* * *

### Carbon Cycle Response to Fossil Fuel Emissions (Figure 22.7)

Figure 22.7 in the textbook shows the response of atmospheric CO2 to fossil fuel emissions. We reproduce this by simulating the carbon cycle with constant emissions.

```@example global_cycles
using OrdinaryDiffEqDefault
using Plots

sys_carbon = CarbonCycle()
sys_c = mtkcompile(sys_carbon)

# Unit conversions
yr_to_s = 31557600.0

# Simulate 200 years with 5 Pg C/yr emissions
Ff_value = 5.0e12 / yr_to_s  # kg/s

tspan = (0.0, 200.0 * yr_to_s)
prob = ODEProblem(sys_c, merge(Dict(), Dict(sys_c.Ff => Ff_value)), tspan)
sol = solve(prob)

# Extract time in years and atmospheric carbon in Pg C
t_years = sol.t ./ yr_to_s
M1_PgC = [sol[sys_c.M1][i] / 1e12 for i in 1:length(sol.t)]
M2_PgC = [sol[sys_c.M2][i] / 1e12 for i in 1:length(sol.t)]
M5_PgC = [sol[sys_c.M5][i] / 1e12 for i in 1:length(sol.t)]

p1 = plot(;
    xlabel = "Time (years)",
    ylabel = "Carbon (Pg C)",
    title = "Carbon Cycle Response to 5 Pg C/yr Fossil Fuel Emissions",
    legend = :topleft,
    size = (700, 500),
    grid = true
)

plot!(p1, t_years, M1_PgC;
    label = "M1 (Atmosphere)",
    linewidth = 2,
    color = :red)

plot!(p1, t_years, M2_PgC;
    label = "M2 (Warm Ocean)",
    linewidth = 2,
    color = :blue)

plot!(p1, t_years, M5_PgC;
    label = "M5 (Biota)",
    linewidth = 2,
    color = :green)

p1
```

The atmospheric carbon (M1) increases from 612 Pg C towards a new equilibrium, while the ocean and biota compartments also absorb additional CO2.

* * *

### Carbon Mass Conservation

The carbon cycle model conserves total carbon mass. We verify this by tracking the sum of all compartments during the simulation.

```@example global_cycles
# Calculate total carbon at each timestep
total_carbon = zeros(length(sol.t))
for i in 1:length(sol.t)
    total_carbon[i] = (sol[sys_c.M1][i] + sol[sys_c.M2][i] + sol[sys_c.M3][i] +
                       sol[sys_c.M4][i] + sol[sys_c.M5][i] + sol[sys_c.M6][i] +
                       sol[sys_c.M7][i]) / 1e12
end

p2 = plot(;
    xlabel = "Time (years)",
    ylabel = "Total Carbon (Pg C)",
    title = "Total Carbon Mass Conservation",
    legend = false,
    size = (700, 400),
    grid = true
)

plot!(p2, t_years, total_carbon;
    linewidth = 2,
    color = :black)

# Add reference line at initial total
hline!(p2, [total_carbon[1]];
    linestyle = :dash,
    color = :gray,
    label = nothing)

p2
```

The total carbon remains constant at approximately 45,862 Pg C throughout the simulation, confirming mass conservation.

* * *

### Four-Compartment Atmosphere: CH3CCl3 Lifetime (Section 22.3)

Section 22.3 discusses the atmospheric lifetime of CH3CCl3 (methyl chloroform) as an example application of the four-compartment model. The expected atmospheric lifetime is approximately 4.8-5.0 years based on IPCC (2001) estimates.

```@example global_cycles
sys_atm = FourCompartmentAtmosphere()
sys_c = mtkcompile(sys_atm)

# Unit conversions
yr_to_s = 31557600.0
g_to_kg = 1e-3

# Emission rates from Prinn et al. (1992)
P_NH_val = 5.647e11 * g_to_kg / yr_to_s  # kg/s
P_SH_val = 2.23e10 * g_to_kg / yr_to_s   # kg/s

# Calculate OH reaction rate at tropospheric average temperature (277 K)
T_trop = 277.0
k_OH_trop = 1.6e-12 * exp(-1520.0 / T_trop)  # cm^3 molecule^-1 s^-1
OH_conc_trop = 8.7e5  # molecules/cm^3
k_OH = k_OH_trop * OH_conc_trop  # s^-1

# Surface deposition rate
k_dep = 0.012 / yr_to_s  # s^-1

# Total tropospheric removal rate
k_T_removal = k_OH + k_dep

# Stratospheric removal
T_stratosphere = 216.7
k_OH_stratosphere = 1.6e-12 * exp(-1520.0 / T_stratosphere)
OH_conc_stratosphere = 6.48e6  # molecules/cm^3
k_S_removal = k_OH_stratosphere * OH_conc_stratosphere

# Set up problem
u0 = Dict(
    sys_c.Q_T_NH => 1e8,
    sys_c.Q_T_SH => 1e8,
    sys_c.Q_S_NH => 1e6,
    sys_c.Q_S_SH => 1e6,
    sys_c.Q_total => 2e8,
    sys_c.τ_atm => 5.0 * yr_to_s
)

p = Dict(
    sys_c.P_NH => P_NH_val,
    sys_c.P_SH => P_SH_val,
    sys_c.k_T_NH => k_T_removal,
    sys_c.k_T_SH => k_T_removal,
    sys_c.k_S_NH => k_S_removal,
    sys_c.k_S_SH => k_S_removal
)

prob = NonlinearProblem(sys_c, u0, p)
sol = solve(prob)

# Results
τ_atm_years = sol[sys_c.τ_atm] / yr_to_s
Q_T_NH_kg = sol[sys_c.Q_T_NH]
Q_T_SH_kg = sol[sys_c.Q_T_SH]
Q_S_NH_kg = sol[sys_c.Q_S_NH]
Q_S_SH_kg = sol[sys_c.Q_S_SH]

ch3ccl3_results = DataFrame(
    :Compartment => ["NH Troposphere", "SH Troposphere", "NH Stratosphere",
        "SH Stratosphere", "Atmospheric Lifetime"],
    :Value => [
        string(round(Q_T_NH_kg / 1e9, digits = 2), " Tg"),
        string(round(Q_T_SH_kg / 1e9, digits = 2), " Tg"),
        string(round(Q_S_NH_kg / 1e9, digits = 2), " Tg"),
        string(round(Q_S_SH_kg / 1e9, digits = 2), " Tg"),
        string(round(τ_atm_years, digits = 2), " years")
    ],
    :Description => [
        "Steady-state burden in NH troposphere",
        "Steady-state burden in SH troposphere",
        "Steady-state burden in NH stratosphere",
        "Steady-state burden in SH stratosphere",
        "Overall atmospheric residence time (IPCC 2001: 4.8 yr)"
    ]
)
ch3ccl3_results
```

The calculated atmospheric lifetime of approximately 5.0 years is consistent with the IPCC (2001) estimate of 4.8 years, validating the four-compartment model implementation.

* * *

### Compartment Distribution (Figure 22.9 analog)

Figure 22.9 in the textbook shows the distribution of a trace species among the four atmospheric compartments. We visualize the CH3CCl3 steady-state distribution.

```@example global_cycles
# Create bar chart of compartment burdens
compartments = ["NH Trop", "SH Trop", "NH Strat", "SH Strat"]
burdens = [Q_T_NH_kg / 1e9, Q_T_SH_kg / 1e9, Q_S_NH_kg / 1e9, Q_S_SH_kg / 1e9]  # Tg

p3 = bar(compartments, burdens;
    xlabel = "Compartment",
    ylabel = "CH3CCl3 Burden (Tg)",
    title = "Steady-State CH3CCl3 Distribution",
    legend = false,
    color = [:red, :blue, :orange, :cyan],
    size = (600, 400),
    grid = true
)

p3
```

The majority of CH3CCl3 resides in the troposphere, with the NH troposphere containing the largest burden due to higher emissions in the Northern Hemisphere.
