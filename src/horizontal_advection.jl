#### This Julia file contains functions to implement 
####  1) 1-D L94 advection: advect1d_l94() (Lin et al., 1994)
####  2) 1-D PPM advection: advect1d_ppm() (Collela and Woodward, 1984)
####  3) 2-D horizontal advection: advect2D() (Lin and Rood, 1996)

#### I will upload the environment later but basically the code block below is the packages I use.
##   -------------------------------------------------------------------------------------------
##   ]activate EarthSciML_Advection
##   using EarthSciData, EarthSciMLBase, GasChem,
##   DomainSets, ModelingToolkit, DifferentialEquations, Dates
##   using Plots, Statistics, GeoDataFrames, NCDatasets
##   using Flux
##   using BSON: @save
##   using BSON: @load
##   using Base.Threads
##   using LoopVectorization
##   using Tullio
##   -------------------------------------------------------------------------------------------




## L94 advection in 1-D (Lin et al., 1994)
## This is to make splitted scheme
function advect1d_l94(s1d_in::Vector{Float64},vel_1d::Vector{Float64},nz,Δt,Δz)

    ϕ1 = zeros(Float64, nz+4)
    ϕ2 = zeros(Float64, nz+4)
    δϕ1 = zeros(Float64, nz+4)
    Δϕ1_avg = zeros(Float64, nz+3)
    ϕ1_min = zeros(Float64, nz+3)
    ϕ1_max = zeros(Float64, nz+3)
    Δϕ1_mono = zeros(Float64, nz+3)
    FLUX = zeros(Float64, nz+1)
    courant = zeros(Float64, nz+1)
    U = zeros(Float64, nz+1)
    s1d_out = zeros(Float64, nz)
    
    U = vel_1d
    
    #@tullio ϕ1[i] = s1d_in[i]
    ## Initialization
    ϕ1[3:nz+2] = s1d_in[1:nz]
    ϕ1[1] = ϕ1[3]; ϕ1[2] = ϕ1[3]
    ϕ1[nz+3] = ϕ1[nz+2]; ϕ1[nz+4] = ϕ1[nz+2]
    
    @tullio δϕ1[i] = ϕ1[i]-ϕ1[i-1]
    
    @tullio Δϕ1_avg[i] = (δϕ1[i]+δϕ1[i+1])/2.0
    
    ## Monotonicity slope limiter
    @tullio ϕ1_min[i] = minimum((ϕ1[i-1], ϕ1[i], ϕ1[i+1]))
    @tullio ϕ1_max[i] = maximum((ϕ1[i-1], ϕ1[i], ϕ1[i+1]))
    @tullio Δϕ1_mono[i+1] = sign(Δϕ1_avg[i+1]) * minimum((abs(Δϕ1_avg[i+1]), 2*(ϕ1[i+1]-ϕ1_min[i+1]), 2*(ϕ1_max[i+1]-ϕ1[i+1])))
    
    @tullio courant[i] = U[i]*Δt/(Δz)
    
    @tullio FLUX[i] = (courant[i] >= 0)*(U[i] * (ϕ1[i+1] + Δϕ1_mono[i+1]*(1-courant[i])/2.0)) + (courant[i] < 0)*(U[i] * (ϕ1[i+2] - Δϕ1_mono[i+2]*(1+courant[i])/2.0))
    

    @tullio ϕ2[i] = ϕ1[i] - Δt/Δz * (FLUX[i-1]-FLUX[i-2])
    
    for i in 1:nz
        if ϕ2[i+2] >= 0
            s1d_out[i] = ϕ2[i+2]
        else
            s1d_out[i] = 0
        end
    end
    
    #@tullio s1d_out[i] = ϕ2[i] * (ϕ2[i] >= 0)
    #s1d_out[1] = 0; s1d_out[2] = 0; s1d_out[nz+3] = 0; s1d_out[nz+4] = 0;
    
    #s1d_out .= s1d_out .- s1d_in
    
    return s1d_out
end

## PPM advection in 1-D (Collela and Woodward, 1984)
## This is to make splitted scheme
function advect1d_ppm(s1d_in::Vector{Float64},vel_1d::Vector{Float64},nz,Δt,Δz)
    
    ϵ = 0.01
    η⁽¹⁾ = 20
    η⁽²⁾ = 0.05
    
    ϕ1 = zeros(Float64, nz+6)
    ϕ2 = zeros(Float64, nz+6)
    δϕ = zeros(Float64, nz+6)
    δₘϕ = zeros(Float64, nz+6)
    ϕ₊½ = zeros(Float64, nz+6)
    ϕL = zeros(Float64, nz+6)
    ϕR = zeros(Float64, nz+6)
    ϕLᵈ = zeros(Float64, nz+6)
    ϕRᵈ = zeros(Float64, nz+6)
    Δϕ = zeros(Float64, nz+6)
    δ²ϕ = zeros(Float64, nz+6)
    η_tilde = zeros(Float64, nz+6)
    η = zeros(Float64, nz+6)
    ϕ₆ = zeros(Float64, nz+6)
    
    FLUX = zeros(Float64, nz+1)
    courant = zeros(Float64, nz+1)
    U = zeros(Float64, nz+1)
    s1d_out = zeros(Float64, nz)
    
    U = vel_1d
    
    ## Initialization
    ϕ1[4:nz+3] = s1d_in[1:nz]
    ϕ1[1] = ϕ1[4]; ϕ1[2] = ϕ1[4]; ϕ1[3] = ϕ1[4]
    ϕ1[nz+4] = ϕ1[nz+3]; ϕ1[nz+5] = ϕ1[nz+3]; ϕ1[nz+6] = ϕ1[nz+3]
    
    ## Edge value calculation
    for i in 2:nz+5
        δϕ[i] = 1/2*(ϕ1[i+1]-ϕ1[i-1])
    end
    
    for i in 2:nz+5
        if (ϕ1[i+1]-ϕ1[i])*(ϕ1[i]-ϕ1[i-1]) > 0
            δₘϕ[i] = min(abs(δϕ[i-1]), 2*abs(ϕ1[i]-ϕ1[i-1]), 2*abs(ϕ1[i+1]-ϕ1[i])) * sign(δϕ[i-1])
        else
            δₘϕ[i] = 0
        end
    end
    
    for i in 2:nz+5
        ϕ₊½[i] = 1/2*(ϕ1[i+1]+ϕ1[i]) - 1/6*(δₘϕ[i+1]-δₘϕ[i])
    end
    
    for i in 2:nz+4
        ϕL[i] = ϕ₊½[i]
        ϕR[i] = ϕ₊½[i+1]
    end
    
    ## Discontinuity detection
    for i in 2:nz+5
        δ²ϕ[i] = 1/(6*Δz^2)*(ϕ1[i+1]-2*ϕ1[i]+ϕ1[i-1])
    end
    
    for i in 2:nz+5
        if -δ²ϕ[i+1]*δ²ϕ[i-1]*abs(ϕ1[i+1]-ϕ1[i-1]) - ϵ*min(abs(ϕ1[i+1]),abs(ϕ1[i-1])) > 0
            η_tilde[i] = -(δ²ϕ[i+1]-δ²ϕ[i-1]) * (Δz^2) / (ϕ1[i+1]-ϕ1[i-1])
        else
            η_tilde[i] = 0
        end
    end
    
    for i in 2:nz+5
        η[i] = max(0, min(η⁽¹⁾*(η_tilde[i]-η⁽²⁾), 1))
    end
    
    for i in 2:nz+4
        ϕLᵈ[i] = ϕ1[i] + 1/2*δₘϕ[i]
        ϕRᵈ[i] = ϕ1[i+1] + 1/2*δₘϕ[i+1]
    end
    
    for i in 2:nz+4
        ϕL[i] = ϕL[i]*(1-η[i]) + ϕLᵈ[i]*η[i]
        ϕR[i] = ϕR[i]*(1-η[i]) + ϕRᵈ[i]*η[i]
    end
    
    ## Monotonicity examination
    for i in 2:nz+4
        if (ϕR[i]-ϕ1[i])*(ϕ1[i]-ϕL[i]) <= 0
            ϕL[i] = ϕ1[i]
            ϕR[i] = ϕ1[i]
        elseif (ϕR[i]-ϕL[i])*(ϕ1[i]-1/2*(ϕL[i]+ϕR[i])) >= (ϕR[i]-ϕL[i])^2/6
            ϕL[i] = 3*ϕ1[i] - 2*ϕR[i]
        elseif -(ϕR[i]-ϕL[i])^2/6 > (ϕR[i]-ϕL[i])*(ϕ1[i]-1/2*(ϕR[i]+ϕL[i]))
            ϕR[i] = 3*ϕ1[i] - 2*ϕL[i]
        end
    end
        
    ## Compute flux
    for i in 1:nz+1
        courant[i] = U[i]*Δt/Δz
    end
    
    for i in 2:nz+4
        Δϕ[i] = ϕR[i] - ϕL[i]
    end
    
    for i in 2:nz+4
        ϕ₆[i] = 6*(ϕ1[i] - 1/2*(ϕL[i]+ϕR[i]))
    end
    
    for i in 3:nz+3
        if U[i-2] >= 0
            FLUX[i-2] = courant[i-2] * (ϕR[i]-1/2*courant[i-2]*(Δϕ[i]-(1-2/3*courant[i-2])*ϕ₆[i]))
        else
            FLUX[i-2] = courant[i-2] * (ϕL[i+1]-1/2*courant[i-2]*(Δϕ[i+1]-(1+2/3*courant[i-2])*ϕ₆[i+1]))
        end
    end

    for i in 4:nz+3
        ϕ2[i] = ϕ1[i] + (FLUX[i-3]-FLUX[i-2])
    end
    
    for i in 1:nz
        s1d_out[i] = ϕ2[i+3]
    end

    ### In case we want to explicitly correct a negative concentration to zero.
    #for i in 1:nz
    #    if ϕ2[i+3] >= 0
    #        s1d_out[i] = ϕ2[i+3]
    #    else
    #        s1d_out[i] = 0
    #    end
        #s1d_out[i] = ϕ2[i+3] * (ϕ2[i+3] >= 0)
    #end
    
    #s1d_out .= s1d_out .- s1d_in
    
    return s1d_out
end



#### Advection in 2-D
## Using the output of 1-D advection, we implemented the non-directional splitting 2-D advection. -- LR96 approach (Lin and Rood 1996)
function advect2D(dt, nx, ny, s1, u, v)

    ### BC implementation -- Need to revisit here later
    s2d = zeros(nx+4,ny+4)
    s2d[3:nx+2,3:ny+2] = s1'
    
    bc!(nx, ny, s2d)
    
    u_edge = zeros(nx+1,ny);v_edge = zeros(nx,ny+1)
    
    u_edge[1,:] = u'[1,:]; u_edge[nx+1,:] = u'[nx,:]
    v_edge[:,1] = v'[:,1]; v_edge[:,ny+1] = v'[:,ny]
    
    for j in 1:ny
        for i in 2:nx
            u_edge[i,j] = (u'[i-1,j] + u'[i,j]) / 2.0
        end
    end
    
    for i in 1:nx
        for j in 2:ny
            v_edge[i,j] = (v'[i,j-1] + v'[i,j]) / 2.0
        end
    end
    
    ### Populate the arrays
    s1d_xin = zeros(nx+4)
    s1d_xout = zeros(nx+4)
    s1d_yin = zeros(ny+4)
    s1d_yout = zeros(ny+4)
    vel_x1d = zeros(nx+1)
    vel_y1d = zeros(ny+1)
    
    F_Q = zeros(nx+4, ny+4)
    G_Q = zeros(nx+4, ny+4)
    
    F_GQ = zeros(nx+4, ny+4)
    G_FQ = zeros(nx+4, ny+4)
    
    s2d_xout = zeros(nx+4, ny+4)
    s2d_yout = zeros(nx+4, ny+4)
    
    Re = 6378000
    dy = Re*(lats[2] - lats[1])*π/180
    
    for j in 1:ny
        for i in 1:nx+4
            s1d_xin[i] = s2d[i,j+2]
        end
        for i in 1:nx+1
            vel_x1d[i] = u_edge[i,j]
        end
        dx = Re * cos(lats[j]*π/180) * (lons[2] - lons[1])*π/180
        s1d_xout = advect1d(s1d_xin,vel_x1d,nx,dt,dx)
        
        F_Q[:,j+2] = s1d_xout[:]
    end    
        
    for i in 1:nx
        for j in 1:ny+4
            s1d_yin[j] = s2d[i+2,j]
        end
        for j in 1:ny+1
            vel_y1d[j] = v_edge[i,j]
        end
        s1d_yout = advect1d(s1d_yin,vel_y1d,ny,dt,dy)

        G_Q[i+2,:] = s1d_yout[:]

    end    
    
    for j in 1:ny
        for i in 1:nx+4
            s1d_xin[i] = s2d[i,j+2] + 0.5*G_Q[i,j+2]
        end
        for i in 1:nx+1
            vel_x1d[i] = u_edge[i,j]
        end
        dx = Re * cos(lats[j]*π/180) * (lons[2] - lons[1])*π/180
        s1d_xout = advect1d(s1d_xin,vel_x1d,nx,dt,dx)

        F_GQ[:,j+2] = s1d_xout[:]

    end    
    
    for i in 1:nx
        for j in 1:ny+4
            s1d_yin[j] = s2d[i+2,j] + 0.5*F_Q[i+2,j]
        end
        for j in 1:ny+1
            vel_y1d[j] = v_edge[i,j]
        end
        s1d_yout = advect1d(s1d_yin,vel_y1d,ny,dt,dy)

        G_FQ[i+2,:] = s1d_yout[:]

    end    
    
    for i in 3:nx+2
        for j in 3:ny+2
            s2d[i,j] = s2d[i,j] + F_GQ[i,j] + G_FQ[i,j]
            s1[j-2,i-2] = s2d[i,j]
        end
    end
       
    return s1
end
