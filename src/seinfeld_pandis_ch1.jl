"""
    Seinfeld & Pandis Chapter 1: Atmospheric Fundamentals

ModelingToolkit.jl implementation of atmospheric fundamentals from:
Seinfeld, J.H. and Pandis, S.N. (2006). Atmospheric Chemistry and Physics,
2nd Edition, Chapter 1: The Atmosphere.

This module implements:
- Equation 1.1: Hydrostatic equation (dp/dz = -rho*g)
- Equation 1.2: Ideal gas law for density (rho = M_air*p/(R*T))
- Equation 1.3: Combined hydrostatic-ideal gas equation
- Equation 1.4: Scale height (H = R*T/(M_air*g))
- Equation 1.5: Barometric formula (p(z)/p_0 = exp(-z/H))
- Equation 1.6: Volume mixing ratio definition (xi_i = c_i/c_total)
- Equation 1.7: Total molar concentration (c_total = p/(R*T))
- Equation 1.8: Mixing ratio and partial pressure relation (xi_i = p_i/p)
- Equation 1.9: Relative humidity (RH = 100*p_H2O/p_H2O_sat)
- Equation 1.10: Saturation vapor pressure of water (empirical formula)
"""

export AtmosphericPressureProfile, IdealGasLaw, ScaleHeight
export BarometricFormula, TotalMolarConcentration
export MixingRatio, PartialPressureMixingRatio
export RelativeHumidity, SaturationVaporPressure
export AtmosphericThermodynamics, WaterVaporThermodynamics
export R_GAS, M_AIR, G_ACCEL, P_0, T_0, T_BOIL, P_STD_MBAR

#=============================================================================
# Physical Constants (from Appendix A)
=============================================================================#

# Universal gas constant
const R_GAS = 8.314          # J/(mol*K)
# Molecular weight of dry air
const M_AIR = 0.02897        # kg/mol (28.97 g/mol)
# Gravitational acceleration
const G_ACCEL = 9.807        # m/s^2
# Standard sea level pressure
const P_0 = 101325.0         # Pa
# Standard temperature
const T_0 = 273.15           # K
# Boiling point of water
const T_BOIL = 373.15        # K
# Standard pressure in mbar
const P_STD_MBAR = 1013.25   # mbar

#=============================================================================
# Equation 1.2: Ideal Gas Law for Air Density
# rho = M_air * p / (R * T)
=============================================================================#

"""
    IdealGasLaw(; name=:IdealGasLaw)

Calculates air density from pressure and temperature using the ideal gas law.

Implements Equation 1.2:
    rho = M_air * p / (R * T)

where:
- rho: air density (kg/m^3)
- M_air: molecular weight of dry air (kg/mol)
- p: atmospheric pressure (Pa)
- R: universal gas constant (J/(mol*K))
- T: temperature (K)
"""
@component function IdealGasLaw(; name=:IdealGasLaw)
    @constants begin
        R = R_GAS, [description = "Universal gas constant", unit = u"J/(mol*K)"]
        M_air = M_AIR, [description = "Molecular weight of dry air", unit = u"kg/mol"]
    end

    @variables begin
        T(t), [description = "Temperature", unit = u"K"]
        p(t), [description = "Atmospheric pressure", unit = u"Pa"]
        rho(t), [description = "Air density", unit = u"kg/m^3"]
    end

    eqs = [
        # Eq. 1.2 - Ideal gas law for air density
        rho ~ M_air * p / (R * T),
    ]

    return System(eqs, t; name)
end

#=============================================================================
# Equation 1.4: Scale Height
# H = R * T / (M_air * g)
=============================================================================#

"""
    ScaleHeight(; name=:ScaleHeight)

Calculates the atmospheric scale height.

Implements Equation 1.4:
    H = R * T / (M_air * g)

The scale height H represents the altitude increase over which pressure
decreases by a factor of e (~2.718).

Typical values:
- At T = 253 K: H = 7.4 km
- At T = 288 K (sea level): H = 8.4 km
"""
@component function ScaleHeight(; name=:ScaleHeight)
    @constants begin
        R = R_GAS, [description = "Universal gas constant", unit = u"J/(mol*K)"]
        M_air = M_AIR, [description = "Molecular weight of dry air", unit = u"kg/mol"]
        g = G_ACCEL, [description = "Gravitational acceleration", unit = u"m/s^2"]
    end

    @variables begin
        T(t), [description = "Temperature", unit = u"K"]
        H(t), [description = "Scale height", unit = u"m"]
    end

    eqs = [
        # Eq. 1.4 - Scale height definition
        H ~ R * T / (M_air * g),
    ]

    return System(eqs, t; name)
end

#=============================================================================
# Equations 1.1, 1.3, 1.5: Atmospheric Pressure Profile
# Combines hydrostatic equation with ideal gas law
=============================================================================#

"""
    AtmosphericPressureProfile(; name=:AtmosphericPressureProfile)

Calculates atmospheric pressure as a function of altitude for an isothermal atmosphere.

Implements:
- Equation 1.1: dp/dz = -rho * g (hydrostatic equation)
- Equation 1.3: dp/dz = -M_air * g * p / (R * T) (combined form)
- Equation 1.5: p(z)/p_0 = exp(-z/H) (barometric formula, isothermal case)

This component uses the barometric formula (Eq. 1.5) which is the integrated
form of the hydrostatic equation for an isothermal atmosphere.

Note: For a non-isothermal atmosphere, the scale height varies with altitude
and numerical integration of Eq. 1.3 would be required.
"""
@component function AtmosphericPressureProfile(; name=:AtmosphericPressureProfile)
    @constants begin
        R = R_GAS, [description = "Universal gas constant", unit = u"J/(mol*K)"]
        M_air = M_AIR, [description = "Molecular weight of dry air", unit = u"kg/mol"]
        g = G_ACCEL, [description = "Gravitational acceleration", unit = u"m/s^2"]
        p_0 = P_0, [description = "Standard sea level pressure", unit = u"Pa"]
    end

    @parameters begin
        z, [description = "Altitude above sea level", unit = u"m"]
    end

    @variables begin
        T(t), [description = "Temperature (assumed constant for isothermal)", unit = u"K"]
        H(t), [description = "Scale height", unit = u"m"]
        p(t), [description = "Atmospheric pressure at altitude z", unit = u"Pa"]
        rho(t), [description = "Air density at altitude z", unit = u"kg/m^3"]
        dpdz(t), [description = "Pressure gradient (Eq. 1.1/1.3)", unit = u"Pa/m"]
    end

    eqs = [
        # Eq. 1.4 - Scale height
        H ~ R * T / (M_air * g),
        # Eq. 1.5 - Barometric formula (isothermal atmosphere)
        p ~ p_0 * exp(-z / H),
        # Eq. 1.2 - Ideal gas law for density
        rho ~ M_air * p / (R * T),
        # Eq. 1.1 / Eq. 1.3 - Hydrostatic equation (for reference)
        dpdz ~ -rho * g,
    ]

    return System(eqs, t; name)
end

#=============================================================================
# Equation 1.5: Barometric Formula (standalone)
# p(z)/p_0 = exp(-z/H)
=============================================================================#

"""
    BarometricFormula(; name=:BarometricFormula)

Calculates pressure at a given altitude using the barometric formula.

Implements Equation 1.5:
    p(z) = p_0 * exp(-z/H)

This is the integrated form of the hydrostatic equation for an isothermal
atmosphere. The scale height H is provided as an input.
"""
@component function BarometricFormula(; name=:BarometricFormula)
    @constants begin
        p_0 = P_0, [description = "Standard sea level pressure", unit = u"Pa"]
    end

    @parameters begin
        z, [description = "Altitude above sea level", unit = u"m"]
    end

    @variables begin
        H(t), [description = "Scale height", unit = u"m"]
        p(t), [description = "Pressure at altitude z", unit = u"Pa"]
        pressure_ratio(t), [description = "Pressure ratio p/p_0 (dimensionless)", unit = u"1"]
    end

    eqs = [
        # Eq. 1.5 - Barometric formula
        pressure_ratio ~ exp(-z / H),
        p ~ p_0 * pressure_ratio,
    ]

    return System(eqs, t; name)
end

#=============================================================================
# Equation 1.7: Total Molar Concentration
# c_total = p / (R * T)
=============================================================================#

"""
    TotalMolarConcentration(; name=:TotalMolarConcentration)

Calculates total molar concentration of air from pressure and temperature.

Implements Equation 1.7:
    c_total = N/V = p / (R * T)

Standard values:
- At STP (T=273.15 K, p=101325 Pa): c_total = 44.6 mol/m^3
- At T=298 K, p=101325 Pa: c_total = 40.9 mol/m^3
"""
@component function TotalMolarConcentration(; name=:TotalMolarConcentration)
    @constants begin
        R = R_GAS, [description = "Universal gas constant", unit = u"J/(mol*K)"]
    end

    @variables begin
        T(t), [description = "Temperature", unit = u"K"]
        p(t), [description = "Atmospheric pressure", unit = u"Pa"]
        c_total(t), [description = "Total molar concentration of air", unit = u"mol/m^3"]
    end

    eqs = [
        # Eq. 1.7 - Total molar concentration from ideal gas law
        c_total ~ p / (R * T),
    ]

    return System(eqs, t; name)
end

#=============================================================================
# Equation 1.6: Volume Mixing Ratio Definition
# xi_i = c_i / c_total
=============================================================================#

"""
    MixingRatio(; name=:MixingRatio)

Calculates the volume (mole) mixing ratio of a species.

Implements Equation 1.6:
    xi_i = c_i / c_total

The mixing ratio is dimensionless and typically expressed in ppm, ppb, or ppt.
"""
@component function MixingRatio(; name=:MixingRatio)
    @variables begin
        c_i(t), [description = "Molar concentration of species i", unit = u"mol/m^3"]
        c_total(t), [description = "Total molar concentration of air", unit = u"mol/m^3"]
        xi(t), [description = "Volume mixing ratio (dimensionless)", unit = u"1"]
    end

    eqs = [
        # Eq. 1.6 - Volume mixing ratio definition
        xi ~ c_i / c_total,
    ]

    return System(eqs, t; name)
end

#=============================================================================
# Equation 1.8: Mixing Ratio and Partial Pressure Relation
# xi_i = p_i / p
=============================================================================#

"""
    PartialPressureMixingRatio(; name=:PartialPressureMixingRatio)

Relates mixing ratio to partial pressure.

Implements Equation 1.8:
    xi_i = c_i / (p/(R*T)) = p_i / p

The mixing ratio equals the ratio of partial pressure to total pressure.
"""
@component function PartialPressureMixingRatio(; name=:PartialPressureMixingRatio)
    @variables begin
        p_i(t), [description = "Partial pressure of species i", unit = u"Pa"]
        p(t), [description = "Total atmospheric pressure", unit = u"Pa"]
        xi(t), [description = "Volume mixing ratio (dimensionless)", unit = u"1"]
    end

    eqs = [
        # Eq. 1.8 - Mixing ratio from partial pressure
        xi ~ p_i / p,
    ]

    return System(eqs, t; name)
end

#=============================================================================
# Equation 1.10: Saturation Vapor Pressure of Water
# p_H2O_sat(T) = 1013.25 * exp(13.3185*a - 1.9760*a^2 - 0.6445*a^3 - 0.1299*a^4)
# where a = 1 - 373.15/T
=============================================================================#

"""
    SaturationVaporPressure(; name=:SaturationVaporPressure)

Calculates the saturation vapor pressure of water as a function of temperature.

Implements Equation 1.10:
    p_H2O_sat(T) = 1013.25 * exp(13.3185*a - 1.9760*a^2 - 0.6445*a^3 - 0.1299*a^4)

where:
    a = 1 - 373.15/T

This empirical formula is valid for liquid water (T > 273 K).

Note: The original equation gives pressure in mbar. Here we convert to Pa for
consistency with SI units: p_sat (Pa) = 100 * p_sat (mbar)

Reference values:
- At T = 273 K: p_sat ~ 611 Pa (6.1 mbar)
- At T = 298 K: p_sat ~ 3170 Pa (31.7 mbar)
- At T = 373 K: p_sat = 101325 Pa (1013.25 mbar, boiling point)
"""
@component function SaturationVaporPressure(; name=:SaturationVaporPressure)
    @constants begin
        T_boil = T_BOIL, [description = "Boiling point of water", unit = u"K"]
        # Standard pressure converted to Pa (1013.25 mbar = 101325 Pa)
        p_std = P_0, [description = "Standard pressure", unit = u"Pa"]
        # Empirical coefficients (dimensionless)
        c1 = 13.3185, [description = "Empirical coefficient 1 (dimensionless)", unit = u"1"]
        c2 = 1.9760, [description = "Empirical coefficient 2 (dimensionless)", unit = u"1"]
        c3 = 0.6445, [description = "Empirical coefficient 3 (dimensionless)", unit = u"1"]
        c4 = 0.1299, [description = "Empirical coefficient 4 (dimensionless)", unit = u"1"]
    end

    @variables begin
        T(t), [description = "Temperature", unit = u"K"]
        a(t), [description = "Dimensionless temperature parameter (dimensionless)", unit = u"1"]
        p_sat(t), [description = "Saturation vapor pressure of water", unit = u"Pa"]
    end

    eqs = [
        # Eq. 1.10 - Temperature parameter
        a ~ 1 - T_boil / T,
        # Eq. 1.10 - Saturation vapor pressure (in Pa)
        p_sat ~ p_std * exp(c1*a - c2*a^2 - c3*a^3 - c4*a^4),
    ]

    return System(eqs, t; name)
end

#=============================================================================
# Equation 1.9: Relative Humidity
# RH = 100 * p_H2O / p_H2O_sat
=============================================================================#

"""
    RelativeHumidity(; name=:RelativeHumidity)

Calculates relative humidity from water vapor partial pressure and
saturation vapor pressure.

Implements Equation 1.9:
    RH = 100 * p_H2O / p_H2O_sat

Relative humidity is expressed as a percentage (0-100%), stored as a
dimensionless ratio multiplied by 100.
"""
@component function RelativeHumidity(; name=:RelativeHumidity)
    @constants begin
        percent_factor = 100.0, [description = "Conversion to percent (dimensionless)", unit = u"1"]
    end

    @variables begin
        p_H2O(t), [description = "Partial pressure of water vapor", unit = u"Pa"]
        p_sat(t), [description = "Saturation vapor pressure of water", unit = u"Pa"]
        RH(t), [description = "Relative humidity (0-100, dimensionless)", unit = u"1"]
    end

    eqs = [
        # Eq. 1.9 - Relative humidity definition
        RH ~ percent_factor * p_H2O / p_sat,
    ]

    return System(eqs, t; name)
end

#=============================================================================
# Composite System: Water Vapor Thermodynamics
# Combines Equations 1.9 and 1.10
=============================================================================#

"""
    WaterVaporThermodynamics(; name=:WaterVaporThermodynamics)

Complete water vapor thermodynamics system combining:
- Equation 1.10: Saturation vapor pressure
- Equation 1.9: Relative humidity

This composite system calculates relative humidity given temperature
and water vapor partial pressure.
"""
@component function WaterVaporThermodynamics(; name=:WaterVaporThermodynamics)
    # Create subsystems
    @named sat = SaturationVaporPressure()
    @named rh = RelativeHumidity()

    @variables begin
        T(t), [description = "Temperature", unit = u"K"]
        p_H2O(t), [description = "Partial pressure of water vapor", unit = u"Pa"]
        RH(t), [description = "Relative humidity (0-100, dimensionless)", unit = u"1"]
        p_sat(t), [description = "Saturation vapor pressure", unit = u"Pa"]
    end

    eqs = [
        # Connect temperature to saturation vapor pressure subsystem
        sat.T ~ T,
        # Connect saturation vapor pressure from subsystem to relative humidity subsystem
        rh.p_sat ~ sat.p_sat,
        # Connect water vapor pressure to relative humidity subsystem
        rh.p_H2O ~ p_H2O,
        # Output variables
        p_sat ~ sat.p_sat,
        RH ~ rh.RH,
    ]

    return System(eqs, t; systems = [sat, rh], name)
end

#=============================================================================
# Composite System: Atmospheric Thermodynamics
# Combines Equations 1.2, 1.4, 1.5, 1.7
=============================================================================#

"""
    AtmosphericThermodynamics(; name=:AtmosphericThermodynamics)

Complete atmospheric thermodynamics system combining:
- Equation 1.2: Ideal gas law for density
- Equation 1.4: Scale height
- Equation 1.5: Barometric formula
- Equation 1.7: Total molar concentration

This composite system calculates pressure, density, scale height, and
total molar concentration given altitude and temperature for an
isothermal atmosphere.
"""
@component function AtmosphericThermodynamics(; name=:AtmosphericThermodynamics)
    @constants begin
        R = R_GAS, [description = "Universal gas constant", unit = u"J/(mol*K)"]
        M_air = M_AIR, [description = "Molecular weight of dry air", unit = u"kg/mol"]
        g = G_ACCEL, [description = "Gravitational acceleration", unit = u"m/s^2"]
        p_0 = P_0, [description = "Standard sea level pressure", unit = u"Pa"]
    end

    @parameters begin
        z, [description = "Altitude above sea level", unit = u"m"]
    end

    @variables begin
        T(t), [description = "Temperature", unit = u"K"]
        H(t), [description = "Scale height", unit = u"m"]
        p(t), [description = "Atmospheric pressure at altitude z", unit = u"Pa"]
        rho(t), [description = "Air density at altitude z", unit = u"kg/m^3"]
        c_total(t), [description = "Total molar concentration", unit = u"mol/m^3"]
    end

    eqs = [
        # Eq. 1.4 - Scale height
        H ~ R * T / (M_air * g),
        # Eq. 1.5 - Barometric formula (isothermal atmosphere)
        p ~ p_0 * exp(-z / H),
        # Eq. 1.2 - Ideal gas law for density
        rho ~ M_air * p / (R * T),
        # Eq. 1.7 - Total molar concentration
        c_total ~ p / (R * T),
    ]

    return System(eqs, t; name)
end
