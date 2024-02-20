require "math"

require("Bullet")
require("Player")
require("LostMekkaBoss")

function love.draw()
    -- bg tiles
    love.graphics.setColor(1,1,1)
    for i=math.floor((scroll_x)/128),math.ceil((scroll_x+800)/128) do
        for j=math.floor((scroll_y)/128),math.ceil((scroll_y+600)/128) do
            drawimage("sprites/floor-tile.png",i*128-scroll_x,j*128-scroll_y)
        end
    end
    -- love.graphics.print(scroll_x, 400-scroll_x, 300-scroll_y)
    for _, obj in pairs(objects) do
        if obj.alive then
            love.graphics.setColor(obj.debugColor)
            local x, y = obj.collider:getPosition()
            local r = obj.radius or 12
            love.graphics.circle("fill", x - scroll_x, y - scroll_y, r, r)
        end
    end
end

function love.load()
    wf = require "libs/windfield"
    world = wf.newWorld()
    world:addCollisionClass("player")
    world:addCollisionClass("enemy")
    world:addCollisionClass("playerBullet", { ignores = { "playerBullet", "player" } })
    world:addCollisionClass("enemyBullet", { ignores = { "playerBullet", "enemyBullet", "enemy" } })
    setup()
end

function love.update()
    if love.keyboard.isScancodeDown("escape") then
        love.event.quit()
    end

    local dt = love.timer.getDelta()
    for _, obj in pairs(objects) do
        if obj.alive and obj.update then obj:update(dt) end
    end

    world:update(dt)
    scroll_x = player.collider:getX() - 400
    scroll_y = player.collider:getY() - 300
end

function setup()
    images = {}
    playerMovementForce = 1500
    playerMovementDamping = 5
    objects = {}
    scroll_x = 0
    scroll_y = 0
    player = Player:new(0, 0)
    createEnemy(40,0)
    createEnemy(80,0)
    createEnemy(120,0)
    boss = LostMekkaBoss:new(0, 80)
end

function createEnemy(x, y)
    local self = {}
    self.type = "enemy"
    self.alive = true
    self.debugColor = { 1, 0, 0 }
    self.collider = world:newCircleCollider(x, y, 12)
    self.collider:setCollisionClass("enemy")
    self.collider:setLinearDamping(playerMovementDamping)
    self.collider:setObject(self)
    table.insert(objects, self)
    return self
end

function newobj(type,x,y)
    local newobj = {}
    newobj.type = type
    newobj.x = x
    newobj.y = y
    newobj.alive = true
    newobj.debugColor = type == "player" and { 1, 1, 1 } or { 1, 0, 0 }
    table.insert(objects,newobj)
end

function drawimage(path, x, y, sx_, sy_)
    local sx = sx_ or 1
    local sy = sy_ or sx
    image = loadimage(path)
    love.graphics.draw(image, x, y, 0, sx, sy)
end

function loadimage(path)
    if images[path] == nil then
        image = love.graphics.newImage(path)
        images[path] = image
    else
        image = images[path]
    end
    return image
end
