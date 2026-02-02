@testitem "SulfurCycle - Structural" begin
    using EnvironmentalTransport
    using ModelingToolkit

    sys = SulfurCycle()

    # Verify correct number of components
    @test length(unknowns(sys)) == 7  # τ_SO2, τ_SO4, b, τ_S, c, τ_S_d, τ_S_w
    @test length(parameters(sys)) == 5  # τ_SO2_d, τ_SO2_w, τ_SO2_c, τ_SO4_d, τ_SO4_w
    @test length(equations(sys)) == 7
end

@testitem "SulfurCycle - Steady State Values" begin
    using EnvironmentalTransport
    using ModelingToolkit
    using NonlinearSolve

    sys = SulfurCycle()
    sys_c = mtkcompile(sys)

    # Provide initial guesses for unknowns (in seconds, will be converted to hours for validation)
    u0 = Dict(
        sys_c.τ_SO2 => 90000.0,   # ~25 hours in seconds
        sys_c.τ_SO4 => 240000.0,  # ~66 hours in seconds
        sys_c.b => 0.3,
        sys_c.τ_S => 165000.0,    # ~46 hours in seconds
        sys_c.c => 0.5,
        sys_c.τ_S_d => 432000.0,  # ~120 hours in seconds
        sys_c.τ_S_w => 324000.0,  # ~90 hours in seconds
    )

    prob = NonlinearProblem(sys_c, u0)
    sol = solve(prob)
    @test sol.retcode == SciMLBase.ReturnCode.Success

    # Extract values (convert from seconds to hours for validation)
    s_to_hr = 1 / 3600.0

    τ_SO2_val = sol[sys_c.τ_SO2] * s_to_hr
    τ_SO4_val = sol[sys_c.τ_SO4] * s_to_hr
    τ_S_val = sol[sys_c.τ_S] * s_to_hr
    b_val = sol[sys_c.b]
    c_val = sol[sys_c.c]

    # Validation targets from Rodhe 1978 (recalculated)
    # tau_SO2: 1/τ = 1/60 + 1/100 + 1/80 = 0.01667 + 0.01 + 0.0125 = 0.0392
    # τ_SO2 = 1/0.0392 ≈ 25.53 hours
    @test τ_SO2_val ≈ 25.53 rtol = 0.01

    # tau_SO4: 1/τ_SO4 = 1/400 + 1/80 = 0.0025 + 0.0125 = 0.015
    # τ_SO4 = 1/0.015 ≈ 66.67 hours
    @test τ_SO4_val ≈ 66.67 rtol = 0.01

    # b = τ_SO2 / τ_SO2_c = 25.53/80 ≈ 0.319
    @test b_val ≈ 0.319 rtol = 0.01

    # τ_S = τ_SO2 + b * τ_SO4 ≈ 25.53 + 0.319 * 66.67 ≈ 46.8 hours
    @test τ_S_val ≈ 46.8 rtol = 0.02
end

@testitem "CarbonCycle - Structural" begin
    using EnvironmentalTransport
    using ModelingToolkit

    sys = CarbonCycle()

    # 8 state variables (M1-M7 + G) + 3 auxiliary flux variables
    @test length(unknowns(sys)) == 11
    # Constants + parameters: Note parameters includes time-dependent Ff, Fd, Fr
    @test length(parameters(sys)) >= 3
    # 11 equations (8 ODEs + 3 flux definitions)
    @test length(equations(sys)) == 11
end

@testitem "CarbonCycle - Preindustrial Steady State" begin
    using EnvironmentalTransport
    using ModelingToolkit
    using OrdinaryDiffEqDefault

    sys = CarbonCycle()
    sys_c = mtkcompile(sys)

    # At preindustrial steady state with zero forcing, derivatives should be ~0
    # Run a short simulation from preindustrial ICs with Ff=Fd=Fr=0 (defaults)
    tspan = (0.0, 10.0)  # 10 years
    prob = ODEProblem(sys_c, [], tspan)
    sol = solve(prob, abstol=1e-10, reltol=1e-10)
    @test sol.retcode == SciMLBase.ReturnCode.Success

    # Final state should be very close to initial (steady state)
    M1_final = sol[sys_c.M1][end]
    M2_final = sol[sys_c.M2][end]
    M3_final = sol[sys_c.M3][end]
    M4_final = sol[sys_c.M4][end]
    M5_final = sol[sys_c.M5][end]
    M6_final = sol[sys_c.M6][end]
    G_final = sol[sys_c.G][end]

    # Check that state hasn't drifted significantly (< 1% change over 10 years)
    @test M1_final ≈ 612.0 rtol = 0.01
    @test M2_final ≈ 730.0 rtol = 0.01
    @test M3_final ≈ 140.0 rtol = 0.01
    @test M4_final ≈ 37000.0 rtol = 0.01
    @test M5_final ≈ 580.0 rtol = 0.01
    @test M6_final ≈ 1500.0 rtol = 0.01
    @test G_final ≈ 1.0 rtol = 0.01
end

@testitem "CarbonCycle - Response to Fossil Fuel Emissions" begin
    using EnvironmentalTransport
    using ModelingToolkit
    using OrdinaryDiffEqDefault

    sys = CarbonCycle()
    sys_c = mtkcompile(sys)

    # Apply constant fossil fuel emissions of 5 Pg C/yr
    # Use the newer merge syntax for parameter setting
    tspan = (0.0, 100.0)  # 100 years
    prob = ODEProblem(sys_c, merge(Dict(), Dict(sys_c.Ff => 5.0)), tspan)
    sol = solve(prob)
    @test sol.retcode == SciMLBase.ReturnCode.Success

    # Atmospheric carbon should increase
    M1_initial = sol[sys_c.M1][1]
    M1_final = sol[sys_c.M1][end]
    @test M1_final > M1_initial

    # Fossil fuel reservoir should decrease
    M7_initial = sol[sys_c.M7][1]
    M7_final = sol[sys_c.M7][end]
    @test M7_final < M7_initial
    @test M7_initial - M7_final ≈ 500.0 rtol = 0.01  # 5 Pg C/yr * 100 yr

    # Total carbon (including M7 source) should be conserved
    total_initial = M1_initial + sol[sys_c.M2][1] + sol[sys_c.M3][1] + sol[sys_c.M4][1] +
                    sol[sys_c.M5][1] + sol[sys_c.M6][1] + M7_initial
    total_final = M1_final + sol[sys_c.M2][end] + sol[sys_c.M3][end] + sol[sys_c.M4][end] +
                  sol[sys_c.M5][end] + sol[sys_c.M6][end] + M7_final

    @test total_initial ≈ total_final rtol = 1e-6
end

@testitem "CarbonCycle - Qualitative Response" begin
    using EnvironmentalTransport
    using ModelingToolkit
    using OrdinaryDiffEqDefault

    sys = CarbonCycle()
    sys_c = mtkcompile(sys)

    # Test that atmospheric CO2 increases with emissions
    tspan = (0.0, 50.0)
    prob = ODEProblem(sys_c, merge(Dict(), Dict(sys_c.Ff => 3.0)), tspan)
    sol = solve(prob)
    @test sol.retcode == SciMLBase.ReturnCode.Success

    # M1 should generally increase with constant emissions (not strictly monotonic due to transients)
    M1_initial = sol[sys_c.M1][1]
    M1_final = sol[sys_c.M1][end]
    @test M1_final > M1_initial

    # Ocean compartments should also increase (taking up some CO2)
    M2_final = sol[sys_c.M2][end]
    M3_final = sol[sys_c.M3][end]
    @test M2_final > 730.0  # Warm ocean should absorb some CO2
    @test M3_final > 140.0  # Cool ocean should absorb some CO2
end

@testitem "FourCompartmentAtmosphere - Structural" begin
    using EnvironmentalTransport
    using ModelingToolkit

    sys = FourCompartmentAtmosphere()

    # 6 variables: Q_T_NH, Q_T_SH, Q_S_NH, Q_S_SH, Q_total, τ_atm
    @test length(unknowns(sys)) == 6
    # 14 parameters
    @test length(parameters(sys)) == 14
    # 6 equations (4 balance equations + 2 definitions)
    @test length(equations(sys)) == 6
end

@testitem "FourCompartmentAtmosphere - Equation Structure" begin
    using EnvironmentalTransport
    using ModelingToolkit

    sys = FourCompartmentAtmosphere()

    # Check that equations are properly formed algebraic equations
    eqs = equations(sys)

    # Equations 1-4 should be steady-state balances (0 ~ ...)
    # Equations 5-6 should be definitions for Q_total and τ_atm
    balance_eqs = filter(eq -> string(eq.lhs) == "0", eqs)
    @test length(balance_eqs) == 4  # 4 compartment balance equations

    # Check that each compartment variable appears in the equations
    vars = unknowns(sys)
    var_names = Set([string(v) for v in vars])
    @test "Q_T_NH(t)" in var_names
    @test "Q_T_SH(t)" in var_names
    @test "Q_S_NH(t)" in var_names
    @test "Q_S_SH(t)" in var_names
    @test "Q_total(t)" in var_names
    @test "τ_atm(t)" in var_names
end

@testitem "FourCompartmentAtmosphere - Parameter Count" begin
    using EnvironmentalTransport
    using ModelingToolkit

    sys = FourCompartmentAtmosphere()

    # Check that we have the expected number of parameters
    ps = parameters(sys)
    @test length(ps) == 14

    # Parameter names should include exchange rates, removal rates, and sources
    param_names = Set([string(p) for p in ps])
    @test "k_T_NH_SH" in param_names
    @test "k_T_SH_NH" in param_names
    @test "k_S_NH_SH" in param_names
    @test "P_NH" in param_names
    @test "P_SH" in param_names
end
