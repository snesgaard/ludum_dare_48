require "nodeworks"
require "components"
require "systems"
camera = require "camera"


function love.load()
    world = ecs.world(
        systems.controls,
        systems.map,
        systems.animation,
        --root_motion_system,
        systems.particles,
        systems.explosion,
        systems.hitbox_sprite,
        --systems.motion,
        systems.motion,
        systems.sprite,
        systems.collision,
        systems.hitbox,
        systems.bump_clean,
        systems.evil,
        systems.death
    )

    map = sti("art/maps/build/blank.lua")
    atlas = get_atlas("art/characters")
    frame = atlas:get_frame("rabbit")
    bump_world = bump.newWorld()

    rabbit = ecs.entity(world)
        :add(components.position, 200, 0)
        :add(components.velocity, 0, 0)
        :add(components.gravity, 0, 200)
        :add(components.sprite)
        :add(components.animation_map, atlas, {idle="rabbit"})
        :add(components.animation_state)
        :add(components.bump_world, bump_world)
        :add(components.body, -8, -10, 16, 10)
        :add(components.controllable, true)

    rotate_evil = ecs.entity(world)
        :add(components.evil)
    --systems.collision.show()

        --[[
    map = ecs.entity(world)
        :add(components.sti_map, "art/maps/build/blank.lua")
        :add(components.position)

    map2 = ecs.entity(world)
        :add(components.sti_map, "art/maps/build/blank.lua")
        :add(components.position, 0, 100)
        ]]--

    systems.animation.play(rabbit, "idle")
end

function love.update(dt)
    world("track", rabbit)
    world("update", dt)
end

function love.draw()
    --gfx.scale(2, 2)
    --map:draw(0, 0, 2, 2)
    if rotate_evil[components.evil].active then
        local t = rotate_evil[components.evil].init_time
        local w, h = gfx.getWidth(), gfx.getHeight()
        local dx, dy = -w * 0.5, -h * 0.5
        gfx.translate(-dx, -dy)
        gfx.rotate(love.timer.getTime() - t)
        gfx.translate(dx, dy)
    end

    camera.center_on_entity(rabbit, 2)
    --map_draw(map, 0, 0)
    --frame:draw("body", 200, 100)
    world("draw")
    gfx.origin()

    if not rabbit[components.controllable] then
    end
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        love.event.quit()
    else
        world("keypressed", key)
    end
end
