@testitem "ZeroGradBC" begin
    a = rand(3, 4)
    x = ZeroGradBC()(a)

    @test x[1:3, 1:4] == a
    @test all(x[-10:1, 15:30] .== a[begin, end])
    @test all(x[end:(end + 20), (begin - 3):begin] .== a[end, begin])

    @test all((@view x[1:3, 1:4]) .== a)

    @test CartesianIndices((3, 4)) == eachindex(x)
end

@testitem "ConstantBC" begin
    using EnvironmentalTransport: ConstantBC
    v = 16.0
    a = rand(3, 4)
    x = ConstantBC(v)(a)

    @test x[1:3, 1:4] == a
    @test all(x[-10:1, 15:30] .== v)
    @test all(x[end:(end + 20), (begin - 3):begin] .== v)

    @test all((@view x[1:3, 1:4]) .== a)

    @test CartesianIndices((3, 4)) == eachindex(x)
end

@testitem "SpeciesConstantBC Integer indices" begin
    using EnvironmentalTransport: SpeciesConstantBC

    # Test with 4D array where first dimension is species
    a = rand(3, 4, 5, 6)  # 3 species, spatial dimensions 4x5x6

    # Set up species-specific boundary conditions
    # Species 1 gets 40.0, others get 0.0
    species_values = Dict(1 => 40.0)
    default_value = 0.0
    x = SpeciesConstantBC(species_values, default_value)(a)

    # Test that in-bounds access returns original values
    @test x[1:3, 1:4, 1:5, 1:6] == a

    # Test out-of-bounds access for species 1
    @test x[1, -1, 1, 1] == 40.0  # Species 1 should get 40.0
    @test x[1, 10, 3, 4] == 40.0  # Species 1 should get 40.0

    # Test out-of-bounds access for other species
    @test x[2, -1, 1, 1] == 0.0   # Species 2 should get default 0.0
    @test x[3, 10, 3, 4] == 0.0   # Species 3 should get default 0.0

    # Test that in-bounds access still works correctly
    @test x[1, 2, 3, 4] == a[1, 2, 3, 4]
    @test x[2, 1, 1, 1] == a[2, 1, 1, 1]

    @test CartesianIndices((3, 4, 5, 6)) == eachindex(x)
end

@testitem "SpeciesConstantBC with species names" begin
    using EnvironmentalTransport: SpeciesConstantBC, resolve_species_bc
    using ModelingToolkit: @variables
    using ModelingToolkit: t

    # Create mock species variables to simulate what would come from a real system
    @variables O3(t) NO2(t) CO(t) CH4(t) H2O(t)
    species_vars = [O3, NO2, CO, CH4, H2O]

    # Set up species-specific boundary conditions using names
    species_values = Dict("O3" => 40.0, "NO2" => 10.0)
    default_value = 0.0
    bc = SpeciesConstantBC(species_values, default_value)

    # Create a test array with the right number of species
    n_species = length(species_vars)
    test_array = rand(n_species, 3, 3, 2)  # species x lon x lat x lev

    # Apply with species information
    x = resolve_species_bc(bc, test_array, species_vars)

    # Test that in-bounds access returns original values
    @test x[1:n_species, 1:3, 1:3, 1:2] == test_array

    # Find indices for O3 and NO2
    o3_idx = findfirst(var -> contains(string(var), "O3"), species_vars)
    no2_idx = findfirst(var -> contains(string(var), "NO2"), species_vars)

    @test o3_idx == 1  # O3 is first in our list
    @test no2_idx == 2  # NO2 is second

    # Test out-of-bounds access for O3
    @test x[o3_idx, -1, 1, 1] == 40.0  # O3 should get 40.0
    @test x[o3_idx, 10, 2, 1] == 40.0  # O3 should get 40.0

    # Test out-of-bounds access for NO2
    @test x[no2_idx, -1, 1, 1] == 10.0  # NO2 should get 10.0
    @test x[no2_idx, 10, 2, 1] == 10.0  # NO2 should get 10.0

    # Test that other species get default value
    for i in 1:n_species
        if i != o3_idx && i != no2_idx
            @test x[i, -1, 1, 1] == 0.0  # Should get default 0.0
            @test x[i, 10, 2, 1] == 0.0  # Should get default 0.0
        end
    end

    # Test that in-bounds access still works correctly
    @test x[1, 2, 2, 1] == test_array[1, 2, 2, 1]
    @test x[2, 1, 1, 1] == test_array[2, 1, 1, 1]
end

@testitem "SpeciesConstantBC range access" begin
    using EnvironmentalTransport: SpeciesConstantBC

    # Test with 4D array where first dimension is species
    a = rand(3, 4, 5, 6)  # 3 species, spatial dimensions 4x5x6

    # Set up species-specific boundary conditions
    species_values = Dict(1 => 40.0)
    default_value = 5.0
    x = SpeciesConstantBC(species_values, default_value)(a)

    # Test out-of-bounds access with a range as the first index
    # This should return the default value
    @test x[1:2, -1, 1, 1] == 5.0  # Range access returns default
end

@testitem "SpeciesConstantBC missing species warning" begin
    using EnvironmentalTransport: SpeciesConstantBC, resolve_species_bc
    using ModelingToolkit: @variables
    using ModelingToolkit: t

    # Create mock species variables
    @variables O3(t) NO2(t)
    species_vars = [O3, NO2]

    # Set up boundary conditions with a species that doesn't exist
    species_values = Dict("O3" => 40.0, "NONEXISTENT" => 100.0)
    default_value = 0.0
    bc = SpeciesConstantBC(species_values, default_value)

    # Create a test array
    test_array = rand(2, 3, 3, 2)

    # Apply with species information - should trigger warning for NONEXISTENT
    x = @test_logs (:warn, r"Species 'NONEXISTENT' not found") resolve_species_bc(bc, test_array, species_vars)

    # O3 should still work
    @test x[1, -1, 1, 1] == 40.0
    # Other species get default
    @test x[2, -1, 1, 1] == 0.0
end
