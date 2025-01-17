function render(mdp::SimpleGridWorld, step::Union{NamedTuple,Dict}=(;);
                color = s->reward(mdp, s),
                policy::Union{Policy,Nothing} = nothing,
                colormin::Float64 = -10.0, colormax::Float64 = 10.0
               )

    color = tofunc(mdp, color)

    nx, ny = mdp.size
    cells = []
    for x in 1:nx, y in 1:ny
        cell = cell_ctx((x,y), mdp.size)
        if policy !== nothing
            a = action(policy, GWPos(x,y))
            txt = compose(context(), text(0.5, 0.5, aarrow[a], hcenter, vcenter), stroke("black"))
            compose!(cell, txt)
        end
        clr = tocolor(color(GWPos(x,y)), colormin, colormax)
        compose!(cell, rectangle(), fill(clr), stroke("gray"))
        push!(cells, cell)
    end
    grid = compose(context(), linewidth(0.5mm), cells...)
    outline = compose(context(), linewidth(1mm), rectangle(), stroke("gray"))

    if haskey(step, :s)
        agent_ctx = cell_ctx(step[:s], mdp.size)
        agent = compose(agent_ctx, circle(0.5, 0.5, 0.4), fill("orange"))
    else
        agent = nothing
    end

    sz = min(w,h)
    return compose(context((w-sz)/2, (h-sz)/2, sz, sz), agent, grid, outline)
end

function cell_ctx(xy, size)
    nx, ny = size
    x, y = xy
    return context((x-1)/nx, (ny-y)/ny, 1/nx, 1/ny)
end

tocolor(x, colormin, colormax) = x
function tocolor(r::Float64, colormin::Float64, colormax::Float64)
    frac = (r-colormin)/(colormax-colormin)
    return get(ColorSchemes.redgreensplit, frac)
end

tofunc(m::SimpleGridWorld, f) = f
tofunc(m::SimpleGridWorld, mat::AbstractMatrix) = s->mat[s...]
tofunc(m::SimpleGridWorld, v::AbstractVector) = s->v[stateindex(m, s)]

const aarrow = Dict(:up=>'↑', :left=>'←', :down=>'↓', :right=>'→')
