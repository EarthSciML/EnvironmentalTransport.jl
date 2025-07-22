export GaussianDispersion
              
struct GaussianDispersionCoupler
    sys::Any
end

function GaussianDispersion()
    @parameters begin
        lon0 = 0.0, [unit = u"rad"]
        lat0 = 0.0, [unit = u"rad"]
        R    = 6.371e6, [unit = u"m"]

        # EPA 402-R-00-004 (Section 12.1.6)
        # https://19january2017snapshot.epa.gov/sites/production/files/2015-05/documents/402-r-00-004.pdf
        AY_A = 0.22 ; AY_B = 0.16 ; AY_C = 0.11
        AY_D = 0.08 ; AY_Ep = 0.06 ; AY_F = 0.04

        AZ_A = 0.20 ; AZ_B = 0.12 ; AZ_C = 0.08
        AZ_D = 0.06 ; AZ_Ep = 0.03 ; AZ_F = 0.016

        BZ_A = 0.0,       [unit = u"m^-1"]
        BZ_B = 0.0,       [unit = u"m^-1"]
        BZ_C = 0.0002,    [unit = u"m^-1"]
        BZ_D = 0.0015,    [unit = u"m^-1"]
        BZ_Ep = 0.0003,   [unit = u"m^-1"]
        BZ_F = 0.0003,    [unit = u"m^-1"]

        BY = 1.0e-4, [unit = u"m^-1"]

        v2 = 2.0, [unit = u"m/s"]
        v3 = 3.0, [unit = u"m/s"]
        v5 = 5.0, [unit = u"m/s"]
        v6 = 6.0, [unit = u"m/s"]

        solrad_night  = 10.0, [unit = u"W/m^2"]
        solrad_strong = 925.0, [unit = u"W/m^2"]
        solrad_moder  = 675.0, [unit = u"W/m^2"]
        solrad_slight = 175.0, [unit = u"W/m^2"]

        cloudfrac_clear = 0.5

        inversion_thresh = 0.0, [unit = u"K"]
    end

    @variables begin
        lon(t), [unit = u"rad"]
        lat(t), [unit = u"rad"]
        x(t), [unit = u"m"]
        sigma_h(t), [unit = u"m"]
        sigma_z(t), [unit = u"m"]
        U10M(t), [unit = u"m/s"]
        V10M(t), [unit = u"m/s"]
        SWGDN(t), [unit = u"W/m^2"]
        CLDTOT(t)
        T2M(t), [unit = u"K"]
        T10M(t), [unit = u"K"]
    end

    wind_speed = sqrt(U10M^2 + V10M^2)
    solar  = SWGDN
    cloud  = CLDTOT
    dTsurf = T10M - T2M

    #   EPA MMGRMA Document, Table 6-7
    #   https://www.epa.gov/sites/default/files/2020-10/documents/mmgrma_0.pdf
    stab_cls = ifelse(
        solar .< solrad_night,
            ifelse(cloud .<= cloudfrac_clear,
                ifelse(dTsurf .> inversion_thresh,
                    ifelse(wind_speed .< v2, 6, 5),
                    4
                ),
                4
            ),
        ifelse(solar .>= solrad_strong,
            ifelse(wind_speed .< v3, 1,
                ifelse(wind_speed .< v5, 2, 3)
            ),
        ifelse(solar .>= solrad_moder,
            ifelse(wind_speed .< v2, 1,
                ifelse(wind_speed .< v5, 2,
                    ifelse(wind_speed .< v6, 3, 4)
                )
            ),
        ifelse(solar .>= solrad_slight,
            ifelse(wind_speed .< v2, 2,
                ifelse(wind_speed .< v5, 3, 4)
            ),
            4
        ))))

    ay = ifelse(stab_cls .== 1, AY_A,
        ifelse(stab_cls .== 2, AY_B,
        ifelse(stab_cls .== 3, AY_C,
        ifelse(stab_cls .== 4, AY_D,
        ifelse(stab_cls .== 5, AY_Ep, AY_F)))))

    az = ifelse(stab_cls .== 1, AZ_A,
        ifelse(stab_cls .== 2, AZ_B,
        ifelse(stab_cls .== 3, AZ_C,
        ifelse(stab_cls .== 4, AZ_D,
        ifelse(stab_cls .== 5, AZ_Ep, AZ_F)))))

    bz = ifelse(stab_cls .== 1, BZ_A,
        ifelse(stab_cls .== 2, BZ_B,
        ifelse(stab_cls .== 3, BZ_C,
        ifelse(stab_cls .== 4, BZ_D,
        ifelse(stab_cls .== 5, BZ_Ep, BZ_F)))))

    by = BY

    sigma_h_rhs = ay * x * (1 + by * x)^(-0.5)

    sigma_z_rhs = az * x / sqrt(1 + bz * x)
    sigma_z_rhs = ifelse(stab_cls .>= 5, az * x / (1 + bz * x), sigma_z_rhs)
    
    delta_lon = lon - lon0
    delta_lat = lat - lat0
    a = sin(delta_lat / 2)^2 + cos(lat0) * cos(lat) * sin(delta_lon / 2)^2
    c = 2 * atan(sqrt(a) / sqrt(1 - a))
    x_expr = R * c

    eqs = [
        x  ~ x_expr,
        sigma_h ~ sigma_h_rhs,
        sigma_z ~ sigma_z_rhs,
    ]

    ODESystem(
        eqs,
        t,
        [lon, lat, x, sigma_h, sigma_z, U10M, V10M, SWGDN, CLDTOT, T2M, T10M],
        [
            lon0, lat0, R,
            v2, v3, v5, v6,
            solrad_night, solrad_strong, solrad_moder, solrad_slight,
            cloudfrac_clear, inversion_thresh,
            AY_A, AY_B, AY_C, AY_D, AY_Ep, AY_F,
            AZ_A, AZ_B, AZ_C, AZ_D, AZ_Ep, AZ_F,
            BZ_A, BZ_B, BZ_C, BZ_D, BZ_Ep, BZ_F,
            BY
        ];
        name = :GaussianDispersion,
        metadata = Dict(:coupletype => GaussianDispersionCoupler)
    )
end