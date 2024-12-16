var documenterSearchIndex = {"docs":
[{"location":"puff/#Air-Pollution-\"Puff\"-Model-Example","page":"Puff Model","title":"Air Pollution \"Puff\" Model Example","text":"","category":"section"},{"location":"puff/","page":"Puff Model","title":"Puff Model","text":"using EarthSciMLBase, EarthSciData, EnvironmentalTransport\nusing ModelingToolkit\nusing ModelingToolkit: t\nusing DynamicQuantities\nusing DifferentialEquations\nusing Plots\nusing Dates\nusing DomainSets\n\nfirestart = DateTime(2021, 10, 1)\nfirelength = 4 * 3600 # Seconds\nsimulationlength = 1 # Days\nfirelon = deg2rad(-97)\nfirelat = deg2rad(40)\nfireradius = 0.05 # Degrees\nsamplerate = 1800.0 # Seconds\nsamples_per_time = 10 # Samples per each emission time\nfireheight = 15.0 # Vertical level (Allowing this to be automatically calculated is a work in progress).\nemis_rate = 1.0 # kg/s, fire emission rate\n\n\ngeosfp, _ = GEOSFP(\"0.5x0.625_NA\"; dtype = Float64,\n    coord_defaults = Dict(:lon => deg2rad(-97), :lat => deg2rad(40), :lev => 1.0), \n    cache_size=simulationlength*24÷3+2)\n\n@parameters lon = firelon [unit=u\"rad\"]\n@parameters lat = firelat [unit=u\"rad\"]\n@parameters lev = fireheight\n\nsim_end = firestart + Day(simulationlength)\ndomain = DomainInfo(\n    [partialderivatives_δxyδlonlat,\n        partialderivatives_δPδlev_geosfp(geosfp)],\n    constIC(16.0, t ∈ Interval(firestart, sim_end)),\n    constBC(16.0,\n        lon ∈ Interval(deg2rad(-115), deg2rad(-68.75)),\n        lat ∈ Interval(deg2rad(25), deg2rad(53.7)),\n        lev ∈ Interval(1, 72)),\n    dtype = Float64)\n\npuff = Puff(domain)\n\nmodel = couple(puff, geosfp)\nsys = convert(ODESystem, model)\nsys, _ = EarthSciMLBase.prune_observed(sys)\n\nu0 = ModelingToolkit.get_defaults(sys)\ntspan = (datetime2unix(firestart), datetime2unix(sim_end))\nprob=ODEProblem(sys, u0, tspan)\nsol = solve(prob, Tsit5()) # Solve once to make sure data is loaded.\nfunction prob_func(prob, i, repeat)\n    r = rand() * fireradius\n    θ = rand() * 2π\n    u0 = [firelon + r * cos(θ), firelat + r * sin(θ), fireheight]\n    ts = (tspan[1] + floor(i / samples_per_time) * samplerate, tspan[2])\n    remake(prob, u0 = u0, tspan = ts)\nend\neprob = EnsembleProblem(prob, prob_func = prob_func)\nesol = solve(eprob, Tsit5(); trajectories=ceil(firelength/samplerate*samples_per_time))\n\nvars = [sys.puff₊lon, sys.puff₊lat, sys.puff₊lev]\nranges = [(Inf, -Inf), (Inf, -Inf), (Inf, -Inf)]\nfor sol in esol\n    for (i, var) in enumerate(vars)\n        rng = (minimum(sol[var]), maximum(sol[var]))\n        ranges[i] = (min(ranges[i][1], rng[1]), \n            max(ranges[i][2], rng[2]))\n    end\nend\n\nanim = @animate for t in datetime2unix(firestart):samplerate:datetime2unix(sim_end)\n    p = plot(\n        xlim=rad2deg.(ranges[1]), ylim=rad2deg.(ranges[2]), zlim=ranges[3],\n        title = \"Time: $(unix2datetime(t))\",\n        xlabel = \"Longitude (deg)\", ylabel = \"Latitude (deg)\", \n        zlabel = \"Vertical Level\",\n    )\n    for sol in esol\n        if t < sol.t[1] || t > sol.t[end]\n            continue\n        end\n        scatter!(p,\n            [rad2deg(sol(t)[1])], [rad2deg(sol(t)[2])], [sol(t)[3]],\n            label = :none, markercolor=:black, markersize=1.5,\n        )\n    end\nend\ngif(anim, fps=15)","category":"page"},{"location":"benchmarks/#Redirecting...","page":"🔗 Benchmarks","title":"Redirecting...","text":"","category":"section"},{"location":"benchmarks/","page":"🔗 Benchmarks","title":"🔗 Benchmarks","text":"<html>\n<head>\n    <meta http-equiv=\"refresh\" content=\"0; url=https://transport.earthsci.dev/benchmarks/\" />\n</head>\n<body>\n    <p>If you are not redirected automatically, follow this <a href=\"https://transport.earthsci.dev/benchmarks/\">link</a>.</p>\n</body>\n</html>","category":"page"},{"location":"api/#API-Index","page":"API","title":"API Index","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"","category":"page"},{"location":"api/#API-Documentation","page":"API","title":"API Documentation","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"Modules = [EnvironmentalTransport]","category":"page"},{"location":"api/#EnvironmentalTransport.AdvectionOperator","page":"API","title":"EnvironmentalTransport.AdvectionOperator","text":"Create an EarthSciMLBase.Operator that performs advection. Advection is performed using the given stencil operator (e.g. l94_stencil or ppm_stencil). p is an optional parameter set to be used by the stencil operator. bc_type is the boundary condition type, e.g. ZeroGradBC().\n\n\n\n\n\n","category":"type"},{"location":"api/#EnvironmentalTransport.BCArray","page":"API","title":"EnvironmentalTransport.BCArray","text":"An array with external indexing implemented for boundary conditions.\n\n\n\n\n\n","category":"type"},{"location":"api/#EnvironmentalTransport.ZeroGradBC","page":"API","title":"EnvironmentalTransport.ZeroGradBC","text":"Zero gradient boundary conditions.\n\n\n\n\n\n","category":"type"},{"location":"api/#EnvironmentalTransport.ZeroGradBCArray","page":"API","title":"EnvironmentalTransport.ZeroGradBCArray","text":"An array with zero gradient boundary conditions.\n\n\n\n\n\n","category":"type"},{"location":"api/#EnvironmentalTransport.Puff-Tuple{EarthSciMLBase.DomainInfo}","page":"API","title":"EnvironmentalTransport.Puff","text":"Puff(\n    di::EarthSciMLBase.DomainInfo;\n    name\n) -> ModelingToolkit.ODESystem\n\n\nCreate a Lagrangian transport model which advects a \"puff\" or particle of matter within a fluid velocity field.\n\nModel boundaries are set by the DomainInfo argument. The model sets boundaries at the ground and model bottom and top, preventing the puff from crossing those boundaries. If the puff reaches one of the horizontal boundaries, the simulation is stopped.\n\n\n\n\n\n","category":"method"},{"location":"api/#EnvironmentalTransport.get_vf-Tuple{Any, AbstractString, Any}","page":"API","title":"EnvironmentalTransport.get_vf","text":"get_vf(sim, varname, data_f)\n\n\nReturn a function that gets the wind velocity at a given place and time for the given varname. data_f should be a function that takes a time and three spatial coordinates and returns the value of the wind speed in the direction indicated by varname.\n\n\n\n\n\n","category":"method"},{"location":"api/#EnvironmentalTransport.get_Δ-Tuple{EarthSciMLBase.Simulator, AbstractString}","page":"API","title":"EnvironmentalTransport.get_Δ","text":"get_Δ(sim, varname)\n\n\nReturn a function that gets the grid spacing at a given place and time for the given varname.\n\n\n\n\n\n","category":"method"},{"location":"api/#EnvironmentalTransport.l94_stencil-NTuple{4, Any}","page":"API","title":"EnvironmentalTransport.l94_stencil","text":"l94_stencil(ϕ, U, Δt, Δz; kwargs...)\n\n\nL94 advection in 1-D (Lin et al., 1994)\n\nϕ is the scalar field at the current time step, it should be a vector of length 5.\nU is the velocity at both edges of the central grid cell, it should be a vector of length 2.\nΔt is the length of the time step.\nΔz is the grid spacing.\n\nThe output will be time derivative of the central index (i.e. index 3) of the ϕ vector (i.e. dϕ/dt).\n\n(The output is dependent on the Courant number, which depends on Δt, so Δt needs to be an input to the function.)\n\n\n\n\n\n","category":"method"},{"location":"api/#EnvironmentalTransport.ppm_stencil-NTuple{4, Any}","page":"API","title":"EnvironmentalTransport.ppm_stencil","text":"ppm_stencil(ϕ, U, Δt, Δz; kwargs...)\n\n\nPPM advection in 1-D (Collela and Woodward, 1984)\n\nϕ is the scalar field at the current time step, it should be a vector of length 8 (3 cells on the left, the central cell, and 4 cells on the right).\nU is the velocity at both edges of the central grid cell, it should be a vector of length 2.\nΔt is the length of the time step.\nΔz is the grid spacing.\n\nThe output will be time derivative of the central index (i.e. index 4) of the ϕ vector (i.e. dϕ/dt).\n\n(The output is dependent on the Courant number, which depends on Δt, so Δt needs to be an input to the function.)\n\n\n\n\n\n","category":"method"},{"location":"api/#EnvironmentalTransport.stencil_size-Tuple{typeof(l94_stencil)}","page":"API","title":"EnvironmentalTransport.stencil_size","text":"Return the left and right stencil size of the L94 stencil. \n\n\n\n\n\n","category":"method"},{"location":"api/#EnvironmentalTransport.stencil_size-Tuple{typeof(ppm_stencil)}","page":"API","title":"EnvironmentalTransport.stencil_size","text":"Return the left and right stencil size of the PPM stencil. \n\n\n\n\n\n","category":"method"},{"location":"api/#EnvironmentalTransport.stencil_size-Tuple{typeof(upwind1_stencil)}","page":"API","title":"EnvironmentalTransport.stencil_size","text":"Return the left and right stencil size of the first-order upwind stencil. \n\n\n\n\n\n","category":"method"},{"location":"api/#EnvironmentalTransport.stencil_size-Tuple{typeof(upwind2_stencil)}","page":"API","title":"EnvironmentalTransport.stencil_size","text":"Return the left and right stencil size of the second-order upwind stencil. \n\n\n\n\n\n","category":"method"},{"location":"api/#EnvironmentalTransport.upwind1_stencil-NTuple{4, Any}","page":"API","title":"EnvironmentalTransport.upwind1_stencil","text":"upwind1_stencil(ϕ, U, Δt, Δz; p)\n\n\nFirst-order upwind advection in 1-D: https://en.wikipedia.org/wiki/Upwind_scheme.\n\nϕ is the scalar field at the current time step, it should be a vector of length 3 (1 cell on the left, the central cell, and 1 cell on the right).\nU is the velocity at both edges of the central grid cell, it should be a vector of length 2.\nΔt is the length of the time step.\nΔz is the grid spacing.\n\nThe output will be time derivative of the central index (i.e. index 2) of the ϕ vector (i.e. dϕ/dt).\n\nΔt and p are not used, but are function arguments for consistency with other operators.\n\n\n\n\n\n","category":"method"},{"location":"api/#EnvironmentalTransport.upwind2_stencil-NTuple{4, Any}","page":"API","title":"EnvironmentalTransport.upwind2_stencil","text":"upwind2_stencil(ϕ, U, Δt, Δz; kwargs...)\n\n\nSecond-order upwind advection in 1-D, otherwise known as linear-upwind differencing (LUD): https://en.wikipedia.org/wiki/Upwind_scheme.\n\nϕ is the scalar field at the current time step, it should be a vector of length 5 (2 cells on the left, the central cell, and 2 cells on the right).\nU is the velocity at both edges of the central grid cell, it should be a vector of length 2.\nΔt is the length of the time step.\nΔz is the grid spacing.\n\nThe output will be time derivative of the central index (i.e. index 3) of the ϕ vector (i.e. dϕ/dt).\n\n(Δt is not used, but is a function argument for consistency with other operators.)\n\n\n\n\n\n","category":"method"},{"location":"api/#EnvironmentalTransport.vf_x-Tuple{Any, Any}","page":"API","title":"EnvironmentalTransport.vf_x","text":"Get a value from the x-direction velocity field.\n\n\n\n\n\n","category":"method"},{"location":"api/#EnvironmentalTransport.vf_y-Tuple{Any, Any}","page":"API","title":"EnvironmentalTransport.vf_y","text":"Get a value from the y-direction velocity field.\n\n\n\n\n\n","category":"method"},{"location":"api/#EnvironmentalTransport.vf_z-Tuple{Any, Any}","page":"API","title":"EnvironmentalTransport.vf_z","text":"Get a value from the z-direction velocity field.\n\n\n\n\n\n","category":"method"},{"location":"api/#EnvironmentalTransport.Δf-Tuple{Any, Any}","page":"API","title":"EnvironmentalTransport.Δf","text":"function to get grid deltas.\n\n\n\n\n\n","category":"method"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = EnvironmentalTransport","category":"page"},{"location":"#EnvironmentalTransport:-Algorithms-for-Environmental-Mass-Transport","page":"Home","title":"EnvironmentalTransport: Algorithms for Environmental Mass Transport","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for EnvironmentalTransport.jl.","category":"page"},{"location":"","page":"Home","title":"Home","text":"This package contains algorithms for simulating environmental mass transport, for use with the EarthSciML ecosystem.","category":"page"},{"location":"#Installation","page":"Home","title":"Installation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"using Pkg\nPkg.add(\"EnvironmentalTransport\")","category":"page"},{"location":"#Feature-Summary","page":"Home","title":"Feature Summary","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This package contains types and functions designed to simplify the process of constructing and composing symbolically-defined Earth Science model components together.","category":"page"},{"location":"#Feature-List","page":"Home","title":"Feature List","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Numerical Advection","category":"page"},{"location":"#Contributing","page":"Home","title":"Contributing","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Please refer to the SciML ColPrac: Contributor's Guide on Collaborative Practices for Community Packages for guidance on PRs, issues, and other matters relating to contributing.","category":"page"},{"location":"#Reproducibility","page":"Home","title":"Reproducibility","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"<details><summary>The documentation of this EnvironmentalTransport package was built using these direct dependencies,</summary>","category":"page"},{"location":"","page":"Home","title":"Home","text":"using Pkg # hide\nPkg.status() # hide","category":"page"},{"location":"","page":"Home","title":"Home","text":"</details>","category":"page"},{"location":"","page":"Home","title":"Home","text":"<details><summary>and using this machine and Julia version.</summary>","category":"page"},{"location":"","page":"Home","title":"Home","text":"using InteractiveUtils # hide\nversioninfo() # hide","category":"page"},{"location":"","page":"Home","title":"Home","text":"</details>","category":"page"},{"location":"","page":"Home","title":"Home","text":"<details><summary>A more complete overview of all dependencies and their versions is also provided.</summary>","category":"page"},{"location":"","page":"Home","title":"Home","text":"using Pkg # hide\nPkg.status(;mode = PKGMODE_MANIFEST) # hide","category":"page"},{"location":"","page":"Home","title":"Home","text":"</details>","category":"page"},{"location":"","page":"Home","title":"Home","text":"You can also download the \n<a href=\"","category":"page"},{"location":"","page":"Home","title":"Home","text":"using TOML\nusing Markdown\nversion = TOML.parse(read(\"../../Project.toml\",String))[\"version\"]\nname = TOML.parse(read(\"../../Project.toml\",String))[\"name\"]\nlink = Markdown.MD(\"https://github.com/EarthSciML/\"*name*\".jl/tree/gh-pages/v\"*version*\"/assets/Manifest.toml\")","category":"page"},{"location":"","page":"Home","title":"Home","text":"\">manifest</a> file and the\n<a href=\"","category":"page"},{"location":"","page":"Home","title":"Home","text":"using TOML\nusing Markdown\nversion = TOML.parse(read(\"../../Project.toml\",String))[\"version\"]\nname = TOML.parse(read(\"../../Project.toml\",String))[\"name\"]\nlink = Markdown.MD(\"https://github.com/EarthSciML/\"*name*\".jl/tree/gh-pages/v\"*version*\"/assets/Project.toml\")","category":"page"},{"location":"","page":"Home","title":"Home","text":"\">project</a> file.","category":"page"},{"location":"advection/#Numerical-Advection-Operator","page":"Advection","title":"Numerical Advection Operator","text":"","category":"section"},{"location":"advection/","page":"Advection","title":"Advection","text":"We have two ways to represent phenomena that occur across space such as advection: through symbolically-defined partial differential equation systems, which will be covered elsewhere in documentation, and through numerically-implemented algorithms. This is an example of the latter. (Currently, symbolically defined PDEs are too slow to be used in large-scale simulations.)","category":"page"},{"location":"advection/","page":"Advection","title":"Advection","text":"To demonstrate how it works, let's first set up our environment:","category":"page"},{"location":"advection/","page":"Advection","title":"Advection","text":"using EnvironmentalTransport\nusing EarthSciMLBase, EarthSciData\nusing ModelingToolkit, DomainSets, DifferentialEquations\nusing ModelingToolkit: t, D\nusing DynamicQuantities\nusing Distributions, LinearAlgebra\nusing Dates\nusing NCDatasets, Plots\nnothing #hide","category":"page"},{"location":"advection/#Emissions","page":"Advection","title":"Emissions","text":"","category":"section"},{"location":"advection/","page":"Advection","title":"Advection","text":"Next, let's set up an emissions scenario to advect. We have some emissions centered around Portland, starting at the beginning of the simulation and then tapering off:","category":"page"},{"location":"advection/","page":"Advection","title":"Advection","text":"starttime = datetime2unix(DateTime(2022, 5, 1, 0, 0))\nendtime = datetime2unix(DateTime(2022, 6, 1, 0, 0))\n\n@parameters(\n    lon=-97.0, [unit=u\"rad\"],\n    lat=30.0, [unit=u\"rad\"],\n    lev=1.0,\n)\n\nfunction emissions(μ_lon, μ_lat, σ)\n    @variables c(t) = 0.0 [unit=u\"kg\"]\n    @constants v_emis = 50.0 [unit=u\"kg/s\"]\n    @constants t_unit = 1.0 [unit=u\"s\"] # Needed so that arguments to `pdf` are unitless.\n    dist = MvNormal([starttime, μ_lon, μ_lat, 1], Diagonal(map(abs2, [3600.0*24*3, σ, σ, 1])))\n    ODESystem([D(c) ~ pdf(dist, [t/t_unit, lon, lat, lev]) * v_emis],\n        t, name = :emissions)\nend\n\nemis = emissions(deg2rad(-122.6), deg2rad(45.5), deg2rad(1))","category":"page"},{"location":"advection/#Coupled-System","page":"Advection","title":"Coupled System","text":"","category":"section"},{"location":"advection/","page":"Advection","title":"Advection","text":"Next, let's set up a spatial and temporal domain for our simulation, and some input data from GEOS-FP to get wind fields for our advection. We need to use coord_defaults in this case to get the GEOS-FP data to work correctly, but  it doesn't matter what the defaults are. We also set up an outputter to save the results of our simulation, and couple the components we've created so far into a  single system.","category":"page"},{"location":"advection/","page":"Advection","title":"Advection","text":"geosfp, geosfp_updater = GEOSFP(\"0.5x0.625_NA\"; dtype = Float64,\n    coord_defaults = Dict(:lon => -97.0, :lat => 30.0, :lev => 1.0))\n\ndomain = DomainInfo(\n    [partialderivatives_δxyδlonlat,\n        partialderivatives_δPδlev_geosfp(geosfp)],\n    constIC(16.0, t ∈ Interval(starttime, endtime)),\n    constBC(16.0,\n        lon ∈ Interval(deg2rad(-129), deg2rad(-61)),\n        lat ∈ Interval(deg2rad(11), deg2rad(59)),\n        lev ∈ Interval(1, 30)),\n    dtype = Float64)\n\noutfile = (\"RUNNER_TEMP\" ∈ keys(ENV) ? ENV[\"RUNNER_TEMP\"] : tempname()) * \"out.nc\" # This is just a location to save the output.\noutput = NetCDFOutputter(outfile, 3600.0)\n\ncsys = couple(emis, domain, geosfp, geosfp_updater, output) ","category":"page"},{"location":"advection/#Advection-Operator","page":"Advection","title":"Advection Operator","text":"","category":"section"},{"location":"advection/","page":"Advection","title":"Advection","text":"Next, we create an AdvectionOperator to perform advection.  We need to specify a time step (600 s in this case), as stencil algorithm to do the advection (current options are l94_stencil and ppm_stencil). We also specify zero gradient boundary conditions.","category":"page"},{"location":"advection/","page":"Advection","title":"Advection","text":"Then, we couple the advection operator to the rest of the system.","category":"page"},{"location":"advection/","page":"Advection","title":"Advection","text":"warning: Warning\nThe advection operator will automatically couple itself to available wind fields such as those from GEOS-FP, but the wind-field component (e.g.. geosfp) must already be present in the coupled system for this to work correctly.","category":"page"},{"location":"advection/","page":"Advection","title":"Advection","text":"adv = AdvectionOperator(300.0, upwind1_stencil, ZeroGradBC())\n\ncsys = couple(csys, adv)","category":"page"},{"location":"advection/","page":"Advection","title":"Advection","text":"Now, we initialize a Simulator to run our demonstration.  We specify a horizontal resolution of 4 degrees and a vertical resolution of 1 level, and use the Tsit5 time integrator for our emissions system of equations, and a time integration scheme for our advection operator (SSPRK22 in this case). Refer here for the available time integrator choices. We also choose a operator splitting interval of 600 seconds. Then, we run the simulation.","category":"page"},{"location":"advection/","page":"Advection","title":"Advection","text":"sim = Simulator(csys, [deg2rad(1), deg2rad(1), 1])\nst = SimulatorStrangThreads(Tsit5(), SSPRK22(), 300.0)\n\n@time run!(sim, st, save_on=false, save_start=false, save_end=false, \n    initialize_save=false)","category":"page"},{"location":"advection/#Visualization","page":"Advection","title":"Visualization","text":"","category":"section"},{"location":"advection/","page":"Advection","title":"Advection","text":"Finally, we can visualize the results of our simulation:","category":"page"},{"location":"advection/","page":"Advection","title":"Advection","text":"ds = NCDataset(outfile, \"r\")\n\nimax = argmax(reshape(maximum(ds[\"emissions₊c\"][:, :, :, :], dims=(1, 3, 4)), :))\nanim = @animate for i ∈ 1:size(ds[\"emissions₊c\"])[4]\n    plot(\n        heatmap(rad2deg.(sim.grid[1]), rad2deg.(sim.grid[2]), \n            ds[\"emissions₊c\"][:, :, 1, i]', title=\"Ground-Level\", xlabel=\"Longitude\", ylabel=\"Latitude\"),\n        heatmap(rad2deg.(sim.grid[1]), sim.grid[3], ds[\"emissions₊c\"][:, imax, :, i]', \n            title=\"Vertical Cross-Section (lat=$(round(rad2deg(sim.grid[2][imax]), digits=1)))\", \n            xlabel=\"Longitude\", ylabel=\"Vertical Level\"),\n    )\nend\ngif(anim, fps = 15)","category":"page"},{"location":"advection/","page":"Advection","title":"Advection","text":"rm(outfile, force=true)","category":"page"}]
}