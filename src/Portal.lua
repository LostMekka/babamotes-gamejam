require("TriggerArea")

Portal = {}
setmetatable(Portal, TriggerArea)
Portal.__index = Portal

function Portal:new(x, y, radius, onEnter)
    local object = TriggerArea:new(
            x, y, radius, nil,
            { player },
            nil,
            onEnter
    )
    setmetatable(object, self)

    object.type = "portal"
    object.debugColor = { 0, 1, 0.5, 0.5 }
    -- dont add object to global objects list, since this is already done by TriggerArea:new
    return object
end
