local function add_sti_to_bump(map, world, x, y)
    local collidables = {}

    for _, tileset in ipairs(map.tilesets) do
        for _, tile in ipairs(tileset.tiles) do
            local gid = tileset.firstgid + tile.id

            if map.tileInstances[gid] then
                for _, instance in ipairs(map.tileInstances[gid]) do
                    -- Every object in every instance of a tile
                    if tile.objectGroup then
                        for _, object in ipairs(tile.objectGroup.objects) do
                            if object.properties.collidable == true then
                                local t = {
                                    name       = object.name,
                                    type       = object.type,
                                    x          = instance.x + x + object.x,
                                    y          = instance.y + y + object.y,
                                    width      = object.width,
                                    height     = object.height,
                                    layer      = instance.layer,
                                    properties = object.properties

                                }

                                world:add(t, t.x, t.y, t.width, t.height)
                                table.insert(collidables, t)
                            end
                        end
                    end

                    -- Every instance of a tile
                    if tile.properties and tile.properties.collidable == true then
                        local t = {
                            x          = instance.x + x,
                            y          = instance.y + y,
                            width      = map.tilewidth,
                            height     = map.tileheight,
                            layer      = instance.layer,
                            properties = tile.properties
                        }

                        world:add(t, t.x, t.y, t.width, t.height)
                        table.insert(collidables, t)
                    end
                end
            end
        end
    end

    for _, layer in ipairs(map.layers) do
        -- Entire layer
        if layer.properties.collidable == true then
            if layer.type == "tilelayer" then
                for y, tiles in ipairs(layer.data) do
                    for x, tile in pairs(tiles) do

                        if tile.objectGroup then
                            for _, object in ipairs(tile.objectGroup.objects) do
                                if object.properties.collidable == true then
                                    local t = {
                                        name       = object.name,
                                        type       = object.type,
                                        x          = ((x-1) * map.tilewidth  + tile.offset.x + x) + object.x,
                                        y          = ((y-1) * map.tileheight + tile.offset.y + y) + object.y,
                                        width      = object.width,
                                        height     = object.height,
                                        layer      = layer,
                                        properties = object.properties
                                    }

                                    world:add(t, t.x, t.y, t.width, t.height)
                                    table.insert(collidables, t)
                                end
                            end
                        end


                        local t = {
                            x          = (x-1) * map.tilewidth  + tile.offset.x + x,
                            y          = (y-1) * map.tileheight + tile.offset.y + y,
                            width      = tile.width,
                            height     = tile.height,
                            layer      = layer,
                            properties = tile.properties
                        }

                        world:add(t, t.x, t.y, t.width, t.height)
                        table.insert(collidables, t)
                    end
                end
            elseif layer.type == "imagelayer" then
                world:add(layer, layer.x, layer.y, layer.width, layer.height)
                table.insert(collidables, layer)
            end
      end

        -- individual collidable objects in a layer that is not "collidable"
        -- or whole collidable objects layer
      if layer.type == "objectgroup" then
            for _, obj in ipairs(layer.objects) do
                if layer.properties.collidable == true or obj.properties.collidable == true then
                    if obj.shape == "rectangle" then
                        local t = {
                            name       = obj.name,
                            type       = obj.type,
                            x          = obj.x + map.offsetx,
                            y          = obj.y + map.offsety,
                            width      = obj.width,
                            height     = obj.height,
                            layer      = layer,
                            properties = obj.properties
                        }

                        if obj.gid then
                            t.y = t.y - obj.height
                        end

                        world:add(t, t.x, t.y, t.width, t.height)
                        table.insert(collidables, t)
                    end -- TODO implement other object shapes?
                end
            end
        end

    end
    map.bump_collidables = collidables
end

local function remove_sti_map_from_bump(map, world)
    for _, c in ipairs(map.bump_collidables or {}) do
        world:remove(c)
    end
end

local function map_draw(self, tx, ty, sx, sy)
	local current_canvas = gfx.getCanvas()
	gfx.setCanvas(self.canvas)
	gfx.clear()

	-- Scale map to 1.0 to draw onto canvas, this fixes tearing issues
	-- Map is translated to correct position so the right section is drawn
	gfx.push()
	gfx.translate(math.floor(tx or 0), math.floor(ty or 0))

	for _, layer in ipairs(self.layers) do
		if layer.visible and layer.opacity > 0 then
			self:drawLayer(layer)
		end
	end

	gfx.pop()

	-- Draw canvas at 0,0; this fixes scissoring issues
	-- Map is scaled to correct scale so the right section is shown
	gfx.push()
	gfx.origin()
	--gfx..scale(sx or 1, sy or sx or 1)

	gfx.setCanvas(current_canvas)
	gfx.draw(self.canvas)

	gfx.pop()
end

local rng

local function get_map(x, y)
    --return "art/maps/build/funnel.lua"
    local maps = {
        "thorn_zigzag.lua",
        "funnel.lua",
        "dual_funnel.lua",
        "swirl.lua",
        "block.lua",
        "double_zigzag.lua",
        --"blank.lua"
    }

    if y < 500 then
        return "art/maps/build/blank.lua"
    else
        rng = rng or love.math.newRandomGenerator(love.timer.getTime())
        --local rng = love.math.newRandomGenerator( y )
        local index = rng:random(#maps)
        --index = 5
        local path = maps[index]
        return string.format("art/maps/build/%s", path)
    end
end



local function get_size(sti_map)
    local tw, th = sti_map.tilewidth, sti_map.tileheight
    local w, h = 0, 0

    for _, layer in ipairs(sti_map.layers) do
        if layer.type == "tilelayer" then
            w = math.max(w, layer.width * tw)
            h = math.max(h, layer.height * th)
        end
    end

    return w, h
end

local function get_box(map)
    local sti_map = map[components.sti_map]
    local pos = map[components.position]
    return spatial(pos.x, pos.y, get_size(sti_map))
end

local function is_inside(map, entity)
    local box = get_box(map)
    local pos = entity[components.position]
    return box.y <= pos.y and pos.y < box.y + box.h
end

local system = ecs.system(components.sti_map, components.position, components.bump_world)

function system:on_entity_added(map)
    local sti_map = map[components.sti_map]
    local pos = map[components.position]
    local bump_world = map[components.bump_world]
    add_sti_to_bump(sti_map, bump_world, pos:unpack())
end

function system:on_entity_removed(map)
    remove_sti_map_from_bump(map[components.sti_map], map[components.bump_world])
end

function system:track(rabbit)
    self.pool:sort(
        function(m1, m2)
            return m1[components.position].y < m2[components.position].y
        end
    )

    -- First find index of box inside

    local inside_index
    for index, map in ipairs(self.pool) do
        if is_inside(map, rabbit) then inside_index = index end
    end

    local bump_world = rabbit[components.bump_world]

    if not inside_index then
        while #self.pool > 0 do
            self.pool[1]:destroy()
        end

        local x, y = rabbit[components.position]:unpack()
        local current = ecs.entity(self.world)
            :add(components.sti_map, get_map(x, y))
            :add(components.position, 0, y)
            :add(components.bump_world, bump_world)
        inside_index = 1
    end

    local map = self.pool[inside_index]

    if inside_index == 1 then
        local box = get_box(map)
        local current = ecs.entity(self.world)
            :add(components.sti_map, get_map(box.x, box.y - box.h))
            :add(components.position, box.x, box.y - box.h)
            :add(components.bump_world, bump_world)
    elseif inside_index == #self.pool then
        local box = get_box(map)
        local current = ecs.entity(self.world)
            :add(components.sti_map, get_map(box.x, box.y + box.h))
            :add(components.position, box.x, box.y + box.h)
            :add(components.bump_world, bump_world)
    end

    local size = #self.pool
    for i = inside_index + 2, size do
        self.pool[#self.pool]:destroy()
    end
    for i = 1, inside_index - 2 do
        self.pool[1]:destroy()
    end
end

function system:draw()
    gfx.setColor(1, 1, 1)
    for _, map in ipairs(self.pool) do
        map_draw(map[components.sti_map], map[components.position]:unpack())
    end
end

return system
