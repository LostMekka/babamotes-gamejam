require("Bullet")

Player = {}

function Player:new(startX, startY)
    local object = {}
    setmetatable(object, self)
    self.__index = self

    object.type = "player"
    object.alive = true
    object.belongsToPlayer = true
    object.debugColor = { 0, 0.7, 0 }
    object.radius = 12
    object.collider = world:newCircleCollider(startX, startY, object.radius)
    object.collider:setCollisionClass("player")
    object.collider:setLinearDamping(playerMovementDamping)
    object.collider:setObject(object)

    object.hp = 100

    table.insert(objects, object)
    return object
end

function Player:update(dt)
    local moveX, moveY = 0, 0
    if love.keyboard.isScancodeDown("up","w") then
        moveY = moveY - 1
    end
    if love.keyboard.isScancodeDown("down","s") then
        moveY = moveY + 1
    end
    if love.keyboard.isScancodeDown("left","a") then
        moveX = moveX - 1
    end
    if love.keyboard.isScancodeDown("right","d") then
        moveX = moveX + 1
    end
    local d = math.sqrt(moveX ^ 2 + moveY ^ 2)
    if (d > 0) then
        self.collider:applyForce(moveX / d * playerMovementForce, moveY / d * playerMovementForce)
    end
end

function Player:damage(amount)
    self.hp = self.hp - amount
    -- TODO: check for player death
end
