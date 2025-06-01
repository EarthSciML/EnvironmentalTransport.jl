# Numerical Advection Operator

We have two ways to represent phenomena that occur across space such as advection: through symbolically-defined partial differential equation systems, which will be covered elsewhere in
documentation, and through numerically-implemented algorithms.
This is an example of the latter. (Currently, symbolically defined PDEs are too slow to be
used in large-scale simulations.)

To demonstrate how it works, let's first set up our environment:

```@example adv
using EnvironmentalTransport
using EarthSciMLBase, EarthSciData
using ModelingToolkit, DifferentialEquations
using ProgressLogging
using ModelingToolkit: t, D
using DynamicQuantities
using Distributions, LinearAlgebra
using Dates
using NCDatasets, Plots
nothing #hide
```

## Emissions

Next, let's set up an emissions scenario to advect.
We'll make the emissions start at the beginning of the simulation and then taper off:

```@example adv
starttime = DateTime(2022, 5, 1)
endtime = DateTime(2022, 5, 10)

struct EmissionsCoupler
    sys
end
function emissions(μ_lon, μ_lat, σ)
    @parameters(lon=-97.0, [unit=u"rad"],
        lat=30.0, [unit=u"rad"],
        lev=1.0,)
    @variables c(t) = 0.0 [unit=u"kg"]
    @constants v_emis = 50.0 [unit=u"kg/s"]
    @constants t_unit = 1.0 [unit=u"s"] # Needed so that arguments to `pdf` are unitless.
    dist = MvNormal([datetime2unix(starttime), μ_lon, μ_lat, 1],
        Diagonal(map(abs2, [3600.0*24*3, σ, σ, 1])))
    ODESystem([D(c) ~ pdf(dist, [t/t_unit, lon, lat, lev]) * v_emis],
        t, name = :emissions, metadata = Dict(:coupletype => EmissionsCoupler))
end
function EarthSciMLBase.couple2(e::EmissionsCoupler, g::EarthSciData.GEOSFPCoupler)
    e, g = e.sys, g.sys
    e = param_to_var(e, :lat, :lon, :lev)
    ConnectorSystem([e.lat ~ g.lat, e.lon ~ g.lon, e.lev ~ g.lev], e, g)
end

emis = emissions(deg2rad(-97.0), deg2rad(40.0), deg2rad(1))
```

## Coupled System

Next, let's set up a spatial and temporal domain for our simulation, and
some input data from GEOS-FP to get wind fields for our advection.
We need to use `coord_defaults` in this case to get the GEOS-FP data to work correctly, but
it doesn't matter what the defaults are.
We also set up an [outputter](https://data.earthsci.dev/stable/api/#EarthSciData.NetCDFOutputter) to save the results of our simulation, and couple the components we've created so far into a
single system.

```@example adv

domain = DomainInfo(
    starttime, endtime;
    lonrange = deg2rad(-115):deg2rad(1):deg2rad(-68.75),
    latrange = deg2rad(25):deg2rad(1):deg2rad(53.7),
    levrange = 1:1:15,
    dtype = Float64)

geosfp = GEOSFP("0.5x0.625_NA", domain)
geosfp = EarthSciMLBase.copy_with_change(geosfp, discrete_events = []) # Workaround for bug.

outfile = ("RUNNER_TEMP" ∈ keys(ENV) ? ENV["RUNNER_TEMP"] : tempname()) * "out.nc" # This is just a location to save the output.
output = NetCDFOutputter(outfile, 3600.0)

csys = couple(emis, domain, geosfp, output)
```

## Advection Operator

Next, we create an [`AdvectionOperator`](@ref) to perform advection.
We need to specify a time step (300 s in this case), as stencil algorithm to do the advection (current options are [`upwind1_stencil`](@ref)).
We also specify zero gradient boundary conditions.

Then, we couple the advection operator to the rest of the system.

```@example adv
adv = AdvectionOperator(300.0, upwind1_stencil, ZeroGradBC())

csys = couple(csys, adv)
```

Now, we initialize a [`ODEProblem`](https://docs.sciml.ai/DiffEqDocs/stable/types/ode_types/) to run our demonstration.
We use the `Tsit5` time integrator for our emissions system of equations, and a time integration scheme for our advection operator (`SSPRK22` in this case).
Refer [here](https://docs.sciml.ai/DiffEqDocs/stable/solvers/ode_solve/) for the available time integrator choices.
We also choose a operator splitting interval of 300 seconds.
Then, we run the simulation.

```@example adv
st = SolverStrangSerial(Tsit5(), 300.0)
prob = ODEProblem(csys, st)

@time solve(
    prob, SSPRK22(), dt = 300, save_on = false, save_start = false, save_end = false,
    initialize_save = false, progress = true, progress_steps = 1)
```

## Visualization

Finally, we can visualize the results of our simulation:

```@example adv
ds = NCDataset(outfile, "r")

imax = argmax(reshape(maximum(ds["emissions₊c"][:, :, :, :], dims = (1, 3, 4)), :))
grid = EarthSciMLBase.grid(domain)
anim = @animate for i in 1:size(ds["emissions₊c"])[4]
    plot(
        heatmap(rad2deg.(grid[1]), rad2deg.(grid[2]),
            ds["emissions₊c"][:, :, 1, i]', title = "Ground-Level", xlabel = "Longitude", ylabel = "Latitude"),
        heatmap(rad2deg.(grid[1]), grid[3], ds["emissions₊c"][:, imax, :, i]',
            title = "Vertical Cross-Section (lat=$(round(rad2deg(grid[2][imax]), digits=1)))",
            xlabel = "Longitude", ylabel = "Vertical Level"),
        size = (1200, 400)
    )
end
gif(anim, fps = 15)
```

```@setup adv
rm(outfile, force=true)
```
