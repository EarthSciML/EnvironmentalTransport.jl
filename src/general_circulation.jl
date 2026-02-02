export GeneralCirculation

"""
    GeneralCirculation(; name = :GeneralCirculation)

Return a `ModelingToolkit.System` implementing equations for the general circulation of the
atmosphere, including the Coriolis parameter, geostrophic wind, and thermal wind relations.

These equations are from Chapter 21 of Seinfeld & Pandis (2006), "Atmospheric Chemistry and
Physics: From Air Pollution to Climate Change", 2nd Edition, John Wiley & Sons, pp. 980-1002.

The component calculates:
- **Coriolis parameter** (f): The latitude-dependent parameter that quantifies the Coriolis
  force magnitude (Eq. 21.2)
- **Geostrophic wind components** (u_g, v_g): Wind speeds resulting from balance between
  pressure gradient force and Coriolis force (Eq. 21.14)
- **Tangential speed** (v_tan): Speed of a point on Earth's surface due to rotation (Eq. 21.1)
- **Thermal wind shear** (du_g_dz, dv_g_dz): Vertical gradients of geostrophic wind due to
  horizontal temperature gradients (Eq. 21.22)

The geostrophic approximation is valid above approximately 500 m altitude where friction
with the Earth's surface is negligible. Near the equator (|φ| < ~5°), the Coriolis parameter
approaches zero and the geostrophic approximation breaks down.

# Example

```julia
using ModelingToolkit
using EnvironmentalTransport

sys = GeneralCirculation()
sys_simplified = mtkcompile(sys)

# Calculate Coriolis parameter and geostrophic wind at 45°N
# with a meridional pressure gradient of -0.01 Pa/m
prob = ODEProblem(sys_simplified, [], (0.0, 1.0), [
    sys_simplified.lat => deg2rad(45.0),
    sys_simplified.dp_dy => -0.01,
    sys_simplified.dp_dx => 0.0,
    sys_simplified.rho => 1.0,
])
sol = solve(prob)

# Access the Coriolis parameter
f = sol[sys_simplified.f][1]  # ≈ 1.03e-4 s⁻¹

# Access geostrophic wind
u_g = sol[sys_simplified.u_g][1]  # Eastward geostrophic wind
```

# References

- Seinfeld, J. H., & Pandis, S. N. (2006). Atmospheric Chemistry and Physics: From Air
  Pollution to Climate Change (2nd ed.). John Wiley & Sons, Inc. Chapter 21.
"""
@component function GeneralCirculation(; name = :GeneralCirculation)
    @constants begin
        Omega = 7.2921e-5, [description = "Earth's angular velocity", unit = u"rad/s"]
        R_earth = 6.371e6, [description = "Earth's mean radius", unit = u"m"]
        g = 9.807, [description = "Gravitational acceleration", unit = u"m/s^2"]
    end

    @parameters begin
        lat, [description = "Latitude", unit = u"rad"]
        rho = 1.225, [description = "Air density", unit = u"kg/m^3"]
        dp_dx = 0.0, [description = "Pressure gradient in x (eastward) direction", unit = u"Pa/m"]
        dp_dy = 0.0, [description = "Pressure gradient in y (northward) direction", unit = u"Pa/m"]
        dT_dx = 0.0, [description = "Temperature gradient in x direction at constant pressure", unit = u"K/m"]
        dT_dy = 0.0, [description = "Temperature gradient in y direction at constant pressure", unit = u"K/m"]
        T = 288.15, [description = "Air temperature", unit = u"K"]
        p = 101325.0, [description = "Air pressure", unit = u"Pa"]
    end

    @variables begin
        f(t), [description = "Coriolis parameter", unit = u"s^-1"]
        v_tan(t), [description = "Tangential speed at latitude due to Earth rotation", unit = u"m/s"]
        u_g(t), [description = "Zonal (eastward) geostrophic wind component", unit = u"m/s"]
        v_g(t), [description = "Meridional (northward) geostrophic wind component", unit = u"m/s"]
        du_g_dz(t), [description = "Thermal wind: vertical gradient of zonal geostrophic wind", unit = u"s^-1"]
        dv_g_dz(t), [description = "Thermal wind: vertical gradient of meridional geostrophic wind", unit = u"s^-1"]
    end

    eqs = [
        # Eq. 21.2 - Coriolis parameter
        f ~ 2 * Omega * sin(lat),

        # Eq. 21.1 - Tangential speed at latitude
        v_tan ~ Omega * R_earth * cos(lat),

        # Eq. 21.14 - Geostrophic wind components
        # u_g = -(1/ρf)(∂p/∂y)
        u_g ~ -dp_dy / (rho * f),
        # v_g = (1/ρf)(∂p/∂x)
        v_g ~ dp_dx / (rho * f),

        # Eq. 21.22 - Thermal wind relations (converted from pressure to height coordinates)
        # In pressure coordinates: ∂u_g/∂p = R/(fp)(∂T/∂y)_p
        # Converting to height using ∂p/∂z = -ρg and ρ = p/(RT):
        # ∂u_g/∂z = -(g/fT)(∂T/∂y)_p
        du_g_dz ~ -(g / (f * T)) * dT_dy,
        # Similarly: ∂v_g/∂z = (g/fT)(∂T/∂x)_p
        dv_g_dz ~ (g / (f * T)) * dT_dx,
    ]

    return System(eqs, t; name)
end
