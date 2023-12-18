using ModelingToolkit, MethodOfLines, OrdinaryDiffEq, DomainSets
using Unitful
using IfElse
using Latexify

@constants k = 0.4 [description = "Von Karman constant (unitless)"]
@constants a = 7.2 [description = "constant for γc calculation (unitless)"]
@constants Ri_cr = 0.5 [description = "critical bulk Richardson number for the ABL (unitless)"]
@constants g = 9.8 [unit = u"m/(s^2)", description = "acceleration of gravity"]

@parameters Kc [unit = u"m^2/s", description = "eddy diffusivity"]
@parameters h [unit = u"m", description = "boundary-layer height"]
@parameters γc [unit = u"m^-1", description = "nonlocal transport due to dry convection"]

@parameters wₜ [unit = u"m/s", description = "characteristic turbulent velocity scale with respect to tracers"]
@parameters wₘ [unit = u"m/s", description = "characteristic turbulent velocity scales with respect to momentum"]
@parameters w_star [unit = u"m/s", description = "convective velocity scale"]
@parameters Dw = 1 [description = "the additional factor represents the availability of water at the surface (unitless)"]
@parameters Cₘ, Cₕ [description = "two surface-layer exchange coefficients (unitless)"]
@parameters Cₙ [description = "the neutral exchange coefficient (unitless)"]
@parameters Ri₀ [description = "surface-layer bulk Richardson number (unitless)"]
@parameters z_0m [unit = u"m", description = "roughness length for momentum, 0.04m over tundra, 2m over tropical rain forest, 0.0001m over ocean"]
@parameters z1 [unit = u"m", description = "height of the lowest model level"]
@parameters h [unit = u"m", description = "PBL height"]

@parameters ϕₕ [description = "dimensionless vertical temperature gradient (unitless)"]
@parameters L [unit = u"m", description = "Obukhov length"]
@parameters u_star [unit = u"m/s", description = "friction velocity"]
@parameters Pr [description = "turbulent Prandtl number (unitless)"]
@constants c1 = 0.6 [description = "parameterized constant (unitless)"]

@parameters stable [description="unstable: -1, neutral: 0,  stable: 1 (unitless)"]
@parameters w_C0 [unit = u"m/s", description = "surface flux of C"]
@parameters w_u0 [unit = u"m^2/(s^2)", description = "parameterized (kinematic) surface flux of u"]
@parameters w_v0 [unit = u"m^2/(s^2)", description = "parameterized (kinematic) surface flux of v"]
@parameters w_θ0 [unit = u"K*m/s", description = "parameterized (kinematic) surface fluxes of θ"]
@parameters w_q0 [unit = u"m/s", description = "parameterized (kinematic) surface fluxes of q"]
@parameters w_θv0 [unit = u"K*m/s", description = "surface virtual heat flux"]

@parameters u_10 [unit = u"m/s", description = "zonal wind components"]
@parameters v_10 [unit = u"m/s", description = "meridional wind components"]
@parameters V_10 [unit = u"m/s", description = "horizontal velocity"]
@parameters T_s [unit = u"K"]
@parameters T_10 [unit = u"K"]
@parameters θ_s [unit = u"K", description = "potential temperature of air"]
@parameters θ_10 [unit = u"K", description = "potential temperature of air"]
@parameters θᵥs [unit = u"K", description = "virtual temperature"]
@parameters θᵥ10 [unit = u"K", description = "virtual temperature"]
@parameters q_s [description = "specific humidity"]
@parameters q_10 [description = "specific humidity"]
@parameters P_10 [unit = u"hPa"]

@parameters t [unit = u"s"]
@parameters z [unit = u"m", description = "height above surface"]

@variables C(..) [description = "mixing ratio of tracer (unitless)"]

Dz = Differential(z)
Dt = Differential(t)

"""
Function to calculate potential temperature
"""

@constants P0 = 1000 [unit = u"hPa", description = "reference pressure"]
@parameters P_s [unit = u"hPa", description = "surface pressure"]
function PT(T,P)
    return T*(P0/P)^0.286
end

"""
Function to calculate virtual potential temperature
"""
function VPT(T,r)
    return T*(1+r/0.622)/(1+r)
end

"""
function to calcualte stable conditions
"""
function calc_stable(θᵥ_0,θᵥ_1)
    stable1 = IfElse.ifelse((θᵥ_0 < θᵥ_1), 1, 0)
    stable = IfElse.ifelse((θᵥ_0 > θᵥ_1), -1, stable1)
    return stable
end

"""
function to calculate parameterized surface fluxes
"""
function Surface_fluxes(stable, V1, u1, v1, θ0, θ1, q0, q1, θᵥ_0, θᵥ_1, z1, z_0m)
    Cₙ = k^2/(log((z1+z_0m)/z_0m))^2
    Ri₀ = g*z1*(θᵥ_1-θᵥ_0)/(θ1*V1^2)
    fₘ = IfElse.ifelse((stable == -1), 1-10*Ri₀/(1+75*Cₙ*(-Ri₀*(z1+z_0m)/z_0m)^0.5), 1/(1+10*Ri₀*(1+8*Ri₀)))
    fₕ = IfElse.ifelse((stable == -1), 1-15*Ri₀/(1+75*Cₙ*(-Ri₀*(z1+z_0m)/z_0m)^0.5), 1/(1+10*Ri₀*(1+8*Ri₀)))
    Cₘ = Cₙ*fₘ
    Cₕ = Cₙ*fₕ
    return Cₘ, Cₕ
end

"""
Function to calculate u_star
"""
function calc_u_star(w_u0,w_v0)
    return (w_u0^2+w_v0^2)^(1/4)
end

"""
Function to calculate L
"""
function calc_L(u_star, θᵥ_0, w_θv0)
    L = -u_star^3/(k*(g/θᵥ_0)*w_θv0)
    return L
end


"""
Function to calculate ϕₕ
"""
function calc_ϕₕ(stable,z,L)
    ϕₕ1 = IfElse.ifelse((stable == 1), IfElse.ifelse((z <= L), 1+5*z/L, 5+z/L), 1)
    ϕₕ = IfElse.ifelse((stable == -1), (1-15*z/L )^(-1/2), ϕₕ1)
    return ϕₕ
end

"""
Function to calculate w_star
"""
function calc_w_star(θᵥ_0, w_θv0, h)
    w_star = ((g/θᵥ_0)*w_θv0*h)^(1/3)
end

"""
Function to calculate wₘ
"""
function calc_wₘ(stable, z, h, u_star, ϕₕ, w_star)
    i1 = IfElse.ifelse((w_star/u_star >= 10),0.85*w_star,(u_star^3+c1*w_star^3)^(1/3))
    i2 = IfElse.ifelse((z/h <= 0.1),u_star/((1-15*z/L )^(-1/3)),i1)
    wₘ = IfElse.ifelse((stable >= 0), u_star/ϕₕ, i2)
    return wₘ
end

"""
Function to calculate wₜ
"""
function calc_wₜ(z, h, u_star, ϕₕ, wₘ, Pr)
    wₜ = IfElse.ifelse((z/h <= 0.1), u_star/ϕₕ, wₘ/Pr)
end

"""
Function to calculate w_C0
"""
function calc_w_C0(C0, C1, z1, u_star, θᵥ_0, w_θv0)
    L = calc_L(u_star, θᵥ_0, w_θv0)
    ϕₕ = calc_ϕₕ(-1,z1,L)
    w_C0 = -k*u_star*z1/ϕₕ*((C1-C0)/z1)
    return w_C0
end

"""
Function to calculate Pr
"""
function calc_Pr(w_star, u_star)
    Pr = IfElse.ifelse((w_star/u_star <= 10), 1-(w_star/u_star)/10*0.4, 0.6)
end

"""
Function to calculate Kc
"""
function calc_Kc(w_u0, w_v0, θᵥ_0, w_θv0, θᵥ_1, z, h)
    u_star = calc_u_star(w_u0, w_v0)
    L = calc_L(u_star, θᵥ_0, w_θv0)
    stable = calc_stable(θᵥ_0,θᵥ_1)
    ϕₕ = calc_ϕₕ(stable, z, L)
    w_star = calc_w_star(θᵥ_0, w_θv0, h)
    wₘ = calc_wₘ(stable, z, h, u_star, ϕₕ, w_star)
    Pr = calc_Pr(w_star, u_star)
    wₜ = calc_wₜ(z, h, u_star, ϕₕ, wₘ, Pr)
    Kc = k*wₜ*z*(1-z/h)^2
    return Kc
end

"""
function to calculate γc
"""
function calc_γc(θᵥ_0, θᵥ_1, z, h, w_θv0, w_u0, w_v0, C0, C1, z1)
    stable = calc_stable(θᵥ_0,θᵥ_1)
    w_star = calc_w_star(θᵥ_0, w_θv0, h)
    u_star = calc_u_star(w_u0, w_v0)
    w_C0 = calc_w_C0(C0, C1, z1, u_star, θᵥ_0, w_θv0)
    ϕₕ = calc_ϕₕ(stable, z, L)
    wₘ = calc_wₘ(stable, z, h, u_star, ϕₕ, w_star)
    γc = (a*w_star*(w_C0)/(wₘ^2*h)) * (z/h <= 0.1) * (stable >= 0)
    return γc
end

"""
When the PBL height is taken from the meteorological datasets 
"""
eqs = [
    θ_s ~ PT(T_s,P_s)
    θ_10 ~ PT(T_10,P_10)
    θᵥs ~ VPT(θ_s,q_s)
    θᵥ10 ~ VPT(θ_10,q_s)
    V_10 ~ (u_10^2+v_10^2)^0.5
    stable ~ calc_stable(θᵥs,θᵥ10)
    w_u0 ~ -V_10*u_10*Surface_fluxes(stable, V_10, u_10, v_10, θ_s, θ_10, q_s, q_10, θᵥs, θᵥ10, z1, z_0m)[1]
    w_v0 ~ -V_10*v_10*Surface_fluxes(stable, V_10, u_10, v_10, θ_s, θ_10, q_s, q_10, θᵥs, θᵥ10, z1, z_0m)[1]
    w_θv0 ~ V_10*(θᵥs-θᵥ10)*Surface_fluxes(stable, V_10, u_10, v_10, θ_s, θ_10, q_s, q_10, θᵥs, θᵥ10, z1, z_0m)[2]

    Kc ~ calc_Kc(w_u0, w_v0, θᵥs, w_θv0, θᵥ10, z, h)
    γc ~ calc_γc(θᵥs, θᵥ10, z, h, w_θv0, w_u0, w_v0, C(0,t), C(z1,t), z1)
    Dt(C(z,t)) ~ Dz(-Kc*(Dz(C(z,t))-γc))
]

render(latexify(eqs))

z_min = t_min = 0
z_max = 200
t_max = 10

domains = [
    z ∈ Interval(z_min,z_max)
    t ∈ Interval(t_min, t_max)
]

# Periodic BCs
bcs = [
    C(z,0) ~ 10
    C(0,t) ~ 10
]

@named pdesys = PDESystem(eqs,bcs,domains,[z,t],[C(z,t)],[u_10=>1.78, v_10=>2.53, T_s=>273.54, T_10=>275.51, q_s=>0.00377, q_10=>0.00377, z1=>10, z_0m=>0.368, h=>208, P_s=>1013.25, P_10=>1012.04])

N = 10

order = 2 # This may be increased to improve accuracy of some schemes

# Integers for x and y are interpreted as number of points. Use a Float to directtly specify stepsizes dx and dy.
discretization = MOLFiniteDifference([z=>N], t, approx_order=order)

@run prob = discretize(pdesys,discretization)

