@testsnippet GeneralCirculationSetup begin
    using Test
    using ModelingToolkit
    using ModelingToolkit: mtkcompile
    using EnvironmentalTransport
    using DynamicQuantities: @u_str
    using OrdinaryDiffEqDefault: solve
end

@testitem "GeneralCirculation - Structural Verification" setup=[GeneralCirculationSetup] tags=[:general_circulation] begin
    sys=GeneralCirculation()

    # Check that the system has the expected variables
    vars=unknowns(sys)
    var_names=Symbol.(vars)

    @test Symbol("f(t)") in var_names
    @test Symbol("v_tan(t)") in var_names
    @test Symbol("u_g(t)") in var_names
    @test Symbol("v_g(t)") in var_names
    @test Symbol("du_g_dz(t)") in var_names
    @test Symbol("dv_g_dz(t)") in var_names

    # Check that we have 6 equations (one for each variable)
    eqs=equations(sys)
    @test length(eqs) == 6
end

@testitem "GeneralCirculation - Coriolis Parameter (Eq. 21.2)" setup=[GeneralCirculationSetup] tags=[:general_circulation] begin
    sys=GeneralCirculation()
    sys_c=mtkcompile(sys)

    # Earth's angular velocity
    Omega=7.2921e-5  # rad/s

    # Test Coriolis parameter at different latitudes
    # f = 2Ω sin(φ)
    test_cases=[
        (0.0, 0.0),           # Equator: f = 0
        (π/6, 7.2921e-5),   # 30°N: f = Ω
        (π/4, 1.0313e-4),   # 45°N: f ≈ √2 * Ω
        (π/2, 1.4584e-4),   # 90°N (pole): f = 2Ω
        (-π/4, -1.0313e-4) # 45°S: f < 0
    ]

    for (lat_rad, expected_f) in test_cases
        prob=ODEProblem(sys_c, [], (0.0, 1.0), [sys_c.lat=>lat_rad])
        sol=solve(prob, saveat = [0.0])
        computed_f=sol[sys_c.f][1]
        @test isapprox(computed_f, expected_f, rtol = 1e-3)
    end
end

@testitem "GeneralCirculation - Tangential Speed (Eq. 21.1)" setup=[GeneralCirculationSetup] tags=[:general_circulation] begin
    sys=GeneralCirculation()
    sys_c=mtkcompile(sys)

    # Earth parameters
    Omega=7.2921e-5  # rad/s
    R_earth=6.371e6  # m
    v_equator=Omega*R_earth  # ≈ 464.5 m/s

    # Test tangential speed at different latitudes
    # v = Ω R cos(φ)
    test_cases=[
        (0.0, v_equator),                  # Equator: maximum speed
        (π/6, v_equator*cos(π/6)),   # 30°
        (π/4, v_equator*cos(π/4)),   # 45°
        (π/2, 0.0)                      # 90°N (pole): v = 0
    ]

    for (lat_rad, expected_v) in test_cases
        prob=ODEProblem(sys_c, [], (0.0, 1.0), [sys_c.lat=>lat_rad])
        sol=solve(prob, saveat = [0.0])
        computed_v_tan=sol[sys_c.v_tan][1]
        # Use atol for comparison when expected is zero (e.g., at the pole)
        if expected_v==0.0
            @test isapprox(computed_v_tan, expected_v, atol = 1e-10)
        else
            @test isapprox(computed_v_tan, expected_v, rtol = 1e-2)
        end
    end
end

@testitem "GeneralCirculation - Geostrophic Wind (Eq. 21.14)" setup=[GeneralCirculationSetup] tags=[:general_circulation] begin
    sys=GeneralCirculation()
    sys_c=mtkcompile(sys)

    # Test case from book (Problem 21.1A, p. 1000):
    # At 40°N, pressure decreases 400 Pa over 200 km from south to north
    # dp/dy = -400 Pa / 200000 m = -0.002 Pa/m

    lat_40N=deg2rad(40.0)
    dp_dy=-0.002  # Pa/m (pressure decreases northward)
    rho=1.0  # kg/m³ (approximate)

    # Coriolis parameter at 40°N
    Omega=7.2921e-5
    f_40N=2*Omega*sin(lat_40N)

    prob=ODEProblem(sys_c, [], (0.0, 1.0),
        [
            sys_c.lat=>lat_40N,
            sys_c.dp_dy=>dp_dy,
            sys_c.dp_dx=>0.0,
            sys_c.rho=>rho
        ])
    sol=solve(prob, saveat = [0.0])

    # Geostrophic wind: u_g = -dp_dy / (ρf)
    expected_u_g=-dp_dy/(rho*f_40N)
    computed_u_g=sol[sys_c.u_g][1]

    # Should be a westerly (positive u) wind since pressure decreases northward
    @test computed_u_g > 0  # Westerly wind
    @test isapprox(computed_u_g, expected_u_g, rtol = 1e-6)

    # v_g should be zero since dp_dx = 0
    @test isapprox(sol[sys_c.v_g][1], 0.0, atol = 1e-10)
end

@testitem "GeneralCirculation - Thermal Wind (Eq. 21.22)" setup=[GeneralCirculationSetup] tags=[:general_circulation] begin
    sys=GeneralCirculation()
    sys_c=mtkcompile(sys)

    # Test case from book example (pp. 995-996):
    # Temperature decreases 4°C per 100 km eastward
    # dT/dx = -4 K / 100000 m = -4e-5 K/m
    # f = 10^-4 s^-1

    dT_dx=-4e-5  # K/m
    dT_dy=0.0  # K/m
    f_test=1e-4  # s^-1
    T=248.0  # K (mean temperature)
    g=9.8  # m/s^2

    # Find latitude where f ≈ 1e-4
    # f = 2Ω sin(φ), so φ = arcsin(f/(2Ω))
    Omega=7.2921e-5
    lat_rad=asin(f_test/(2*Omega))

    prob=ODEProblem(sys_c, [], (0.0, 1.0),
        [
            sys_c.lat=>lat_rad,
            sys_c.dT_dx=>dT_dx,
            sys_c.dT_dy=>dT_dy,
            sys_c.T=>T
        ])
    sol=solve(prob, saveat = [0.0])

    computed_f=sol[sys_c.f][1]
    @test isapprox(computed_f, f_test, rtol = 0.01)

    # Thermal wind: dv_g/dz = (g/fT)(dT/dx)
    expected_dv_g_dz=(g/(computed_f*T))*dT_dx
    computed_dv_g_dz=sol[sys_c.dv_g_dz][1]

    @test isapprox(computed_dv_g_dz, expected_dv_g_dz, rtol = 1e-3)

    # du_g/dz should be zero since dT_dy = 0
    @test isapprox(sol[sys_c.du_g_dz][1], 0.0, atol = 1e-10)
end

@testitem "GeneralCirculation - Physical Consistency" setup=[GeneralCirculationSetup] tags=[:general_circulation] begin
    sys=GeneralCirculation()
    sys_c=mtkcompile(sys)

    # Test that Coriolis parameter has correct sign in both hemispheres
    # Northern Hemisphere: f > 0
    prob_NH=ODEProblem(sys_c, [], (0.0, 1.0), [sys_c.lat=>deg2rad(45.0)])
    sol_NH=solve(prob_NH, saveat = [0.0])
    @test sol_NH[sys_c.f][1] > 0

    # Southern Hemisphere: f < 0
    prob_SH=ODEProblem(sys_c, [], (0.0, 1.0), [sys_c.lat=>deg2rad(-45.0)])
    sol_SH=solve(prob_SH, saveat = [0.0])
    @test sol_SH[sys_c.f][1] < 0

    # Magnitude should be the same
    @test isapprox(abs(sol_NH[sys_c.f][1]), abs(sol_SH[sys_c.f][1]), rtol = 1e-10)
end

@testitem "GeneralCirculation - Buys Ballot's Law" setup=[GeneralCirculationSetup] tags=[:general_circulation] begin
    # Buys Ballot's Law: In NH, low pressure is on the left when facing downwind
    # This means: if pressure decreases northward (dp/dy < 0), wind blows eastward (u_g > 0)

    sys=GeneralCirculation()
    sys_c=mtkcompile(sys)

    lat_45N=deg2rad(45.0)

    # Case 1: Pressure decreases northward -> eastward (westerly) wind
    prob1=ODEProblem(sys_c, [], (0.0, 1.0),
        [
            sys_c.lat=>lat_45N,
            sys_c.dp_dy=>-0.001,  # Pressure decreases northward
            sys_c.dp_dx=>0.0,
            sys_c.rho=>1.0
        ])
    sol1=solve(prob1, saveat = [0.0])
    @test sol1[sys_c.u_g][1] > 0  # Westerly (from west, blowing east)

    # Case 2: Pressure decreases eastward -> northward wind
    prob2=ODEProblem(sys_c, [], (0.0, 1.0),
        [
            sys_c.lat=>lat_45N,
            sys_c.dp_dy=>0.0,
            sys_c.dp_dx=>-0.001,  # Pressure decreases eastward
            sys_c.rho=>1.0
        ])
    sol2=solve(prob2, saveat = [0.0])
    @test sol2[sys_c.v_g][1] < 0  # Southerly wind (from south, blowing north would be positive v)
    # Actually: v_g = dp_dx / (ρf), if dp_dx < 0 and f > 0, then v_g < 0
end

@testitem "GeneralCirculation - Units Consistency" setup=[GeneralCirculationSetup] tags=[:general_circulation] begin
    sys=GeneralCirculation()

    # Check that variables have correct units
    vars=unknowns(sys)

    for v in vars
        unit=ModelingToolkit.get_unit(v)
        name=Symbol(v)
        if name==Symbol("f(t)")
            @test unit == u"s^-1"
        elseif name in [Symbol("v_tan(t)"), Symbol("u_g(t)"), Symbol("v_g(t)")]
            @test unit == u"m/s"
        elseif name in [Symbol("du_g_dz(t)"), Symbol("dv_g_dz(t)")]
            @test unit == u"s^-1"
        end
    end
end
