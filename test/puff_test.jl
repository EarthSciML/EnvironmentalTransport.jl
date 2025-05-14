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
        x ∈ Interval(-1.0, 1.0),
        y ∈ Interval(-1.0, 1.0),
        z ∈ Interval(-1.0, 1.0)
    ),
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
end

@testset "x terminate -" begin
    p = MTKParameters(puff, [puff.v_x => -2.0])
    prob2 = remake(prob, p = p)
    sol = solve(prob2)
    @test sol.t[end] ≈ 0.5
    @test sol[puff.x][end] ≈ -1.0
end

@testset "y terminate +" begin
    p = MTKParameters(puff, [puff.v_y => 2.0])
    prob2 = remake(prob, p = p)
    sol = solve(prob2)
    @test sol.t[end] ≈ 0.5
    @test sol[puff.y][end] ≈ 1.0
end

@testset "y terminate -" begin
    p = MTKParameters(puff, [puff.v_y => -2.0])
    prob2 = remake(prob, p = p)
    sol = solve(prob2)
    @test sol.t[end] ≈ 0.5
    @test sol[puff.y][end] ≈ -1.0
end

@testset "z bounded +" begin
    p = MTKParameters(puff, [puff.v_z => 10.0])
    prob2 = remake(prob, p = p)
    sol = solve(prob2)
    @test sol.t[end] ≈ 1
    @test maximum(sol[puff.z]) ≈ 1.0
end

@testset "z bounded -" begin
    p = MTKParameters(puff, [puff.v_z => -10.0])
    prob2 = remake(prob, p = p)
    sol = solve(prob2)
    @test sol.t[end] ≈ 1
    @test minimum(sol[puff.z]) ≈ -1.0
end
