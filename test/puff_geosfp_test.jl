using Test
using EnvironmentalTransport
using EarthSciMLBase
using EarthSciData
using ModelingToolkit
using ModelingToolkit: t
using DynamicQuantities
using OrdinaryDiffEq
import SciMLBase
using Dates

starttime = DateTime(2022, 5, 1)
endtime = DateTime(2022, 5, 1, 0, 1)

di = DomainInfo(
    starttime, endtime;
    lonrange = deg2rad(-115):deg2rad(1):deg2rad(-68.75),
    latrange = deg2rad(25):deg2rad(1):deg2rad(53.7),
    levrange = 1:15,
    dtype = Float64)

geosfp = GEOSFP("4x5", di; stream = false)

puff = Puff(di)

model = couple(puff, geosfp)
sys = convert(ODESystem, model; simplify = true)

@test length(equations(sys)) == 3
@test occursin("PS", string(observed(sys))) # Check that we're using the GEOSFP pressure data.
@test issetequal([Symbol("puff₊lon(t)"), Symbol("puff₊lat(t)"), Symbol("puff₊lev(t)")],
    Symbol.(unknowns(sys)))
@test length(parameters(sys)) == 72
@test length(observed(sys)) == 17

u0 = ModelingToolkit.get_defaults(sys)
tspan = EarthSciMLBase.get_tspan(di)
prob=ODEProblem(sys, u0, tspan)
sol = solve(prob, Tsit5())
@test sol.retcode == SciMLBase.ReturnCode.Success
