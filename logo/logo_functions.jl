function particle(p::Point = O; size::Real = 1, gray::Real = 0.5, opacity::Real = 0.5)
    transmat = getmatrix()

    transform([1, 0, 0, 1, p.x, p.y])
    @layer begin
        setgray(gray)
        setopacity(opacity)
        circle(0,0,2*size,:fill)
    end

    @layer begin
        juliacircles(size)
    end

    setmatrix(transmat)
end

function opaque_box_rounded(opacity::Real; fill_color::String = "white", stroke_color::String = "black")
    sethue(fill_color)
    setopacity(opacity)
    polysmooth(box(Point(0,0),Point(1,-1), vertices=true),.01,:fillpreserve)
    sethue(stroke_color)
    setopacity(1)
    strokepath()
end

function draw_grid(grid::Real)
    transmat = getmatrix()
    for x = 1:grid-1
        transform([1, 0, 0, 1, 1/grid, 0])
        line(Point(0,0),Point(0,-1),:stroke)
    end
    transform([1, 0, 0, 1, -(grid-1)/grid, 0])
    for x = 1:grid-1
        transform([1, 0, 0, 1, 0, -1/grid])
        line(Point(0,0),Point(1,0),:stroke)
    end
    setmatrix(transmat)
end

function cube_back(grid::Real, deg::Real = π/7, ratio::Real = 1/sqrt(2); opacity::Real = 0.3, kws...)

    transmat = getmatrix();

    # some factors
    degfac = tan(deg);
    fac = degfac*ratio;

    # back-plate
    transform([1, 0, 0, 1, fac/degfac, -fac])
    opaque_box_rounded(opacity; kws...)
    #back-grid
    draw_grid(grid)
    # reset transform
    transform([1, 0, 0, 1, -fac/degfac, fac])


    # transform for left-plate
    transform([ratio, -fac, 0, 1, 0, 0])
    opaque_box_rounded(opacity; kws...)
    #left-grid
    draw_grid(grid)
    # reset transform
    transform([1/ratio, degfac, 0, 1, 0, 0])


    #transform for bottom-plate
    transform([1, 0, -fac/degfac, fac, 0, 0])
    opaque_box_rounded(opacity; kws...)
    draw_grid(grid)

    # Reset matrix
    setmatrix(transmat)
end


function cube_front(grid::Real, deg::Real = π/7, ratio::Real = 1/sqrt(2); opacity::Real = 0.3, kws...)

    transmat = getmatrix();

    # some factors
    degfac = tan(deg);
    fac = degfac*ratio;

    # back-plate
    transform([1, 0, 0, 1, 0, 0])
    opaque_box_rounded(opacity; kws...)
    #back-grid
    draw_grid(grid)
    # reset transform
    transform([1, 0, 0, 1, 0, 0])


    # transform for right-plate
    transform([ratio, -fac, 0, 1, 1, 0])
    opaque_box_rounded(opacity; kws...)
    #left-grid
    draw_grid(grid)
    # reset transform
    transform([1/ratio, degfac, 0, 1, -1/ratio, -degfac])


    #transform for top-plate
    transform([1, 0, -fac/degfac, fac, 0, -1])
    opaque_box_rounded(opacity; kws...)
    draw_grid(grid)

    # Reset matrix
    setmatrix(transmat)
end

# very specific for our particle_positions but nor for degrees and ratios
function inner_grid(grid::Real, deg::Real = π/7, ratio::Real = 1/sqrt(2); particle_at::Vector{Tuple{Int64,Int64,Int64}}=[(missing,missing)], particle_opacity::Real = 0.5)
    transmat = getmatrix();

    # some factors
    degfac = tan(deg);
    fac = degfac*ratio;

    # grid
    setgray(0.7)
    particles = Array{Point}(undef,length(particle_at))
    i = 0;
    transform([1, 0, 0, 1, fac/degfac, -fac])
    for z = 1:grid
        transform([1, 0, 0, 1, -fac/(degfac*grid), fac/grid])
        if (z != grid) draw_grid(grid); end
        for x = 1:grid-1, y = 1:grid-1
            p = Point(x/grid,-y/grid)
            line(p,p+Point(ratio/grid,-fac/grid),:stroke)
            if (x,y,grid-z) ∈ particle_at
                sethue(Colors.JULIA_LOGO_COLORS.blue)
                setline(4)
                setdash("dashed")
                if i%2 != 0
                    parrow = p + Point(0,-.8/grid)
                    line(p,p+Point(0,-1/grid),:stroke)
                    arrowhead(parrow,headlength=0.1, shaftangle=pi/2, headangle=pi/8)
                    parrow = p + Point(.5/grid,0)
                    line(p,p+Point(1/grid,0),:stroke)
                    arrowhead(parrow,headlength=0.1, shaftangle=0, headangle=pi/12)
                    particles[(i+=1)] = p+Point(0,-1/grid)+x*Point(ratio/grid, -fac/grid)
                else
                    parrow = p + Point(0,.8/grid)
                    line(p,p+Point(0,1/grid),:stroke)
                    arrowhead(parrow,headlength=0.1, shaftangle=-pi/2, headangle=pi/8)
                    parrow = p + Point(-.5/grid,0)
                    line(p,p+Point(-1/grid,0),:stroke)
                    arrowhead(parrow,headlength=0.1, shaftangle=pi, headangle=pi/12)
                    particles[(i+=1)] = p+Point(0,1/grid)+x*Point(ratio/grid, -fac/grid)
                end
                setdash("solid")
                setline(1)
                setgray(0.7)
                particle(p,size=0.075, opacity=particle_opacity)
            end
        end
    end

    sethue(Colors.JULIA_LOGO_COLORS.blue)
    setline(4)
    setdash("dashed")
    parrow = particles[2] + 0.8*Point(ratio/grid, -fac/grid)
    line(particles[2],particles[2]+Point(ratio/grid, -fac/grid),:stroke)
    arrowhead(parrow,headlength=0.1, shaftangle=pi-deg, headangle=pi/10)
    parrow = particles[1] + 0.8*Point(-ratio/grid, fac/grid)
    line(particles[1],particles[1]+Point(-ratio/grid, fac/grid),:stroke)
    arrowhead(parrow,headlength=0.1, shaftangle=-deg, headangle=pi/10)
    setdash("solid")
    setline(1)
    sethue("black")

    # Reset matrix
    setmatrix(transmat)
end
