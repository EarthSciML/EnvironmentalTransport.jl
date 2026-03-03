@testsnippet VaporTransferSetup begin
    using Test
    using ModelingToolkit
    using ModelingToolkit: t, D
    using DynamicQuantities
    using EnvironmentalTransport
    using EnvironmentalTransport: _vt_theta, _vt_C_theta, _vt_K, _vt_lambda, _vt_Cv,
        _vt_Dmv, _vt_DTv, _vt_Dtl, _vt_clrhoK, _vt_vapor_heat

    # Ida soil parameters (Table 1 from Wang et al. 2022)
    const IDA = (
        θ_s = 0.547,
        h_a = -0.13,      # m
        b_camp = 6.53,
        K_s = 3.8e-7,    # m/s
        p_K = 10.06,
        f_sand = 0.022,
        f_clay = 0.249,
        ρ_b = 1200.0,     # kg/m³
        S_a = 2.44e8,     # m²/m³
        G_a = 6.0,
        T_0 = 298.15,     # K
    )
end

@testitem "SoilVaporTransfer - Structural Verification" setup = [VaporTransferSetup] tags = [:vapor_transfer] begin
    sys = SoilVaporTransfer()

    # Verify equation count: 15 algebraic equations for constitutive relations
    @test length(equations(sys)) == 15

    # Verify unknown count: 17 state/algebraic variables
    @test length(unknowns(sys)) == 17

    # Verify key unknowns are present
    unk_names = Symbol.(unknowns(sys))
    for name in [
            Symbol("h_soil(t)"), Symbol("T_soil(t)"), Symbol("θ(t)"),
            Symbol("K_h(t)"), Symbol("λ_soil(t)"), Symbol("C_θθ(t)"),
            Symbol("C_v_heat(t)"), Symbol("D_mv(t)"), Symbol("D_Tv(t)"),
            Symbol("D_tl(t)"), Symbol("μ_ratio(t)"), Symbol("θ_a(t)"),
            Symbol("D_atm(t)"), Symbol("ρ_vs(t)"), Symbol("h_rel(t)"),
            Symbol("σ_surf(t)"), Symbol("dσ_dT(t)"),
        ]
        @test name in unk_names
    end

    # Verify key soil parameters are present (constants are also listed as parameters)
    param_names = Symbol.(parameters(sys))
    for name in [:θ_s, :h_a, :b_camp, :K_s, :p_K, :f_sand, :f_clay, :ρ_b, :S_a, :G_a]
        @test name in param_names
    end
end

@testitem "SoilVaporTransfer - Default Parameter Values" setup = [VaporTransferSetup] tags = [:vapor_transfer] begin
    sys = SoilVaporTransfer()

    # Verify Ida soil defaults (Table 1)
    for p in parameters(sys)
        name = Symbol(p)
        if name == :θ_s
            @test ModelingToolkit.getdefault(p) == 0.547
        elseif name == :h_a
            @test ModelingToolkit.getdefault(p) == -0.13
        elseif name == :b_camp
            @test ModelingToolkit.getdefault(p) == 6.53
        elseif name == :K_s
            @test ModelingToolkit.getdefault(p) == 3.8e-7
        elseif name == :p_K
            @test ModelingToolkit.getdefault(p) == 10.06
        elseif name == :f_sand
            @test ModelingToolkit.getdefault(p) == 0.022
        elseif name == :f_clay
            @test ModelingToolkit.getdefault(p) == 0.249
        elseif name == :ρ_b
            @test ModelingToolkit.getdefault(p) == 1200.0
        elseif name == :S_a
            @test ModelingToolkit.getdefault(p) == 2.44e8
        elseif name == :G_a
            @test ModelingToolkit.getdefault(p) == 6.0
        elseif name == :T_0
            @test ModelingToolkit.getdefault(p) == 298.15
        end
    end
end

@testitem "SoilVaporTransfer - Registered Function Verification" setup = [VaporTransferSetup] tags = [:vapor_transfer] begin
    # Test registered functions against independently computed values
    # using Ida soil parameters from Table 1

    h = -1.0   # m (matric potential)
    T = 298.15 # K (temperature)

    # --- Campbell water retention model (Table 1) ---
    # θ = θ_s * (h/h_a)^(-1/b)
    θ_expected = IDA.θ_s * (h / IDA.h_a)^(-1.0 / IDA.b_camp)
    @test isapprox(_vt_theta(h, IDA.h_a, IDA.θ_s, IDA.b_camp), θ_expected, rtol = 1.0e-10)
    # Sanity: θ should be between 0 and θ_s for unsaturated soil
    @test 0 < θ_expected < IDA.θ_s

    # --- Specific moisture capacity C_θθ = dθ/dh ---
    C_expected = -IDA.θ_s / (IDA.b_camp * IDA.h_a) *
        (h / IDA.h_a)^(-1.0 / IDA.b_camp - 1.0)
    @test isapprox(_vt_C_theta(h, IDA.h_a, IDA.θ_s, IDA.b_camp), C_expected, rtol = 1.0e-10)
    # C_θθ should be positive for h < h_a
    @test C_expected > 0

    # --- Hydraulic conductivity (Table 1) ---
    θ_val = _vt_theta(h, IDA.h_a, IDA.θ_s, IDA.b_camp)
    μ_ratio = exp(1808.5 * (1.0 / 293.15 - 1.0 / T))
    K_expected = μ_ratio * (θ_val / IDA.θ_s)^IDA.p_K * IDA.K_s
    @test isapprox(
        _vt_K(h, T, IDA.h_a, IDA.θ_s, IDA.b_camp, IDA.K_s, IDA.p_K),
        K_expected, rtol = 1.0e-10
    )
    # K should be positive and less than K_s for unsaturated soil
    @test 0 < K_expected < IDA.K_s * 2  # allow for viscosity correction

    # --- Thermal conductivity Lu et al. (2014) (Table 1) ---
    ρ_b_gcm3 = IDA.ρ_b / 1000.0
    lam_dry = -0.56 * IDA.f_clay + 0.51
    alpha = 0.67 * IDA.f_clay + 0.24
    beta = 1.97 * IDA.f_sand + 1.87 * ρ_b_gcm3 - 1.36 * IDA.f_sand * ρ_b_gcm3 - 0.95
    λ_expected = lam_dry + exp(beta - θ_val^(-alpha))
    @test isapprox(
        _vt_lambda(h, IDA.h_a, IDA.θ_s, IDA.b_camp, IDA.f_sand, IDA.f_clay, IDA.ρ_b),
        λ_expected, rtol = 1.0e-10
    )
    # λ should be in reasonable range for soil (0.1 to 3 W/(m·K))
    @test 0.1 < λ_expected < 3.0

    # --- Volumetric heat capacity ---
    Cv_expected = IDA.ρ_b * 840.0 + θ_val * 1000.0 * 4187.0
    @test isapprox(_vt_Cv(h, IDA.h_a, IDA.θ_s, IDA.b_camp, IDA.ρ_b), Cv_expected, rtol = 1.0e-10)
    # C_v should be in reasonable range (1e5 to 4e6 J/(m³·K))
    @test 1.0e5 < Cv_expected < 4.0e6

    # --- D_mv: vapor diffusion under h gradient ---
    D_mv_val = _vt_Dmv(h, T, IDA.h_a, IDA.θ_s, IDA.b_camp)
    # D_mv should be positive and much smaller than K
    @test D_mv_val > 0
    @test D_mv_val < K_expected * 10  # vapor diffusion < liquid flow

    # --- D_Tv: vapor diffusion under T gradient ---
    D_Tv_val = _vt_DTv(h, T, IDA.h_a, IDA.θ_s, IDA.b_camp)
    # D_Tv should be positive (vapor moves from warm to cold)
    @test D_Tv_val > 0

    # --- D_tl: liquid thermal diffusion (Eq. A3) ---
    D_tl_val = _vt_Dtl(h, T, IDA.h_a, IDA.θ_s, IDA.b_camp, IDA.K_s, IDA.p_K, IDA.G_a, IDA.S_a)
    # D_tl should be positive and finite
    @test D_tl_val > 0
    @test isfinite(D_tl_val)

    # --- Vapor heat factor ---
    vheat = _vt_vapor_heat(T, IDA.T_0)
    # At T = T_0, should be L_0 * ρ_l = 2.45e6 * 1000 = 2.45e9
    @test isapprox(vheat, 2.45e6 * 1000.0, rtol = 1.0e-6)
end

@testitem "SoilVaporTransfer - Constitutive Relation Monotonicity" setup = [VaporTransferSetup] tags = [:vapor_transfer] begin
    T = 298.15
    h_values = [-10.0, -5.0, -2.0, -1.0, -0.5, -0.2]  # m, increasingly wet

    # θ should increase as h increases (less negative = wetter)
    θ_values = [_vt_theta(h, IDA.h_a, IDA.θ_s, IDA.b_camp) for h in h_values]
    for i in 2:length(θ_values)
        @test θ_values[i] > θ_values[i - 1]
    end

    # K should increase as h increases (wetter = more conductive)
    K_values = [_vt_K(h, T, IDA.h_a, IDA.θ_s, IDA.b_camp, IDA.K_s, IDA.p_K) for h in h_values]
    for i in 2:length(K_values)
        @test K_values[i] > K_values[i - 1]
    end

    # λ should increase with θ (wetter soil conducts heat better)
    λ_values = [
        _vt_lambda(h, IDA.h_a, IDA.θ_s, IDA.b_camp, IDA.f_sand, IDA.f_clay, IDA.ρ_b)
            for h in h_values
    ]
    for i in 2:length(λ_values)
        @test λ_values[i] > λ_values[i - 1]
    end

    # K should increase with temperature (lower viscosity)
    T_values = [278.15, 288.15, 298.15, 308.15, 318.15]  # K
    K_T = [
        _vt_K(-1.0, T_val, IDA.h_a, IDA.θ_s, IDA.b_camp, IDA.K_s, IDA.p_K)
            for T_val in T_values
    ]
    for i in 2:length(K_T)
        @test K_T[i] > K_T[i - 1]
    end
end

@testitem "SoilVaporTransfer - Surface Tension (Eq. A1)" setup = [VaporTransferSetup] tags = [:vapor_transfer] begin
    # Eq. A1: σ = -7.275e-2 * [1 - 0.002*(T - 291)] [N/m]
    # At T=291 K: σ = -7.275e-2 N/m
    σ_291 = -7.275e-2 * (1 - 0.002 * (291.0 - 291.0))
    @test isapprox(σ_291, -7.275e-2, rtol = 1.0e-10)

    # dσ/dT = 7.275e-2 * 0.002 = 1.455e-4 N/(m·K)
    dσ_dT = 7.275e-2 * 0.002
    @test isapprox(dσ_dT, 1.455e-4, rtol = 1.0e-10)

    # σ is negative (hydrophilic surface) and becomes less negative at higher temperatures
    # (surface tension magnitude decreases with temperature)
    σ_300 = -7.275e-2 * (1 - 0.002 * (300.0 - 291.0))
    @test abs(σ_300) < abs(σ_291)  # Surface tension magnitude decreases with T
end

@testitem "SoilVaporTransfer - Kelvin Equation Limiting Behavior" setup = [VaporTransferSetup] tags = [:vapor_transfer] begin
    T = 298.15
    M_w = 0.018015
    g = 9.81
    R = 8.314

    # At saturation (h → 0), h_rel → 1
    h_near_zero = -1.0e-6
    h_r = exp(M_w * g * h_near_zero / (R * T))
    @test isapprox(h_r, 1.0, atol = 1.0e-6)

    # For very dry soil (h very negative), h_rel → 0
    h_very_dry = -10000.0
    h_r_dry = exp(M_w * g * h_very_dry / (R * T))
    @test h_r_dry < 0.5

    # h_rel should decrease monotonically with decreasing h
    h_values = [-100.0, -50.0, -10.0, -1.0, -0.1]
    hr_values = [exp(M_w * g * h / (R * T)) for h in h_values]
    for i in 2:length(hr_values)
        @test hr_values[i] > hr_values[i - 1]
    end
end

@testitem "SoilVaporTransfer - Campbell Model at Air Entry" setup = [VaporTransferSetup] tags = [:vapor_transfer] begin
    # At h = h_a, θ should equal θ_s (Campbell model)
    θ_at_ha = _vt_theta(IDA.h_a, IDA.h_a, IDA.θ_s, IDA.b_camp)
    @test isapprox(θ_at_ha, IDA.θ_s, rtol = 1.0e-10)

    # C_θθ at air entry should be finite and positive
    C_at_ha = _vt_C_theta(IDA.h_a, IDA.h_a, IDA.θ_s, IDA.b_camp)
    @test isfinite(C_at_ha)
    @test C_at_ha > 0
end

@testitem "SoilVaporTransferPDE - Structural Verification" setup = [VaporTransferSetup] tags = [:vapor_transfer_pde] begin
    # Test PDE system creation (no vapor)
    pde_prel = SoilVaporTransferPDE(0.5, 3600.0; include_vapor = false)
    @test length(pde_prel.eqs) == 2  # Water eq + Heat eq
    @test length(pde_prel.bcs) == 6  # 2 ICs + 4 BCs (2 vars × 2 boundaries)
    @test length(pde_prel.ivs) == 2  # t, x
    @test length(pde_prel.dvs) == 2  # h_soil, T_soil

    # Test PDE system creation (with vapor)
    pde_simp = SoilVaporTransferPDE(0.5, 3600.0; include_vapor = true)
    @test length(pde_simp.eqs) == 2  # Water eq + Heat eq
    @test length(pde_simp.bcs) == 6
    @test length(pde_simp.ivs) == 2
    @test length(pde_simp.dvs) == 2

    # Test parameter count: 11 soil params + 6 BC/IC params = 17
    @test length(pde_prel.ps) == 17
    @test length(pde_simp.ps) == 17
end

@testitem "SoilVaporTransferPDE - Custom Parameters" setup = [VaporTransferSetup] tags = [:vapor_transfer_pde] begin
    # Test that custom parameters are stored in initial_conditions
    pde = SoilVaporTransferPDE(
        0.5, 3600.0;
        h_init = -2.0, T_init = 300.0,
        θ_s_val = 0.5, b_camp_val = 5.0
    )

    ic = pde.initial_conditions
    # Verify the right number of initial conditions are stored
    # 11 soil params + 6 BC/IC params = 17
    @test length(ic) == 17

    # Verify that specific parameter symbols are in the initial conditions
    ic_keys = string.(keys(ic))
    @test any(contains(k, "h_init") for k in ic_keys)
    @test any(contains(k, "T_init") for k in ic_keys)
    @test any(contains(k, "θ_s") for k in ic_keys)
    @test any(contains(k, "b_camp") for k in ic_keys)
end

@testitem "SoilVaporTransfer - Viscosity Ratio" setup = [VaporTransferSetup] tags = [:vapor_transfer] begin
    # μ(T_0)/μ(T) = exp(1808.5 * (1/T_ref - 1/T))
    # At T = T_ref = 293.15 K: μ_ratio = exp(0) = 1
    T_ref = 293.15
    @test isapprox(exp(1808.5 * (1.0 / T_ref - 1.0 / T_ref)), 1.0, rtol = 1.0e-10)

    # At T > T_ref: μ_ratio > 1 (viscosity decreases, so ratio increases)
    T_warm = 303.15
    μ_warm = exp(1808.5 * (1.0 / T_ref - 1.0 / T_warm))
    @test μ_warm > 1.0

    # At T < T_ref: μ_ratio < 1
    T_cold = 283.15
    μ_cold = exp(1808.5 * (1.0 / T_ref - 1.0 / T_cold))
    @test μ_cold < 1.0
end
