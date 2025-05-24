export Sofiev2012PlumeRise

struct Sofiev2012PlumeRiseCoupler
    sys
end

"""
Wildfire plume rise model based on Sofiev et al. (2012) [1].

[1] Sofiev, M., Ermakova, T., and Vankevich, R.: Evaluation of the smoke-injection height
from wild-land fires using remote-sensing data, Atmos. Chem. Phys., 12, 1995–2006,
https://doi.org/10.5194/acp-12-1995-2012, 2012.
"""
function Sofiev2012PlumeRise(; name = :Sofiev2012PlumeRise)
    @constants begin
        P_f0 = 1e6, [unit = u"W", description = "Reference fire power"]
        N_0 = sqrt(2.5e-4),
        [unit = u"1/s", description = "Reference Brunt-Vaisala frequency"]
        α = 0.24, [description = "Empirical constant"]
        β = 170.0, [unit = u"m", description = "Empirical constant"]
        γ = 0.35, [description = "Empirical constant"]
        δ = 0.6, [description = "Empirical constant"]
    end

    params = @parameters begin
        H_abl = 1000.0, [unit = u"m", description = "Atmospheric boundary layer height"]
        N_ft = 0.02, # TODO(CT): Calculate this from data.
        [unit = u"1/s", description = "Free troposphere Brunt-Vaisala frequency"]
        P_fr = 5e6, [unit = u"W", description = "Fire radiative power"]

        # TODO(CT): Shouldn't have to substitute constants, remove after underlying issue is fixed.
        H_p = subs_constants(α * H_abl + β * (P_fr / P_f0)^γ * exp(-δ * N_ft^2 / N_0^2)),
        [unit = u"m", description = "Final plume top height"]
    end
    ODESystem(Equation[], t, [], params; name = name,
        metadata = Dict(:coupletype => Sofiev2012PlumeRiseCoupler))
end

function EarthSciMLBase.couple2(s12::Sofiev2012PlumeRiseCoupler, puff::PuffCoupler)
    s12, puff = s12.sys, puff.sys

    @constants h_to_lev = 1.0, [unit = u"m", description = "Height to level transform"]

    # Set level initial condition equal to the plume top height.
    puff.lev = ParentScope(s12.H_p) #/ h_to_lev

    ConnectorSystem([], s12, puff)
end
