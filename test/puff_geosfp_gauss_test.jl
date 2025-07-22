using Test
using Dates
using EarthSciMLBase, EarthSciData, EnvironmentalTransport
using ModelingToolkit, DifferentialEquations
using ModelingToolkit: t
using EnvironmentalTransport: PuffCoupler, GaussianDispersionCoupler

starttime = DateTime(2019, 6, 15, 0, 0, 0)
endtime = DateTime(2019, 6, 15, 10, 0, 0)
lonv, latv, levv = (-108, 38, 3)

domain = DomainInfo(
    starttime, endtime;
    lonrange = deg2rad(-125):deg2rad(1.25):deg2rad(-68.75),
    latrange = deg2rad(25.0):deg2rad(1.00):deg2rad(53.7),
    levrange = 1:72,
    dtype = Float64
)

model = couple(
    Puff(domain),
    GEOSFP("4x5", domain; stream=false),
    GaussianDispersion()
)

sys = convert(ODESystem, model)

tspan = (datetime2unix(starttime),
         datetime2unix(endtime))

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

@test sol.retcode == SciMLBase.ReturnCode.Success