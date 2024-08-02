var documenterSearchIndex = {"docs":
[{"location":"api/#API-Index","page":"API","title":"API Index","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"","category":"page"},{"location":"api/#API-Documentation","page":"API","title":"API Documentation","text":"","category":"section"},{"location":"api/","page":"API","title":"API","text":"Modules = [EnvironmentalTransport]","category":"page"},{"location":"api/#EnvironmentalTransport.AdvectionOperator","page":"API","title":"EnvironmentalTransport.AdvectionOperator","text":"Create an EarthSciMLBase.Operator that performs advection. Δt is the time step size and alg is the ODE solver algorithm to use.  Advection is performed using the given stencil operator  (e.g. l94_stencil or ppm_stencil).  p is an optional parameter set to be used by the stencil operator. Any additional keyword arguments are passed to the ODEProblem and ODEIntegrator constructors.\n\n\n\n\n\n","category":"type"},{"location":"api/#EarthSciMLBase.couple-Tuple{EarthSciMLBase.CoupledSystem, AdvectionOperator}","page":"API","title":"EarthSciMLBase.couple","text":"couple(c, op)\n\n\nCouple the advection operator into the CoupledSystem. This function mutates the operator to add the windfield variables. There must already be a source of wind data in the coupled system for this to work. Currently the only valid source of wind data is EarthSciData.GEOSFP.\n\n\n\n\n\n","category":"method"},{"location":"api/#EnvironmentalTransport.advect_1d_op-NTuple{6, Any}","page":"API","title":"EnvironmentalTransport.advect_1d_op","text":"advect_1d_op(dtype, shape, stencil, v_f, Δx_f, Δt; p)\n\n\nCreate a SciMLOperator to perform 1D advection.\n\nArguments:     * dtype: The data type of the input and output arrays, e.g. Float64 or Float32.     * shape: The shape of the input vector or matrix, e.g. (8,) or (8,10).              If the input is a matrix, 1D advection will be applied to each of the             columns in the matrix.     * stencil: The stencil operator, e.g. l94_stencil or ppm_stencil.     *  v_f: A function to get the wind velocity at a given place and time. For vector inputs             the function signature should be v_f(i, t), where i is the staggered-grid              index and t is time. For matrix, inputs, the signature should be v_f(i,j,t),             where i is a staggered grid index, j is the non-staggered grid column index             (where max(i) == shape(2)), andtis time.     *Δxf: A function to get the grid spacing at a given place and time. For vector inputs             the function signature should beΔxf(i, t), whereiis the grid              index andtis time. For matrix, inputs, the signature should bev_f(i,j,t),             whereiis a grid index,jis the column index             (wheremax(i) == shape(2)), and t is time.     * Δt: The time step size, which is assumed to be fixed.     * p: Optional parameters to pass to the stencil function.\n\n\n\n\n\n","category":"method"},{"location":"api/#EnvironmentalTransport.get_vf-Tuple{Any, AbstractString, Any, Any}","page":"API","title":"EnvironmentalTransport.get_vf","text":"get_vf(sim, varname, data_f, idx_f)\n\n\nReturn a function that gets the wind velocity at a given place and time for the given varname. vardict should be a dictionary with keys that are strings with the  possible varnames and values that are the corresponding variables in the ODESystem that should be used to get the wind velocity values. idx_f should be an index function of the type returned by EnvironmentalTransport.orderby_op. data_f should be a function that takes a time and three spatial coordinates and returns the value of  the wind speed in the direction indicated by varname.\n\n\n\n\n\n","category":"method"},{"location":"api/#EnvironmentalTransport.get_Δ-Tuple{EarthSciMLBase.Simulator, AbstractString}","page":"API","title":"EnvironmentalTransport.get_Δ","text":"get_Δ(sim, varname)\n\n\nReturn a function that gets the grid spacing at a given place and time for the given varname.\n\n\n\n\n\n","category":"method"},{"location":"api/#EnvironmentalTransport.l94_stencil-NTuple{4, Any}","page":"API","title":"EnvironmentalTransport.l94_stencil","text":"l94_stencil(ϕ, U, Δt, Δz; kwargs...)\n\n\nL94 advection in 1-D (Lin et al., 1994)\n\nϕ is the scalar field at the current time step, it should be a vector of length 5.\nU is the velocity at both edges of the central grid cell, it should be a vector of length 2.\nΔt is the length of the time step.\nΔz is the grid spacing.\n\nThe output will be time derivative of the central index (i.e. index 3)  of the ϕ vector (i.e. dϕ/dt).\n\n(The output is dependent on the Courant number, which depends on Δt, so Δt needs to be an input to the function.)\n\n\n\n\n\n","category":"method"},{"location":"api/#EnvironmentalTransport.orderby_op-Tuple{Any, AbstractVector, Int64}","page":"API","title":"EnvironmentalTransport.orderby_op","text":"orderby_op(dtype, shape, index; p)\n\n\nCreate a SciMLOperator to reorder a tensor into a matrix,  where each column in the matrix is an element in the given  index of the original tensor. dtype is the type of  the input and output data, e.g. Float64 or Float32, and shape is the shape of the tensor, e.g. [2,3,5].\n\nThe inverse of the operator can be used to put the tensor back into the orinal order. So if op is the operator and  u is the original tensor, then: x = op * u[:] returns the reordered tensor x, and u_prime = inv(op) * x returns a vector version of the orginal tensor, so uprime == u[:].\n\nThis function returns the operator and also a function idx_f that takes a  column number of the transformed matrix as an input and returns a vector of  CartesianIndexes in the original tensfor that make up that transformed matrix column.\n\n\n\n\n\n","category":"method"},{"location":"api/#EnvironmentalTransport.ppm_stencil-NTuple{4, Any}","page":"API","title":"EnvironmentalTransport.ppm_stencil","text":"ppm_stencil(ϕ, U, Δt, Δz; kwargs...)\n\n\nPPM advection in 1-D (Collela and Woodward, 1984)\n\nϕ is the scalar field at the current time step, it should be a vector of length 8 (3 cells on the left, the central cell, and 4 cells on the right).\nU is the velocity at both edges of the central grid cell, it should be a vector of length 2.\nΔt is the length of the time step.\nΔz is the grid spacing.\n\nThe output will be time derivative of the central index (i.e. index 4)  of the ϕ vector (i.e. dϕ/dt).\n\n(The output is dependent on the Courant number, which depends on Δt, so Δt needs to be an input to the function.)\n\n\n\n\n\n","category":"method"},{"location":"api/#EnvironmentalTransport.simulator_advection_1d-Tuple{EarthSciMLBase.Simulator, Any, Any}","page":"API","title":"EnvironmentalTransport.simulator_advection_1d","text":"simulator_advection_1d(sim, op, varname; p)\n\n\nCreate a 1D advection SciMLOperator for the given variable name varname. vardict should be a dictionary with keys that are strings with the  possible varnames and values that are the corresponding variables in the ODESystem that should be used to get the wind velocity values. p is an optional parameter set that can be passed to the stencil function.\n\n\n\n\n\n","category":"method"},{"location":"api/#EnvironmentalTransport.stencil_size-Tuple{typeof(l94_stencil)}","page":"API","title":"EnvironmentalTransport.stencil_size","text":"Return the left and right stencil size of the L94 stencil. \n\n\n\n\n\n","category":"method"},{"location":"api/#EnvironmentalTransport.stencil_size-Tuple{typeof(ppm_stencil)}","page":"API","title":"EnvironmentalTransport.stencil_size","text":"Return the left and right stencil size of the PPM stencil. \n\n\n\n\n\n","category":"method"},{"location":"api/#EnvironmentalTransport.tensor_advection_op-NTuple{4, Any}","page":"API","title":"EnvironmentalTransport.tensor_advection_op","text":"tensor_advection_op(\n    dtype,\n    shape,\n    index,\n    stencil;\n    bc_opf,\n    p,\n    kwargs...\n)\n\n\nReturn a SciMLOperator that performs 1D advection on the dimension of a  tensor given by index, where the original tensor has the given data type dtype  (e.g. Float32 or Float64), and given shape (e.g. (10, 20, 30)). Advection is performed using the given stencil operator  (e.g. l94_stencil or ppm_stencil). \n\nOptionally, a function can be  specified to create boundary conditions, where the function should have the signature bc_opf(vector_length, stencil). See the default boundary condition operator  EnvironmentalTransport.zerograd_bc_op for more information.\n\nThis function returns a function that creates the the operator and also a  function idx_f that takes a  column number of the transformed matrix as an input and returns a vector of  CartesianIndexes in the original tensor that make up that transformed matrix column.\n\nThe first returned function (the function that creates the operator) can be called with the  following arguments to create the operator:\n\n*  `v_f`: A function to get the wind velocity at a given place and time. For vector inputs\n        the function signature should be `v_f(i, t)`, where `i` is the staggered-grid \n        index and `t` is time. For matrix, inputs, the signature should be `v_f(i,j,t)`,\n        where `i` is a staggered grid index, `j` is the non-staggered grid column index\n        (where `max(i) == shape(2)`)`, and `t` is time.\n* `Δx_f`: A function to get the grid spacing at a given place and time. For vector inputs\n        the function signature should be `Δx_f(i, t)`, where `i` is the grid \n        index and `t` is time. For matrix, inputs, the signature should be `v_f(i,j,t)`,\n        where `i` is a grid index, `j` is the column index\n        (where `max(i) == shape(2)`)`, and `t` is time.\n* `Δt`: The time step size, which is assumed to be fixed.\n* `p`: Optional parameters to pass to the stencil function.\n\nThe reason for the two-step process is that Δv_f and Δx_fmay be dependent onidxf, so we need to returnidxf` before we create the operator.\n\n\n\n\n\n","category":"method"},{"location":"api/#EnvironmentalTransport.zerograd_bc_op-Tuple{Any, Any}","page":"API","title":"EnvironmentalTransport.zerograd_bc_op","text":"zerograd_bc_op(vec_length, stencil)\n\n\nCreate an SciMLOperator which adds zero gradient Newmann boundary conditions to a 1D array of length vec_length, which work with the given stencil.\n\n\n\n\n\n","category":"method"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = EnvironmentalTransport","category":"page"},{"location":"#EnvironmentalTransport:-Algorithms-for-Environmental-Mass-Transport","page":"Home","title":"EnvironmentalTransport: Algorithms for Environmental Mass Transport","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for EnvironmentalTransport.jl.","category":"page"},{"location":"","page":"Home","title":"Home","text":"This package contains algorithms for simulating environmental mass transport, for use with the EarthSciML ecosystem.","category":"page"},{"location":"#Installation","page":"Home","title":"Installation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"using Pkg\nPkg.add(\"EnvironmentalTransport\")","category":"page"},{"location":"#Feature-Summary","page":"Home","title":"Feature Summary","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This package contains types and functions designed to simplify the process of constructing and composing symbolically-defined Earth Science model components together.","category":"page"},{"location":"#Feature-List","page":"Home","title":"Feature List","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Numerical Advection","category":"page"},{"location":"#Contributing","page":"Home","title":"Contributing","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Please refer to the SciML ColPrac: Contributor's Guide on Collaborative Practices for Community Packages for guidance on PRs, issues, and other matters relating to contributing.","category":"page"},{"location":"#Reproducibility","page":"Home","title":"Reproducibility","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"<details><summary>The documentation of this EnvironmentalTransport package was built using these direct dependencies,</summary>","category":"page"},{"location":"","page":"Home","title":"Home","text":"using Pkg # hide\nPkg.status() # hide","category":"page"},{"location":"","page":"Home","title":"Home","text":"</details>","category":"page"},{"location":"","page":"Home","title":"Home","text":"<details><summary>and using this machine and Julia version.</summary>","category":"page"},{"location":"","page":"Home","title":"Home","text":"using InteractiveUtils # hide\nversioninfo() # hide","category":"page"},{"location":"","page":"Home","title":"Home","text":"</details>","category":"page"},{"location":"","page":"Home","title":"Home","text":"<details><summary>A more complete overview of all dependencies and their versions is also provided.</summary>","category":"page"},{"location":"","page":"Home","title":"Home","text":"using Pkg # hide\nPkg.status(;mode = PKGMODE_MANIFEST) # hide","category":"page"},{"location":"","page":"Home","title":"Home","text":"</details>","category":"page"},{"location":"","page":"Home","title":"Home","text":"You can also download the \n<a href=\"","category":"page"},{"location":"","page":"Home","title":"Home","text":"using TOML\nusing Markdown\nversion = TOML.parse(read(\"../../Project.toml\",String))[\"version\"]\nname = TOML.parse(read(\"../../Project.toml\",String))[\"name\"]\nlink = Markdown.MD(\"https://github.com/EarthSciML/\"*name*\".jl/tree/gh-pages/v\"*version*\"/assets/Manifest.toml\")","category":"page"},{"location":"","page":"Home","title":"Home","text":"\">manifest</a> file and the\n<a href=\"","category":"page"},{"location":"","page":"Home","title":"Home","text":"using TOML\nusing Markdown\nversion = TOML.parse(read(\"../../Project.toml\",String))[\"version\"]\nname = TOML.parse(read(\"../../Project.toml\",String))[\"name\"]\nlink = Markdown.MD(\"https://github.com/EarthSciML/\"*name*\".jl/tree/gh-pages/v\"*version*\"/assets/Project.toml\")","category":"page"},{"location":"","page":"Home","title":"Home","text":"\">project</a> file.","category":"page"},{"location":"advection/#Numerical-Advection-Operator","page":"Advection","title":"Numerical Advection Operator","text":"","category":"section"},{"location":"advection/","page":"Advection","title":"Advection","text":"We have two ways to represent phenomena that occur across space such as advection: through symbolically-defined partial differential equation systems, which will be covered elsewhere in documentation, and through numerically-implemented algorithms. This is an example of the latter. (Currently, symbolically defined PDEs are too slow to be used in large-scale simulations.)","category":"page"},{"location":"advection/","page":"Advection","title":"Advection","text":"To demonstrate how it works, let's first set up our environment:","category":"page"},{"location":"advection/","page":"Advection","title":"Advection","text":"using EnvironmentalTransport\nusing EarthSciMLBase, EarthSciData\nusing ModelingToolkit, DomainSets, DifferentialEquations\nusing Distributions, LinearAlgebra\nusing Dates\nusing NCDatasets, Plots\nnothing #hide","category":"page"},{"location":"advection/#Emissions","page":"Advection","title":"Emissions","text":"","category":"section"},{"location":"advection/","page":"Advection","title":"Advection","text":"Next, let's set up an emissions scenario to advect. We have some emissions centered around Portland, starting at the beginning of the simulation and then tapering off:","category":"page"},{"location":"advection/","page":"Advection","title":"Advection","text":"starttime = datetime2unix(DateTime(2022, 5, 1, 0, 0))\nendtime = datetime2unix(DateTime(2022, 5, 15, 0, 0))\n\n@parameters lon=0.0 lat=0.0 lev=1.0 t\n\nfunction emissions(t, μ_lon, μ_lat, σ)\n    @variables c(t) = 0.0\n    dist =MvNormal([starttime, μ_lon, μ_lat, 1], Diagonal(map(abs2, [3600.0, σ, σ, 1])))\n    D = Differential(t)\n    ODESystem([D(c) ~ pdf(dist, [t, lon, lat, lev]) * 50],\n        t, name = :Test₊emissions)\nend\n\nemis = emissions(t, deg2rad(-122.6), deg2rad(45.5), 0.1)","category":"page"},{"location":"advection/#Coupled-System","page":"Advection","title":"Coupled System","text":"","category":"section"},{"location":"advection/","page":"Advection","title":"Advection","text":"Next, let's set up a spatial and temporal domain for our simulation, and some input data from GEOS-FP to get wind fields for our advection. We need to use coord_defaults in this case to get the GEOS-FP data to work correctly, but  it doesn't matter what the defaults are. We also set up an outputter to save the results of our simulation, and couple the components we've created so far into a  single system.","category":"page"},{"location":"advection/","page":"Advection","title":"Advection","text":"geosfp = GEOSFP(\"4x5\", t; dtype = Float64,\n    coord_defaults = Dict(:lon => 0.0, :lat => 0.0, :lev => 1.0))\n\ndomain = DomainInfo(\n    [partialderivatives_δxyδlonlat,\n        partialderivatives_δPδlev_geosfp(geosfp)],\n    constIC(16.0, t ∈ Interval(starttime, endtime)),\n    constBC(16.0,\n        lon ∈ Interval(deg2rad(-130.0), deg2rad(-60.0)),\n        lat ∈ Interval(deg2rad(9.75), deg2rad(60.0)),\n        lev ∈ Interval(1, 15)),\n    dtype = Float64)\n\noutfile = (\"RUNNER_TEMP\" ∈ keys(ENV) ? ENV[\"RUNNER_TEMP\"] : tempname()) * \"out.nc\" # This is just a location to save the output.\noutput = NetCDFOutputter(outfile, 3600.0)\n\ncsys = couple(emis, domain, geosfp, output) ","category":"page"},{"location":"advection/#Advection-Operator","page":"Advection","title":"Advection Operator","text":"","category":"section"},{"location":"advection/","page":"Advection","title":"Advection","text":"Next, we create an AdvectionOperator to perform advection.  We need to specify a time step (600 s in this case), as stencil algorithm to do the advection (current options are l94_stencil and ppm_stencil), and a time integration scheme (SSPRK22 in this case). Refer here for the available time integrator choices.","category":"page"},{"location":"advection/","page":"Advection","title":"Advection","text":"Then, we couple the advection operator to the rest of the system.","category":"page"},{"location":"advection/","page":"Advection","title":"Advection","text":"warning: Warning\nThe advection operator will automatically couple itself to available wind fields such as those from GEOS-FP, but the wind-field component (e.g.. geosfp) must already be present in the coupled system for this to work correctly.","category":"page"},{"location":"advection/","page":"Advection","title":"Advection","text":"adv = AdvectionOperator(600.0, l94_stencil, SSPRK22())\n\ncsys = couple(csys, adv)","category":"page"},{"location":"advection/","page":"Advection","title":"Advection","text":"Now, we initialize a Simulator to run our demonstration.  We specify a horizontal resolution of 4 degrees and a vertical resolution of 1 level, and use the Tsit5 time integrator for our emissions system of equations. Then, we run the simulation.","category":"page"},{"location":"advection/","page":"Advection","title":"Advection","text":"sim = Simulator(csys, [deg2rad(4), deg2rad(4), 1], Tsit5())\n\n@time run!(sim)","category":"page"},{"location":"advection/#Visualization","page":"Advection","title":"Visualization","text":"","category":"section"},{"location":"advection/","page":"Advection","title":"Advection","text":"Finally, we can visualize the results of our simulation:","category":"page"},{"location":"advection/","page":"Advection","title":"Advection","text":"ds = NCDataset(outfile, \"r\")\n\nanim = @animate for i ∈ 1:size(ds[\"Test₊emissions₊c\"])[4]\n    plot(\n        heatmap(ds[\"Test₊emissions₊c\"][:, :, 1, i]', title=\"Ground-Level\"),\n        heatmap(ds[\"Test₊emissions₊c\"][:, 10, :, i]', title=\"Vertical Cross-Section\"),\n    )\nend\ngif(anim, fps = 15)","category":"page"},{"location":"advection/","page":"Advection","title":"Advection","text":"rm(outfile, force=true)","category":"page"}]
}
