require "nodeworks"
require "components"
require "systems"
camera = require "camera"


function love.load()
    world = ecs.world(
        --systems.wild,
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
        systems.evil_monitor,
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
        :add(components.body, -7, -10, 14, 8)
        :add(components.controllable, true)
        :add(components.wild)

    rotate_evil = ecs.entity(world)
        :add(components.evil, 5)
    flip_evil = ecs.entity(world)
        :add(components.evil, 5)
    box_evil = ecs.entity(world)
        :add(components.evil, 5)
    --systems.collision.show()

    evil_timer = ecs.entity(world)
        :add(components.evil_timer, 30)

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

function text_box(text, x, y, w, h, align)
    local f = font(16)
    local lh = f:getHeight()
    side = 5

    local colors = {
        text = gfx.hex2color("453e68"),
        bg = gfx.hex2color("f2f7f8"),
        side = gfx.hex2color("bfdfe8")
    }
    gfx.setFont(f)
    gfx.setColor(colors.side)
    --gfx.rectangle("fill", x, y, w, h + side, 2)
    gfx.setColor(colors.bg)
    gfx.rectangle("fill", x, y, w, h, 2)
    gfx.setColor(colors.text)

    local margin = 2
    gfx.printf(
        text, x + margin, y + h * 0.5 - lh * 0.25, (w - margin * 2) * 2,
        align or "center", 0, 0.5, 0.5
    )
end

function draw_gui(pos)
    gfx.setColor(1, 1, 1)
    gfx.scale(2, 2)
    gfx.translate(0, 310)
    atlas:get_frame("arrow_keys/up"):draw(20 + 18, 2)
    atlas:get_frame("arrow_keys/left"):draw(20, 20)
    atlas:get_frame("arrow_keys/down"):draw(20 + 18, 20)
    atlas:get_frame("arrow_keys/right"):draw(20 + 36, 20)
    atlas:get_frame("arrow_keys/r"):draw(20 + 18, 38)
    atlas:get_frame("return_key"):draw(20 + 10, 55)

    local w = 100
    local x = 75
    text_box("Explode", x, 2, w, 28 + 5)
    text_box("Restart", x, 38, w, 11 + 5)
    text_box("Don't press this!!", x, 56, w, 24 + 5)

    text_box("Depth", x + 215, 56, 32, 20)
    text_box(string.format("%im", pos.y * 0.1), x + 250, 56, 48, 20, "right")

    --gfx.setColor(1, 1, 1)
    --atlas:get_frame("evil_meter"):draw(0, 0, 0, 2)
end

function love.draw()
    --gfx.scale(2, 2)
    --map:draw(0, 0, 2, 2)
    local w, h = gfx.getWidth(), gfx.getHeight()
    local dx, dy = -w * 0.5, -h * 0.5

    if rotate_evil[components.evil].active then
        local t = rotate_evil[components.evil].init_time
        gfx.translate(-dx, -dy)
        local angle = math.pi * 2  * rotate_evil[components.evil].timer:time_left_normalized()
        gfx.rotate(angle)
        gfx.translate(dx, dy)
    end

    if flip_evil[components.evil].active then
        gfx.translate(-dx, -dy)
        gfx.scale(1, -1)
        gfx.translate(dx, dy)
    end

    camera.center_on_entity(rabbit, 2)

    --map_draw(map, 0, 0)
    --frame:draw("body", 200, 100)
    world("draw")

    if box_evil[components.evil].active then
        local pos = rabbit[components.position]
        gfx.setColor(0.5, 0.5, 0.5)
        local w, h = 100, 50
        gfx.rectangle("fill", pos.x - w * 0.5, pos.y - h * 0.5, w, h)
    end

    gfx.origin()

    world("gui")
    gfx.setColor(1, 0, 0)
    --gfx.printf(string.format("%i", pos.y * 0.1), gfx.getWidth() - 100, 50, 100)

    draw_gui(rabbit[components.position])
    if not rabbit[components.controllable] then

    end

end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        love.event.quit()
    elseif key == "r" then
        love.load()
    else
        world("keypressed", key)
    end
end
