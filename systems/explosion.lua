local system = ecs.system(components.explosion, components.position)

function is_entity_done(entity)
    local explosion = entity[components.explosion]
    return explosion[components.explosion_flash].alpha <= 0
        and explosion[components.explosion_cloud]:getCount() == 0
        and explosion[components.sparks]:getCount() == 0
        and explosion[components.fire]:getCount() == 0
end

function system:explode(entity, direction)
    ecs.entity(self.world)
        :add(
            components.explosion,
            {
                [components.sparks]={direction},
                [components.fire]={direction}
            }
        )
        :add(components.position, entity[components.position]:unpack())
end

function system:update(dt)
    local function do_update(entity)
        local explosion = entity[components.explosion]
        local flash = explosion[components.explosion_flash]
        flash.timer:update(dt)
        flash.alpha = flash.timer:time_left_normalized()
        explosion[components.explosion_cloud]:update(dt)
        explosion[components.sparks]:update(dt)
        explosion[components.fire]:update(dt)
    end

    for _, entity in ipairs(self.pool) do
        do_update(entity)
    end

    local size = #self.pool

    for i = size, 1, -1 do
        local entity = self.pool[i]
        if is_entity_done(entity) then entity:destroy() end
    end
end

function system:draw()
    local function do_draw(entity)
        local pos = entity[components.position]
        local explosion = entity[components.explosion]
        local flash = explosion[components.explosion_flash]
        local smoke = explosion[components.explosion_cloud]
        local spark = explosion[components.sparks]
        local fire = explosion[components.fire]
        gfx.setColor(1, 1, 1)
        gfx.draw(smoke, pos.x, pos.y)
        gfx.setColor(1, 1, 1)
        gfx.draw(fire, pos.x, pos.y)
        gfx.setColor(1, 1, 1)
        gfx.draw(spark, pos.x, pos.y)
        gfx.setColor(1, 1, 1, flash.alpha)
        gfx.circle("fill", pos.x, pos.y, 35)
    end

    for _, entity in ipairs(self.pool) do
        do_draw(entity)
    end
end

return system
