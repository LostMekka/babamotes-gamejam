require("TriggerArea")

Portal = {}
setmetatable(Portal, TriggerArea)
Portal.__index = Portal

function Portal:new(x, y, radius, onEnter, text)
    local object = TriggerArea:new(
            x, y, radius, nil,
            { player },
            nil,
            onEnter
    )
    setmetatable(object, self)

    object.type = "portal"
    object.debugColor = { 0, 1, 0.5, 0.5 }
    object.text = text
    -- dont add object to global objects list, since this is already done by TriggerArea:new
    return object
end

function Portal:draw()
    if self.text then
        local x, y = self.collider:getPosition()
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(self.text, x - scroll_x, y - scroll_y)
    end
end
