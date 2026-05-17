export Sofiev2012PlumeRise

struct Sofiev2012PlumeRiseCoupler
    sys
end

"""
Wildfire plume rise model based on Sofiev et al. (2012) [1].

When coupled with [`Puff`](@ref) and a meteorology source like
`EarthSciData.GEOSFP`, this model sets `Puff.lev`'s initial condition to
the symbolic expression `Sofiev2012PlumeRise.lev_p` (computed from
interpolated meteorology and fire radiative power) so the puff is released
at the plume-top level.

`lev_p` cannot be evaluated until the EarthSciData data-load callback has
populated the meteorology buffers (which happens at integrator init).
Because the InitializationProblem is solved before callbacks fire, a
freshly constructed `prob` cannot just be `solve`d — the symbolic IC
evaluates against zero-filled buffers and produces NaN. The standard
workaround is a two-step warmup:

```julia
# 1. Build a warmup prob with an explicit numeric `Puff.lev` so init can
#    proceed; solve briefly (one saved sample) to populate buffers.
warm_prob = ODEProblem(sys, [sys.Puff₊lev => 5.0], get_tspan(di))
warm_sol = solve(warm_prob; save_everystep = false, save_start = true,
                 save_end = false)

# 2. Read the numerical `lev_p` from the warmup, build the real prob with
#    that value, and solve.
lev_p_value = first(getu(sys, sys.Sofiev2012PlumeRise₊lev_p)(warm_sol))
prob = ODEProblem(sys, [sys.Puff₊lev => lev_p_value], get_tspan(di))
sol = solve(prob)
```

For an `EnsembleProblem` whose `prob_func` varies the fire `lon`/`lat`/
`P_fr` per trajectory, the warmup yields a representative `lev_p`; if
per-trajectory plume heights are required, run a warmup per trajectory or
have `prob_func` return a problem whose `Puff.lev` is computed from that
trajectory's parameters.

[1] Sofiev, M., Ermakova, T., and Vankevich, R.: Evaluation of the smoke-injection height
from wild-land fires using remote-sensing data, Atmos. Chem. Phys., 12, 1995–2006,
https://doi.org/10.5194/acp-12-1995-2012, 2012.
"""
function Sofiev2012PlumeRise(; name = :Sofiev2012PlumeRise)
    params1 = @parameters begin # TODO(CT): Should be able to use @constants instead.
        P_f0 = 1.0e6, [unit = u"W", description = "Reference fire power"]
        N_0 = sqrt(2.5e-4),
            [unit = u"1/s", description = "Reference Brunt-Vaisala frequency"]
        α = 0.24, [description = "Empirical constant"]
        β = 170.0, [unit = u"m", description = "Empirical constant"]
        γ = 0.35, [description = "Empirical constant"]
        δ = 0.6, [description = "Empirical constant"]
        Rd = 287.05, [unit = u"J/(kg*K)", description = "Dry-air gas constant"]
        g = 9.80665, [unit = u"m/s^2", description = "Gravitational acceleration"]
        Punit = 1.0, [unit = u"Pa", description = "Unit pressure"]
        H_scale = 1.0, [description = "Scaling factor for plume height"]
    end

    params2 = @parameters begin
        P_fr = 5.0e6, [unit = u"W", description = "Fire radiative power"]

        # Used to calculate the initial guess of the plume top level
        h_to_lev = 100.0, [unit = u"m", description = "Height to level transform"]
    end

    # TODO(HE): Use as parameters?
    @variables begin
        H_abl(t), [unit = u"m", description = "Atmospheric boundary layer height"]
        H_p(t), [unit = u"m", description = "Plume top height"]
        lev_p(t), [description = "Vertical level of the plume top height"]
        N_ft(t), [unit = u"1/s", description = "Free troposphere Brunt-Vaisala frequency"]
    end

    eqs = [H_p ~ α * H_abl + β * (P_fr / P_f0)^γ * exp(-δ * N_ft^2 / N_0^2) * H_scale]

    return System(
        eqs, t, [H_abl, H_p, lev_p, N_ft], [params1; params2];
        name = name,
        metadata = Dict(CoupleType => Sofiev2012PlumeRiseCoupler)
    )
end

function EarthSciMLBase.couple2(s12::Sofiev2012PlumeRiseCoupler, puff::PuffCoupler)
    s12, puff = s12.sys, puff.sys
    puff = EarthSciMLBase.strip_var_default(puff, :lev)
    return ConnectorSystem([], s12, puff; initialization_equations = [puff.lev ~ s12.lev_p])
end
