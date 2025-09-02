#test
using Test
using Dates
using EarthSciMLBase, EarthSciData, EnvironmentalTransport
using ModelingToolkit, OrdinaryDiffEq

starttime = DateTime(2022, 5, 1, 0)
endtime = DateTime(2022, 5, 1, 5)
lonv, latv, levv = (-108, 38, 1.4)
Δλ      = deg2rad(5.0)
Δφ      = deg2rad(4.0)

domain = DomainInfo(
    starttime, endtime;
    lonrange = deg2rad(-130):Δλ:deg2rad(-60),
    latrange = deg2rad(25):Δφ:deg2rad(61),
    levrange = 1:72
)

@testset "Puff GeosFP GaussianPGB" begin
    model = couple(
        Puff(domain),
        GEOSFP("4x5", domain; stream=false),
        GaussianPGB()
    )

    sys = convert(System, model)

    tspan = get_tspan(domain)

    u0 = [
        sys.Puff₊lon => deg2rad(lonv),
        sys.Puff₊lat => deg2rad(latv),
        sys.Puff₊lev => levv
    ]
    p = [
        sys.GaussianPGB₊lon0 => deg2rad(lonv),
        sys.GaussianPGB₊lat0 => deg2rad(latv)
    ]

    prob = ODEProblem(sys, u0, tspan, p)
    sol = solve(prob, Tsit5())

    C_gl_val    = sol[sys.GaussianPGB₊C_gl][end]
    C_gl_want = 8.23e-11

    @test isapprox(C_gl_val, C_gl_want; rtol = 1e-2)
end

@testset "Puff GeosFP GaussianSD" begin
    model = couple(
        Puff(domain),
        GEOSFP("4x5", domain; stream = false),
        GaussianSD()
    )

    sys = convert(System, model)

    tspan = get_tspan(domain)

    u0 = [
        sys.Puff₊lon => deg2rad(lonv),
        sys.Puff₊lat => deg2rad(latv),
        sys.Puff₊lev => levv,
        sys.GaussianSD₊sigma_h => 0.0
    ]
    p = [
        sys.GaussianSD₊Δλ => Δλ,
        sys.GaussianSD₊Δφ => Δφ,
        sys.GaussianSD₊Δz => 500
    ]

    prob = ODEProblem(sys, u0, tspan, p)
    sol = solve(prob, Tsit5())

    C_gl_val = sol[sys.GaussianSD₊C_gl][end]
    C_gl_want = 6.58e-13

    @test isapprox(C_gl_val, C_gl_want; rtol = 1e-2)
end
