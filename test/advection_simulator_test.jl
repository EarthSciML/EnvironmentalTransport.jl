using EnvironmentalTransport
using EnvironmentalTransport: get_vf, get_Δ, get_datafs

using Test
using EarthSciMLBase, EarthSciData
using ModelingToolkit, OrdinaryDiffEq
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

struct EmissionsCoupler
    sys::Any
end

function Emissions(μ_lon, μ_lat, σ)
    @parameters(lon=0.0, [unit = u"rad"],
        lat=0.0, [unit = u"rad"],
        lev=1.0)
    @variables c(t)=0.0 [unit = u"kg"]
    @constants v_emis=50.0 [unit = u"kg/s"]
    @constants t_unit=1.0 [unit = u"s"] # Needed so that arguments to `pdf` are unitless.
    dist = MvNormal([starttime, μ_lon, μ_lat, 1], Diagonal(map(abs2, [3600.0, σ, σ, 1])))
    ODESystem([D(c) ~ pdf(dist, [t / t_unit, lon, lat, lev]) * v_emis],
        t, name = :Test₊emissions, metadata = Dict(:coupletype => EmissionsCoupler))
end

function EarthSciMLBase.couple2(e::EmissionsCoupler, g::EarthSciData.GEOSFPCoupler)
    e, g = e.sys, g.sys
    e = param_to_var(e, :lon, :lat, :lev)
    ConnectorSystem([
            e.lat ~ g.lat,
            e.lon ~ g.lon,
            e.lev ~ g.lev
        ], e, g)
end

emis = Emissions(deg2rad(-122.6), deg2rad(45.5), 0.1)

csys = couple(emis, domain, geosfp)

dt = 1.0
st = SolverStrangThreads(Tsit5(), dt)
prob = ODEProblem(csys, st)

sol = solve(prob, SSPRK22(), dt = dt)

@test 310 < norm(sol.u[end]) < 330

op = AdvectionOperator(100.0, l94_stencil, ZeroGradBC())

csys = couple(csys, op)

@testset "solve" begin
    prob = ODEProblem(csys, st)
    sol = solve(prob, SSPRK22(), dt = dt)
    # With advection, the norm should be lower because the pollution is more spread out.
    @test 310 < norm(sol.u[end]) < 350
end

sys_mtk = convert(ODESystem, csys; simplify = true)
vars = EarthSciMLBase.get_needed_vars(op, csys, sys_mtk, domain)
@test length(vars) == 6
p = EarthSciMLBase.default_params(sys_mtk)

v_fs, Δ_fs = get_datafs(op, csys, sys_mtk, domain)

@testset "get_vf lon" begin
    @test v_fs[1](2, 3, 1, p, starttime) ≈ -6.816295428727573
end

@testset "get_vf lat" begin
    @test v_fs[2](3, 2, 1, p, starttime) ≈ -5.443038969820774
end

@testset "get_vf lev" begin
    @test v_fs[3](3, 1, 2, p, starttime) ≈ -0.019995461793337128
end

@testset "get_Δ" begin
    @test Δ_fs[1](2, 3, 1, p, starttime) ≈ 424080.6852300487
    @test Δ_fs[2](3, 2, 1, p, starttime) ≈ 445280.0
    @test Δ_fs[3](3, 1, 2, p, starttime) ≈ -1511.6930930013798
end
