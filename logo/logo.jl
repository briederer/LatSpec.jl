outpath = joinpath(@__DIR__,"logos");
mkpath(outpath)
using Luxor
using Colors

include("logo_functions.jl")

gs = 3              # gridsize
deg = π/7           # degree of tilting for 3rd dimension
ratio = 1/sqrt(3)   # how to compress the 3rd dimension

# start drawing
Drawing(1000, 400, "$(outpath)/logo_2.svg")


origin()
background("white")

@layer begin
    # The lattice
    @layer begin
        Luxor.translate(-500,150)
        scale(240)
        setlinecap(:round)
        @layer begin
            setline(2)
            #cube_back(gs, deg, ratio)
            setline(1)
            inner_grid(gs, deg, ratio; particle_at=[(1,1,1),gs .- (1,1,1)], particle_opacity = 0.9)
            setline(2)
            #cube_front(gs, deg, ratio; opacity=0.2)
        end
    end

    # The title
    @layer begin
        Luxor.translate(-100,0)
        scale(12)
        @layer begin
            fontface("Telugu MN Bold")
            textoutlines("LatSpec.jl",O,:fill,valign=:middle,halign=:left)
        end
    end
end


finish()

preview()
