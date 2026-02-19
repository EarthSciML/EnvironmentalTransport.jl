# Puff GaussianKC Model

This document demonstrates the setup and execution of a **Puff Model** for simulating the trajectory and concentration of multiple puffs. The model computes how puffs disperse in the atmosphere over time. This example uses **GaussianKC** model that calculates the time evolution of horizontal puff dispersion (sigma_x, sigma_y) based on turbulent velocity fluctuations (σu_x, σu_y). It also computes the ground-level centerline concentration (C_gl) per unit mass assuming a top-hat vertical distribution within the lowest layer. The concentration is evaluated only when the puff is within the surface layer (z_agl ≤ Δz); otherwise, it is set to zero. **GaussianKC** model must be coupled with **BoundaryLayerMixingKC** model that implements the Kantha-Clayson & Garratt turbulence parameterization for boundary layer mixing, as described in NOAA ARL-224 (https://www.arl.noaa.gov/documents/reports/arl-224.pdf) and HYSPLIT documentation.

We begin by importing the necessary libraries. 

```@example puff_gauss-kc
using Dates
using Plots
using Random
using EarthSciMLBase, EarthSciData, EnvironmentalTransport
using Aerosol
using ModelingToolkit, DiffEqBase, StochasticDiffEq
using ModelingToolkit: t
using EnvironmentalTransport: GaussianKC, PuffCoupler, GaussianKCCoupler, BoundaryLayerMixingKC, BoundaryLayerMixingKCCoupler
nothing #hide
```

## Reproducibility Setup

Here we set a fixed seed (e.g., 1234) so the random turbulence is reproducible across different runs.

```@example puff_gauss-kc
Random.seed!(1234)
```

## Simulation Parameters
The following are key simulation parameters used to define the puff model and the scenario being simulated:

start: Defines the time when the event starts.
simulationlength: Duration of the simulation (24 hours in this case).
puff_release_interval: The time interval between each puff release (in seconds).
puff_release_per_interval: The number of puffs released per time interval.
ec_0: Initial mass of elemental carbon released in each interval.

```@example puff_gauss-kc
start = DateTime(2019, 06, 15, 0, 0, 0)
simulationlength = 24 * 1
puff_release_interval = 3600.0
puff_release_per_interval = 5
ec_0 = 100.0

puffs = [
    (-120.6, 46.6, 3.0),
    (-119.0, 47.0, 5.0),
    (-121.0, 46.5, 4.0),
    (-120.8, 46.8, 3.5),
    (-120.4, 46.7, 6.0),
    (-120.9, 46.6, 2.0),
    (-119.5, 46.9, 3.0),
    (-120.7, 47.2, 5.5),
    (-120.2, 46.5, 4.0),
    (-120.6, 46.3, 6.0)
]

Δλ_deg = 0.3125
Δφ_deg = 0.25
Δλ = deg2rad(Δλ_deg)
Δφ = deg2rad(Δφ_deg)
```

## Domain and Model

We define the simulation domain, including the range of longitudes, latitudes, and vertical levels. Then, we couple the models necessary for simulating particle dispersion and mixing, such as Puff, BoundaryLayerMixingKC, and GaussianKC.

DomainInfo: Defines the spatial and temporal extent of the simulation, including longitude, latitude, and vertical levels.

```@example puff_gauss-kc
domain = DomainInfo(
    start, start + Hour(simulationlength);
    lonrange = deg2rad(-130 - Δλ_deg):Δλ:deg2rad(-60 + Δλ_deg),
    latrange = deg2rad(25 - Δφ_deg):Δφ:deg2rad(61 + Δφ_deg),
    levrange = 1:72
)

model = couple(
    Puff(domain), 
    BoundaryLayerMixingKC(),            
    GEOSFP("0.25x0.3125", domain; stream = false),
    ElementalCarbon(),
    GaussianKC()
)

sys = convert(System, model)
equations(sys)[1:5]
```

## Solve The Model

In this step, we solve the model once to ensure that all necessary data is properly loaded and that the system is initialized correctly. We define the initial conditions for key parameters, such as sigma_x (horizontal dispersion in the x-direction), sigma_y (horizontal dispersion in the y-direction), and turbulent velocity components (wprime, uprime_x, uprime_y). We then set up the SDEProblem (Stochastic Differential Equation Problem) to model the system stochastically. The SRIW1 solver is used to solve the system of equations, accounting for the random variability in the system's behavior over time. 

```@example puff_gauss-kc
tspan = get_tspan(domain)

u0 = ModelingToolkit.get_defaults(sys)
u0[sys.GaussianKC₊sigma_x] = 0.00001
u0[sys.GaussianKC₊sigma_y] = 0.00001
u0[sys.BoundaryLayerMixingKC₊wprime] = 0.0
u0[sys.BoundaryLayerMixingKC₊uprime_x] = 0.0
u0[sys.BoundaryLayerMixingKC₊uprime_y] = 0.0

prob = SDEProblem(sys, u0, tspan)

sol = solve(prob, SRIW1(); dt = 60.0)
```

## Define Per-Puff Problems

We define the function prob_func, which sets the initial conditions for each puff. The initial release time for each puff is calculated based on the index i of the puff, and the release interval.

```@example puff_gauss-kc

function prob_func(prob, i, repeat)
    rlon = deg2rad(puffs[i][1])
    rlat = deg2rad(puffs[i][2])
    rlev = puffs[i][3]

    u0 = [
        sys.Puff₊lon => rlon,
        sys.Puff₊lat => rlat,
        sys.Puff₊lev => rlev,
        sys.ElementalCarbon₊EC => ec_0 / puff_release_per_interval
    ]

    p = [
        sys.GaussianKC₊Δz => 100,
    ]
    
    ts = (tspan[1] + floor((i-1) / puff_release_per_interval) * puff_release_interval, tspan[2])
    remake(prob; u0 = u0, tspan = ts, p = p)
end

```

## Solve Each Puff and Plot Trajectories

We solve the problem for puffs and store the results. Then, we generate an animation of the puff trajectories on a 3D map to visualize their movement and dispersion over time.

```@example puff_gauss-kc
ensemble_prob = EnsembleProblem(prob, prob_func = prob_func, safetycopy = false)

esol = solve(ensemble_prob, SRIW1(), EnsembleThreads(); trajectories = length(puffs), dt = 60.0)

vars = [sys.Puff₊lon, sys.Puff₊lat, sys.Puff₊lev]
ranges = [(Inf, -Inf), (Inf, -Inf), (Inf, -Inf)]

for sol in esol
    for (i, var) in enumerate(vars)
        if !isempty(sol)
            data = sol[var]
            current_min, current_max = ranges[i]
            ranges[i] = (min(current_min, minimum(data)), max(current_max, maximum(data)))
        end
    end
end

t_ref = EarthSciMLBase.get_tref(domain)
sim_end_time = start + Hour(simulationlength)

anim = @animate for dt in datetime2unix(start):puff_release_interval:datetime2unix(sim_end_time)
    t = dt - t_ref
    
    p = plot(
        xlim = rad2deg.(ranges[1]), 
        ylim = rad2deg.(ranges[2]), 
        zlim = ranges[3],
        title = "Time: $(unix2datetime(dt))",
        xlabel = "Longitude", ylabel = "Latitude", zlabel = "Level",
        camera = (30, 45)
    )
    
    for sol in esol
        if t < sol.t[1] || t > sol.t[end]
            continue
        end
        
        lon = rad2deg(sol(t, idxs=sys.Puff₊lon))
        lat = rad2deg(sol(t, idxs=sys.Puff₊lat))
        lev = sol(t, idxs=sys.Puff₊lev)
        conc = sol(t, idxs=sys.GaussianKC₊C_gl)
        
        marker_color = cgrad(:inferno)[min(1.0, log10(conc + 1e-9) / 5)] 
        
        scatter!(p,
            [lon], [lat], [lev],
            label = :none, 
            markercolor = marker_color, 
            markersize = 5
        )
    end
end

gif(anim, "puff_animation.gif", fps = 5)
```

## Plot Ground-Level Centerline Concentration

Next we plot the **Ground-Level Centerline Concentration** for all simulated puffs. This represents the concentration of the pollutant at the surface (per unit mass) at the center of each puff derived from the Gaussian puff equations.

```@example puff_gauss-kc
p_conc = plot(
    title = "Ground-level centerline concentration",
    xlabel = "Time",
    ylabel = "Concentration (1/m³)",
    legend = :outertopright,
    xrotation = 45
)

for (i, sol) in enumerate(esol)
    time_vals = [start + Second(round(Int, t)) for t in sol.t]
    c_gl_vals = sol[sys.GaussianKC₊C_gl]
    
    plot!(p_conc, time_vals, c_gl_vals, 
          label = "Puff $i", lw = 2, alpha = 0.8)
end

p_conc
```



