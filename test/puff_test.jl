using Test
using EnvironmentalTransport
using EarthSciMLBase
using ModelingToolkit
using ModelingToolkit: t
using OrdinaryDiffEq
using DynamicQuantities
using DomainSets

@parameters x=0 [unit = u"m"]
@parameters y=0 [unit = u"m"]
@parameters z=0 [unit = u"m"]
starttime = 0.0
endtime = 1.0

di = DomainInfo(
    constIC(16.0, t ∈ Interval(starttime, endtime)),
    constBC(16.0,
        x ∈ Interval(-1.1, 1.1),
        y ∈ Interval(-1.1, 1.1),
        z ∈ Interval(-1, 1)
    ),
    grid_spacing = [0.1, 0.1, 0.1],
    dtype = Float64)

puff = Puff(di)
puff = structural_simplify(puff)

@test length(equations(puff)) == 3
@test issetequal([Symbol("z(t)"), Symbol("x(t)"), Symbol("y(t)")], Symbol.(unknowns(puff)))
@test issetequal(
    [:v_x, :v_y, :v_z, :x_trans, :y_trans, :lev_trans], Symbol.(parameters(puff)))

prob = ODEProblem(puff, [], (starttime, endtime), [])

@testset "x terminate +" begin
    p = MTKParameters(puff, [puff.v_x => 2.0])
    prob2 = remake(prob, p = p)
    sol = solve(prob2)
    @test sol.t[end] ≈ 0.5
    @test sol[puff.x][end] ≈ 1.0
    @test sol.retcode == SciMLBase.ReturnCode.Terminated
end

@testset "x terminate -" begin
    p = MTKParameters(puff, [puff.v_x => -2.0])
    prob2 = remake(prob, p = p)
    sol = solve(prob2)
    @test sol.t[end] ≈ 0.5
    @test sol[puff.x][end] ≈ -1.0
    @test sol.retcode == SciMLBase.ReturnCode.Terminated
end

@testset "y terminate +" begin
    p = MTKParameters(puff, [puff.v_y => 2.0])
    prob2 = remake(prob, p = p)
    sol = solve(prob2)
    @test sol.t[end] ≈ 0.5
    @test sol[puff.y][end] ≈ 1.0
    @test sol.retcode == SciMLBase.ReturnCode.Terminated
end

@testset "y terminate -" begin
    p = MTKParameters(puff, [puff.v_y => -2.0])
    prob2 = remake(prob, p = p)
    sol = solve(prob2)
    @test sol.t[end] ≈ 0.5
    @test sol[puff.y][end] ≈ -1.0
    @test sol.retcode == SciMLBase.ReturnCode.Terminated
end

@testset "z bounded +" begin
    p = MTKParameters(puff, [puff.v_z => 10.0])
    prob2 = remake(prob, p = p)
    sol = solve(prob2)
    @test sol.t[end] ≈ 1
    @test maximum(sol[puff.z]) ≈ 1.0
    @test sol.retcode == SciMLBase.ReturnCode.Success
end

@testset "z bounded -" begin
    p = MTKParameters(puff, [puff.v_z => -10.0])
    prob2 = remake(prob, p = p)
    sol = solve(prob2)
    @test sol.t[end] ≈ 1
    @test minimum(sol[puff.z]) ≈ -1.0
    @test sol.retcode == SciMLBase.ReturnCode.Success
end

@testset "puff coupling" begin
    struct VelCoupler
        sys
    end

    function Vel(; name = :Vel)
        @parameters vp=2 [unit = u"m/s"]
        @variables v(t) [unit = u"m/s"]
        ODESystem(
            Equation[v ~ vp], t; name = name, metadata = Dict(:coupletype => VelCoupler))
    end

    function EarthSciMLBase.couple2(p::EnvironmentalTransport.PuffCoupler, v::VelCoupler)
        p, v = p.sys, v.sys
        p = param_to_var(p, :v_x)
        ConnectorSystem([
                p.v_x ~ v.v
            ], p, v)
    end

    puff = Puff(di)
    v = Vel()
    model = couple(puff, v)
    sys = convert(ODESystem, model, simplify = true)
    prob = ODEProblem(sys, [], (starttime, endtime))
    sol = solve(prob)
    @test sol.retcode == SciMLBase.ReturnCode.Terminated
end
