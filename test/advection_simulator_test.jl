@testitem "advection simulator" begin
    using EnvironmentalTransport
    using EnvironmentalTransport: get_vf, get_Δ, get_datafs
    using EnvironmentalTransport: vector_obs_function, pbl_obs_function, advection_op

    using Test
    using EarthSciMLBase, EarthSciData
    using EarthSciMLBase: MapBroadcast
    using ModelingToolkit, OrdinaryDiffEqDefault
    using OrdinaryDiffEqTsit5: Tsit5
    using OrdinaryDiffEqSSPRK: SSPRK22
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

    struct EmissionsCoupler
        sys::Any
    end

    function Emissions(μ_lon, μ_lat, σ)
        @parameters(
            lon = 0.0, [unit = u"rad"],
            lat = 0.0, [unit = u"rad"],
            lev = 1.0
        )
        @variables c(t) = 0.0 [unit = u"kg"]
        @constants v_emis = 50.0 [unit = u"kg/s"]
        @constants t_unit = 1.0 [unit = u"s"] # Needed so that arguments to `pdf` are unitless.
        @constants t_ref = starttime [unit = u"s"]
        dist = MvNormal(
            [starttime, μ_lon, μ_lat, 1], Diagonal(map(abs2, [3600.0, σ, σ, 1]))
        )
        System(
            [D(c) ~ pdf(dist, [(t + t_ref) / t_unit, lon, lat, lev]) * v_emis],
            t, name = :Test₊emissions, metadata = Dict(CoupleType => EmissionsCoupler)
        )
    end

    function EarthSciMLBase.couple2(e::EmissionsCoupler, g::EarthSciData.GEOSFPCoupler)
        e, g = e.sys, g.sys
        e = param_to_var(e, :lon, :lat, :lev)
        ConnectorSystem(
            [
                e.lat ~ g.lat,
                e.lon ~ g.lon,
                e.lev ~ g.lev,
            ], e, g
        )
    end

    emis = Emissions(deg2rad(-122.6), deg2rad(45.5), 0.1)

    csys = couple(emis, domain, geosfp)

    dt = 1.0
    st = SolverStrangThreads(Tsit5(), dt)
    prob = ODEProblem(csys, st)

    sol = solve(prob, SSPRK22(), dt = dt)

    @test 310 < norm(sol.u[end]) < 330

    op = AdvectionOperator(100.0, upwind1_stencil, ZeroGradBC())

    csys = couple(csys, op)

    # Build the advection-coupled prob outside the testset so we can reuse its
    # populated parameter buffer below: in EarthSciData ≥ 0.16 the GEOSFP
    # interpolator data lives in `DataBufferType` discretes that are zero
    # until the data-load callback fires (which happens at solve start). Using
    # `EarthSciMLBase.default_params(sys_coords)` for the v_fs/Δ_fs tests gives
    # back the zero-initialized buffers and the wind/Δ accessors return 0.
    prob = ODEProblem(csys, st)
    sol = solve(prob, SSPRK22(), dt = dt)
    @testset "solve" begin
        # With advection, the norm should be lower because the pollution is more spread out.
        @test 310 < norm(sol.u[end]) < 350
    end

    mtk_sys = convert(System, csys)
    sys_coords, coord_args = EarthSciMLBase._prepare_coord_sys(mtk_sys, domain)
    vars = EarthSciMLBase.get_needed_vars(op, csys, sys_coords, domain)
    @test length(vars) == 6
    p = prob.p  # populated by the solve above; not `default_params(sys_coords)`

    v_fs, Δ_fs = get_datafs(op, csys, sys_coords, coord_args, domain)

    @testset "get_vf lon" begin
        @test only(v_fs[1](2, 3, 1, p, 0.0)) ≈ -6.816295428727573
    end

    @testset "get_vf lat" begin
        @test only(v_fs[2](3, 2, 1, p, 0.0)) ≈ -5.443038969820774
    end

    @testset "get_vf lev" begin
        @test only(v_fs[3](3, 1, 2, p, 0.0)) ≈ -0.019995461793337128
    end

    @testset "get_Δ" begin
        @test only(Δ_fs[1](2, 3, 1, p, 0.0)) ≈ 424080.6852300487
        @test only(Δ_fs[2](3, 2, 1, p, 0.0)) ≈ 445280.0
        @test only(Δ_fs[3](3, 1, 2, p, 0.0)) ≈ -1511.6930930013798
    end

    # The data readers above use the scalar observed-function builder when
    # EarthSciMLBase has one; they must match the vector builder bit for bit.
    @testset "scalar observed functions match the vector builder" begin
        bitwise_equal(a, b) = size(a) == size(b) && all(map(===, a, b))
        T = eltype(domain)
        grd = EarthSciMLBase.grid(domain)
        tt = sol.t[end]
        u = sol.u[end]

        ref_fs = [vector_obs_function(sys_coords, coord_args, v, T) for v in vars]
        pvarstrs = [String(Symbol(pv)) for pv in EarthSciMLBase.pvars(domain)]
        v_ref = [get_vf(domain, pvarstrs[i], ref_fs[i]) for i in 1:3]
        Δ_ref = [get_Δ(domain, ref_fs[3 + i], i) for i in 1:3]
        u4 = reshape(u, :, length.(grd)...)
        tendency(v_fs, Δ_fs) = advection_op(
            u4, upwind1_stencil, v_fs, Δ_fs, op.Δt, ZeroGradBC(), MapBroadcast()
        )(u, p, tt)
        du = tendency(v_fs, Δ_fs)
        @test any(!iszero, du)
        @test bitwise_equal(du, tendency(v_ref, Δ_ref))

        pbl_vars = EarthSciMLBase.get_needed_vars(
            PBLMixingCallback(), csys, sys_coords, domain
        )
        pblh(f) = [f(p, tt, x1, x2, grd[3][1]) for x1 in grd[1], x2 in grd[2]]
        pblh_new = pblh(pbl_obs_function(sys_coords, coord_args, pbl_vars[1], T))
        @test all(>(0), pblh_new)
        @test bitwise_equal(
            pblh_new, pblh(vector_obs_function(sys_coords, coord_args, pbl_vars[1], T))
        )
    end
end
