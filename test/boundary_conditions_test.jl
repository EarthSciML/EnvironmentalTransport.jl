using Main.EnvironmentalTransport
using Test

a = rand(3, 4)
x = ZeroGradBC()(a)

@test x[1:3, 1:4] == a
@test all(x[-10:1, 15:30] .== a[begin, end])
@test all(x[end:(end + 20), (begin - 3):begin] .== a[end, begin])

@test all((@view x[1:3, 1:4]) .== a)

@test CartesianIndices((3, 4)) == eachindex(x)
