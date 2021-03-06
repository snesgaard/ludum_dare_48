systems.motion = ecs.system(
    components.position, components.velocity, components.gravity
)

function systems.motion:update(dt)
    for _, entity in ipairs(self.pool) do
        local p = entity[components.position]
        local v = entity[components.velocity]
        local g = entity[components.gravity]

        v = v + g * dt
        p = p + v * dt

        v.y = math.min(v.y, 250)

        if math.abs(v.x) > 50 then
            v.x = v.x * 0.95
        end

        entity[components.velocity] = v
        entity[components.position] = p
    end
end

function systems.motion:die(entity)
    if not self.pool[entity] then return end
    entity:update(components.velocity, 0, 0)
    entity:update(components.gravity, 0, 0)
end

systems.map = require(... .. ".map")

systems.bump_clean = ecs.system(components.bump_world)

function systems.bump_clean:update()
    local cleaned_world = {}
    local cells = 0
    for _, entity in ipairs(self.pool) do
        local world = entity[components.bump_world]
        if not cleaned_world[world] then
            cleaned_world[world] = true
            for cy, row in pairs(world.rows) do
                for cx, cell in pairs(row) do
                    if cell.itemCount == 0 then
                        row[cx] = nil
                    end
                    cells = cells + 1
                end
            end
        end
    end
end

systems.controls = require(... .. ".control")
systems.explosion = require(... .. ".explosion")

systems.evil_monitor = ecs.system(components.evil_timer)

function systems.evil_monitor:update(dt)
    for _, entity in ipairs(self.pool) do
        if entity[components.evil_timer]:update(dt) then
            entity:update(
                components.evil_timer,
                math.max(1, entity[components.evil_timer].duration - 5)
            )
            self.world:event("evil_activate")
        end
    end
end

function systems.evil_monitor:keypressed(key)
    if key == "return" then
        for _, entity in ipairs(self.pool) do
            entity:update(
                components.evil_timer,
                math.max(1, entity[components.evil_timer].duration - 5)
            )
            self.world:event("evil_activate")
        end
    end
end

function systems.evil_monitor:gui()
    local atlas = get_atlas("art/characters")
    for _, entity in ipairs(self.pool) do
        --local w = entity[components.evil_timer]
        --gfx.setColor(1, 1, 1)
        --gfx.rectangle("fill", 50, 50, 20, 100)
        --gfx.setColor(0, 0, 0)
        --gfx.rectangle("fill", 50, 50, 20, 100 * w:time_left_normalized())
        gfx.push()
        gfx.translate(20, 20)
        gfx.scale(2, 2)
        gfx.setColor(1, 1, 1)
        atlas:get_frame("evil_meter/back"):draw(0, 0)
        local frame = atlas:get_frame("evil_meter/front")
        local slice = frame.slices.fill
        gfx.setColor(gfx.hex2color("7b0a0a"))
        local s = 1 - entity[components.evil_timer]:time_left_normalized()
        local x, y, w, h = slice:unpack()
        gfx.rectangle("fill", x, y + h * (1 - s), w, h * s)
        gfx.setColor(1, 1, 1)
        frame:draw(0, 0)
        gfx.pop()
    end
end


systems.evil = ecs.system(components.evil)

function systems.evil:update(dt)
    for _, entity in ipairs(self.pool) do
        if entity[components.evil].timer:update(dt) then
            entity[components.evil].active = false
        end
    end
end

function systems.evil:evil_activate()
    local index = love.math.random(#self.pool)
    local entity = self.pool[index]
    entity[components.evil].timer:reset()
    entity[components.evil].active = true
end

systems.death = require(... .. ".death")

systems.wild = ecs.system(components.wild)

function systems.wild:update(dt)
    for _, entity in ipairs(self.pool) do
        local w = entity[components.wild]
        if w.timer:update(dt) then
            w.timer:reset()
            w.scale = w.scale + 0.25
        end
    end
end

function systems.wild:gui()
    for _, entity in ipairs(self.pool) do
        local w = entity[components.wild]
        gfx.setColor(1, 1, 1)
        gfx.rectangle("fill", 50, 50, 20, 100)
        gfx.setColor(0, 0, 0)
        gfx.rectangle("fill", 50, 50, 20, 100 * w.timer:time_left_normalized())
    end
end
