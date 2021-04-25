local function death_timer(...)
    return components.timer.create(...)
end

local death_system = ecs.system(death_timer, components.position)

function death_system:on_collision(collision_info)
    if type(collision_info.item) ~= "table" or type(collision_info.other) ~= "table" then
        return
    end

    if collision_info.item[components.controllable] then
        collision_info.item:add(death_timer, 0.3, 0)
        self.world:event("die", collision_info.item)

        if collision_info.item[components.sprite] then
            collision_info.item[components.sprite]:update(components.visible, false)
        end
    end


end

function death_system:update(dt)
    for _, entity in ipairs(self.pool) do
        if entity[death_timer]:update(dt) then
            entity[death_timer]:reset()
            local dir = love.math.random() < 0.5 and 1 or -1
            self.world:event("explode", entity, dir)
        end
    end
end

return death_system
