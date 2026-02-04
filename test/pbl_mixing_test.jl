using Test
using EnvironmentalTransport

using EarthSciMLBase
using ModelingToolkit, OrdinaryDiffEq
using ModelingToolkit: t, D
using DynamicQuantities
using Dates
using Distributions
using EarthSciMLBase: SolverStrangThreads, PositiveDomain

# Access functions directly from the module since they're not exported
compute_imix_fpbl = EnvironmentalTransport.compute_imix_fpbl
pbl_full_mix! = EnvironmentalTransport.pbl_full_mix!
air_mass_from_pressure = EnvironmentalTransport.air_mass_from_pressure
extract_domain_pressure_edges = EnvironmentalTransport.extract_domain_pressure_edges

@testset "PBL Mixing Core Functions" begin
    @testset "extract_domain_pressure_edges" begin
        # Test extraction for a subset of levels
        domain_levels = 1:5
        pedge_domain = extract_domain_pressure_edges(domain_levels)

        @test length(pedge_domain) == 6  # n+1 edges for n layers
        @test pedge_domain[1] > pedge_domain[end]  # Pressure decreases with height
        @test all(pedge_domain .> 0)  # All pressures should be positive
    end

    @testset "compute_imix_fpbl" begin
        # Test with simple pressure profile
        pedge = [1013.15, 998, 982, 967, 952, 880]  # hPa, surface to top

        # Test PBL height within domain
        pblh = 1200.0  # m
        imix, fpbl = compute_imix_fpbl(pedge, pblh)
        @test imix == 5
        @test fpbl == 1.0

        # Test PBL height above domain
        pblh_high = 1000.0  # m
        imix_high, fpbl_high = compute_imix_fpbl(pedge, pblh_high)
        @test imix_high == 5
        @test fpbl_high == 0.8041425437002374

        # Test PBL height below domain
        pblh_low = 300.0  # m
        imix_low, fpbl_low = compute_imix_fpbl(pedge, pblh_low)
        @test imix_low == 3
    end

    @testset "pbl_full_mix!" begin
        nz, nspec = 5, 2
        pedge = [1013.15, 998, 982, 967, 952, 880]  # hPa
        area_m2 = 2.5e10  # example box area
        ad = air_mass_from_pressure(pedge, area_m2)
        # Use exact values from GEOS-Chem reference test for first 2 columns
        tc = zeros(nz, nspec)
        tc[:, 1] = [9.788397646421418e-10, 3.8194425771985734e-11, 5.139643503128196e-10,
            7.920951982452883e-10, 3.6657542451709716e-10]
        tc[:, 2] = [6.610569640583867e-10, 1.903820236452969e-13, 5.432899816585908e-10,
            4.720893983058938e-10, 9.800751203546894e-10]
        pblh_m = 1200.0  # PBL height [m]
        imix, fpbl = compute_imix_fpbl(pedge, pblh_m)

        # Save before mixing
        tc_before = copy(tc)

        # Run mixing
        pbl_full_mix!(tc, ad, imix, fpbl)

        # Test checks
        @test imix == 5
        @test tc[1, :] == tc[2, :] == tc[3, :] == tc[4, :] == tc[5, :]  # All layers identical (fully mixed)

        # Test mass conservation
        for n in 1:nspec
            mass_before = sum(ad .* tc_before[:, n])
            mass_after = sum(ad .* tc[:, n])
            @test mass_after ≈ mass_before rtol=1e-10
        end
    end

    @testset "pbl_full_mix!" begin
        nz, nspec = 5, 2
        pedge = [1013.15, 998, 982, 967, 952, 880]  # hPa
        area_m2 = 2.5e10  # example box area
        ad = air_mass_from_pressure(pedge, area_m2)
        # Use exact values from GEOS-Chem reference test for first 2 columns
        tc = zeros(nz, nspec)
        tc[:, 1] = [9.788397646421418e-10, 3.8194425771985734e-11, 5.139643503128196e-10,
            7.920951982452883e-10, 3.6657542451709716e-10]
        tc[:, 2] = [6.610569640583867e-10, 1.903820236452969e-13, 5.432899816585908e-10,
            4.720893983058938e-10, 9.800751203546894e-10]
        pblh_m = 300.0  # PBL height [m]
        imix, fpbl = compute_imix_fpbl(pedge, pblh_m)

        # Save before mixing
        tc_before = copy(tc)

        # Run mixing
        pbl_full_mix!(tc, ad, imix, fpbl)

        # Test checks
        @test imix == 3
        @test tc[1, :] == tc[2, :]  # Layers 1-2 identical (fully mixed)
        @test tc[1, :] != tc[3, :]  # Layer 3 different (partially mixed)
        @test tc[4, :] == tc_before[4, :]  # Layer 4 unchanged (above PBL)

        # Test mass conservation
        for n in 1:nspec
            mass_before = sum(ad .* tc_before[:, n])
            mass_after = sum(ad .* tc[:, n])
            @test mass_after ≈ mass_before rtol=1e-10
        end
    end
end

@testset "PBL Mixing Callback" begin
    # Test that PBLMixingCallback can be created
    @test PBLMixingCallback(3600.0) isa PBLMixingCallback
    @test PBLMixingCallback(600.0, every_step = false) isa PBLMixingCallback
    @test PBLMixingCallback(every_step = true) isa PBLMixingCallback

    # Test default values
    cb = PBLMixingCallback()
    @test cb.interval == 3600.0
    @test cb.every_step == false

    # Test custom values
    cb_custom = PBLMixingCallback(1800.0, every_step = true)
    @test cb_custom.interval == 1800.0
    @test cb_custom.every_step == true
end
