function components.sti_map(map_path)
    return sti(map_path)
end

function components.controllable(enabled)
    if enabled == nil then return true end
    return enabled
end
