# Air Pollution "Puff" Model Example

```@example puff
using EarthSciMLBase, EarthSciData, EnvironmentalTransport
using ModelingToolkit
using ModelingToolkit: t
using DynamicQuantities
using DifferentialEquations
using Plots
using Dates
using DomainSets

firestart = DateTime(2021, 10, 1)
firelength = 4 * 3600 # Seconds
simulationlength = 1 # Days
firelon = deg2rad(-97)
firelat = deg2rad(40)
fireradius = 0.05 # Degrees
samplerate = 1800.0 # Seconds
samples_per_time = 10 # Samples per each emission time
fireheight = 15.0 # Vertical level (Allowing this to be automatically calculated is a work in progress).
emis_rate = 1.0 # kg/s, fire emission rate


geosfp, _ = GEOSFP("0.5x0.625_NA"; dtype = Float64,
    coord_defaults = Dict(:lon => deg2rad(-97), :lat => deg2rad(40), :lev => 1.0), 
    cache_size=simulationlength*24÷3+2)

@parameters lon = firelon [unit=u"rad"]
@parameters lat = firelat [unit=u"rad"]
@parameters lev = fireheight

sim_end = firestart + Day(simulationlength)
domain = DomainInfo(
    [partialderivatives_δxyδlonlat,
        partialderivatives_δPδlev_geosfp(geosfp)],
    constIC(16.0, t ∈ Interval(firestart, sim_end)),
    constBC(16.0,
        lon ∈ Interval(deg2rad(-115), deg2rad(-68.75)),
        lat ∈ Interval(deg2rad(25), deg2rad(53.7)),
        lev ∈ Interval(1, 72)),
    dtype = Float64)

puff = Puff(domain)

model = couple(puff, geosfp)
sys = convert(ODESystem, model)
sys, _ = EarthSciMLBase.prune_observed(sys)

u0 = ModelingToolkit.get_defaults(sys)
tspan = (datetime2unix(firestart), datetime2unix(sim_end))
prob=ODEProblem(sys, u0, tspan)
sol = solve(prob, Tsit5()) # Solve once to make sure data is loaded.
function prob_func(prob, i, repeat)
    r = rand() * fireradius
    θ = rand() * 2π
    u0 = [firelon + r * cos(θ), firelat + r * sin(θ), fireheight]
    ts = (tspan[1] + floor(i / samples_per_time) * samplerate, tspan[2])
    remake(prob, u0 = u0, tspan = ts)
end
eprob = EnsembleProblem(prob, prob_func = prob_func)
esol = solve(eprob, Tsit5(); trajectories=ceil(firelength/samplerate*samples_per_time))

vars = [sys.puff₊lon, sys.puff₊lat, sys.puff₊lev]
ranges = [(Inf, -Inf), (Inf, -Inf), (Inf, -Inf)]
for sol in esol
    for (i, var) in enumerate(vars)
        rng = (minimum(sol[var]), maximum(sol[var]))
        ranges[i] = (min(ranges[i][1], rng[1]), 
            max(ranges[i][2], rng[2]))
    end
end

anim = @animate for t in datetime2unix(firestart):samplerate:datetime2unix(sim_end)
    p = plot(
        xlim=rad2deg.(ranges[1]), ylim=rad2deg.(ranges[2]), zlim=ranges[3],
        title = "Time: $(unix2datetime(t))",
        xlabel = "Longitude (deg)", ylabel = "Latitude (deg)", 
        zlabel = "Vertical Level",
    )
    for sol in esol
        if t < sol.t[1] || t > sol.t[end]
            continue
        end
        scatter!(p,
            [rad2deg(sol(t)[1])], [rad2deg(sol(t)[2])], [sol(t)[3]],
            label = :none, markercolor=:black, markersize=1.5,
        )
    end
end
gif(anim, fps=15)
```