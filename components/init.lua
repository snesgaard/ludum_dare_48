function components.sti_map(map_path)
    return sti(map_path)
end

function components.controllable(enabled)
    if enabled == nil then return true end
    return enabled
end

local smoke_circle_image = gfx.prerender(32, 32, function(w, h)
    gfx.setColor(1, 1, 1)
    gfx.ellipse("fill", w * 0.5, h * 0.5, w * 0.25, h * 0.25)
end)

function components.explosion_cloud()
    return components.particles{
        image=smoke_circle_image,
        buffer=40,
        rate=0,
        emit=40,
        lifetime={0.35, 0.75},
        color=List.concat(
            gfx.hex2color("6f3e23cf"),
            gfx.hex2color("6d758d00")
        ),
        size={1, 3},
        speed={50, 600},
        acceleration={0, -600},
        damp=5,
        area={"ellipse", 20, 20, 0, true}
    }
end

local spark_image = gfx.prerender(5, 1, function(w, h)
    gfx.setColor(1, 1, 1)
    gfx.ellipse("fill", w * 0.5, h * 0.5, w * 0.5, h * 0.5)
end)

function components.sparks(dir)
    dir = dir or 1
    return components.particles{
        image=spark_image,
        buffer=20,
        rate=0,
        emit=10,
        lifetime={0.75, 1.2},
        color={1, 1, 1, 1},
        size={1},
        speed={200, 500},
        relative_rotation=true,
        acceleration={0, 500},
        damp=1,
        dir=-math.pi* (0.5 + dir * 0.25),
        spread=math.sqrt(2)
    }
end

local fire_circle_image = gfx.prerender(16, 16, function(w, h)
    gfx.setColor(1, 1, 1)
    gfx.ellipse("fill", w * 0.5, h * 0.5, w * 0.25, h * 0.25)
end)

function components.fire(dir)
    dir = dir or 1
    return particles{
        image=fire_circle_image,
        buffer=30,
        rate=0,
        emit=30,
        lifetime={0.35, 0.75},
        color=List.concat(
            gfx.hex2color("ffd541af"),
            gfx.hex2color("f9a31b8f"),
            gfx.hex2color("fa6a0a0f"),
            gfx.hex2color("df3e2300")
        ),
        size={1, 6},
        spread=3,
        speed={200, 1000},
        acceleration={0, -600},
        dir=-math.pi* (0.5 + dir * 0.25),
        damp=8,
        --area={"ellipse", 20, 20, 0, true}
    }
end

function components.explosion_flash()
    return {
        timer = components.timer.create(0.1),
        alpha = 1
    }
end


components.explosion = ecs.assemblage(
    components.explosion_flash, components.explosion_cloud, components.sparks,
    components.fire
)
