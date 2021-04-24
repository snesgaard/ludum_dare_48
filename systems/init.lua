systems.motion = ecs.system(components.position, components.velocity, components.gravity)

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

systems.evil = ecs.system(components.evil)

function systems.evil:keypressed(key)
    if key == "return" then
        for _, entity in ipairs(self.pool) do
            entity[components.evil].active = true
            entity[components.evil].init_time = love.timer.getTime()
        end
    end
end
