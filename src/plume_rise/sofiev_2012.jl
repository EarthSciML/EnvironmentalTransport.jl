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
    params1 = @parameters begin # TODO(CT): Should be able to use @constants instead.
        P_f0 = 1e6, [unit = u"W", description = "Reference fire power"]
        N_0 = sqrt(2.5e-4),
        [unit = u"1/s", description = "Reference Brunt-Vaisala frequency"]
        α = 0.24, [description = "Empirical constant"]
        β = 170.0, [unit = u"m", description = "Empirical constant"]
        γ = 0.35, [description = "Empirical constant"]
        δ = 0.6, [description = "Empirical constant"]
    end

    params2 = @parameters begin
        P_fr = 5e6, [unit = u"W", description = "Fire radiative power"]

        # Used to calculate the initial guess of the plume top level
        h_to_lev = 100.0, [unit = u"m", description = "Height to level transform"]
        k_s12 = β * (P_fr / P_f0)^γ, [unit = u"m"]
    end

    # TODO(HE): Use as parameters.
    @variables begin
        H_abl(t),   [unit = u"m",  description = "Atmospheric boundary layer height"]
        H_p(t),   [unit = u"m", description = "Plume top height"]
        lev_p(t),   [description = "Vertical level of the plume top height"]
        N_ft(t), [unit = u"1/s", description = "Free troposphere Brunt-Vaisala frequency"]
    end

    #pd = [H_p ~ α * H_abl + β * (P_fr / P_f0)^γ * exp(-δ * N_ft^2 / N_0^2)]
    eqs = [
        H_p ~ α*H_abl + k_s12 * exp(-δ * (N_ft/N_0)^2)
    ]
    #observed = [
    #H_p ~ α * H_abl + β * (P_fr / P_f0)^γ * exp(-δ * (N_ft^2) / (N_0^2))
    #]
    #System(
    #    Equation[], t, [H_abl, H_p, lev_p, N_ft], [params1; params2]; name = name, parameter_dependencies = pd,
    #    metadata = Dict(CoupleType => Sofiev2012PlumeRiseCoupler))
    System(
        eqs, t, [H_abl, H_p, lev_p, N_ft], [params1; params2]; name = name,
        metadata = Dict(:coupletype => Sofiev2012PlumeRiseCoupler))
end

function EarthSciMLBase.couple2(s12::Sofiev2012PlumeRiseCoupler, puff::PuffCoupler)
    s12, puff = s12.sys, puff.sys

    # Set level initial condition equal to the plume top height.
    @unpack lev = puff
    dflt = get_defaults(puff)
    dflt[lev] = ParentScope(s12.lev_p)

    ConnectorSystem([], s12, puff)
end
