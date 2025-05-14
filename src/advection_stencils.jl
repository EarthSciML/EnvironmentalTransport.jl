export l94_stencil, ppm_stencil, upwind1_stencil, upwind2_stencil, ppm_stencil_grid
"""
$(SIGNATURES)

L94 advection in 1-D (Lin et al., 1994)

  - ϕ is the scalar field at the current time step, it should be a vector of length 5.
  - U is the velocity at both edges of the central grid cell, it should be a vector of length 2.
  - Δt is the length of the time step.
  - Δz is the grid spacing.

The output will be time derivative of the central index (i.e. index 3)
of the ϕ vector (i.e. dϕ/dt).

(The output is dependent on the Courant number, which depends on Δt, so Δt needs to be
an input to the function.)
"""
function l94_stencil(ϕ, U, Δt, Δz::Number; kwargs...)
    δϕ1(i) = ϕ[i] - ϕ[i - 1]

    Δϕ1_avg(i) = (δϕ1(i) + δϕ1(i + 1)) / 2.0

    ## Monotonicity slope limiter
    ϕ1_min(i) = minimum((ϕ[i - 1], ϕ[i], ϕ[i + 1]))
    ϕ1_max(i) = maximum((ϕ[i - 1], ϕ[i], ϕ[i + 1]))
    function Δϕ1_mono(i)
        sign(Δϕ1_avg(i)) *
        minimum((abs(Δϕ1_avg(i)), 2 * (ϕ[i] - ϕ1_min(i)),
            2 * (ϕ1_max(i) - ϕ[i])))
    end

    courant(i) = U[i] * Δt / Δz

    function FLUX(i)
        ifelse(U[i] >= 0,
            (U[i] * (ϕ[i + 1] + Δϕ1_mono(i + 1) * (1 - courant(i)) / 2.0)),
            (U[i] * (ϕ[i + 2] - Δϕ1_mono(i + 2) * (1 + courant(i)) / 2.0)))
    end

    ϕ2(i) = -(FLUX(i - 1) - FLUX(i - 2)) / Δz

    ϕ2(3)
end

function l94_stencil(ϕ, U, Δt, Δz::AbstractVector; kwargs...)
    δϕ1(i) = ϕ[i] - ϕ[i - 1]

    Δϕ1_avg(i) = (δϕ1(i) + δϕ1(i + 1)) / 2.0

    ## Monotonicity slope limiter
    ϕ1_min(i) = minimum((ϕ[i - 1], ϕ[i], ϕ[i + 1]))
    ϕ1_max(i) = maximum((ϕ[i - 1], ϕ[i], ϕ[i + 1]))
    function Δϕ1_mono(i)
        sign(Δϕ1_avg(i)) *
        minimum((abs(Δϕ1_avg(i)), 2 * (ϕ[i] - ϕ1_min(i)),
            2 * (ϕ1_max(i) - ϕ[i])))
    end

    courant(i) = U[i] * Δt / Δz[i]

    function FLUX(i)
        ifelse(U[i] >= 0,
            (U[i] * (ϕ[i + 1] + Δϕ1_mono(i + 1) * (1 - courant(i)) / 2.0)),
            (U[i] * (ϕ[i + 2] - Δϕ1_mono(i + 2) * (1 + courant(i)) / 2.0)))
    end

    ϕ2(i) = -(FLUX(i - 1) - FLUX(i - 2)) / Δz[i]

    ϕ2(3)
end

"""
Return the left and right stencil size of the L94 stencil.
"""
stencil_size(s::typeof(l94_stencil)) = (2, 2)

"""
$(SIGNATURES)

PPM advection in 1-D (Collela and Woodward, 1984)

  - ϕ is the scalar field at the current time step, it should be a vector of length 8 (3 cells on the left, the central cell, and 4 cells on the right).
  - U is the velocity at both edges of the central grid cell, it should be a vector of length 2.
  - Δt is the length of the time step.
  - Δz is the grid spacing.

The output will be time derivative of the central index (i.e. index 4)
of the ϕ vector (i.e. dϕ/dt).

(The output is dependent on the Courant number, which depends on Δt, so Δt needs to be
an input to the function.)
"""
function ppm_stencil(ϕ, U, Δt, Δz::Number; kwargs...)
    ϵ = 0.01
    η⁽¹⁾ = 20
    η⁽²⁾ = 0.05

    ## Edge value calculation
    δϕ(i) = 1 / 2 * (ϕ[i + 1] - ϕ[i - 1])

    function δₘϕ(i)
        ifelse((ϕ[i + 1] - ϕ[i]) * (ϕ[i] - ϕ[i - 1]) > 0,
            min(
                abs(δϕ(i - 1)), 2 * abs(ϕ[i] - ϕ[i - 1]), 2 * abs(ϕ[i + 1] - ϕ[i])) *
            sign(δϕ(i - 1)),
            zero(eltype(ϕ))
        )
    end

    ϕ₊½(i) = 1 / 2 * (ϕ[i + 1] + ϕ[i]) - 1 / 6 * (δₘϕ(i + 1) - δₘϕ(i))

    ## Discontinuity detection
    δ²ϕ(i) = 1 / (6 * Δz^2) * (ϕ[i + 1] - 2 * ϕ[i] + ϕ[i - 1])

    function η_tilde(i)
        ifelse(
            -δ²ϕ(i + 1) * δ²ϕ(i - 1) * abs(ϕ[i + 1] - ϕ[i - 1]) -
            ϵ * min(abs(ϕ[i + 1]), abs(ϕ[i - 1])) > 0,
            -(δ²ϕ(i + 1) - δ²ϕ(i - 1)) * (Δz^2) / (ϕ[i + 1] - ϕ[i - 1]),
            zero(eltype(ϕ))
        )
    end

    η(i) = clamp(η⁽¹⁾ * (η_tilde(i) - η⁽²⁾), 0, 1)

    ϕLᵈ(i) = ϕ[i] + 1 / 2 * δₘϕ(i)
    ϕRᵈ(i) = ϕ[i + 1] + 1 / 2 * δₘϕ(i + 1)

    ϕL₀(i) = ϕ₊½(i) * (1 - η(i)) + ϕLᵈ(i) * η(i)
    ϕR₀(i) = ϕ₊½(i + 1) * (1 - η(i)) + ϕRᵈ(i) * η(i)

    ## Monotonicity examination
    function ϕL(i)
        ifelse((ϕR₀(i) - ϕ[i]) * (ϕ[i] - ϕL₀(i)) <= 0,
            ϕ[i],
            ifelse(
                (ϕR₀(i) - ϕL₀(i)) * (ϕ[i] - 1 / 2 * (ϕL₀(i) + ϕR₀(i))) >=
                (ϕR₀(i) - ϕL₀(i))^2 / 6,
                3 * ϕ[i] - 2 * ϕR₀(i),
                ϕL₀(i)
            ))
    end

    function ϕR(i)
        ifelse((ϕR₀(i) - ϕ[i]) * (ϕ[i] - ϕL₀(i)) <= 0,
            ϕ[i],
            ifelse(
                -(ϕR₀(i) - ϕL₀(i))^2 / 6 >
                (ϕR₀(i) - ϕL₀(i)) * (ϕ[i] - 1 / 2 * (ϕR₀(i) + ϕL₀(i))),
                3 * ϕ[i] - 2 * ϕL₀(i),
                ϕR₀(i)
            ))
    end

    ## Compute flux
    courant(i) = U[i] * Δt / Δz

    Δϕ(i) = ϕR(i) - ϕL(i)

    ϕ₆(i) = 6 * (ϕ[i] - 1 / 2 * (ϕL(i) + ϕR(i)))

    function FLUX(i)
        ifelse(U[i] >= 0,
            courant(i) * (ϕR(i + 2) -
             1 / 2 * courant(i) *
             (Δϕ(i + 2) - (1 - 2 / 3 * courant(i)) * ϕ₆(i + 2))),
            courant(i) * (ϕL(i + 3) -
             1 / 2 * courant(i) *
             (Δϕ(i + 3) - (1 + 2 / 3 * courant(i)) * ϕ₆(i + 3)))
        )
    end

    ϕ2(i) = (FLUX(i - 3) - FLUX(i - 2)) / Δt

    ϕ2(4)
end

function ppm_stencil(ϕ, U, Δt, Δz::AbstractVector; kwargs...)
    ϵ = 0.01
    η⁽¹⁾ = 20
    η⁽²⁾ = 0.05

    ## Edge value calculation
    δϕ(i) = (Δz[i]/(Δz[i-1]+Δz[i]+Δz[i+1])) * 
                ( ((2*Δz[i-1]+Δz[i])/(Δz[i+1]+Δz[i]))*(ϕ[i+1]-ϕ[i]) + 
                ((Δz[i]+2*Δz[i+1])/(Δz[i-1]+Δz[i]))*(ϕ[i]-ϕ[i-1]) )

    function δₘϕ(i)
        ifelse((ϕ[i + 1] - ϕ[i]) * (ϕ[i] - ϕ[i - 1]) > 0,
            min(
                abs(δϕ(i - 1)), 2 * abs(ϕ[i] - ϕ[i - 1]), 2 * abs(ϕ[i + 1] - ϕ[i])) *
            sign(δϕ(i - 1)),
            zero(eltype(ϕ))
        )
    end

    ϕ₊½(i) = ϕ[i] + 
            (Δz[i])/(Δz[i]+Δz[i+1])*(ϕ[i+1]-ϕ[i]) + 
            1/(Δz[i-1]+Δz[i]+Δz[i+1]+Δz[i+2])*(
            (2*Δz[i+1]*Δz[i])/(Δz[i]+Δz[i+1])*
            ((Δz[i-1]+Δz[i])/(2*Δz[i]+Δz[i+1])-(Δz[i+2]+Δz[i+1])/(2*Δz[i+1]+Δz[i]))*
            (ϕ[i+1]-ϕ[i]) - 
            Δz[i]*(Δz[i-1]+Δz[i])/(2*Δz[i]+Δz[i+1])*δₘϕ(i+1) +
            Δz[i+1]*(Δz[i+1]+Δz[i+2])/(Δz[i]+2*Δz[i+1])*δₘϕ(i) )

    ## Discontinuity detection
    δ²ϕ(i) = 1/(Δz[i-1]+Δz[i]+Δz[i+1])*((ϕ[i+1]-ϕ[i])/(Δz[i+1]+Δz[i])-(ϕ[i]-ϕ[i-1])/(Δz[i]+Δz[i-1]))

    function η_tilde(i)
        ifelse(
            -δ²ϕ(i + 1) * δ²ϕ(i - 1) * abs(ϕ[i + 1] - ϕ[i - 1]) -
            ϵ * min(abs(ϕ[i + 1]), abs(ϕ[i - 1])) > 0,
            -(δ²ϕ(i+1)-δ²ϕ(i-1))/(Δz[i+1]+Δz[i])*(Δz[i]^3+Δz[i-1]^3)/(ϕ[i+1]-ϕ[i-1]),
            zero(eltype(ϕ))
        )
    end

    η(i) = clamp(η⁽¹⁾ * (η_tilde(i) - η⁽²⁾), 0, 1)

    ϕLᵈ(i) = ϕ[i] + 1 / 2 * δₘϕ(i)
    ϕRᵈ(i) = ϕ[i + 1] + 1 / 2 * δₘϕ(i + 1)

    ϕL₀(i) = ϕ₊½(i) * (1 - η(i)) + ϕLᵈ(i) * η(i)
    ϕR₀(i) = ϕ₊½(i + 1) * (1 - η(i)) + ϕRᵈ(i) * η(i)

    ## Monotonicity examination
    function ϕL(i)
        ifelse((ϕR₀(i) - ϕ[i]) * (ϕ[i] - ϕL₀(i)) <= 0,
            ϕ[i],
            ifelse(
                (ϕR₀(i) - ϕL₀(i)) * (ϕ[i] - 1 / 2 * (ϕL₀(i) + ϕR₀(i))) >=
                (ϕR₀(i) - ϕL₀(i))^2 / 6,
                3 * ϕ[i] - 2 * ϕR₀(i),
                ϕL₀(i)
            ))
    end

    function ϕR(i)
        ifelse((ϕR₀(i) - ϕ[i]) * (ϕ[i] - ϕL₀(i)) <= 0,
            ϕ[i],
            ifelse(
                -(ϕR₀(i) - ϕL₀(i))^2 / 6 >
                (ϕR₀(i) - ϕL₀(i)) * (ϕ[i] - 1 / 2 * (ϕR₀(i) + ϕL₀(i))),
                3 * ϕ[i] - 2 * ϕL₀(i),
                ϕR₀(i)
            ))
    end

    ## Compute flux
    courant(i) = ifelse(U[i] > 0, U[i] * Δt / Δz[i+3], U[i] * Δt / Δz[i+2])

    Δϕ(i) = ϕR(i) - ϕL(i)

    ϕ₆(i) = 6 * (ϕ[i] - 1 / 2 * (ϕL(i) + ϕR(i)))

    function FLUX(i)
        ifelse(U[i] >= 0,
            courant(i) * (ϕR(i + 2) -
             1 / 2 * courant(i) *
             (Δϕ(i + 2) - (1 - 2 / 3 * courant(i)) * ϕ₆(i + 2))),
            courant(i) * (ϕL(i + 3) -
             1 / 2 * courant(i) *
             (Δϕ(i + 3) - (1 + 2 / 3 * courant(i)) * ϕ₆(i + 3)))
        )
    end

    ϕ2(i) = (FLUX(i - 3) - FLUX(i - 2)) / Δt

    ϕ2(4)
end



"""
Return the left and right stencil size of the PPM stencil.
"""
stencil_size(s::typeof(ppm_stencil)) = (3, 4)

"""
$(SIGNATURES)

First-order upwind advection in 1-D: https://en.wikipedia.org/wiki/Upwind_scheme.

  - ϕ is the scalar field at the current time step, it should be a vector of length 3 (1 cell on the left, the central cell, and 1 cell on the right).
  - U is the velocity at both edges of the central grid cell, it should be a vector of length 2.
  - Δt is the length of the time step.
  - Δz is the grid spacing.

The output will be time derivative of the central index (i.e. index 2)
of the ϕ vector (i.e. dϕ/dt).

`Δt` and `p` are not used, but are function arguments for consistency with other operators.
"""
function upwind1_stencil(ϕ, U, Δt, Δz::Number; p = nothing)
    sz = sign(Δz) # Handle negative grid spacing
    ul₊ = sz*max(sz*U[1], zero(eltype(U)))
    ul₋ = sz*min(sz*U[1], zero(eltype(U)))
    ur₊ = sz*max(sz*U[2], zero(eltype(U)))
    ur₋ = sz*min(sz*U[2], zero(eltype(U)))
    flux₊ = (ϕ[1]*ul₊ - ϕ[2]*ur₊) / Δz
    flux₋ = (ϕ[2]*ul₋ - ϕ[3]*ur₋) / Δz
    flux₊ + flux₋
end

function upwind1_stencil(ϕ, U, Δt, Δz::AbstractVector; p = nothing)
    sz = sign(Δz[1]) # Handle negative grid spacing
    ul₊ = sz*max(sz*U[1], zero(eltype(U)))
    ul₋ = sz*min(sz*U[1], zero(eltype(U)))
    ur₊ = sz*max(sz*U[2], zero(eltype(U)))
    ur₋ = sz*min(sz*U[2], zero(eltype(U)))
    flux₊ = (ϕ[1]*ul₊ - ϕ[2]*ur₊) / Δz[1]
    flux₋ = (ϕ[2]*ul₋ - ϕ[3]*ur₋) / Δz[1]
    flux₊ + flux₋
end

"""
Return the left and right stencil size of the first-order upwind stencil.
"""
stencil_size(s::typeof(upwind1_stencil)) = (1, 1)

"""
$(SIGNATURES)

Second-order upwind advection in 1-D, otherwise known as linear-upwind differencing (LUD): https://en.wikipedia.org/wiki/Upwind_scheme.

  - ϕ is the scalar field at the current time step, it should be a vector of length 5 (2 cells on the left, the central cell, and 2 cells on the right).
  - U is the velocity at both edges of the central grid cell, it should be a vector of length 2.
  - Δt is the length of the time step.
  - Δz is the grid spacing.

The output will be time derivative of the central index (i.e. index 3)
of the ϕ vector (i.e. dϕ/dt).

(Δt is not used, but is a function argument for consistency with other operators.)
"""
function upwind2_stencil(ϕ, U, Δt, Δz::Number; kwargs...)
    u₊ = max(U[1], zero(eltype(U)))
    u₋ = min(U[2], zero(eltype(U)))
    ϕ₋ = (3ϕ[3] - 4ϕ[2] + ϕ[1]) / (2Δz)
    ϕ₊ = (-ϕ[4] + 4ϕ[3] - 3ϕ[2]) / (2Δz)
    -(u₊ * ϕ₋ + u₋ * ϕ₊)
end

function upwind2_stencil(ϕ, U, Δt, Δz::AbstractVector; kwargs...)
    u₊ = max(U[1], zero(eltype(U)))
    u₋ = min(U[2], zero(eltype(U)))
    ϕ₋ = (3ϕ[3] - 4ϕ[2] + ϕ[1]) / (2Δz[1])
    ϕ₊ = (-ϕ[4] + 4ϕ[3] - 3ϕ[2]) / (2Δz[1])
    -(u₊ * ϕ₋ + u₋ * ϕ₊)
end

"""
Return the left and right stencil size of the second-order upwind stencil.
"""
stencil_size(s::typeof(upwind2_stencil)) = (2, 2)

