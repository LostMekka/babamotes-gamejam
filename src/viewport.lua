require("images")

local Viewport = {
    x = 0,
    y = 0,
    scale = 1,
    targetX = 0,
    targetY = 0,
    movementEasingSpeed = 10,
    targetScale = 1,
    scaleEasingSpeed = 3,
}

function Viewport:new(x, y, scale)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    if x then o.x = x end
    if y then o.y = y end
    if scale then o.scale = scale end
    return o
end

screenViewport = Viewport:new()
screenViewport.fitScreen = true
worldViewport = Viewport:new()

function resetWorldViewport(x, y, scale)
    worldViewport = Viewport:new(x, y, scale)
end

function Viewport:setTargetPosition(x, y)
    self.targetX = x
    self.targetY = y
end

function Viewport:setTargetScale(scale)
    self.targetScale = scale
end

local function ease(current, target, easingSpeed, dt)
    return current + (target - current) * dt * easingSpeed
end

function Viewport:update(dt)
    self.x = ease(self.x, self.targetX, self.movementEasingSpeed, dt)
    self.y = ease(self.y, self.targetY, self.movementEasingSpeed, dt)
    self.scale = ease(self.scale, self.targetScale, self.scaleEasingSpeed, dt)
end

function Viewport:use(block)
    local sw = love.graphics.getPixelWidth()
    local sh = love.graphics.getPixelHeight()
    love.graphics.push()
    if self.fitScreen then

    else
        love.graphics.scale(self.scale)
        love.graphics.translate(
                sw / 2 / self.scale - self.x,
                sh / 2 / self.scale - self.y
        )
    end
    block()
    love.graphics.pop()
end

function Viewport:getWorldViewportRect()
    local sw = love.graphics.getPixelWidth()
    local sh = love.graphics.getPixelHeight()
    local x = self.x - sw / 2 / self.scale
    local y = self.y - sh / 2 / self.scale
    local w = sw / self.scale
    local h = sh / self.scale
    return x, y, w, h
end

function Viewport:screenToWorld(x, y)
    local sw = love.graphics.getPixelWidth()
    local sh = love.graphics.getPixelHeight()
    return (x - sw / 2) / self.scale + self.x, (y - sh / 2) / self.scale + self.y
end
