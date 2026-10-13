@testitem "scalar observed functions" begin
    using EnvironmentalTransport
    using EnvironmentalTransport: obs_function, vector_obs_function, pbl_obs_function,
        get_vf, get_Δ, advection_op
    using EarthSciMLBase
    using EarthSciMLBase: MapBroadcast
    using ModelingToolkit
    using ModelingToolkit: t, D
    using DynamicQuantities
    using Dates

    # Element-wise bit-pattern equality (`===` on two Float64s compares their bits).
    bitwise_equal(a, b) = size(a) == size(b) && all(map(===, a, b))

    domain = DomainInfo(
        DateTime(2022, 5, 1), DateTime(2022, 5, 1, 1);
        lonrange = deg2rad(-130):deg2rad(10):deg2rad(-60),
        latrange = deg2rad(10):deg2rad(10):deg2rad(60),
        levrange = 1:1:4
    )

    # Synthetic stand-ins for the GEOS-FP winds, grid spacings and PBL height: they
    # depend on parameters, time and coordinates but not on the state, like the real ones.
    @parameters lon = 0.0 [unit = u"rad"] lat = 0.0 [unit = u"rad"] lev = 1.0
    @parameters a = 7.3 k = 1.0e-4 [unit = u"s^-1"]
    @variables c(t) = 1.0 U(t) V(t) OMEGA(t) δxδlon(t) δyδlat(t) δPδlev(t) PBLH(t)
    sys = System(
        [
            D(c) ~ -k * c,
            U ~ a * sin(lon) * cos(lat) + lev * exp(-k * t),
            V ~ a * cos(2lon) * sin(3lat) / lev,
            OMEGA ~ 0.37 * sin(lon + lat) * sqrt(lev) * cos(k * t),
            δxδlon ~ 6.371e6 * cos(lat),
            δyδlat ~ 6.371e6,
            δPδlev ~ -1517.3 / (lev + 0.25),
            PBLH ~ 812.5 + 413.7 * sin(lon) * cos(lat) * (1 + k * t),
        ], t; name = :met
    )
    csys = couple(sys, domain)
    mtk_sys = convert(System, csys)
    sys_coords, coord_args = EarthSciMLBase._prepare_coord_sys(mtk_sys, domain)
    p = EarthSciMLBase.default_params(sys_coords)
    T = eltype(domain)
    grd = EarthSciMLBase.grid(domain)
    ts = (0.0, 1234.5)

    vars = [sys.U, sys.V, sys.OMEGA, sys.δxδlon, sys.δyδlat, sys.δPδlev]
    new_fs = [obs_function(sys_coords, coord_args, v, T) for v in vars]
    ref_fs = [vector_obs_function(sys_coords, coord_args, v, T) for v in vars]
    evalgrid(f, tt) = [f(p, tt, x1, x2, x3) for x1 in grd[1], x2 in grd[2], x3 in grd[3]]

    @testset "field values" begin
        for (f, g) in zip(new_fs, ref_fs), tt in ts
            @test bitwise_equal(evalgrid(f, tt), evalgrid(g, tt))
        end
    end

    @testset "advection tendencies" begin
        pvarstrs = [String(Symbol(pv)) for pv in EarthSciMLBase.pvars(domain)]
        u0 = [
            1 + 0.5 * sin(s + 2i + 3j + 5k)
                for s in 1:2, i in eachindex(grd[1]), j in eachindex(grd[2]),
                k in eachindex(grd[3])
        ]
        function tendency(fs, tt)
            v_fs = [get_vf(domain, pvarstrs[i], fs[i]) for i in 1:3]
            Δ_fs = [get_Δ(domain, fs[3 + i], i) for i in 1:3]
            op = advection_op(
                u0, upwind1_stencil, v_fs, Δ_fs, 300.0, ZeroGradBC(), MapBroadcast()
            )
            return op(vec(u0), p, tt)
        end
        for tt in ts
            du_new = tendency(new_fs, tt)
            @test any(!iszero, du_new)
            @test bitwise_equal(du_new, tendency(ref_fs, tt))
        end
    end

    @testset "PBL heights" begin
        pblh_new = pbl_obs_function(sys_coords, coord_args, sys.PBLH, T)
        pblh_ref = vector_obs_function(sys_coords, coord_args, sys.PBLH, T)
        for tt in ts
            @test bitwise_equal(evalgrid(pblh_new, tt), evalgrid(pblh_ref, tt))
        end
    end

    if isdefined(EarthSciMLBase, :build_coord_observed_scalar_function)
        @testset "no allocations" begin
            # Function barrier so that only the call itself is measured.
            allocs(f, p, x) = (f(p, 0.0, x...); @allocated f(p, 0.0, x...))
            x = (grd[1][2], grd[2][3], grd[3][2])
            for f in new_fs
                @test allocs(f, p, x) == 0
            end
        end
    end
end
