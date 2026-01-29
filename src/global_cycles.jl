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

Equations 22.1-22.15 are implemented as algebraic relations. The system uses
first-order rate constants for all removal processes.

Default residence time values are from Rodhe (1978).

**Reference**: Seinfeld, J. H. and Pandis, S. N. (2006), *Atmospheric Chemistry and Physics:
From Air Pollution to Climate Change*, 2nd Ed., John Wiley & Sons, Ch. 22, pp. 1003-1007.
"""
function SulfurCycle(; name=:SulfurCycle)
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
        b(t), [description = "Fraction of S converted to SO4 before removal (dimensionless)"]
        τ_S(t), [description = "Mean residence time of a sulfur atom", unit = u"s"]
        c(t), [description = "Fraction of total sulfur that is SO2 (dimensionless)"]
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
        c ~ 1 / (1 + b * (1 / τ_SO2) / (1 / τ_SO4)),

        # Eq. 22.14 — Sulfur dry deposition residence time
        1 / τ_S_d ~ c / τ_SO2_d + (1 - c) / τ_SO4_d,

        # Eq. 22.12 — Sulfur wet deposition residence time
        1 / τ_S_w ~ c / τ_SO2_w + (1 - c) / τ_SO4_w,
    ]

    System(eqs, t; name)
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

All mass quantities are in Pg C (petagrams of carbon, 1 Pg = 10^15 g)
and time is in years. Rate constants are in yr^-1.

Default parameter values and initial conditions correspond to the preindustrial
(~1850) steady state from Schmitz (2002) as presented in Figure 22.6 and Table 22.1.

**Reference**: Seinfeld, J. H. and Pandis, S. N. (2006), *Atmospheric Chemistry and Physics:
From Air Pollution to Climate Change*, 2nd Ed., John Wiley & Sons, Ch. 22, pp. 1009-1015.
Schmitz, R. A. (2002), The Earth's carbon cycle, *Chem. Eng. Educ.*, 296.
"""
function CarbonCycle(; name=:CarbonCycle)
    # All quantities are dimensionless; values interpreted as Pg C for masses and yr^-1 for rates.
    # This avoids MTK unit prefactor issues when mixing dimensionless quantities with non-SI units.
    @constants begin
        # Table 22.1 — First-order exchange coefficients (yr^-1)
        k12 = 0.0931, [description = "Atmosphere to warm ocean transfer coefficient (yr^-1)"]
        k13 = 0.0311, [description = "Atmosphere to cool ocean transfer coefficient (yr^-1)"]
        k23 = 0.0781, [description = "Warm ocean to cool ocean transfer coefficient (yr^-1)"]
        k24 = 0.0164, [description = "Warm ocean to deep ocean transfer coefficient (yr^-1)"]
        k34 = 0.714, [description = "Cool ocean to deep ocean transfer coefficient (yr^-1)"]
        k42 = 0.00189, [description = "Deep ocean to warm ocean transfer coefficient (yr^-1)"]
        k43 = 0.00114, [description = "Deep ocean to cool ocean transfer coefficient (yr^-1)"]
        k51 = 0.0862, [description = "Biota to atmosphere transfer coefficient (yr^-1)"]
        k56 = 0.0862, [description = "Biota to soils/detritus transfer coefficient (yr^-1)"]
        k61 = 0.0333, [description = "Soils/detritus to atmosphere transfer coefficient (yr^-1)"]

        # Table 22.1 — Nonlinear ocean parameters (dimensionless)
        β2 = 9.4, [description = "Warm ocean carbonate buffer exponent (dimensionless)"]
        β3 = 10.2, [description = "Cool ocean carbonate buffer exponent (dimensionless)"]

        # Table 22.1 — Photosynthetic uptake parameters (Pg C)
        γ_c = 62.0, [description = "CO2 uptake threshold for biota (Pg C)"]
        Γ_c = 198.0, [description = "CO2 saturation parameter for biota (Pg C)"]

        # Table 22.1 — Land use change parameters (dimensionless)
        a_d = 0.230, [description = "Fraction of deforested area unavailable for regrowth (dimensionless)"]
        a_r = 1.0, [description = "Fraction of reforested area increasing biota (dimensionless)"]

        # Derived constants from preindustrial steady state (Table 22.1)
        # k15 = F15_pre * (M1_pre + Γ) / (M1_pre - γ) = 100 * (612+198)/(612-62) ≈ 147.27
        k15 = 147.0, [description = "Atmosphere to biota base transfer coefficient (yr^-1)"]

        # Preindustrial flux values for nonlinear ocean terms (Pg C yr^-1)
        # Used as reference: F21 = F21_pre * (M2/M2_pre)^β2
        F21_pre = 58.0, [description = "Preindustrial warm ocean to atmosphere flux (Pg C yr^-1)"]
        F31_pre = 18.0, [description = "Preindustrial cool ocean to atmosphere flux (Pg C yr^-1)"]

        # Preindustrial reservoir masses for normalization (Pg C)
        M2_pre = 730.0, [description = "Preindustrial warm ocean surface carbon (Pg C)"]
        M3_pre = 140.0, [description = "Preindustrial cool ocean surface carbon (Pg C)"]

        # Preindustrial M5(0) for G equation (Pg C)
        M5_0 = 580.0, [description = "Preindustrial terrestrial biota carbon (Pg C)"]
    end

    @parameters begin
        Ff = 0.0, [description = "Fossil fuel emissions (Pg C yr^-1)"]
        Fd = 0.0, [description = "Deforestation flux (Pg C yr^-1)"]
        Fr = 0.0, [description = "Reforestation flux (Pg C yr^-1)"]
    end

    @variables begin
        M1(t) = 612.0, [description = "Carbon in atmosphere (Pg C)"]
        M2(t) = 730.0, [description = "Carbon in warm ocean surface waters (Pg C)"]
        M3(t) = 140.0, [description = "Carbon in cool ocean surface waters (Pg C)"]
        M4(t) = 37000.0, [description = "Carbon in deep ocean waters (Pg C)"]
        M5(t) = 580.0, [description = "Carbon in terrestrial biota (Pg C)"]
        M6(t) = 1500.0, [description = "Carbon in soils and detritus (Pg C)"]
        M7(t) = 5300.0, [description = "Carbon in fossil fuels (Pg C)"]
        G(t) = 1.0, [description = "Deforestation/reforestation scaling factor (dimensionless)"]
        F15_flux(t), [description = "Atmosphere to biota flux (Pg C yr^-1)"]
        F21_flux(t), [description = "Warm ocean to atmosphere flux (Pg C yr^-1)"]
        F31_flux(t), [description = "Cool ocean to atmosphere flux (Pg C yr^-1)"]
    end

    eqs = [
        # Eq. 22.19 — Photosynthetic uptake with saturation and land-use scaling
        F15_flux ~ k15 * G * max(0.0, (M1 - γ_c) / (M1 + Γ_c)),

        # Eq. 22.18 — Nonlinear ocean-to-atmosphere fluxes
        # F21 = k21 * M2^β2, with k21 = F21_pre / M2_pre^β2
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

    # Unit checking disabled because the model uses dimensionless quantities
    # with time in years, while MTK's default t is in seconds.
    System(eqs, t; name, checks=false)
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

Default parameter values correspond to the CH3CCl3 example in Section 22.3.

**Reference**: Seinfeld, J. H. and Pandis, S. N. (2006), *Atmospheric Chemistry and Physics:
From Air Pollution to Climate Change*, 2nd Ed., John Wiley & Sons, Ch. 22, pp. 1018-1022.
"""
function FourCompartmentAtmosphere(; name=:FourCompartmentAtmosphere)
    # All quantities are dimensionless; values interpreted with time in years and mass in grams.
    # This avoids MTK unit prefactor issues when mixing dimensionless quantities with non-SI units.
    @parameters begin
        # Interhemispheric exchange rates (yr^-1)
        k_T_NH_SH = 1.0, [description = "NH to SH troposphere exchange rate (yr^-1)"]
        k_T_SH_NH = 1.0, [description = "SH to NH troposphere exchange rate (yr^-1)"]
        k_S_NH_SH = 0.25, [description = "NH to SH stratosphere exchange rate (yr^-1)"]
        k_S_SH_NH = 0.25, [description = "SH to NH stratosphere exchange rate (yr^-1)"]

        # Troposphere-stratosphere exchange rates (yr^-1)
        k_NH_T_S = 0.063, [description = "NH troposphere to stratosphere exchange rate (yr^-1)"]
        k_NH_S_T = 0.4, [description = "NH stratosphere to troposphere exchange rate (yr^-1)"]
        k_SH_T_S = 0.063, [description = "SH troposphere to stratosphere exchange rate (yr^-1)"]
        k_SH_S_T = 0.4, [description = "SH stratosphere to troposphere exchange rate (yr^-1)"]

        # First-order removal rate constants (yr^-1)
        k_T_NH = 0.0, [description = "Removal rate in NH troposphere (yr^-1)"]
        k_T_SH = 0.0, [description = "Removal rate in SH troposphere (yr^-1)"]
        k_S_NH = 0.0, [description = "Removal rate in NH stratosphere (yr^-1)"]
        k_S_SH = 0.0, [description = "Removal rate in SH stratosphere (yr^-1)"]

        # Source emission rates (g/yr)
        P_NH = 0.0, [description = "Source emission rate in NH troposphere (g/yr)"]
        P_SH = 0.0, [description = "Source emission rate in SH troposphere (g/yr)"]
    end

    @variables begin
        Q_T_NH(t), [description = "Substance quantity in NH troposphere (g)"]
        Q_T_SH(t), [description = "Substance quantity in SH troposphere (g)"]
        Q_S_NH(t), [description = "Substance quantity in NH stratosphere (g)"]
        Q_S_SH(t), [description = "Substance quantity in SH stratosphere (g)"]
        Q_total(t), [description = "Total atmospheric burden (g)"]
        τ_atm(t), [description = "Overall atmospheric residence time (yr)"]
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

    # Unit checking disabled because the model uses dimensionless quantities
    # with time in years, while MTK's default t is in seconds.
    System(eqs, t; name, checks=false)
end
