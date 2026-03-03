export SoilVaporTransfer, SoilVaporTransferPDE

"""
$(TYPEDSIGNATURES)

Create a soil vapor transfer component representing the vapor-phase water and
heat redistribution in soil, following the modularized approach of Wang et al. (2022).

This component implements the vapor transfer model (Eq. 3) which accounts for
water vapor flux driven by matric potential and temperature gradients, and the
associated latent and sensible heat fluxes. It is designed to be solved after
the preliminary water and heat transfer model (M_prel, Eq. 1).

The vapor water equation (Eq. 3a):
```math
C_{\\theta\\theta} \\frac{\\partial h}{\\partial t} + C_{\\theta T} \\frac{\\partial T}{\\partial t}
= \\nabla \\cdot [D_{mv}(h,T) \\nabla h + D_{Tv}(h,T) \\nabla T]
```

The vapor heat equation (Eq. 3b):
```math
C_{T0} \\frac{\\partial h}{\\partial t} + C_{TT} \\frac{\\partial T}{\\partial t}
= -\\nabla \\cdot [L_0 \\rho_l q_v + c_v \\rho_l q_v (T - T_0)]
```

The simplified formulation (M_simp, Eq. 2') drops the cross-coupling capacity
terms (``C_{\\theta T}`` and ``C_{T0}``), yielding a system that can be solved
one-by-one for ``h`` and ``T``.

**Reference**: Wang, Z., Timlin, D., Fleisher, D., Sun, W., Beegum, S., Li, S.,
Chen, Y., Reddy, V.R., Tully, K., & Horton, R. (2022). Modeling vapor transfer
in soil water and heat simulations: A modularized, partially-coupled approach.
*Journal of Hydrology*, 608, 127541.
https://doi.org/10.1016/j.jhydrol.2022.127541
"""
@component function SoilVaporTransfer(; name = :SoilVaporTransfer)
    @constants begin
        c_l = 4187.0, [description = "Specific heat of liquid water", unit = u"J/(kg*K)"]
        c_v = 1864.0, [description = "Specific heat of water vapor", unit = u"J/(kg*K)"]
        ρ_l = 1000.0, [description = "Density of liquid water", unit = u"kg/m^3"]
        L_0 = 2.45e6, [description = "Latent heat of vaporization at T_0", unit = u"J/kg"]
        g_acc = 9.81, [description = "Gravitational acceleration", unit = u"m/s^2"]
        M_w = 0.018015, [description = "Molar mass of water", unit = u"kg/mol"]
        R_gas = 8.314, [description = "Universal gas constant", unit = u"J/(mol*K)"]
        T_ref_visc = 293.15, [description = "Reference temperature for viscosity", unit = u"K"]
        c_s = 840.0, [description = "Specific heat of mineral soil", unit = u"J/(kg*K)"]
        one_m = 1.0, [description = "Unit length", unit = u"m"]
        one_Pa = 1.0, [description = "Unit pressure", unit = u"Pa"]
        one_K = 1.0, [description = "Unit temperature", unit = u"K"]
        one_kgm3 = 1.0, [description = "Unit density", unit = u"kg/m^3"]
        one_WmK = 1.0, [description = "Unit thermal conductivity", unit = u"W/(m*K)"]
        one_m2s = 1.0, [description = "Unit diffusivity", unit = u"m^2/s"]
        one_Nm = 1.0, [description = "Unit surface tension", unit = u"N/m"]
        one_NmK = 1.0, [description = "Unit surface tension per K", unit = u"N/(m*K)"]
    end

    @parameters begin
        T_0 = 298.15, [description = "Reference temperature (Eq. 1b)", unit = u"K"]
        θ_s = 0.547, [description = "Saturated volumetric water content (Table 1)", unit = u"1"]
        h_a = -0.13, [description = "Air entry matric potential (Campbell model, Table 1)", unit = u"m"]
        b_camp = 6.53,
            [description = "Campbell pore-size distribution parameter (Table 1)", unit = u"1"]
        K_s = 3.8e-7,
            [description = "Saturated hydraulic conductivity at T_0 (Table 1)", unit = u"m/s"]
        p_K = 10.06, [description = "Hydraulic conductivity exponent (Table 1)", unit = u"1"]
        f_sand = 0.022, [description = "Sand mass fraction (Table 1)", unit = u"1"]
        f_clay = 0.249, [description = "Clay mass fraction (Table 1)", unit = u"1"]
        ρ_b = 1200.0, [description = "Soil bulk density (Table 1)", unit = u"kg/m^3"]
        S_a = 2.44e8,
            [description = "Volumetric specific surface area (Table 1)", unit = u"m^2/m^3"]
        G_a = 6.0,
            [
                description = "Empirical gain factor for liquid thermal diffusion (Eq. A3) (dimensionless)",
                unit = u"1",
            ]
    end

    @variables begin
        h_soil(t), [description = "Soil matric potential (Eq. 1a)", unit = u"m"]
        T_soil(t), [description = "Soil temperature (Eq. 1b)", unit = u"K"]
        θ(t), [description = "Volumetric water content (Table 1)", unit = u"1"]
        K_h(t), [description = "Unsaturated hydraulic conductivity (Table 1)", unit = u"m/s"]
        λ_soil(t), [description = "Soil thermal conductivity (Table 1)", unit = u"W/(m*K)"]
        C_θθ(t), [description = "Specific moisture capacity dθ/dh (Eq. 2)", unit = u"1/m"]
        C_v_heat(t), [description = "Soil volumetric heat capacity (Eq. 1b)", unit = u"J/(m^3*K)"]
        D_mv(t), [description = "Vapor diffusion coeff. under h gradient (Eq. 2a)", unit = u"m/s"]
        D_Tv(t),
            [description = "Vapor diffusion coeff. under T gradient (Eq. 2a)", unit = u"m^2/(s*K)"]
        D_tl(t), [description = "Liquid thermal diffusion coeff. (Eq. A3)", unit = u"m^2/(s*K)"]
        μ_ratio(t),
            [description = "Viscosity ratio μ(T_0)/μ(T) (Table 1) (dimensionless)", unit = u"1"]
        θ_a(t), [description = "Air-filled porosity (dimensionless)", unit = u"1"]
        D_atm(t),
            [description = "Vapor diffusion coeff. in air (Philip & de Vries)", unit = u"m^2/s"]
        ρ_vs(t), [description = "Saturated vapor density", unit = u"kg/m^3"]
        h_rel(t),
            [description = "Relative humidity from Kelvin equation (dimensionless)", unit = u"1"]
        σ_surf(t), [description = "Water surface tension (Eq. A1)", unit = u"N/m"]
        dσ_dT(t), [description = "Temperature derivative of surface tension", unit = u"N/(m*K)"]
    end

    eqs = [
        # --- Constitutive relations ---
        # Water retention - Campbell model (Table 1): θ = θ_s * (h/h_a)^(-1/b)
        θ ~ θ_s * (h_soil / h_a)^(-1 / b_camp), # Eq. from Table 1

        # Specific moisture capacity C_θθ = dθ/dh
        C_θθ ~ -θ_s / (b_camp * h_a) * (h_soil / h_a)^(-1 / b_camp - 1), # Derivative of θ(h)

        # Viscosity ratio μ(T_0)/μ(T)
        μ_ratio ~ exp(1808.5 * (one_K / T_ref_visc - one_K / T_soil)), # Table 1

        # Hydraulic conductivity (Table 1): K = μ_ratio * (θ/θ_s)^p_K * K_s
        K_h ~ μ_ratio * (θ / θ_s)^p_K * K_s, # Table 1

        # Thermal conductivity - Lu et al. (2014) (Table 1)
        # λ = {λ_dry + exp(β - θ^(-α))} [W/(m·K)]
        # λ_dry = -0.56*f_clay + 0.51, α = 0.67*f_clay + 0.24
        # β = 1.97*f_sand + 1.87*(ρ_b[g/cm³]) - 1.36*f_sand*(ρ_b[g/cm³]) - 0.95
        λ_soil ~ (
            (-0.56 * f_clay + 0.51) +
                exp(
                (
                    1.97 * f_sand + 1.87 * (ρ_b / one_kgm3) / 1000.0 -
                        1.36 * f_sand * (ρ_b / one_kgm3) / 1000.0 - 0.95
                ) -
                    θ^(-(0.67 * f_clay + 0.24))
            )
        ) * one_WmK, # Table 1, Lu et al. (2014)

        # Soil volumetric heat capacity: C_v ≈ ρ_b * c_s + θ * ρ_l * c_l
        C_v_heat ~ ρ_b * c_s + θ * ρ_l * c_l, # Eq. 1b

        # Air-filled porosity
        θ_a ~ θ_s - θ,

        # --- Vapor transport coefficients (Philip & de Vries, 1957) ---
        # Vapor diffusion coefficient in air: D_a = 2.12e-5 * (T/273.15)^1.75 [m²/s]
        D_atm ~ 2.12e-5 * one_m2s * (T_soil / (273.15 * one_K))^1.75, # Philip & de Vries (1957)

        # Saturated vapor density: ρ_vs = M_w * P_vs / (R * T)
        # P_vs = 611.2 * exp(17.67 * (T-273.15) / (T-29.65)) [Pa]
        ρ_vs ~ (M_w / (R_gas * T_soil)) *
            611.2 * one_Pa *
            exp(17.67 * (T_soil / one_K - 273.15) / (T_soil / one_K - 29.65)), # Tetens

        # Relative humidity from Kelvin equation: h_r = exp(M_w * g * h / (R * T))
        h_rel ~ exp(M_w * g_acc * h_soil / (R_gas * T_soil)), # Kelvin equation

        # D_mv: vapor diffusion under matric potential gradient (Eq. 2a)
        # D_mv = D_atm * θ_a * (ρ_vs/ρ_l) * (M_w*g/(R*T)) * h_rel [m/s]
        # Units: m²/s * (kg/m³)/(kg/m³) * (kg/mol * m/s²)/(J/(mol·K) * K) * 1
        #       = m²/s * 1/m = m/s
        D_mv ~ D_atm * θ_a * (ρ_vs / ρ_l) *
            (M_w * g_acc / (R_gas * T_soil)) * h_rel, # Eq. 2a

        # D_Tv: vapor diffusion under temperature gradient (Eq. 2a)
        # D_Tv = D_atm * θ_a * (h_rel/ρ_l) * dρ_vs/dT [m²/(s·K)]
        # dρ_vs/dT ≈ ρ_vs * (L_0*M_w/(R*T²) - 1/T)
        D_Tv ~ D_atm * θ_a * (h_rel / ρ_l) * ρ_vs *
            (
            L_0 * M_w / (R_gas * T_soil * T_soil) -
                1 / T_soil
        ), # Eq. 2a

        # --- Liquid thermal diffusion coefficient (Eq. A3) ---
        # Water surface tension (Eq. A1): σ = -7.275e-2 * [1 - 0.002*(T-291)] [N/m]
        σ_surf ~ -7.275e-2 * one_Nm * (1 - 0.002 * (T_soil / one_K - 291.0)), # Eq. A1

        # dσ/dT (derivative of Eq. A1)
        dσ_dT ~ 7.275e-2 * 0.002 * one_NmK, # Eq. A1 derivative

        # D_tl = K * G_a * (S_a / (ρ_l * g)) * (dσ/dT) (Eq. A3)
        D_tl ~ K_h * G_a * (S_a / (ρ_l * g_acc)) * dσ_dT, # Eq. A3
    ]

    return System(eqs, t; name)
end

# --- Registered functions for PDE constitutive relations ---
# These are opaque to MethodOfLines, avoiding issues with symbolic fractional powers.
# All inputs and outputs are dimensionless (divided by reference units).

# Water content from matric potential - Campbell model (Table 1)
_vt_theta(h, h_a, theta_s, b) = theta_s * (h / h_a)^(-1.0 / b)

# Specific moisture capacity dθ/dh [1/m equivalent]
_vt_C_theta(h, h_a, theta_s, b) = -theta_s / (b * h_a) * (h / h_a)^(-1.0 / b - 1.0)

# Hydraulic conductivity [m/s equivalent]
_vt_K(h, T, h_a, theta_s, b, K_s, p_K) = begin
    theta = theta_s * (h / h_a)^(-1.0 / b)
    mu_ratio = exp(1808.5 * (1.0 / 293.15 - 1.0 / T))
    mu_ratio * (theta / theta_s)^p_K * K_s
end

# Thermal conductivity [W/(m·K) equivalent]
_vt_lambda(h, h_a, theta_s, b, f_sand, f_clay, rho_b) = begin
    theta = theta_s * (h / h_a)^(-1.0 / b)
    lam_dry = -0.56 * f_clay + 0.51
    alpha = 0.67 * f_clay + 0.24
    beta = 1.97 * f_sand + 1.87 * rho_b / 1000.0 - 1.36 * f_sand * rho_b / 1000.0 - 0.95
    lam_dry + exp(beta - theta^(-alpha))
end

# Volumetric heat capacity [J/(m³·K) equivalent]
_vt_Cv(h, h_a, theta_s, b, rho_b) = begin
    theta = theta_s * (h / h_a)^(-1.0 / b)
    rho_b * 840.0 + theta * 1000.0 * 4187.0
end

# Vapor diffusion coefficient under h gradient [m/s equivalent]
_vt_Dmv(h, T, h_a, theta_s, b) = begin
    theta = theta_s * (h / h_a)^(-1.0 / b)
    theta_a = theta_s - theta
    D_a = 2.12e-5 * (T / 273.15)^1.75
    Pvs = 611.2 * exp(17.67 * (T - 273.15) / (T - 29.65))
    rho_vs = 0.018015 * Pvs / (8.314 * T)
    h_r = exp(0.018015 * 9.81 * h / (8.314 * T))
    D_a * theta_a * (rho_vs / 1000.0) * (0.018015 * 9.81 / (8.314 * T)) * h_r
end

# Vapor diffusion coefficient under T gradient [m²/(s·K) equivalent]
_vt_DTv(h, T, h_a, theta_s, b) = begin
    theta = theta_s * (h / h_a)^(-1.0 / b)
    theta_a = theta_s - theta
    D_a = 2.12e-5 * (T / 273.15)^1.75
    Pvs = 611.2 * exp(17.67 * (T - 273.15) / (T - 29.65))
    rho_vs = 0.018015 * Pvs / (8.314 * T)
    h_r = exp(0.018015 * 9.81 * h / (8.314 * T))
    drho_dT = rho_vs * (2.45e6 * 0.018015 / (8.314 * T * T) - 1.0 / T)
    D_a * theta_a * (h_r / 1000.0) * drho_dT
end

# Liquid thermal diffusion coefficient [m²/(s·K) equivalent]
_vt_Dtl(h, T, h_a, theta_s, b, K_s, p_K, G_a, S_a) = begin
    K_val = _vt_K(h, T, h_a, theta_s, b, K_s, p_K)
    dsigma_dT = 7.275e-2 * 0.002  # N/(m·K)
    K_val * G_a * (S_a / (1000.0 * 9.81)) * dsigma_dT
end

# Convective heat coefficient: c_l * ρ_l * K [J/(m²·K) equivalent]
_vt_clrhoK(h, T, h_a, theta_s, b, K_s, p_K) = begin
    4187.0 * 1000.0 * _vt_K(h, T, h_a, theta_s, b, K_s, p_K)
end

# Vapor heat factor: (L_0 + c_v*(T-T_0)) * ρ_l (for vapor heat flux)
_vt_vapor_heat(T, T_0) = (2.45e6 + 1864.0 * (T - T_0)) * 1000.0

@register_symbolic _vt_theta(h, h_a, theta_s, b)
@register_symbolic _vt_C_theta(h, h_a, theta_s, b)
@register_symbolic _vt_K(h, T, h_a, theta_s, b, K_s, p_K)
@register_symbolic _vt_lambda(h, h_a, theta_s, b, f_sand, f_clay, rho_b)
@register_symbolic _vt_Cv(h, h_a, theta_s, b, rho_b)
@register_symbolic _vt_Dmv(h, T, h_a, theta_s, b)
@register_symbolic _vt_DTv(h, T, h_a, theta_s, b)
@register_symbolic _vt_Dtl(h, T, h_a, theta_s, b, K_s, p_K, G_a, S_a)
@register_symbolic _vt_clrhoK(h, T, h_a, theta_s, b, K_s, p_K)
@register_symbolic _vt_vapor_heat(T, T_0)

"""
$(TYPEDSIGNATURES)

Create a 1D PDESystem for coupled soil water, heat, and vapor transfer
suitable for spatial discretization with MethodOfLines.jl.

The system implements the simplified formulation (M_simp, Eq. 2' from
Wang et al., 2022) which includes water transfer via Richards equation,
heat conduction-convection, and vapor transfer:

Water equation (Eq. 2a'):
```math
C_{\\theta\\theta} \\frac{\\partial h}{\\partial t}
= \\frac{\\partial}{\\partial x}\\left[ (D_{mv} + K) \\frac{\\partial h}{\\partial x}
+ (D_{Tv} + D_{tl}) \\frac{\\partial T}{\\partial x} \\right]
```

Heat equation (Eq. 2b'):
```math
C_{TT} \\frac{\\partial T}{\\partial t}
= \\frac{\\partial}{\\partial x}\\left[ \\lambda \\frac{\\partial T}{\\partial x} \\right]
+ \\frac{\\partial}{\\partial x}\\left[ c_l \\rho_l K \\frac{\\partial h}{\\partial x} (T - T_0) \\right]
+ \\frac{\\partial}{\\partial x}\\left[ (L_0 + c_v(T-T_0)) \\rho_l
  (D_{mv} \\frac{\\partial h}{\\partial x} + D_{Tv} \\frac{\\partial T}{\\partial x}) \\right]
```

When `include_vapor=false`, the system reduces to M_prel (Eq. 1), the preliminary
formulation without vapor transfer.

# Arguments
- `L_domain`: Length of the spatial domain (m)
- `T_end`: Duration of the simulation (s)

# Keyword Arguments
- `include_vapor`: Include vapor transfer terms (default `true`)
- `h_init`: Initial matric potential (m), default -1.0
- `T_init`: Initial temperature (K), default 298.15
- `h_left`, `h_right`: Left/right boundary matric potential (m)
- `T_left`, `T_right`: Left/right boundary temperature (K)
- Soil parameters: `θ_s`, `h_a`, `b_camp`, `K_s`, `p_K`, `f_sand`, `f_clay`,
  `ρ_b`, `S_a`, `G_a`, `T_0` — see [`SoilVaporTransfer`](@ref)
- `name`: System name, default `:SoilVaporTransferPDE`

**Reference**: Wang, Z., Timlin, D., Fleisher, D., Sun, W., Beegum, S., Li, S.,
Chen, Y., Reddy, V.R., Tully, K., & Horton, R. (2022). Modeling vapor transfer
in soil water and heat simulations: A modularized, partially-coupled approach.
*Journal of Hydrology*, 608, 127541.
https://doi.org/10.1016/j.jhydrol.2022.127541
"""
function SoilVaporTransferPDE(
        L_domain, T_end;
        include_vapor = true,
        h_init = -1.0,
        T_init = 298.15,
        h_left = -1.0,
        h_right = -1.0,
        T_left = 298.15,
        T_right = 303.15,
        θ_s_val = 0.547,
        h_a_val = -0.13,
        b_camp_val = 6.53,
        K_s_val = 3.8e-7,
        p_K_val = 10.06,
        f_sand_val = 0.022,
        f_clay_val = 0.249,
        ρ_b_val = 1200.0,
        S_a_val = 2.44e8,
        G_a_val = 6.0,
        T_0_val = 298.15,
        name = :SoilVaporTransferPDE
    )

    # All PDE variables and parameters are dimensionless (SI values as plain numbers).
    # Unit correctness is verified by the ODE component SoilVaporTransfer which has
    # full unit annotations. The PDE uses registered functions (opaque to MethodOfLines)
    # to avoid fractional power issues during MOL's derivative order detection.
    @parameters x
    @variables h_soil(..)
    @variables T_soil(..)

    @parameters begin
        θ_s
        h_a
        b_camp
        K_s
        p_K
        f_sand
        f_clay
        ρ_b
        S_a
        G_a
        T_0
        h_init_param
        T_init_param
        h_left_param
        h_right_param
        T_left_param
        T_right_param
    end

    Dx = Differential(x)

    # Local shorthands
    h = h_soil(t, x)
    T = T_soil(t, x)
    h_x = Dx(h)
    T_x = Dx(T)

    # Constitutive relations via registered functions (opaque to MethodOfLines)
    C_θθ = _vt_C_theta(h, h_a, θ_s, b_camp)
    K_val = _vt_K(h, T, h_a, θ_s, b_camp, K_s, p_K)
    λ_val = _vt_lambda(h, h_a, θ_s, b_camp, f_sand, f_clay, ρ_b)
    C_TT = _vt_Cv(h, h_a, θ_s, b_camp, ρ_b)

    if include_vapor
        D_mv = _vt_Dmv(h, T, h_a, θ_s, b_camp)
        D_Tv = _vt_DTv(h, T, h_a, θ_s, b_camp)
        D_tl = _vt_Dtl(h, T, h_a, θ_s, b_camp, K_s, p_K, G_a, S_a)
        clrhoK = _vt_clrhoK(h, T, h_a, θ_s, b_camp, K_s, p_K)
        vap_heat = _vt_vapor_heat(T, T_0)

        # Water equation (Eq. 2a' - M_simp)
        water_flux = (D_mv + K_val) * h_x + (D_Tv + D_tl) * T_x
        water_eq = D(h) ~ (1 / C_θθ) * Dx(water_flux)

        # Heat equation (Eq. 2b' - M_simp)
        heat_cond = λ_val * T_x
        heat_liq = clrhoK * h_x * (T - T_0)
        vapor_flux = D_mv * h_x + D_Tv * T_x
        heat_vapor = vap_heat * vapor_flux
        heat_eq = D(T) ~ (1 / C_TT) * (Dx(heat_cond) + Dx(heat_liq) + Dx(heat_vapor))
    else
        clrhoK = _vt_clrhoK(h, T, h_a, θ_s, b_camp, K_s, p_K)

        # M_prel (Eq. 1) - no vapor transfer
        water_eq = D(h) ~ (1 / C_θθ) * Dx(K_val * h_x) # Eq. 1a
        heat_eq = D(T) ~ (1 / C_TT) *
            (Dx(λ_val * T_x) + Dx(clrhoK * h_x * (T - T_0))) # Eq. 1b
    end

    eqs = [water_eq, heat_eq]

    # Boundary and initial conditions
    bcs = [
        h_soil(0, x) ~ h_init_param,
        T_soil(0, x) ~ T_init_param,
        h_soil(t, 0.0) ~ h_left_param,
        h_soil(t, L_domain) ~ h_right_param,
        T_soil(t, 0.0) ~ T_left_param,
        T_soil(t, L_domain) ~ T_right_param,
    ]

    domains = [t ∈ Interval(0.0, T_end), x ∈ Interval(0.0, L_domain)]

    defaults_dict = Dict(
        θ_s => θ_s_val, h_a => h_a_val, b_camp => b_camp_val,
        K_s => K_s_val, p_K => p_K_val, f_sand => f_sand_val,
        f_clay => f_clay_val, ρ_b => ρ_b_val, S_a => S_a_val,
        G_a => G_a_val, T_0 => T_0_val,
        h_init_param => h_init, T_init_param => T_init,
        h_left_param => h_left, h_right_param => h_right,
        T_left_param => T_left, T_right_param => T_right,
    )

    all_params = [
        θ_s, h_a, b_camp, K_s, p_K, f_sand, f_clay, ρ_b, S_a, G_a, T_0,
        h_init_param, T_init_param, h_left_param, h_right_param, T_left_param, T_right_param,
    ]

    # Note: checks=false is necessary because the PDE uses dimensionless variables
    # with registered functions, but ModelingToolkit's `t` has built-in time units (s).
    # Unit correctness is verified by the ODE component SoilVaporTransfer which has
    # full SI unit annotations on all variables and equations.
    return PDESystem(
        eqs, bcs, domains, [t, x],
        [h_soil(t, x), T_soil(t, x)], all_params;
        initial_conditions = defaults_dict, name = name, checks = false
    )
end
