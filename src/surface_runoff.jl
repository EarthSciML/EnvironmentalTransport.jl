export SurfaceRunoff, HeavisideBoundaryCondition, SaintVenantPDE

"""
$(TYPEDSIGNATURES)

Create a surface runoff model based on the Saint-Venant equation system for
surface water movement, following the approach of Wang et al. (2020).

The model describes mass conservation and momentum conservation of surface
water flow along a soil surface slope. The Saint-Venant equations are:

```math
\\frac{\\partial \\tilde{h}}{\\partial t} = -\\frac{\\partial q}{\\partial l} + (P - I)
```

```math
\\frac{\\partial q}{\\partial t} = -\\frac{\\partial}{\\partial l}\\left(\\frac{q^2}{\\tilde{h}} + \\frac{g \\tilde{h}^2}{2}\\right) + g \\tilde{h} (S_0 - S_f)
```

where ``\\tilde{h}`` is the flow depth (ponded water height), ``q`` is the surface
runoff flux per unit width, ``P`` is precipitation flux, ``I`` is infiltration
flux, ``S_0`` is the surface slope, and ``S_f`` is the friction slope computed
from Manning's equation.

This component represents the equations at a single surface node. The spatial
derivative terms (``\\partial q / \\partial l`` and the momentum flux divergence)
are represented as input parameters that should be provided by a spatial
discretization scheme or coupled model.

**Reference**: Wang, Z., Timlin, D., Kouznetsov, M., Fleisher, D., Li, S., Tully, K.,
& Reddy, V. (2020). Coupled model of surface runoff and surface-subsurface
water movement. *Advances in Water Resources*, 137, 103499.
https://doi.org/10.1016/j.advwatres.2019.103499
"""
@component function SurfaceRunoff(; name = :SurfaceRunoff)
    @constants begin
        g = 9.81, [description = "Gravitational acceleration", unit = u"m/s^2"]
        h_ref = 1.0, [description = "Reference flow depth for non-dimensionalization", unit = u"m"]
        q_ref = 1.0, [description = "Reference flux for non-dimensionalization", unit = u"m^2/s"]
        n_ref = 1.0, [
                description = "Reference Manning coefficient for non-dimensionalization",
                unit = u"m^(-1/3)*s",
            ]
    end

    @parameters begin
        P(t), [description = "Precipitation/irrigation flux density (Eq. 1)", unit = u"m/s"]
        I_infil(t), [description = "Infiltration flux density (Eq. 1)", unit = u"m/s"]
        S_0, [description = "Surface slope (dimensionless)", unit = u"1"]
        n_mann, [description = "Manning roughness coefficient", unit = u"m^(-1/3)*s"]
        h̃_0 = 1.0e-5,
            [description = "Minimum flow depth to prevent singularity (Eq. 1)", unit = u"m"]
        dqdl(t) = 0.0,
            [description = "Spatial derivative of runoff flux ∂q/∂l (Eq. 1)", unit = u"m/s"]
        dFdl(t) = 0.0,
            [
                description = "Spatial derivative of momentum flux ∂/∂l(q²/h̃ + g·h̃²/2) (Eq. 1)",
                unit = u"m^2/s^2",
            ]
    end

    @variables begin
        h̃(t), [description = "Flow depth / ponded water height (Eq. 1)", unit = u"m"]
        q(t), [description = "Surface runoff flux per unit width (Eq. 1)", unit = u"m^2/s"]
        S_f(t),
            [description = "Friction slope from Manning's equation (Eq. 1)", unit = u"1"]
    end

    eqs = [
        # Eq. 1a - Mass conservation (Saint-Venant)
        D(h̃) ~ -dqdl + (P - I_infil),
        # Eq. 1b - Momentum conservation (Saint-Venant)
        D(q) ~ -dFdl + g * max(h̃, h̃_0) * (S_0 - S_f),
        # Manning's friction slope: Sf = (n*q)² / h̃^(10/3)
        # From Wang et al. (2020) Eq. 1, page 2
        # Non-dimensionalize fractional powers to handle units properly
        S_f ~ ((n_mann * q) / (n_ref * q_ref))^2 / (max(h̃, h̃_0) / h_ref)^(10 / 3),
    ]

    return System(eqs, t; name)
end

"""
$(TYPEDSIGNATURES)

Create a `PDESystem` for the Saint-Venant equations (Eq. 1 from Wang et al., 2020)
suitable for spatial discretization with MethodOfLines.jl.

The system implements the full 1D Saint-Venant equations with proper SI units:
- Mass conservation (Eq. 1a): ``\\partial \\tilde{h}/\\partial t = -\\partial q/\\partial l + (P - I)``
- Momentum conservation (Eq. 1b): ``\\partial q/\\partial t = -\\partial F/\\partial l + g \\tilde{h}(S_0 - S_f)``
- Momentum flux (auxiliary): ``F = q^2/\\tilde{h} + g \\tilde{h}^2/2``

where ``S_f`` is Manning's friction slope computed with non-dimensionalized
fractional exponents: ``S_f = ((n/n_{ref})(q/q_{ref}))^2 / (\\tilde{h}/h_{ref})^{10/3}``.

# Arguments
- `L_domain`: Length of the spatial domain (m)
- `T_end`: Duration of the simulation (s)

# Keyword Arguments
- `P_val`: Precipitation rate (m/s), default 70 mm/hr
- `I_val`: Infiltration rate (m/s), default 0.0
- `S_0_val`: Surface slope (dimensionless), default 0.01
- `n_manning_val`: Manning roughness coefficient (m^(-1/3)·s), default 0.03
- `g_val`: Gravitational acceleration (m/s²), default 9.81
- `h_min_val`: Minimum flow depth to prevent singularity (m), default 1e-5
- `h_init_val`: Initial and boundary flow depth (m), default 1e-3
- `q_init_val`: Initial and boundary flux (m²/s), default 0.0
- `name`: System name, default `:SaintVenantPDE`

**Reference**: Wang, Z., Timlin, D., Kouznetsov, M., Fleisher, D., Li, S., Tully, K.,
& Reddy, V. (2020). Coupled model of surface runoff and surface-subsurface
water movement. *Advances in Water Resources*, 137, 103499.
https://doi.org/10.1016/j.advwatres.2019.103499
"""
function SaintVenantPDE(
        L_domain, T_end;
        P_val = 70.0 / 1000 / 3600,
        I_val = 0.0,
        S_0_val = 0.01,
        n_manning_val = 0.03,
        g_val = 9.81,
        h_min_val = 1.0e-5,
        h_init_val = 1.0e-3,
        q_init_val = 0.0,
        name = :SaintVenantPDE
    )

    @parameters l [unit = u"m"]
    @variables h_tilde(..) [unit = u"m", description = "Flow depth / ponded water height (Eq. 1)"]
    @variables q_flux(..) [unit = u"m^2/s", description = "Surface runoff flux per unit width (Eq. 1)"]
    @variables F_mom(..) [unit = u"m^3/s^2", description = "Momentum flux q²/h̃ + g·h̃²/2 (Eq. 1b)"]

    @parameters begin
        P_rate, [unit = u"m/s", description = "Precipitation/irrigation flux density (Eq. 1)"]
        I_rate, [unit = u"m/s", description = "Infiltration flux density (Eq. 1)"]
        S_0_slope, [description = "Surface slope (dimensionless)", unit = u"1"]
        n_mann, [unit = u"m^(-1/3)*s", description = "Manning roughness coefficient"]
        g_grav, [unit = u"m/s^2", description = "Gravitational acceleration"]
        h_min, [unit = u"m", description = "Minimum flow depth to prevent singularity"]
        h_bc, [unit = u"m", description = "Boundary/initial flow depth"]
        q_bc, [unit = u"m^2/s", description = "Boundary/initial flux"]
        n_ref, [unit = u"m^(-1/3)*s", description = "Reference Manning coefficient for non-dimensionalization"]
        q_ref, [unit = u"m^2/s", description = "Reference flux for non-dimensionalization"]
        h_ref, [unit = u"m", description = "Reference flow depth for non-dimensionalization"]
    end

    Dl = Differential(l)

    # Eq. 1a - Mass conservation (Saint-Venant)
    eq1 = D(h_tilde(t, l)) ~ -Dl(q_flux(t, l)) + (P_rate - I_rate)

    # Eq. 1b - Momentum conservation (Saint-Venant)
    # Uses auxiliary variable F_mom to avoid MethodOfLines creating untyped auxiliaries
    eq2 = D(q_flux(t, l)) ~
        -Dl(F_mom(t, l)) +
        g_grav * max(h_tilde(t, l), h_min) *
        (
        S_0_slope - ((n_mann / n_ref) * (q_flux(t, l) / q_ref))^2 /
            (max(h_tilde(t, l), h_min) / h_ref)^(10 / 3)
    )

    # Auxiliary equation for momentum flux (part of Eq. 1b)
    eq3 = F_mom(t, l) ~ q_flux(t, l)^2 / max(h_tilde(t, l), h_min) +
        g_grav * h_tilde(t, l)^2 / 2

    # Boundary and initial conditions
    F_bc = q_bc^2 / max(h_bc, h_min) + g_grav * h_bc^2 / 2
    bcs = [
        h_tilde(0, l) ~ h_bc,
        q_flux(0, l) ~ q_bc,
        F_mom(0, l) ~ F_bc,
        h_tilde(t, 0.0) ~ h_bc,
        q_flux(t, 0.0) ~ q_bc,
        F_mom(t, 0.0) ~ F_bc,
        h_tilde(t, L_domain) ~ h_bc,
        q_flux(t, L_domain) ~ q_bc,
        F_mom(t, L_domain) ~ F_bc,
    ]

    domains = [t ∈ Interval(0.0, T_end), l ∈ Interval(0.0, L_domain)]

    defaults_dict = Dict(
        P_rate => P_val, I_rate => I_val, S_0_slope => S_0_val,
        n_mann => n_manning_val, g_grav => g_val, h_min => h_min_val,
        h_bc => h_init_val, q_bc => q_init_val,
        n_ref => 1.0, q_ref => 1.0, h_ref => 1.0,
    )

    all_params = [P_rate, I_rate, S_0_slope, n_mann, g_grav, h_min, h_bc, q_bc, n_ref, q_ref, h_ref]

    return PDESystem(
        [eq1, eq2, eq3], bcs, domains, [t, l],
        [h_tilde(t, l), q_flux(t, l), F_mom(t, l)], all_params;
        defaults = defaults_dict, name = name
    )
end

"""
$(TYPEDSIGNATURES)

Create a smoothed Heaviside boundary condition component for coupling surface
and subsurface water flow, following Wang et al. (2020).

The Heaviside step function determines whether the soil surface is in a ponding
state (h ≥ 0) or unsaturated state (h < 0), enabling automatic switching between
infiltration and evaporation boundary conditions:

```math
\\eta_\\omega(h) = \\frac{1}{\\pi} \\arctan\\left(\\frac{h}{\\omega}\\right) + \\frac{1}{2}
```

```math
\\delta_\\omega(h) = \\frac{1}{\\pi} \\frac{\\omega}{\\omega^2 + h^2}
```

These smooth approximations converge to the Heaviside step function and Dirac
delta function respectively as ``\\omega \\to 0^+``.

The boundary condition equation is (Eq. 3):

```math
\\frac{\\partial(\\eta(h) \\cdot h)}{\\partial t} - (P - I) = 0
```

**Reference**: Wang, Z., Timlin, D., Kouznetsov, M., Fleisher, D., Li, S., Tully, K.,
& Reddy, V. (2020). Coupled model of surface runoff and surface-subsurface
water movement. *Advances in Water Resources*, 137, 103499.
https://doi.org/10.1016/j.advwatres.2019.103499
"""
@component function HeavisideBoundaryCondition(; name = :HeavisideBoundaryCondition)
    @constants begin
        one_over_pi = 1.0 / π, [description = "1/π constant (dimensionless)", unit = u"1"]
        one_half = 0.5, [description = "1/2 constant (dimensionless)", unit = u"1"]
    end

    @parameters begin
        ω = 1.0e-4,
            [
                description = "Smoothing parameter for Heaviside approximation (Eq. 5)", unit = u"m",
            ]
        P(t), [description = "Precipitation/irrigation flux density (Eq. 3)", unit = u"m/s"]
        I_infil(t), [description = "Infiltration flux density (Eq. 3)", unit = u"m/s"]
    end

    @variables begin
        h(t), [description = "Soil water pressure head at surface (Eq. 3)", unit = u"m"]
        η_ω(t),
            [
                description = "Smoothed Heaviside step function (Eq. 5) (dimensionless)", unit = u"1",
            ]
        δ_ω(t), [description = "Smoothed Dirac delta function (Eq. 5)", unit = u"1/m"]
    end

    eqs = [
        # Eq. 5a - Smoothed Heaviside step function
        η_ω ~ one_over_pi * atan(h / ω) + one_half,
        # Eq. 5b - Smoothed Dirac delta function (derivative of η_ω with respect to h)
        δ_ω ~ one_over_pi * ω / (ω^2 + h^2),
        # Eq. 3 - Surface boundary condition
        # ∂(η(h)·h)/∂t = (P - I)
        # Using product rule: η'(h)·h·dh/dt + η(h)·dh/dt = P - I
        # So: (δ_ω·h + η_ω)·dh/dt = P - I
        D(h) ~ (P - I_infil) / (δ_ω * h + η_ω),
    ]

    return System(eqs, t; name)
end
