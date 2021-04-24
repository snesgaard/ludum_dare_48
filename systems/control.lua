local system = ecs.system(components.velocity, components.controllable)

function system:keypressed(key)
    local function do_control(key, entity)
        if not entity[components.controllable] then return end
        if key == "left" then
            entity:update(components.velocity, -200, 0)
        elseif key == "right" then
            entity:update(components.velocity, 200, 0)
        end
    end

    for _, entity in ipairs(self.pool) do
        do_control(key, entity)
    end
end

return system