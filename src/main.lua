function love.draw()
    -- love.graphics.print(scroll_x, 400-scroll_x, 300-scroll_y)
    for o,obj in pairs(objects) do
        love.graphics.setColor(obj.debugColor)
        love.graphics.rectangle("fill",obj.x-scroll_x,obj.y-scroll_y,24,24)
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
    local player = objects[1]
    dt = love.timer.getDelta()
    movePlayer()
    if love.keyboard.isScancodeDown("escape") then
        love.event.quit()
    end
    scroll_x = player.x - 400
    scroll_y = player.y - 300
    world:update(dt)
end

function movePlayer()
    player.x, player.y = player.collider:getPosition() -- we should prly use the collider coords directly

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
    newobj("test",40,0)
end

function createPlayer(x, y)
    local self = {}
    self.type = "player"
    self.x = x
    self.y = y
    self.alive = true
    self.debugColor = { 1, 1, 1 }
    self.collider = world:newCircleCollider(x, y, 12)
    self.collider:setCollisionClass("player")
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
