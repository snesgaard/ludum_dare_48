local system = ecs.system(
    components.velocity, components.controllable, components.sprite,
    components.dynamite_charges
)

function system:keypressed(key)
    local function do_control(key, entity)
        if not entity[components.controllable] then return end
        local v = entity[components.velocity]
        local w = entity[components.wild] or components.wild()
        local s = w.scale
        if key == "left" then
            entity[components.sprite]:update(components.mirror, true)
            entity:update(components.velocity, v.x - 150 * s, 0)
            self.world:event("explode", entity, -1)
        elseif key == "right" then
            entity[components.sprite]:update(components.mirror, false)
            entity:update(components.velocity, v.x + 150 * s, 0)
            self.world:event("explode", entity, 1)
        elseif key == "up" then
            entity[components.sprite]:update(components.mirror, false)
            entity:update(components.velocity, v.x, -100 * s)
            self.world:event("explode", entity, v.x >= 0 and 1 or -1)
        elseif key == "down" then
            entity[components.sprite]:update(components.mirror, false)
            entity:update(components.velocity, v.x, v.y + 100 * s)
            self.world:event("explode", entity, v.x > 0 and 1 or -1)
        end
    end

    for _, entity in ipairs(self.pool) do
        do_control(key, entity)
    end
end

function system:die(entity)
    if not self.pool[entity] then return end

    entity:update(components.controllable, false)
end

function system:gui()
end

return system
