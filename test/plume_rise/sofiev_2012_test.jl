using EnvironmentalTransport
using EarthSciMLBase
using ModelingToolkit
using Dates
using Test

starttime = DateTime(2022, 5, 1)
endtime = DateTime(2022, 5, 1, 0, 1)

di = DomainInfo(
    starttime, endtime;
    lonrange = deg2rad(-115):deg2rad(1):deg2rad(-68.75),
    latrange = deg2rad(25):deg2rad(1):deg2rad(53.7),
    levrange = 1:15,
    dtype = Float64)


puff = Puff(di)

prob = ODEProblem(structural_simplify(puff))
@test prob.ps[Initial(puff.lev)] == 8.0

s12 = Sofiev2012PlumeRise()

model = couple(puff, s12)
sys = convert(ODESystem, model)
prob = ODEProblem(sys)#, symbolic_u0=true)

@test prob.ps[Initial(sys.PuffXXX₊lev)] != 8.0
