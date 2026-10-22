@testsnippet SubcycleSetup begin
    using EnvironmentalTransport
    using EnvironmentalTransport: advection_op, inflow_courant, vertical_subcycles,
        subcycle_column!
    using EarthSciMLBase: MapBroadcast
    using SciMLBase: NullParameters
    using OrdinaryDiffEqSSPRK: SSPRK22
    using OrdinaryDiffEq: ODEProblem, solve

    # A single column (1 species, 1×1×nz cells) on a pressure-like (negative-Δ)
    # vertical coordinate with no horizontal wind and a uniform (divergence-free)
    # vertical face velocity `w`. Positive `w` on a pressure coordinate is
    # subsidence, i.e. inflow from the top boundary. The vertical Courant number
    # is `w·Δt/|Δz|` in every cell.
    function column_setup(w; Δz = -100.0)
        v_fs = ((i, j, k, p, t) -> 0.0, (i, j, k, p, t) -> 0.0, (i, j, k, p, t) -> w)
        Δ_fs = ((i, j, k, p, t) -> 1.0, (i, j, k, p, t) -> 1.0, (i, j, k, p, t) -> Δz)
        return v_fs, Δ_fs
    end
end

@testitem "inflow Courant number" setup = [SubcycleSetup] begin
    # positive Δ: inflow through the left face for v > 0, through the right face for v < 0
    @test inflow_courant((2.0, 2.0), 1.0, 0.25) ≈ 0.5        # left inflow only
    @test inflow_courant((-2.0, -2.0), 1.0, 0.25) ≈ 0.5      # right inflow only
    @test inflow_courant((2.0, -2.0), 1.0, 0.25) ≈ 1.0       # converging: both faces
    @test inflow_courant((-2.0, 2.0), 1.0, 0.25) ≈ 0.0       # diverging: no inflow
    # negative Δ (pressure-like vertical coordinate): the roles of the faces swap
    @test inflow_courant((2.0, 2.0), -1.0, 0.25) ≈ 0.5
    @test inflow_courant((-2.0, 2.0), -1.0, 0.25) ≈ 1.0
    @test inflow_courant((2.0, -2.0), -1.0, 0.25) ≈ 0.0
    @test isnan(inflow_courant((2.0, 2.0), 1.0, NaN))

    @test vertical_subcycles([0.2, 0.9, 1.0], 100) == 1
    @test vertical_subcycles([0.2, 1.0001, 0.5], 100) == 2
    @test vertical_subcycles([2.4], 100) == 3
    @test vertical_subcycles([250.0], 100) == 100
    @test vertical_subcycles([1e300], 100) == 100
    @test vertical_subcycles([NaN, 3.0], 100) == 1
    @test vertical_subcycles(Float64[], 100) == 1
    @test vertical_subcycles((c for c in (0.5, 1.5)), 100) == 2
end

@testitem "sub-cycled column matches explicit sub-steps" setup = [SubcycleSetup] begin
    nz = 8
    lpad, rpad = EnvironmentalTransport.stencil_size(upwind1_stencil)
    Δt = 300.0
    # height-varying face velocities: the sub-cycling must reproduce n explicit
    # sub-steps of the stencil exactly, whatever the wind profile
    vzs = [(3.0 * (k - 1) / nz, 3.0 * k / nz) for k in 1:nz]
    Δzs = fill(-100.0, nz)
    ϕ0 = [10.0, 10, 10, 50, 50, 50, 10, 10]
    # peak inflow Courant number is 3.0·300/100 = 9 → 9 sub-steps keep every sub-step ≤ 1
    n = vertical_subcycles([inflow_courant(vzs[k], Δzs[k], Δt) for k in 1:nz], 100)
    @test n == 9
    colp = vcat(fill(ϕ0[1], lpad), copy(ϕ0), fill(ϕ0[end], rpad))
    subcycle_column!(colp, zeros(nz), upwind1_stencil, vzs, Δzs, Δt, n, nz, lpad, rpad, nothing)
    # reference: n explicit steps of Δt/n with fixed ghosts
    reference = let r = vcat(fill(ϕ0[1], lpad), copy(ϕ0), fill(ϕ0[end], rpad))
        for _ in 1:n
            new = copy(r)
            for k in 1:nz
                kk = k + lpad
                new[kk] = r[kk] + Δt / n *
                                  upwind1_stencil(r[(kk - lpad):(kk + rpad)], vzs[k], Δt / n, Δzs[k])
            end
            r = new
        end
        r
    end
    @test colp ≈ reference
    @test !(colp ≈ vcat(fill(ϕ0[1], lpad), ϕ0, fill(ϕ0[end], rpad)))   # something moved

    # with a uniform wind (no divergence) the sub-cycled column is monotone
    vzs_u = fill((3.0, 3.0), nz)
    n_u = vertical_subcycles([inflow_courant(vzs_u[k], Δzs[k], Δt) for k in 1:nz], 100)
    @test n_u == 9
    colu = vcat(fill(ϕ0[1], lpad), copy(ϕ0), fill(ϕ0[end], rpad))
    subcycle_column!(colu, zeros(nz), upwind1_stencil, vzs_u, Δzs, Δt, n_u, nz, lpad, rpad, nothing)
    @test minimum(colu) >= minimum(ϕ0) - 1e-12
    @test maximum(colu) <= maximum(ϕ0) + 1e-12
end

@testitem "advection op: unchanged when the vertical Courant number is at most one" setup = [SubcycleSetup] begin
    nz = 12
    Δt = 300.0
    v_fs, Δ_fs = column_setup(0.3)                 # Courant 0.3·300/100 = 0.9 < 1
    c = zeros(1, 1, 1, nz)
    c[1, 1, 1, :] .= [5.0, 5, 5, 20, 40, 20, 5, 5, 5, 30, 30, 5]
    op_dt = advection_op(c, upwind1_stencil, v_fs, Δ_fs, Δt, ZeroGradBC(), MapBroadcast())
    op_nan = advection_op(c, upwind1_stencil, v_fs, Δ_fs, NaN, ZeroGradBC(), MapBroadcast())
    d1 = op_dt(c[:], NullParameters(), 0.0)
    d2 = op_nan(c[:], NullParameters(), 0.0)
    @test d1 == d2                                   # bit-for-bit the plain tendency
    d3 = similar(d1)
    op_dt(d3, c[:], NullParameters(), 0.0)
    @test d3 == d1                                   # in-place == out-of-place
    # the plain tendency equals the sum of the per-direction stencils (x, y are zero)
    cc = ZeroGradBC()(c)
    manual = [upwind1_stencil(cc[1, 1, 1, (k - 1):(k + 1)], (0.3, 0.3), Δt, -100.0) for k in 1:nz]
    @test d1 ≈ manual
    @test any(!iszero, d1)
end

@testitem "advection op: sub-cycling keeps a column monotone at Courant > 1" setup = [SubcycleSetup] begin
    nz = 12
    Δt = 300.0
    v_fs, Δ_fs = column_setup(0.75)                # Courant 0.75·300/100 = 2.25 → 3 sub-steps
    c = zeros(1, 1, 1, nz)
    c[1, 1, 1, :] .= [5.0, 5, 5, 20, 40, 20, 5, 5, 5, 30, 30, 5]
    bc = ConstantBC(50.0)             # air subsiding in from the top carries 50
    lo, hi = 5.0, 50.0                # bounds every monotone update must respect
    op_dt = advection_op(c, upwind1_stencil, v_fs, Δ_fs, Δt, bc, MapBroadcast())
    op_nan = advection_op(c, upwind1_stencil, v_fs, Δ_fs, NaN, bc, MapBroadcast())

    # One explicit step with the plain tendency overshoots (Courant > 1) …
    plain = c[:] .+ Δt .* op_nan(c[:], NullParameters(), 0.0)
    @test minimum(plain) < lo || maximum(plain) > hi
    # … the sub-cycled tendency does not.
    sub = c[:] .+ Δt .* op_dt(c[:], NullParameters(), 0.0)
    @test minimum(sub) >= lo - 1e-9
    @test maximum(sub) <= hi + 1e-9
    @test !(sub ≈ c[:])                               # and it does advect
    # in-place agrees with out-of-place
    d = similar(sub)
    op_dt(d, c[:], NullParameters(), 0.0)
    @test c[:] .+ Δt .* d ≈ sub

    # A uniform field (equal to the boundary value) stays uniform to round-off,
    # sub-cycled or not.
    u = fill(50.0, size(c))
    @test maximum(abs, op_dt(u[:], NullParameters(), 0.0)) < 1e-12
    @test maximum(abs, op_nan(u[:], NullParameters(), 0.0)) < 1e-12

    # Time integration with SSPRK22 and a positivity limiter (the production
    # setup) while air with a different mixing ratio keeps subsiding in from the
    # top: the plain tendency rectifies its undershoots into runaway growth, the
    # sub-cycled one stays inside [lo, hi] and fills the column with the inflow value.
    limiter!(u, integrator, p, t) = (u .= max.(u, 0.0); nothing)
    tspan = (0.0, 48 * Δt)
    run(op) = solve(ODEProblem(op, c[:], tspan), SSPRK22(limiter!, limiter!); dt = Δt,
        save_everystep = false, adaptive = false)
    sol_plain = run(op_nan)
    sol_sub = run(op_dt)
    @test maximum(sol_plain.u[end]) > 10 * hi                  # the bug
    @test maximum(sol_sub.u[end]) <= hi + 1e-9                 # the fix
    @test minimum(sol_sub.u[end]) >= lo - 1e-9
    @test sol_sub.u[end][end] > 45                             # top of the column ≈ inflow value
end

@testitem "advection op: sub-cycling with horizontal wind and species boundary values" setup = [SubcycleSetup] begin
    # 2 species, 4×3×6 cells; uniform strong subsidence (Courant 2.25) plus a
    # gentle uniform horizontal wind (Courant 0.2 each), species-specific constant
    # boundary values. The update must remain a convex combination of old values
    # and boundary values for every cell.
    nspec, nx, ny, nz = 2, 4, 3, 6
    Δt = 300.0
    v_fs = ((i, j, k, p, t) -> 2.0, (i, j, k, p, t) -> -2.0, (i, j, k, p, t) -> 0.75)
    Δ_fs = ((i, j, k, p, t) -> 3000.0, (i, j, k, p, t) -> 3000.0, (i, j, k, p, t) -> -100.0)
    c = rand(nspec, nx, ny, nz) .* 10
    c[2, :, :, :] .+= 100
    bcvals = (3.0, 200.0)
    bc = SpeciesConstantBC(Dict(1 => bcvals[1], 2 => bcvals[2]), 0.0)
    op = advection_op(c, upwind1_stencil, v_fs, Δ_fs, Δt, bc, MapBroadcast())
    @test inflow_courant((0.75, 0.75), -100.0, Δt) > 2
    unew = reshape(c[:] .+ Δt .* op(c[:], NullParameters(), 0.0), size(c))
    for s in 1:nspec
        lo = min(minimum(c[s, :, :, :]), bcvals[s])
        hi = max(maximum(c[s, :, :, :]), bcvals[s])
        @test minimum(unew[s, :, :, :]) >= lo - 1e-9
        @test maximum(unew[s, :, :, :]) <= hi + 1e-9
    end
    # the plain tendency at this Courant number does NOT respect the bounds
    op_nan = advection_op(c, upwind1_stencil, v_fs, Δ_fs, NaN, bc, MapBroadcast())
    uplain = reshape(c[:] .+ Δt .* op_nan(c[:], NullParameters(), 0.0), size(c))
    @test any(s -> minimum(uplain[s, :, :, :]) < min(minimum(c[s, :, :, :]), bcvals[s]) - 1e-9 ||
                   maximum(uplain[s, :, :, :]) > max(maximum(c[s, :, :, :]), bcvals[s]) + 1e-9, 1:nspec)
    # in-place path gives the same answer
    d = zeros(length(c))
    op(d, c[:], NullParameters(), 0.0)
    @test reshape(c[:] .+ Δt .* d, size(c)) ≈ unew
    # the operator constructor accepts and validates max_subcycles
    @test AdvectionOperator(Δt, upwind1_stencil, ZeroGradBC(); max_subcycles = 7).max_subcycles == 7
    @test AdvectionOperator(Δt, upwind1_stencil, ZeroGradBC()).max_subcycles == 100
    @test_throws ArgumentError AdvectionOperator(Δt, upwind1_stencil, ZeroGradBC(); max_subcycles = 0)
end
