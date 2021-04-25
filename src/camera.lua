local camera = {}

function camera.center_on_entity(entity, sx, sy)
    local pos = entity[components.position]
    if not pos then return false end

    sx = sx or 2
    sy = sy or sx

    gfx.scale(sx, sy)
    gfx.translate(0, math.min(0, -pos.y + 75))

    return true
end

return camera
