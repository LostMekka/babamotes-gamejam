require("sounds")
require("timers")
require("Bullet")

Player = {}

playerMovementForce = 1100
playerMovementDamping = 5
playerShootCooldown = 0.1
playerShootVelocity = 400
playerShootDamage = 1
playerEnergyRegen = 30
playerShootCost = 3.2
playerDashCost = 40
playerDashCooldown = 0.2
playerDashDuration = 0.22
playerDashImpulse = 1200

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

    addHpComponentToEntity(object, 100)
    object.maxEnergy = 100
    object.energy = object.maxEnergy
    object.timers = TimerArray:new()
    object.canShoot = true
    object.canDash = true
    object.isDashing = false

    table.insert(objects, object)
    return object
end

function Player:update(dt)
    self.energy = self.energy + playerEnergyRegen * dt
    if self.energy > self.maxEnergy then self.energy = self.maxEnergy end
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
    if (d > 0 and not self.isDashing) then
        self.collider:applyForce(moveX / d * playerMovementForce, moveY / d * playerMovementForce)
    end

    if self.energy >= playerShootCost and self.canShoot and love.mouse.isDown(1) then
        self.energy = self.energy - playerShootCost
        self.canShoot = false
        self.timers:setTimer("shoot cooldown", playerShootCooldown, 1, function() self.canShoot = true end)
        local mx, my = worldViewport:screenToWorld(love.mouse.getPosition())
        Bullet:new(
                self,
                { x = mx, y = my },
                playerShootVelocity,
                1.1,
                playerShootDamage,
                5,
                0,
                nil,
                nil,
                nil
        )
        sounds.shoot:play()
    end

    if self.energy >= playerDashCost and self.canDash and love.mouse.isDown(2) and self.rmbWasUpLastFrame then
        self.rmbWasUpLastFrame = false
        self.energy = self.energy - playerDashCost
        self.canDash = false
        self.isDashing = true
        self.collider:setSensor(true)
        self.timers:setTimer("dash duration", playerDashDuration, 1, function()
            self.collider:setSensor(false)
            self.isDashing = false
            self.timers:setTimer("dash cooldown", playerDashCooldown, 1, function() self.canDash = true end)
        end)
        local mx, my = worldViewport:screenToWorld(love.mouse.getPosition())
        local sx, sy = self.collider:getPosition()
        local dx, dy = mx - sx, my - sy
        local d = math.sqrt(dx * dx + dy * dy)
        self.collider:applyLinearImpulse(dx / d * playerDashImpulse, dy / d * playerDashImpulse)
        -- TODO: dash sound
    end
    if not love.mouse.isDown(2) then self.rmbWasUpLastFrame = true end
end

function Player:filterDamage(amount, willDie)
    return not self.isDashing
end

function Player:onHit()
    sounds.hit:play()
end

function Player:onDeath()
    sounds.death:play()
end
