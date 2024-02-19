function love.draw()
    -- love.graphics.print(scroll_x, 400-scroll_x, 300-scroll_y)
    for o,obj in pairs(objects) do
        love.graphics.setColor(obj.debugColor)
        local x, y = obj.collider:getPosition()
        love.graphics.rectangle("fill",x-scroll_x,y-scroll_y,24,24)
    end
end

function love.load()
    wf = require "libs/windfield"
    world = wf.newWorld()
    world:addCollisionClass("player")
    world:addCollisionClass("enemy")
    world:addCollisionClass("bullet", { ignores = { "bullet" } })
    setup()
end

function love.update()
    if love.keyboard.isScancodeDown("escape") then
        love.event.quit()
    end

    dt = love.timer.getDelta()
    movePlayer()
    scroll_x = player.collider:getX() - 400
    scroll_y = player.collider:getY() - 300
    world:update(dt)
end

function movePlayer()
    local playerMoveX, playerMoveY = 0, 0
    if love.keyboard.isScancodeDown("up","w") then
        playerMoveY = playerMoveY - 1
    end
    if love.keyboard.isScancodeDown("down","s") then
        playerMoveY = playerMoveY + 1
    end
    if love.keyboard.isScancodeDown("left","a") then
        playerMoveX = playerMoveX - 1
    end
    if love.keyboard.isScancodeDown("right","d") then
        playerMoveX = playerMoveX + 1
    end
    local d = math.sqrt(playerMoveX ^ 2 + playerMoveY ^ 2)
    if (d > 0) then
        player.collider:applyForce(playerMoveX / d * playerMovementForce, playerMoveY / d * playerMovementForce)
    end
end

function setup()
    playerMovementForce = 1500
    playerMovementDamping = 5
    objects = {}
    scroll_x = 0
    scroll_y = 0
    player = createPlayer(0, 0) -- always make sure player is at position 1
    createEnemy(40,0)
    createEnemy(80,0)
    createEnemy(120,0)
end

function createPlayer(x, y)
    local self = {}
    self.type = "player"
    self.alive = true
    self.debugColor = { 0, 0.7, 0 }
    self.collider = world:newCircleCollider(x, y, 12)
    self.collider:setCollisionClass("player")
    self.collider:setLinearDamping(playerMovementDamping)
    self.collider:setObject(self)
    table.insert(objects, self)
    return self
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
