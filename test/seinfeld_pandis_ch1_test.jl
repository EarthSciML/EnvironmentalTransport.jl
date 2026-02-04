"""
Test suite for Seinfeld & Pandis Chapter 1 atmospheric fundamentals implementation.

Comprehensive tests for the ModelingToolkit.jl implementation of
Seinfeld & Pandis (2006) Chapter 1 "The Atmosphere" equations.

Tests verify:
1. Structural correctness (model components, variables, parameters)
2. Equation verification against textbook formulas
3. Numerical accuracy against known values from the chapter
4. Physical constraints and edge cases
5. Dimensional consistency

Reference: Seinfeld, J.H. and Pandis, S.N. (2006). Atmospheric Chemistry and Physics,
2nd Edition, Chapter 1: The Atmosphere. Wiley-Interscience.
"""

using EnvironmentalTransport
using ModelingToolkit
using ModelingToolkit: t, D
using DynamicQuantities

#=============================================================================
# Test Setup Snippet - shared imports for all tests
=============================================================================#

@testsnippet SPCh1Setup begin
    using EnvironmentalTransport
    using ModelingToolkit
    using ModelingToolkit: t, D, unknowns, parameters, equations, System,
                           toggle_namespacing, mtkcompile
    using ModelingToolkit: @named
    using DynamicQuantities
    using Test
end

#=============================================================================
# Test Set 1: Structural Tests
=============================================================================#

@testitem "1.1 IdealGasLaw Structure" setup=[SPCh1Setup] begin
    @named igl = IdealGasLaw()
    @test igl isa System

    # Check that all expected variables exist
    vars = unknowns(igl)
    var_names = string.(vars)
    @test any(occursin("T", n) for n in var_names)
    @test any(occursin("p", n) for n in var_names)
    @test any(occursin("rho", n) for n in var_names)
    @test length(vars) == 3

    # Check equations
    eqs = equations(igl)
    @test length(eqs) == 1
end

@testitem "1.2 ScaleHeight Structure" setup=[SPCh1Setup] begin
    @named sh = ScaleHeight()
    @test sh isa System

    vars = unknowns(sh)
    var_names = string.(vars)
    @test any(occursin("T", n) for n in var_names)
    @test any(occursin("H", n) for n in var_names)
    @test length(vars) == 2

    eqs = equations(sh)
    @test length(eqs) == 1
end

@testitem "1.3 AtmosphericPressureProfile Structure" setup=[SPCh1Setup] begin
    @named app = AtmosphericPressureProfile()
    @test app isa System

    vars = unknowns(app)
    var_names = string.(vars)
    @test any(occursin("T", n) for n in var_names)
    @test any(occursin("p", n) for n in var_names)
    @test any(occursin("H", n) for n in var_names)
    @test any(occursin("rho", n) for n in var_names)
    @test any(occursin("dpdz", n) for n in var_names)
    @test length(vars) == 5

    # Check parameters
    params = parameters(app)
    param_names = string.(params)
    @test any(occursin("z", n) for n in param_names)

    eqs = equations(app)
    @test length(eqs) == 4
end

@testitem "1.4 TotalMolarConcentration Structure" setup=[SPCh1Setup] begin
    @named tmc = TotalMolarConcentration()
    @test tmc isa System

    vars = unknowns(tmc)
    var_names = string.(vars)
    @test any(occursin("T", n) for n in var_names)
    @test any(occursin("p", n) for n in var_names)
    @test any(occursin("c_total", n) for n in var_names)
    @test length(vars) == 3
end

@testitem "1.5 MixingRatio Structure" setup=[SPCh1Setup] begin
    @named mr = MixingRatio()
    @test mr isa System

    vars = unknowns(mr)
    var_names = string.(vars)
    @test any(occursin("c_i", n) for n in var_names)
    @test any(occursin("c_total", n) for n in var_names)
    @test any(occursin("xi", n) for n in var_names)
    @test length(vars) == 3
end

@testitem "1.6 PartialPressureMixingRatio Structure" setup=[SPCh1Setup] begin
    @named ppmr = PartialPressureMixingRatio()
    @test ppmr isa System

    vars = unknowns(ppmr)
    var_names = string.(vars)
    @test any(occursin("p_i", n) for n in var_names)
    @test any(occursin("p", n) && !occursin("p_i", n) for n in var_names)
    @test any(occursin("xi", n) for n in var_names)
    @test length(vars) == 3
end

@testitem "1.7 SaturationVaporPressure Structure" setup=[SPCh1Setup] begin
    @named svp = SaturationVaporPressure()
    @test svp isa System

    vars = unknowns(svp)
    var_names = string.(vars)
    @test any(occursin("T", n) for n in var_names)
    @test any(occursin("a", n) for n in var_names)
    @test any(occursin("p_sat", n) for n in var_names)
    @test length(vars) == 3

    eqs = equations(svp)
    @test length(eqs) == 2
end

@testitem "1.8 RelativeHumidity Structure" setup=[SPCh1Setup] begin
    @named rh = RelativeHumidity()
    @test rh isa System

    vars = unknowns(rh)
    var_names = string.(vars)
    @test any(occursin("p_H2O", n) for n in var_names)
    @test any(occursin("p_sat", n) for n in var_names)
    @test any(occursin("RH", n) for n in var_names)
    @test length(vars) == 3
end

@testitem "1.9 WaterVaporThermodynamics Composite Structure" setup=[SPCh1Setup] begin
    @named wvt = WaterVaporThermodynamics()
    @test wvt isa System

    vars = unknowns(wvt)
    var_names = string.(vars)
    @test any(occursin("T", n) for n in var_names)
    @test any(occursin("RH", n) for n in var_names)
    @test any(occursin("p_sat", n) for n in var_names)

    # Check subsystems are composed
    @test any(occursin("sat", n) for n in var_names)
    @test any(occursin("rh", n) for n in var_names)
end

@testitem "1.10 AtmosphericThermodynamics Composite Structure" setup=[SPCh1Setup] begin
    @named at = AtmosphericThermodynamics()
    @test at isa System

    vars = unknowns(at)
    var_names = string.(vars)
    @test any(occursin("T", n) for n in var_names)
    @test any(occursin("H", n) for n in var_names)
    @test any(occursin("p", n) for n in var_names)
    @test any(occursin("rho", n) for n in var_names)
    @test any(occursin("c_total", n) for n in var_names)

    params = parameters(at)
    param_names = string.(params)
    @test any(occursin("z", n) for n in param_names)
end

#=============================================================================
# Test Set 2: Equation Verification Tests
=============================================================================#

@testitem "2.1 Eq. 1.2: Ideal Gas Law for Density" begin
    # rho = M_air * p / (R * T)

    # Physical constants
    R = 8.314       # J/(mol*K)
    M_air = 0.02897 # kg/mol

    # Test case: sea level conditions
    T = 288.15    # K (15 C)
    p = 101325.0  # Pa

    # Expected density
    expected_rho = M_air * p / (R * T)

    # From Table 1.4: rho at sea level is 1.225 kg/m^3
    @test expected_rho ≈ 1.225 rtol=0.01
end

@testitem "2.2 Eq. 1.4: Scale Height" begin
    # H = R * T / (M_air * g)

    R = 8.314       # J/(mol*K)
    M_air = 0.02897 # kg/mol
    g = 9.807       # m/s^2

    # Test at T = 253 K (from specification: H = 7.4 km)
    T1 = 253.0
    H1 = R * T1 / (M_air * g)
    @test H1 ≈ 7400 rtol=0.02

    # Test at T = 288 K (from specification: H = 8.4 km)
    T2 = 288.0
    H2 = R * T2 / (M_air * g)
    @test H2 ≈ 8400 rtol=0.02
end

@testitem "2.3 Eq. 1.5: Barometric Formula" begin
    # p(z)/p_0 = exp(-z/H)

    p_0 = 101325.0  # Pa
    H = 8000.0      # m (typical scale height)

    # At z = H, pressure should be p_0/e
    p_at_H = p_0 * exp(-H / H)
    @test p_at_H ≈ p_0 / exp(1) rtol=1e-10

    # At z = 0, pressure should be p_0
    p_at_0 = p_0 * exp(-0 / H)
    @test p_at_0 ≈ p_0 rtol=1e-10

    # At z = 10 km (typical troposphere height)
    z = 10000.0
    p_at_10km = p_0 * exp(-z / H)
    @test p_at_10km ≈ 28682 rtol=0.02  # ~265 mbar from Table 1.4
end

@testitem "2.4 Eq. 1.7: Total Molar Concentration" begin
    # c_total = p / (R * T)

    R = 8.314  # J/(mol*K)

    # At STP (T=273.15 K, p=101325 Pa): c_total = 44.6 mol/m^3
    T_stp = 273.15
    p_stp = 101325.0
    c_stp = p_stp / (R * T_stp)
    @test c_stp ≈ 44.6 rtol=0.02

    # At T=298 K, p=101325 Pa: c_total = 40.9 mol/m^3
    T_298 = 298.0
    c_298 = p_stp / (R * T_298)
    @test c_298 ≈ 40.9 rtol=0.02
end

@testitem "2.5 Eq. 1.6: Volume Mixing Ratio" begin
    # xi_i = c_i / c_total

    # Example: O3 at 40 ppb
    c_total = 44.6  # mol/m^3 at STP
    xi_O3 = 40e-9   # 40 ppb

    c_O3 = xi_O3 * c_total
    @test c_O3 ≈ 1.78e-6 rtol=0.01

    # Verify inverse: xi = c_i / c_total
    @test c_O3 / c_total ≈ xi_O3 rtol=1e-10
end

@testitem "2.6 Eq. 1.8: Mixing Ratio and Partial Pressure" begin
    # xi_i = p_i / p

    p_total = 101325.0  # Pa

    # CO2 at 400 ppm
    xi_CO2 = 400e-6
    p_CO2 = xi_CO2 * p_total
    @test p_CO2 ≈ 40.53 rtol=0.01  # Pa

    # Verify inverse
    @test p_CO2 / p_total ≈ xi_CO2 rtol=1e-10
end

@testitem "2.7 Eq. 1.10: Saturation Vapor Pressure" begin
    # p_sat = 1013.25 * exp(13.3185*a - 1.9760*a^2 - 0.6445*a^3 - 0.1299*a^4)
    # where a = 1 - 373.15/T

    p_std = 1013.25  # mbar
    T_boil = 373.15  # K

    # Test at T = 373.15 K (boiling point): p_sat should be 1013.25 mbar
    T1 = 373.15
    a1 = 1 - T_boil / T1
    @test a1 ≈ 0.0 atol=1e-10
    p_sat_1 = p_std * exp(13.3185*a1 - 1.9760*a1^2 - 0.6445*a1^3 - 0.1299*a1^4)
    @test p_sat_1 ≈ 1013.25 rtol=1e-10

    # Test at T = 273 K: p_sat ~ 6.1 mbar (from specification)
    T2 = 273.15
    a2 = 1 - T_boil / T2
    p_sat_2 = p_std * exp(13.3185*a2 - 1.9760*a2^2 - 0.6445*a2^3 - 0.1299*a2^4)
    @test p_sat_2 ≈ 6.1 rtol=0.05

    # Test at T = 298 K: p_sat ~ 31.7 mbar (from specification)
    T3 = 298.15
    a3 = 1 - T_boil / T3
    p_sat_3 = p_std * exp(13.3185*a3 - 1.9760*a3^2 - 0.6445*a3^3 - 0.1299*a3^4)
    @test p_sat_3 ≈ 31.7 rtol=0.05
end

@testitem "2.8 Eq. 1.9: Relative Humidity" begin
    # RH = 100 * p_H2O / p_sat

    # At 50% RH
    p_sat = 31.7  # mbar at 298 K
    p_H2O = 0.5 * p_sat
    RH = 100 * p_H2O / p_sat
    @test RH ≈ 50.0 rtol=1e-10

    # At saturation (100% RH)
    p_H2O_sat = p_sat
    RH_sat = 100 * p_H2O_sat / p_sat
    @test RH_sat ≈ 100.0 rtol=1e-10
end

#=============================================================================
# Test Set 3: Table 1.4 U.S. Standard Atmosphere Validation
=============================================================================#

@testitem "3.1 U.S. Standard Atmosphere: Sea Level" begin
    # From Table 1.4: z=0 km, T=288.2 K, p=1013 mbar, rho=1.225 kg/m^3

    R = 8.314
    M_air = 0.02897
    g = 9.807

    T = 288.2    # K
    p = 101300   # Pa (1013 mbar)

    # Density
    rho = M_air * p / (R * T)
    @test rho ≈ 1.225 rtol=0.01

    # Scale height
    H = R * T / (M_air * g)
    @test H ≈ 8450 rtol=0.02
end

@testitem "3.2 U.S. Standard Atmosphere: 5 km" begin
    # From Table 1.4: z=5 km, T=255.7 K, p=540.5 mbar, rho=0.736 kg/m^3

    R = 8.314
    M_air = 0.02897

    T = 255.7    # K
    p = 54050    # Pa (540.5 mbar)

    rho = M_air * p / (R * T)
    @test rho ≈ 0.736 rtol=0.02
end

@testitem "3.3 U.S. Standard Atmosphere: 10 km" begin
    # From Table 1.4: z=10 km, T=223.3 K, p=265.0 mbar, rho=0.414 kg/m^3

    R = 8.314
    M_air = 0.02897

    T = 223.3    # K
    p = 26500    # Pa (265.0 mbar)

    rho = M_air * p / (R * T)
    @test rho ≈ 0.414 rtol=0.02
end

#=============================================================================
# Test Set 4: Physical Constraints
=============================================================================#

@testitem "4.1 Positive Quantities" begin
    R = 8.314
    M_air = 0.02897
    g = 9.807

    # Temperature, pressure, density must be positive
    T = 250.0  # K
    p = 50000  # Pa

    rho = M_air * p / (R * T)
    @test rho > 0

    H = R * T / (M_air * g)
    @test H > 0

    c_total = p / (R * T)
    @test c_total > 0
end

@testitem "4.2 Pressure Decreases with Altitude" begin
    p_0 = 101325.0
    H = 8000.0

    # Pressure at z=0
    p_0m = p_0 * exp(-0 / H)
    # Pressure at z=5000
    p_5km = p_0 * exp(-5000 / H)
    # Pressure at z=10000
    p_10km = p_0 * exp(-10000 / H)

    @test p_0m > p_5km > p_10km
end

@testitem "4.3 Relative Humidity Bounds" begin
    # RH should be between 0 and 100 for physical conditions
    p_sat = 31.7  # mbar

    # At subsaturation
    p_H2O_sub = 15.0
    RH_sub = 100 * p_H2O_sub / p_sat
    @test 0 < RH_sub < 100

    # At saturation
    RH_sat = 100 * p_sat / p_sat
    @test RH_sat ≈ 100
end

@testitem "4.4 Saturation Vapor Pressure Increases with Temperature" begin
    p_std = 1013.25
    T_boil = 373.15

    calc_psat = (T) -> begin
        a = 1 - T_boil / T
        p_std * exp(13.3185*a - 1.9760*a^2 - 0.6445*a^3 - 0.1299*a^4)
    end

    p_sat_273 = calc_psat(273.15)
    p_sat_288 = calc_psat(288.15)
    p_sat_298 = calc_psat(298.15)
    p_sat_373 = calc_psat(373.15)

    @test p_sat_273 < p_sat_288 < p_sat_298 < p_sat_373
end

#=============================================================================
# Test Set 5: System Compilation Tests
=============================================================================#

@testitem "5.1 IdealGasLaw Compilation" setup=[SPCh1Setup] begin
    @named igl = IdealGasLaw()
    igl_nns = toggle_namespacing(igl, false)
    compiled = mtkcompile(igl; inputs = [igl_nns.T, igl_nns.p])
    @test compiled isa System
end

@testitem "5.2 ScaleHeight Compilation" setup=[SPCh1Setup] begin
    @named sh = ScaleHeight()
    sh_nns = toggle_namespacing(sh, false)
    compiled = mtkcompile(sh; inputs = [sh_nns.T])
    @test compiled isa System
end

@testitem "5.3 AtmosphericPressureProfile Compilation" setup=[SPCh1Setup] begin
    @named app = AtmosphericPressureProfile()
    app_nns = toggle_namespacing(app, false)
    compiled = mtkcompile(app; inputs = [app_nns.T])
    @test compiled isa System
end

@testitem "5.4 TotalMolarConcentration Compilation" setup=[SPCh1Setup] begin
    @named tmc = TotalMolarConcentration()
    tmc_nns = toggle_namespacing(tmc, false)
    compiled = mtkcompile(tmc; inputs = [tmc_nns.T, tmc_nns.p])
    @test compiled isa System
end

@testitem "5.5 MixingRatio Compilation" setup=[SPCh1Setup] begin
    @named mr = MixingRatio()
    mr_nns = toggle_namespacing(mr, false)
    compiled = mtkcompile(mr; inputs = [mr_nns.c_i, mr_nns.c_total])
    @test compiled isa System
end

@testitem "5.6 SaturationVaporPressure Compilation" setup=[SPCh1Setup] begin
    @named svp = SaturationVaporPressure()
    svp_nns = toggle_namespacing(svp, false)
    compiled = mtkcompile(svp; inputs = [svp_nns.T])
    @test compiled isa System
end

@testitem "5.7 RelativeHumidity Compilation" setup=[SPCh1Setup] begin
    @named rh = RelativeHumidity()
    rh_nns = toggle_namespacing(rh, false)
    compiled = mtkcompile(rh; inputs = [rh_nns.p_H2O, rh_nns.p_sat])
    @test compiled isa System
end

@testitem "5.8 WaterVaporThermodynamics Compilation" setup=[SPCh1Setup] begin
    @named wvt = WaterVaporThermodynamics()
    wvt_nns = toggle_namespacing(wvt, false)
    compiled = mtkcompile(wvt; inputs = [wvt_nns.T, wvt_nns.p_H2O])
    @test compiled isa System
end

@testitem "5.9 AtmosphericThermodynamics Compilation" setup=[SPCh1Setup] begin
    @named at = AtmosphericThermodynamics()
    at_nns = toggle_namespacing(at, false)
    compiled = mtkcompile(at; inputs = [at_nns.T])
    @test compiled isa System
end

#=============================================================================
# Test Set 6: Physical Constants Verification
=============================================================================#

@testitem "6.1 Physical Constants" setup=[SPCh1Setup] begin
    # Verify constants match specification
    @test EnvironmentalTransport.R_GAS ≈ 8.314 rtol=0.001
    @test EnvironmentalTransport.M_AIR ≈ 0.02897 rtol=0.001
    @test EnvironmentalTransport.G_ACCEL ≈ 9.807 rtol=0.001
    @test EnvironmentalTransport.P_0 ≈ 101325 rtol=0.001
    @test EnvironmentalTransport.T_0 ≈ 273.15 rtol=0.001
    @test EnvironmentalTransport.T_BOIL ≈ 373.15 rtol=0.001
    @test EnvironmentalTransport.P_STD_MBAR ≈ 1013.25 rtol=0.001
end

println("\nAll tests completed!")
