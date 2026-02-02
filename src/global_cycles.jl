export SulfurCycle, CarbonCycle, FourCompartmentAtmosphere

"""
    SulfurCycle(; name=:SulfurCycle)

Return a `ModelingToolkit.System` implementing the steady-state atmospheric sulfur cycle
from Chapter 22.1 of Seinfeld and Pandis (2006), "Atmospheric Chemistry and Physics",
2nd Edition.

The model describes the exchange of sulfur between SO2 and sulfate (SO4^2-) reservoirs
in the atmosphere. SO2 is emitted from natural and anthropogenic sources, removed by
dry deposition, wet deposition, and chemical conversion to sulfate. Sulfate is removed
by dry and wet deposition.

Equations 22.6-22.15 are implemented as algebraic relations. The system uses
first-order rate constants for all removal processes.

Default residence time values are from Rodhe (1978).

**Reference**: Seinfeld, J. H. and Pandis, S. N. (2006), *Atmospheric Chemistry and Physics:
From Air Pollution to Climate Change*, 2nd Ed., John Wiley & Sons, Ch. 22, pp. 1003-1007.
"""
@component function SulfurCycle(; name=:SulfurCycle)
    # Default residence times from Rodhe (1978), converted from hours to seconds
    # Original values in hours: τ_SO2_d=60, τ_SO2_w=100, τ_SO2_c=80, τ_SO4_d=400, τ_SO4_w=80
    @parameters begin
        τ_SO2_d = 216000.0, [description = "SO2 dry deposition residence time (60 hr)", unit = u"s"]
        τ_SO2_w = 360000.0, [description = "SO2 wet deposition residence time (100 hr)", unit = u"s"]
        τ_SO2_c = 288000.0, [description = "SO2 chemical conversion residence time (80 hr)", unit = u"s"]
        τ_SO4_d = 1440000.0, [description = "SO4 dry deposition residence time (400 hr)", unit = u"s"]
        τ_SO4_w = 288000.0, [description = "SO4 wet deposition residence time (80 hr)", unit = u"s"]
    end

    @variables begin
        τ_SO2(t), [description = "Overall SO2 residence time", unit = u"s"]
        τ_SO4(t), [description = "Overall SO4 residence time", unit = u"s"]
        b(t), [description = "Fraction of S converted to SO4 before removal (dimensionless)", unit = u"1"]
        τ_S(t), [description = "Mean residence time of a sulfur atom", unit = u"s"]
        c(t), [description = "Fraction of total sulfur that is SO2 (dimensionless)", unit = u"1"]
        τ_S_d(t), [description = "Sulfur dry deposition residence time", unit = u"s"]
        τ_S_w(t), [description = "Sulfur wet deposition residence time", unit = u"s"]
    end

    eqs = [
        # Eq. 22.8 — SO2 residence time from individual processes
        1 / τ_SO2 ~ 1 / τ_SO2_d + 1 / τ_SO2_w + 1 / τ_SO2_c,

        # Eq. 22.9 — SO4 residence time from individual processes
        1 / τ_SO4 ~ 1 / τ_SO4_d + 1 / τ_SO4_w,

        # Eq. 22.7 — Fraction of S converted to SO4 (b = τ_SO2 / τ_SO2_c at steady state)
        b ~ τ_SO2 / τ_SO2_c,

        # Eq. 22.6 — Sulfur atom residence time
        τ_S ~ τ_SO2 + b * τ_SO4,

        # Eq. 22.15 — Fraction of total sulfur as SO2
        # c = Q_SO2 / (Q_SO2 + Q_SO4) = 1 / (1 + Q_SO4/Q_SO2)
        # At steady state: Q_SO4/Q_SO2 = b * τ_SO4 / τ_SO2
        c ~ 1 / (1 + b * τ_SO4 / τ_SO2),

        # Eq. 22.14 — Sulfur dry deposition residence time
        1 / τ_S_d ~ c / τ_SO2_d + (1 - c) / τ_SO4_d,

        # Eq. 22.12 — Sulfur wet deposition residence time
        1 / τ_S_w ~ c / τ_SO2_w + (1 - c) / τ_SO4_w,
    ]

    return System(eqs, t; name)
end

"""
    CarbonCycle(; name=:CarbonCycle)

Return a `ModelingToolkit.System` implementing the six-compartment model of the
global carbon cycle from Table 22.1 of Seinfeld and Pandis (2006), based on
Schmitz (2002).

The model tracks carbon exchange among seven reservoirs:
1. Atmosphere (M1)
2. Warm ocean surface waters (M2)
3. Cool ocean surface waters (M3)
4. Deep ocean waters (M4)
5. Terrestrial biota (M5)
6. Soils and detritus (M6)
7. Fossil fuels (M7)

Plus a scaling factor G(t) for permanent land-use change effects on biotic uptake.

External forcing functions Ff(t), Fd(t), and Fr(t) represent fossil fuel emissions,
deforestation, and reforestation fluxes respectively.

All mass quantities are in kg (SI units). Time is in seconds (SI units).
The source material uses Pg C (1 Pg = 10^12 kg) and years (1 yr = 31557600 s).
Conversions are applied to maintain SI unit consistency.

Default parameter values and initial conditions correspond to the preindustrial
(~1850) steady state from Schmitz (2002) as presented in Figure 22.6 and Table 22.1.

**Reference**: Seinfeld, J. H. and Pandis, S. N. (2006), *Atmospheric Chemistry and Physics:
From Air Pollution to Climate Change*, 2nd Ed., John Wiley & Sons, Ch. 22, pp. 1009-1015.
Schmitz, R. A. (2002), The Earth's carbon cycle, *Chem. Eng. Educ.*, 296.
"""
@component function CarbonCycle(; name=:CarbonCycle)
    # Unit conversion constants
    # 1 Pg = 10^12 kg = 10^15 g
    # 1 year = 31557600 s (Julian year)
    @constants begin
        Pg_to_kg = 1e12, [description = "Conversion from Pg to kg", unit = u"kg"]
        yr_to_s = 31557600.0, [description = "Conversion from year to seconds", unit = u"s"]
        one_kg = 1.0, [description = "Unit mass for non-dimensionalization", unit = u"kg"]

        # Table 22.1 — First-order exchange coefficients (converted from yr^-1 to s^-1)
        k12 = 0.0931 / 31557600.0, [description = "Atmosphere to warm ocean transfer coefficient", unit = u"s^-1"]
        k13 = 0.0311 / 31557600.0, [description = "Atmosphere to cool ocean transfer coefficient", unit = u"s^-1"]
        k23 = 0.0781 / 31557600.0, [description = "Warm ocean to cool ocean transfer coefficient", unit = u"s^-1"]
        k24 = 0.0164 / 31557600.0, [description = "Warm ocean to deep ocean transfer coefficient", unit = u"s^-1"]
        k34 = 0.714 / 31557600.0, [description = "Cool ocean to deep ocean transfer coefficient", unit = u"s^-1"]
        k42 = 0.00189 / 31557600.0, [description = "Deep ocean to warm ocean transfer coefficient", unit = u"s^-1"]
        k43 = 0.00114 / 31557600.0, [description = "Deep ocean to cool ocean transfer coefficient", unit = u"s^-1"]
        k51 = 0.0862 / 31557600.0, [description = "Biota to atmosphere transfer coefficient", unit = u"s^-1"]
        k56 = 0.0862 / 31557600.0, [description = "Biota to soils/detritus transfer coefficient", unit = u"s^-1"]
        k61 = 0.0333 / 31557600.0, [description = "Soils/detritus to atmosphere transfer coefficient", unit = u"s^-1"]

        # Table 22.1 — Nonlinear ocean parameters (dimensionless)
        β2 = 9.4, [description = "Warm ocean carbonate buffer exponent (dimensionless)", unit = u"1"]
        β3 = 10.2, [description = "Cool ocean carbonate buffer exponent (dimensionless)", unit = u"1"]

        # Table 22.1 — Photosynthetic uptake parameters (converted from Pg C to kg)
        γ_c = 62.0e12, [description = "CO2 uptake threshold for biota", unit = u"kg"]
        Γ_c = 198.0e12, [description = "CO2 saturation parameter for biota", unit = u"kg"]

        # Table 22.1 — Land use change parameters (dimensionless)
        a_d = 0.230, [description = "Fraction of deforested area unavailable for regrowth (dimensionless)", unit = u"1"]
        a_r = 1.0, [description = "Fraction of reforested area increasing biota (dimensionless)", unit = u"1"]

        # Derived constants from preindustrial steady state (Table 22.1)
        # F15 = k15 * G * (M1 - γ) / (M1 + Γ)  (Eq. 22.19)
        # At preindustrial: F15_pre = 100 Pg/yr, M1 = 612 Pg, γ = 62 Pg, Γ = 198 Pg
        # k15 = F15_pre * (M1 + Γ) / (M1 - γ) = 100 * (612+198)/(612-62) = 100 * 810/550 ≈ 147.27 Pg/yr
        # Converted to kg/s: 147.27e12 / 31557600 ≈ 4.666e6 kg/s
        k15 = 147.27e12 / 31557600.0, [description = "Atmosphere to biota base uptake rate", unit = u"kg/s"]

        # Preindustrial flux values for nonlinear ocean terms (converted from Pg C yr^-1 to kg s^-1)
        # Used as reference: F21 = F21_pre * (M2/M2_pre)^β2
        F21_pre = 58.0e12 / 31557600.0, [description = "Preindustrial warm ocean to atmosphere flux", unit = u"kg/s"]
        F31_pre = 18.0e12 / 31557600.0, [description = "Preindustrial cool ocean to atmosphere flux", unit = u"kg/s"]

        # Preindustrial reservoir masses for normalization (converted from Pg C to kg)
        M2_pre = 730.0e12, [description = "Preindustrial warm ocean surface carbon", unit = u"kg"]
        M3_pre = 140.0e12, [description = "Preindustrial cool ocean surface carbon", unit = u"kg"]

        # Preindustrial M5(0) for G equation (converted from Pg C to kg)
        M5_0 = 580.0e12, [description = "Preindustrial terrestrial biota carbon", unit = u"kg"]
    end

    @parameters begin
        Ff = 0.0, [description = "Fossil fuel emissions", unit = u"kg/s"]
        Fd = 0.0, [description = "Deforestation flux", unit = u"kg/s"]
        Fr = 0.0, [description = "Reforestation flux", unit = u"kg/s"]
    end

    @variables begin
        M1(t) = 612.0e12, [description = "Carbon in atmosphere", unit = u"kg"]
        M2(t) = 730.0e12, [description = "Carbon in warm ocean surface waters", unit = u"kg"]
        M3(t) = 140.0e12, [description = "Carbon in cool ocean surface waters", unit = u"kg"]
        M4(t) = 37000.0e12, [description = "Carbon in deep ocean waters", unit = u"kg"]
        M5(t) = 580.0e12, [description = "Carbon in terrestrial biota", unit = u"kg"]
        M6(t) = 1500.0e12, [description = "Carbon in soils and detritus", unit = u"kg"]
        M7(t) = 5300.0e12, [description = "Carbon in fossil fuels", unit = u"kg"]
        G(t) = 1.0, [description = "Deforestation/reforestation scaling factor (dimensionless)", unit = u"1"]
        F15_flux(t), [description = "Atmosphere to biota flux", unit = u"kg/s"]
        F21_flux(t), [description = "Warm ocean to atmosphere flux", unit = u"kg/s"]
        F31_flux(t), [description = "Cool ocean to atmosphere flux", unit = u"kg/s"]
    end

    eqs = [
        # Eq. 22.19 — Photosynthetic uptake with saturation and land-use scaling
        # F15 = k15 * G * (M1 - γ) / (M1 + Γ) where k15 has units of kg/s
        F15_flux ~ k15 * G * max(0.0, (M1 - γ_c) / (M1 + Γ_c)),

        # Eq. 22.18 — Nonlinear ocean-to-atmosphere fluxes
        # F21 = k21 * M2^β2, with k21 = F21_pre / M2_pre^β2
        # Non-dimensionalize for non-integer exponent: (M2/M2_pre)^β2
        F21_flux ~ F21_pre * (M2 / M2_pre)^β2,

        # F31 = k31 * M3^β3, with k31 = F31_pre / M3_pre^β3
        F31_flux ~ F31_pre * (M3 / M3_pre)^β3,

        # Table 22.1, Eq. 1 — Atmosphere
        D(M1) ~ -(k12 + k13) * M1 - F15_flux + F21_flux + F31_flux + k51 * M5 + k61 * M6 + Ff + Fd - Fr,

        # Table 22.1, Eq. 2 — Warm ocean surface waters
        D(M2) ~ k12 * M1 - (k23 + k24) * M2 - F21_flux + k42 * M4,

        # Table 22.1, Eq. 3 — Cool ocean surface waters
        D(M3) ~ k13 * M1 + k23 * M2 - k34 * M3 - F31_flux + k43 * M4,

        # Table 22.1, Eq. 4 — Deep ocean waters
        D(M4) ~ k24 * M2 + k34 * M3 - (k42 + k43) * M4,

        # Table 22.1, Eq. 5 — Terrestrial biota
        D(M5) ~ F15_flux - (k51 + k56) * M5 - Fd + Fr,

        # Table 22.1, Eq. 6 — Soils and detritus
        D(M6) ~ k56 * M5 - k61 * M6,

        # Table 22.1, Eq. 7 — Fossil fuels
        D(M7) ~ -Ff,

        # Eq. 22.21 — Land-use change scaling factor
        D(G) ~ -(a_d * Fd - a_r * Fr) / M5_0,
    ]

    return System(eqs, t; name)
end

"""
    FourCompartmentAtmosphere(; name=:FourCompartmentAtmosphere)

Return a `ModelingToolkit.System` implementing the four-compartment steady-state
atmospheric model from Section 22.3 of Seinfeld and Pandis (2006).

The model divides the atmosphere into four reservoirs: NH troposphere, SH troposphere,
NH stratosphere, and SH stratosphere. A substance emitted into the troposphere is
exchanged between compartments and removed by first-order processes (e.g., OH reaction
in the troposphere, photolysis in the stratosphere, surface deposition).

The steady-state analytical solution (Eqs. 22.38-22.39, 22.34-22.35) gives the
substance quantity in each reservoir as a function of source rates and all transport/removal
parameters.

All quantities are in SI units (kg for mass, s for time).
The source material uses years for time and grams for mass.
Conversions are applied to maintain SI unit consistency.

Default parameter values correspond to the CH3CCl3 example in Section 22.3.

**Reference**: Seinfeld, J. H. and Pandis, S. N. (2006), *Atmospheric Chemistry and Physics:
From Air Pollution to Climate Change*, 2nd Ed., John Wiley & Sons, Ch. 22, pp. 1018-1022.
"""
@component function FourCompartmentAtmosphere(; name=:FourCompartmentAtmosphere)
    # Unit conversion: 1 year = 31557600 s (Julian year)
    @constants begin
        yr_to_s = 31557600.0, [description = "Conversion from year to seconds", unit = u"s"]
    end

    @parameters begin
        # Interhemispheric exchange rates (converted from yr^-1 to s^-1)
        k_T_NH_SH = 1.0 / 31557600.0, [description = "NH to SH troposphere exchange rate", unit = u"s^-1"]
        k_T_SH_NH = 1.0 / 31557600.0, [description = "SH to NH troposphere exchange rate", unit = u"s^-1"]
        k_S_NH_SH = 0.25 / 31557600.0, [description = "NH to SH stratosphere exchange rate", unit = u"s^-1"]
        k_S_SH_NH = 0.25 / 31557600.0, [description = "SH to NH stratosphere exchange rate", unit = u"s^-1"]

        # Troposphere-stratosphere exchange rates (converted from yr^-1 to s^-1)
        k_NH_T_S = 0.063 / 31557600.0, [description = "NH troposphere to stratosphere exchange rate", unit = u"s^-1"]
        k_NH_S_T = 0.4 / 31557600.0, [description = "NH stratosphere to troposphere exchange rate", unit = u"s^-1"]
        k_SH_T_S = 0.063 / 31557600.0, [description = "SH troposphere to stratosphere exchange rate", unit = u"s^-1"]
        k_SH_S_T = 0.4 / 31557600.0, [description = "SH stratosphere to troposphere exchange rate", unit = u"s^-1"]

        # First-order removal rate constants (converted from yr^-1 to s^-1)
        k_T_NH = 0.0, [description = "Removal rate in NH troposphere", unit = u"s^-1"]
        k_T_SH = 0.0, [description = "Removal rate in SH troposphere", unit = u"s^-1"]
        k_S_NH = 0.0, [description = "Removal rate in NH stratosphere", unit = u"s^-1"]
        k_S_SH = 0.0, [description = "Removal rate in SH stratosphere", unit = u"s^-1"]

        # Source emission rates (in kg/s)
        P_NH = 0.0, [description = "Source emission rate in NH troposphere", unit = u"kg/s"]
        P_SH = 0.0, [description = "Source emission rate in SH troposphere", unit = u"kg/s"]
    end

    @variables begin
        Q_T_NH(t), [description = "Substance quantity in NH troposphere", unit = u"kg"]
        Q_T_SH(t), [description = "Substance quantity in SH troposphere", unit = u"kg"]
        Q_S_NH(t), [description = "Substance quantity in NH stratosphere", unit = u"kg"]
        Q_S_SH(t), [description = "Substance quantity in SH stratosphere", unit = u"kg"]
        Q_total(t), [description = "Total atmospheric burden", unit = u"kg"]
        τ_atm(t), [description = "Overall atmospheric residence time", unit = u"s"]
    end

    eqs = [
        # Eq. 22.26 — NH troposphere steady-state balance
        0 ~ -(k_T_NH_SH + k_NH_T_S + k_T_NH) * Q_T_NH + k_T_SH_NH * Q_T_SH + k_NH_S_T * Q_S_NH + P_NH,

        # Eq. 22.27 — SH troposphere steady-state balance
        0 ~ -(k_T_SH_NH + k_SH_T_S + k_T_SH) * Q_T_SH + k_T_NH_SH * Q_T_NH + k_SH_S_T * Q_S_SH + P_SH,

        # Eq. 22.28 — NH stratosphere steady-state balance
        0 ~ -(k_S_NH_SH + k_NH_S_T + k_S_NH) * Q_S_NH + k_S_SH_NH * Q_S_SH + k_NH_T_S * Q_T_NH,

        # Eq. 22.29 — SH stratosphere steady-state balance
        0 ~ -(k_S_SH_NH + k_SH_S_T + k_S_SH) * Q_S_SH + k_S_NH_SH * Q_S_NH + k_SH_T_S * Q_T_SH,

        # Eq. 22.40 — Total atmospheric burden
        Q_total ~ Q_T_NH + Q_T_SH + Q_S_NH + Q_S_SH,

        # Eq. 22.41 — Overall average residence time
        τ_atm ~ Q_total / (P_NH + P_SH),
    ]

    return System(eqs, t; name)
end
