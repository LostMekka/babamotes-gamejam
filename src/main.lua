require "math"

require("_deploy")
require("images")
require("worlds")
require("viewport")

function love.load()
    love.window.setMode(1024, 768)
    createHubWorld()
end

local function drawBar(x, y, w, h, amount, color)
    love.graphics.setColor(0,0,0)
    love.graphics.rectangle("line", x, y, w, h)
    love.graphics.setColor(color)
    love.graphics.rectangle("fill", x + 2, y + 2, (w - 4) * amount, h - 4)
end

function love.draw()
    -- WORLD
    worldViewport:use(function()
        -- bg tiles
        love.graphics.setColor(1, 1, 1)
        local vpx, vpy, vpw, vph = worldViewport:getWorldViewportRect()
        for i = math.floor(vpx / 128), math.ceil((vpx + vpw) / 128) do
            for j = math.floor(vpy / 128), math.ceil((vpy + vph) / 128) do
                drawimage("sprites/floor-tile.png", i * 128, j * 128)
            end
        end
        -- game entities
        for _, obj in pairs(objects) do
            if obj.alive then
                love.graphics.setColor(obj.debugColor)
                local x, y = obj.collider:getPosition()
                local r = obj.radius or 12
                love.graphics.circle("fill", x, y, r)
                if obj.draw then obj:draw() end
            end
        end
    end)

    -- GUI
    screenViewport:use(function()
        drawBar(15, love.graphics.getPixelHeight() - 25, 200, 15, player.hp / player.maxHp, { 1, 0, 0 })
        if boss and boss.alive and boss.hp then
            local w = love.graphics.getPixelWidth()
            local wr = 0.8
            drawBar((1 - wr) * w / 2, 25, w * wr, 20, boss.hp / boss.maxHp, { 1, 0, 0 })
        end
    end)
end

breakUpdateLoop = false
function love.update()
    if not isLiveBuild and love.keyboard.isScancodeDown("escape") then
        love.event.quit()
    end

    local dt = love.timer.getDelta()
    breakUpdateLoop = false
    for key, obj in pairs(objects) do
        if obj.alive and obj.update then
            obj:update(dt)
        else
            objects[key] = nil
        end
        if breakUpdateLoop then break end
    end

    world:update(dt)
    if customWorldUpdate then
        customWorldUpdate(dt)
    elseif player.alive then
        worldViewport:setTargetPosition(player.collider:getPosition())
    end
    worldViewport:update(dt)
    screenViewport:update(dt)
end
