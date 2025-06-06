using BenchmarkTools
using EnvironmentalTransport

using EarthSciMLBase, EarthSciData
using ModelingToolkit, DomainSets
using ModelingToolkit: t, D
using Dates
using DynamicQuantities

starttime_date = DateTime(2022, 5, 1)
starttime = datetime2unix(starttime_date)
endtime = DateTime(2022, 5, 1, 1, 0, 5)

function setup_advection_simulator(lonres, latres, stencil)
    domain = DomainInfo(
        starttime_date, endtime;
        lonrange = deg2rad(-129):deg2rad(lonres):deg2rad(-61),
        latrange = deg2rad(11):deg2rad(latres):deg2rad(59),
        levrange = 1:1:3
    )

    geosfp = GEOSFP("0.25x0.3125_NA", domain)

    domain = EarthSciMLBase.add_partial_derivative_func(
        domain, partialderivatives_δPδlev_geosfp(geosfp))

    function emissions()
        @parameters(lonx=-97.0, [unit=1u"s^-1"],
            latx=30.0, [unit=1u"s^-1"],
            levx=1.0, [unit=1u"s^-1"])
        @variables c(t) = 1.0
        ODESystem([D(c) ~ latx + lonx + levx], t, name = :emissions)
    end

    emis = emissions()

    op = AdvectionOperator(100.0, stencil, ZeroGradBC())
    csys = couple(emis, domain, geosfp, op)
    st = SolverIMEX()
    prob = ODEProblem(csys, st)
    return prob.f.f2, prob.u0, prob.p
end

suite = BenchmarkGroup()
suite["Advection Simulator"] = BenchmarkGroup(["advection", "simulator"])
suite["Advection Simulator"]["in-place"] = BenchmarkGroup()
suite["Advection Simulator"]["out-of-place"] = BenchmarkGroup()

for stencil in [upwind1_stencil]
    suite["Advection Simulator"]["in-place"][stencil] = BenchmarkGroup()
    suite["Advection Simulator"]["out-of-place"][stencil] = BenchmarkGroup()
    for (lonres, latres) in ((0.625, 0.5), (0.3125, 0.25))
        @info "setting up $lonres x $latres with $stencil"
        op, u, p = setup_advection_simulator(lonres, latres, stencil)
        suite["Advection Simulator"]["in-place"][stencil]["$lonres x $latres (N=$(length(u)))"] = @benchmarkable $(op)(
            $(u[:]), $(u[:]), $(p), 0.0)
        suite["Advection Simulator"]["out-of-place"][stencil]["$lonres x $latres (N=$(length(u)))"] = @benchmarkable $(op)(
            $(u[:]), $(p), 0.0)
    end
end

# op, u = setup_advection_simulator(0.1, 0.1, l94_stencil)
# @profview op(u[:], u[:], [0.0], starttime)

tune!(suite)
results = run(suite, verbose = true)

BenchmarkTools.save("output.json", median(results))
