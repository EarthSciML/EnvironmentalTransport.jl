@testsnippet SurfaceRunoffSetup begin
    using EarthSciMLBase
    using ModelingToolkit
    using ModelingToolkit: t
    using OrdinaryDiffEqDefault
    using DynamicQuantities
    using EnvironmentalTransport
end

# =============================================================================
# SurfaceRunoff Component Tests
# =============================================================================

@testitem "SurfaceRunoff - Structural Verification" setup = [SurfaceRunoffSetup] tags = [:surface_runoff] begin
    sys = SurfaceRunoff()

    # Verify equation count: mass conservation + momentum conservation + friction slope
    @test length(equations(sys)) == 3

    # Verify unknowns
    unk_names = Symbol.(unknowns(sys))
    @test Symbol("h̃(t)") in unk_names  # flow depth
    @test Symbol("q(t)") in unk_names   # runoff flux
    @test Symbol("S_f(t)") in unk_names # friction slope

    # Verify key parameters exist (time-dependent params have "(t)" in symbol name)
    param_names = Symbol.(parameters(sys))
    @test Symbol("P(t)") in param_names          # precipitation
    @test Symbol("I_infil(t)") in param_names    # infiltration
    @test :S_0 in param_names                    # surface slope
    @test :n_mann in param_names                 # Manning coefficient
    @test :h̃_0 in param_names                   # minimum flow depth
    @test Symbol("dqdl(t)") in param_names       # spatial derivative of q
    @test Symbol("dFdl(t)") in param_names       # spatial derivative of momentum flux
end

@testitem "SurfaceRunoff - Compilation" setup = [SurfaceRunoffSetup] tags = [:surface_runoff] begin
    sys = SurfaceRunoff()
    csys = mtkcompile(sys)

    # After compilation, S_f should be eliminated (algebraic), leaving h̃ and q as states
    state_names = Symbol.(unknowns(csys))
    @test Symbol("h̃(t)") in state_names
    @test Symbol("q(t)") in state_names
    @test length(unknowns(csys)) == 2
end

@testitem "SurfaceRunoff - Mass Conservation (no spatial flux)" setup = [SurfaceRunoffSetup] tags = [:surface_runoff] begin
    # Test: with dqdl=0, dFdl=0, the mass equation reduces to dh̃/dt = P - I
    # For P > I, h̃ should increase linearly
    sys = SurfaceRunoff()
    csys = mtkcompile(sys)

    P_val = 1.0e-6  # m/s (~3.6 mm/hr)
    I_val = 0.0

    prob = ODEProblem(
        csys,
        merge(
            Dict(csys.h̃ => 1.0e-5, csys.q => 0.0),
            Dict(
                csys.P => P_val,
                csys.I_infil => I_val,
                csys.S_0 => 0.0,       # flat surface to minimize momentum effects
                csys.n_mann => 1.0,     # high friction to damp momentum
                csys.h̃_0 => 1.0e-5,
                csys.dqdl => 0.0,
                csys.dFdl => 0.0
            )
        ),
        (0.0, 10.0)
    )

    sol = solve(prob)
    @test sol.retcode == SciMLBase.ReturnCode.Success

    # h̃ should increase linearly: h̃(t) = h̃_0 + (P - I)*t
    for i in eachindex(sol.t)
        expected_h = 1.0e-5 + P_val * sol.t[i]
        @test isapprox(sol[csys.h̃][i], expected_h, rtol = 0.01)
    end
end

@testitem "SurfaceRunoff - Friction Slope Steady State" setup = [SurfaceRunoffSetup] tags = [:surface_runoff] begin
    # At steady state with S_0 = S_f, dq/dt = 0 (ignoring spatial terms)
    # Manning's equation: S_f = (n*q)^2 / h^(10/3)
    # At equilibrium S_0 = S_f => q_eq = sqrt(S_0) * h^(5/3) / n
    # Verify this relationship holds for computed S_f

    sys = SurfaceRunoff()
    csys = mtkcompile(sys)

    h_val = 0.01   # 1 cm flow depth
    S_0_val = 0.01  # 1% slope
    n_val = 0.03    # Manning coefficient in SI

    # Compute equilibrium q from Manning's equation
    q_eq = sqrt(S_0_val) * h_val^(5 / 3) / n_val

    # Start near equilibrium
    prob = ODEProblem(
        csys,
        merge(
            Dict(csys.h̃ => h_val, csys.q => q_eq),
            Dict(
                csys.P => 0.0,
                csys.I_infil => 0.0,
                csys.S_0 => S_0_val,
                csys.n_mann => n_val,
                csys.h̃_0 => 1.0e-7,
                csys.dqdl => 0.0,
                csys.dFdl => 0.0
            )
        ),
        (0.0, 0.01)
    )

    sol = solve(prob)

    # At equilibrium, S_f should equal S_0
    S_f_val = sol[csys.S_f][1]
    @test isapprox(S_f_val, S_0_val, rtol = 1.0e-6)
end

@testitem "SurfaceRunoff - Qualitative: Precipitation increases water depth" setup = [SurfaceRunoffSetup] tags = [:surface_runoff] begin
    sys = SurfaceRunoff()
    csys = mtkcompile(sys)

    prob = ODEProblem(
        csys,
        merge(
            Dict(csys.h̃ => 1.0e-4, csys.q => 0.0),
            Dict(
                csys.P => 2.0e-6,         # rainfall
                csys.I_infil => 1.0e-6,   # infiltration < rainfall
                csys.S_0 => 0.0,        # flat surface
                csys.n_mann => 1.0,
                csys.h̃_0 => 1.0e-5,
                csys.dqdl => 0.0,
                csys.dFdl => 0.0
            )
        ),
        (0.0, 10.0)
    )

    sol = solve(prob)
    @test sol.retcode == SciMLBase.ReturnCode.Success

    # Water depth should increase when P > I
    @test sol[csys.h̃][end] > sol[csys.h̃][1]
end

@testitem "SurfaceRunoff - Qualitative: Infiltration decreases water depth" setup = [SurfaceRunoffSetup] tags = [:surface_runoff] begin
    sys = SurfaceRunoff()
    csys = mtkcompile(sys)

    prob = ODEProblem(
        csys,
        merge(
            Dict(csys.h̃ => 0.01, csys.q => 0.0),
            Dict(
                csys.P => 0.0,           # no rainfall
                csys.I_infil => 1.0e-6,    # infiltration drains water
                csys.S_0 => 0.0,         # flat surface
                csys.n_mann => 1.0,
                csys.h̃_0 => 1.0e-5,
                csys.dqdl => 0.0,
                csys.dFdl => 0.0
            )
        ),
        (0.0, 100.0)
    )

    sol = solve(prob)
    @test sol.retcode == SciMLBase.ReturnCode.Success

    # Water depth should decrease when I > P
    @test sol[csys.h̃][end] < sol[csys.h̃][1]
end

@testitem "SurfaceRunoff - Manning friction slope formula" setup = [SurfaceRunoffSetup] tags = [:surface_runoff] begin
    # Verify the friction slope formula against analytical values
    # S_f = (n*q)^2 / h^(10/3)
    sys = SurfaceRunoff()
    csys = mtkcompile(sys)

    test_cases = [
        (h = 0.01, q = 1.0e-4, n = 0.03),
        (h = 0.05, q = 1.0e-3, n = 0.01),
        (h = 0.1, q = 5.0e-3, n = 0.05),
    ]

    for tc in test_cases
        expected_Sf = (tc.n * tc.q)^2 / tc.h^(10 / 3)

        prob = ODEProblem(
            csys,
            merge(
                Dict(csys.h̃ => tc.h, csys.q => tc.q),
                Dict(
                    csys.P => 0.0,
                    csys.I_infil => 0.0,
                    csys.S_0 => 0.01,
                    csys.n_mann => tc.n,
                    csys.h̃_0 => 1.0e-7,
                    csys.dqdl => 0.0,
                    csys.dFdl => 0.0
                )
            ),
            (0.0, 0.001)
        )

        sol = solve(prob)
        S_f_computed = sol[csys.S_f][1]
        @test isapprox(S_f_computed, expected_Sf, rtol = 1.0e-6)
    end
end

# =============================================================================
# HeavisideBoundaryCondition Component Tests
# =============================================================================

@testitem "HeavisideBoundaryCondition - Structural Verification" setup = [SurfaceRunoffSetup] tags = [:surface_runoff] begin
    hbc = HeavisideBoundaryCondition()

    # Verify equation count: η_ω + δ_ω + boundary condition ODE
    @test length(equations(hbc)) == 3

    # Verify unknowns
    unk_names = Symbol.(unknowns(hbc))
    @test Symbol("h(t)") in unk_names
    @test Symbol("η_ω(t)") in unk_names
    @test Symbol("δ_ω(t)") in unk_names

    # Verify parameters (time-dependent params have "(t)" in symbol name)
    param_names = Symbol.(parameters(hbc))
    @test :ω in param_names
    @test Symbol("P(t)") in param_names
    @test Symbol("I_infil(t)") in param_names
end

@testitem "HeavisideBoundaryCondition - Compilation" setup = [SurfaceRunoffSetup] tags = [:surface_runoff] begin
    hbc = HeavisideBoundaryCondition()
    chbc = mtkcompile(hbc)

    # After compilation, η_ω and δ_ω should be eliminated (algebraic), leaving h as state
    @test length(unknowns(chbc)) == 1
    @test Symbol("h(t)") in Symbol.(unknowns(chbc))
end

@testitem "HeavisideBoundaryCondition - Smoothed Heaviside properties" setup = [SurfaceRunoffSetup] tags = [:surface_runoff] begin
    hbc = HeavisideBoundaryCondition()
    chbc = mtkcompile(hbc)

    # Test η_ω values at specific h values
    # η_ω(h=0) should be exactly 0.5
    prob = ODEProblem(
        chbc,
        merge(
            Dict(chbc.h => 0.0),
            Dict(chbc.P => 1.0e-6, chbc.I_infil => 0.0, chbc.ω => 1.0e-4)
        ),
        (0.0, 0.001)
    )
    sol = solve(prob)
    @test isapprox(sol[chbc.η_ω][1], 0.5, atol = 1.0e-10)

    # η_ω(h >> ω) should approach 1.0
    prob_pos = ODEProblem(
        chbc,
        merge(
            Dict(chbc.h => 1.0),
            Dict(chbc.P => 0.0, chbc.I_infil => 0.0, chbc.ω => 1.0e-4)
        ),
        (0.0, 0.001)
    )
    sol_pos = solve(prob_pos)
    @test isapprox(sol_pos[chbc.η_ω][1], 1.0, atol = 1.0e-3)

    # η_ω(h << -ω) should approach 0.0
    prob_neg = ODEProblem(
        chbc,
        merge(
            Dict(chbc.h => -1.0),
            Dict(chbc.P => 0.0, chbc.I_infil => 0.0, chbc.ω => 1.0e-4)
        ),
        (0.0, 0.001)
    )
    sol_neg = solve(prob_neg)
    @test isapprox(sol_neg[chbc.η_ω][1], 0.0, atol = 1.0e-3)
end

@testitem "HeavisideBoundaryCondition - Net positive flux increases head" setup = [SurfaceRunoffSetup] tags = [:surface_runoff] begin
    hbc = HeavisideBoundaryCondition()
    chbc = mtkcompile(hbc)

    # With P > I and h > 0 (ponding state), head should increase
    prob = ODEProblem(
        chbc,
        merge(
            Dict(chbc.h => 0.01),
            Dict(chbc.P => 2.0e-6, chbc.I_infil => 1.0e-6, chbc.ω => 1.0e-4)
        ),
        (0.0, 100.0)
    )
    sol = solve(prob)
    @test sol.retcode == SciMLBase.ReturnCode.Success
    @test sol[chbc.h][end] > sol[chbc.h][1]
end

@testitem "HeavisideBoundaryCondition - Transition from unsaturated to saturated" setup = [SurfaceRunoffSetup] tags = [:surface_runoff] begin
    # Start with h < 0 (unsaturated), apply precipitation.
    # Head should increase and eventually become positive (ponding).
    hbc = HeavisideBoundaryCondition()
    chbc = mtkcompile(hbc)

    prob = ODEProblem(
        chbc,
        merge(
            Dict(chbc.h => -0.05),
            Dict(chbc.P => 1.0e-5, chbc.I_infil => 0.0, chbc.ω => 1.0e-3)
        ),
        (0.0, 10000.0)
    )
    sol = solve(prob)
    @test sol.retcode == SciMLBase.ReturnCode.Success

    # h should transition from negative to positive
    @test sol[chbc.h][1] < 0
    @test sol[chbc.h][end] > 0
end

@testitem "HeavisideBoundaryCondition - Smoothed delta function" setup = [SurfaceRunoffSetup] tags = [:surface_runoff] begin
    # δ_ω should be maximum at h=0 and decrease away from h=0
    hbc = HeavisideBoundaryCondition()
    chbc = mtkcompile(hbc)

    ω_val = 1.0e-3

    # δ_ω at h=0 should be 1/(π*ω)
    prob_zero = ODEProblem(
        chbc,
        merge(
            Dict(chbc.h => 0.0),
            Dict(chbc.P => 0.0, chbc.I_infil => 0.0, chbc.ω => ω_val)
        ),
        (0.0, 0.001)
    )
    sol_zero = solve(prob_zero)
    expected_delta_max = 1.0 / (π * ω_val)
    @test isapprox(sol_zero[chbc.δ_ω][1], expected_delta_max, rtol = 1.0e-6)

    # δ_ω at h >> ω should approach 0
    prob_far = ODEProblem(
        chbc,
        merge(
            Dict(chbc.h => 1.0),
            Dict(chbc.P => 0.0, chbc.I_infil => 0.0, chbc.ω => ω_val)
        ),
        (0.0, 0.001)
    )
    sol_far = solve(prob_far)
    @test sol_far[chbc.δ_ω][1] < 0.01 * expected_delta_max
end

# =============================================================================
# SaintVenantPDE Tests
# =============================================================================

@testitem "SaintVenantPDE - Structural verification" setup = [SurfaceRunoffSetup] tags = [:surface_runoff] begin
    # Verify that SaintVenantPDE creates a well-formed PDESystem
    pde = SaintVenantPDE(0.5, 60.0)

    # Should have 3 equations: mass conservation, momentum conservation, auxiliary
    @test length(pde.eqs) == 3

    # Should have 3 dependent variables: h_tilde, q_flux, F_mom
    @test length(pde.dvs) == 3

    # Should have 11 parameters
    @test length(pde.ps) == 11

    # Should have 2 independent variables: t, l
    @test length(pde.ivs) == 2
end

@testitem "SaintVenantPDE - Custom parameters" setup = [SurfaceRunoffSetup] tags = [:surface_runoff] begin
    # Verify that custom parameters are correctly applied
    pde = SaintVenantPDE(
        1.0, 120.0;
        P_val = 1.0e-4,
        I_val = 5.0e-5,
        S_0_val = 0.02,
        n_manning_val = 0.05,
        h_init_val = 5.0e-3,
    )

    # Verify the defaults were set correctly
    defaults = pde.defaults
    ps_names = string.(pde.ps)
    # Find the P_rate parameter and check its default
    P_idx = findfirst(p -> contains(string(p), "P_rate"), pde.ps)
    @test !isnothing(P_idx)
    @test defaults[pde.ps[P_idx]] == 1.0e-4
end
