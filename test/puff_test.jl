@testsnippet PuffSetup begin
    using EnvironmentalTransport
    using EarthSciMLBase
    using ModelingToolkit
    using ModelingToolkit: t
    using OrdinaryDiffEqDefault
    using DynamicQuantities
    using Dates

    @parameters x = 0 [unit = u"m"]
    @parameters y = 0 [unit = u"m"]
    @parameters z = 0 [unit = u"m"]
    starttime = DateTime(0, 1, 1, 0.0)
    endtime = DateTime(0, 1, 1, 0.0, 0.0, 1.0)

    di = DomainInfo(
        starttime, endtime,
        xrange = -1.1:0.1:1.1,
        yrange = -1.1:0.1:1.1,
        levrange = -1:0.1:1
    )

    puff = Puff(di)
    puff = mtkcompile(puff)

    prob = ODEProblem(puff, [], get_tspan(di))
end

@testitem "Equations" setup = [PuffSetup] begin
    @test length(equations(puff)) == 3
    want_unknowns = [Symbol("lev(t)"), Symbol("x(t)"), Symbol("y(t)")]
    @test issetequal(want_unknowns, Symbol.(unknowns(puff)))
    want_params = [
        :lev_trans, :x_trans, :v_x, :y_trans, :v_lev, :v_y, :offset, :glo,
        :ghi, :v_zero,
    ]
    @test issetequal(want_params, Symbol.(parameters(puff)))
end

@testitem "x terminate +" setup = [PuffSetup] begin
    p = MTKParameters(puff, [puff.v_x => 2.0])
    prob2 = remake(prob, p = p)
    sol = solve(prob2)
    @test sol.t[end] ≈ 0.5
    @test sol[puff.x][end] ≈ 1.0
    @test sol.retcode == SciMLBase.ReturnCode.Terminated
end

@testitem "x terminate -" setup = [PuffSetup] begin
    p = MTKParameters(puff, [puff.v_x => -2.0])
    prob2 = remake(prob, p = p)
    sol = solve(prob2)
    @test sol.t[end] ≈ 0.5
    @test sol[puff.x][end] ≈ -1.0
    @test sol.retcode == SciMLBase.ReturnCode.Terminated
end

@testitem "y terminate +" setup = [PuffSetup] begin
    p = MTKParameters(puff, [puff.v_y => 2.0])
    prob2 = remake(prob, p = p)
    sol = solve(prob2)
    @test sol.t[end] ≈ 0.5
    @test sol[puff.y][end] ≈ 1.0
    @test sol.retcode == SciMLBase.ReturnCode.Terminated
end

@testitem "y terminate -" setup = [PuffSetup] begin
    p = MTKParameters(puff, [puff.v_y => -2.0])
    prob2 = remake(prob, p = p)
    sol = solve(prob2)
    @test sol.t[end] ≈ 0.5
    @test sol[puff.y][end] ≈ -1.0
    @test sol.retcode == SciMLBase.ReturnCode.Terminated
end

@testitem "z bounded +" setup = [PuffSetup] begin
    p = MTKParameters(puff, [puff.v_lev => 10.0])
    prob2 = remake(prob, p = p)
    sol = solve(prob2)
    @test sol.t[end] ≈ 1
    @test maximum(sol[puff.lev]) ≈ 1.0
    @test sol.retcode == SciMLBase.ReturnCode.Success
end

@testitem "z bounded -" setup = [PuffSetup] begin
    p = MTKParameters(puff, [puff.v_lev => -10.0])
    prob2 = remake(prob, p = p)
    sol = solve(prob2)
    @test sol.t[end] ≈ 1
    @test minimum(sol[puff.lev]) ≈ -1.0
    @test sol.retcode == SciMLBase.ReturnCode.Success
end

@testitem "puff coupling" setup = [PuffSetup] begin
    struct VelCoupler
        sys
    end

    function Vel(; name = :Vel)
        @parameters vp = 2 [unit = u"m/s"]
        @variables v(t) [unit = u"m/s"]
        System(
            Equation[v ~ vp], t; name = name, metadata = Dict(CoupleType => VelCoupler)
        )
    end

    function EarthSciMLBase.couple2(p::EnvironmentalTransport.PuffCoupler, v::VelCoupler)
        p, v = p.sys, v.sys
        p = param_to_var(p, :v_x)
        ConnectorSystem(
            [
                p.v_x ~ v.v,
            ], p, v
        )
    end

    puff = Puff(di)
    v = Vel()
    model = couple(puff, v)
    sys = convert(System, model)
    prob = ODEProblem(sys, [], get_tspan(di))
    sol = solve(prob)
    @test sol.retcode == SciMLBase.ReturnCode.Terminated
end
