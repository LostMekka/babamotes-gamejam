require("TriggerArea")
require("sounds")

Portal = {}
setmetatable(Portal, TriggerArea)
Portal.__index = Portal

local sounds = {
    teleport = PolyVoiceSound:new("sfx/teleport1.wav"),
}

function Portal:new(x, y, radius, onEnter, text)
    local object = TriggerArea:new(
            x, y, radius, nil,
            { player },
            nil,
            function(...)
                sounds.teleport:play()
                onEnter(...)
            end
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
        local w = love.graphics.getFont():getWidth(self.text)
        love.graphics.print(self.text, x - w / 2, y + 5)
    end
end
