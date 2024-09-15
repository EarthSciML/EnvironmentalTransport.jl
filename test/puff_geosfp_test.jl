using Test
using Main.EnvironmentalTransport
using EarthSciMLBase
using EarthSciData
using ModelingToolkit
using ModelingToolkit: t
using DynamicQuantities
using DomainSets
using OrdinaryDiffEq
using Dates

starttime = DateTime(2022, 5, 1)
endtime = DateTime(2022, 5, 1, 3)

geosfp, geosfp_updater = GEOSFP("0.5x0.625_NA"; dtype = Float64,
    coord_defaults = Dict(:lon => deg2rad(-97), :lat => deg2rad(40), :lev => 1.0),
    cache_size = 3)
EarthSciData.lazyload!(geosfp_updater, datetime2unix(starttime))

@parameters lon=deg2rad(-97) [unit = u"rad"]
@parameters lat=deg2rad(40) [unit = u"rad"]
@parameters lev = 3.0

di = DomainInfo(
    [partialderivatives_δxyδlonlat,
        partialderivatives_δPδlev_geosfp(geosfp)],
    constIC(16.0, t ∈ Interval(starttime, endtime)),
    constBC(16.0,
        lon ∈ Interval(deg2rad(-115), deg2rad(-68.75)),
        lat ∈ Interval(deg2rad(25), deg2rad(53.7)),
        lev ∈ Interval(1, 15)),
    dtype = Float64)

puff = Puff(di)

model = couple(puff, geosfp)
sys = convert(ODESystem, model)
sys, _ = EarthSciMLBase.prune_observed(sys)

@test length(equations(sys)) == 3
@test occursin("PS", string(equations(sys))) # Check that we're using the GEOSFP pressure data.
@test issetequal([Symbol("puff₊lon(t)"), Symbol("puff₊lat(t)"), Symbol("puff₊lev(t)")],
    Symbol.(unknowns(sys)))
@test length(parameters(sys)) == 0
@test length(observed(sys)) == 9
