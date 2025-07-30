using Test
using Dates
using EarthSciMLBase, EarthSciData, EnvironmentalTransport
using ModelingToolkit, OrdinaryDiffEq
using EnvironmentalTransport: PuffCoupler, GaussianDispersionCoupler

starttime = DateTime(2022, 5, 1)
endtime = DateTime(2022, 5, 2)
lonv, latv, levv = (-108, 38, 2)

domain = DomainInfo(
    starttime, endtime;
    lonrange = deg2rad(-125):deg2rad(1.25):deg2rad(-68.75),
    latrange = deg2rad(25.0):deg2rad(1.00):deg2rad(53.7),
    levrange = 1:72,
)

model = couple(
    Puff(domain),
    GEOSFP("4x5", domain; stream=false),
    GaussianDispersion()
)

sys = convert(ODESystem, model)

tspan = get_tspan(domain)

u0 = [
    sys.Puff₊lon => deg2rad(lonv),
    sys.Puff₊lat => deg2rad(latv),
    sys.Puff₊lev => levv,
]
p = [
    sys.GaussianDispersion₊lon0 => deg2rad(lonv),
    sys.GaussianDispersion₊lat0 => deg2rad(latv),
]

prob = ODEProblem(sys, u0, tspan, p)
sol = solve(prob, Tsit5())

C_gl_val    = sol[sys.GaussianDispersion₊C_gl][end]
C_gl_want = 2.47e-13

@test isapprox(C_gl_val, C_gl_want; rtol = 1e-2)

