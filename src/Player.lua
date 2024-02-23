require("sounds")
require("timers")
require("Bullet")

Player = {}

playerMovementForce = 1500
playerMovementDamping = 5
playerShootCooldown = 0.1
playerShootVelocity = 400
playerShootDamage = 1

local sounds = {
    hit = PolyVoiceSound:new("sfx/playerhit.wav"),
    shoot = PolyVoiceSound:new("sfx/shot1.wav", 0.6),
    death = PolyVoiceSound:new("sfx/gameover.wav"),
}

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

    addHpComponentToEntity(object, 100,
            function(self, amount)
                if self.hp - amount > 0 then sounds.hit:play() end
            end,
            function()
                sounds.death:play()
            end
    )
    object.timers = TimerArray:new()
    object.canShoot = true

    table.insert(objects, object)
    return object
end

function Player:update(dt)
    self.timers:update(dt)

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

    if self.canShoot and love.mouse.isDown(1) then
        self.canShoot = false
        self.timers:setTimer("shoot cooldown", playerShootCooldown, 1, function() self.canShoot = true end)
        local mx, my = worldViewport:screenToWorld(love.mouse.getPosition())
        Bullet:new(
                self,
                { x = mx, y = my },
                playerShootVelocity,
                3,
                playerShootDamage,
                5,
                0,
                nil,
                nil,
                nil
        )
        sounds.shoot:play()
    end
end
