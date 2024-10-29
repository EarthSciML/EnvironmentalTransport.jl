using Test
using Main.EnvironmentalTransport
using EarthSciMLBase
using EarthSciData
using ModelingToolkit
using ModelingToolkit: t
using DynamicQuantities
using OrdinaryDiffEq
using Dates

starttime = DateTime(2022, 5, 1)
endtime = DateTime(2022, 5, 1, 3)

di = DomainInfo(
    starttime, endtime;
    lonrange = deg2rad(-115):deg2rad(-68.75),
    latrange = deg2rad(25):deg2rad(53.7),
    levrange = 1:15,
    dtype = Float64)

geosfp = GEOSFP("4x5", di; stream_data = false)

di = EarthSciMLBase.add_partial_derivative_func(di, partialderivatives_δPδlev_geosfp(geosfp))

puff = Puff(di)

model = couple(puff, geosfp)
sys, _ = convert(ODESystem, model; simplify=true)

@test length(equations(sys)) == 3
@test occursin("PS", string(observed(sys))) # Check that we're using the GEOSFP pressure data.
@test issetequal([Symbol("puff₊lon(t)"), Symbol("puff₊lat(t)"), Symbol("puff₊lev(t)")],
    Symbol.(unknowns(sys)))
@test length(parameters(sys)) == 0
@test length(observed(sys)) == 10
