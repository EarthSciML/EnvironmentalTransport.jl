using EnvironmentalTransport
using EnvironmentalTransport: get_vf, get_Δ

using Test
using EarthSciMLBase, EarthSciData
using ModelingToolkit, DomainSets, OrdinaryDiffEq
using ModelingToolkit: t, D
using Distributions, LinearAlgebra
using DynamicQuantities
using Dates

starttime = datetime2unix(DateTime(2022, 5, 1))
endtime = datetime2unix(DateTime(2022, 5, 1, 1, 0, 5))

domain = DomainInfo(
    DateTime(2022, 5, 1), DateTime(2022, 5, 1, 1, 0, 5);
    lonrange = deg2rad(-130):deg2rad(4):deg2rad(-60),
    latrange = deg2rad(9.75):deg2rad(4):deg2rad(60),
    levrange = 1:1:3
)
geosfp = GEOSFP("4x5", domain)

domain = EarthSciMLBase.add_partial_derivative_func(
    domain, partialderivatives_δPδlev_geosfp(geosfp))

function emissions(μ_lon, μ_lat, σ)
    @parameters(lon=0.0, [unit = u"rad"],
        lat=0.0, [unit = u"rad"],
        lev=1.0)
    @variables c(t)=0.0 [unit = u"kg"]
    @constants v_emis=50.0 [unit = u"kg/s"]
    @constants t_unit=1.0 [unit = u"s"] # Needed so that arguments to `pdf` are unitless.
    dist = MvNormal([starttime, μ_lon, μ_lat, 1], Diagonal(map(abs2, [3600.0, σ, σ, 1])))
    ODESystem([D(c) ~ pdf(dist, [t / t_unit, lon, lat, lev]) * v_emis],
        t, name = :Test₊emissions)
end

emis = emissions(deg2rad(-122.6), deg2rad(45.5), 0.1)

csys = couple(emis, domain, geosfp)

dt = 1.0
st = SolverStrangThreads(Tsit5(), dt)
prob = ODEProblem(csys, st)

sol = solve(prob, SSPRK22(), dt = dt)

@test 310 < norm(sol.u[end]) < 330

op = AdvectionOperator(100.0, l94_stencil, ZeroGradBC())

csys = couple(csys, op)

prob = ODEProblem(csys, st)

sol = solve(prob, SSPRK22(), dt = dt)

# With advection, the norm should be lower because the pollution is more spread out.
@test 310 < norm(sol.u[end]) < 350

sys_mtk, obs_eqs = convert(ODESystem, csys; simplify = true)
tf_fs = EarthSciMLBase.coord_trans_functions(obs_eqs, domain)
obs_fs = EarthSciMLBase.obs_functions(obs_eqs, domain)

vardict = EnvironmentalTransport.get_wind_funcs(csys, op)

@testset "get_vf lon" begin
    f = obs_fs(vardict["lon"])
    @test get_vf(domain, "lon", f)(2, 3, 1, starttime) ≈ -6.816295428727573
end

@testset "get_vf lat" begin
    f = obs_fs(vardict["lat"])
    @test get_vf(domain, "lat", f)(3, 2, 1, starttime) ≈ -5.443038969820774
end

@testset "get_vf lev" begin
    f = obs_fs(vardict["lev"])
    @test get_vf(domain, "lev", f)(3, 1, 2, starttime) ≈ -0.019995461793337128
end

@testset "get_Δ" begin
    @test get_Δ(domain, tf_fs, "lat")(2, 3, 1, starttime) ≈ 445280.0
    @test get_Δ(domain, tf_fs, "lon")(3, 2, 1, starttime) ≈ 432517.0383085161
    @test get_Δ(domain, tf_fs, "lev")(3, 1, 2, starttime) ≈ -1516.7789198950632
end
