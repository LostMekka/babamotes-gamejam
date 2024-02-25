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
    shoot = PolyVoiceSound:new("sfx/shot1_lowpass.wav", 0.45),
    death = PolyVoiceSound:new("sfx/gameover.wav"),
}

local sprites = {
    walkRight = {
        loadImage("sprites/baba1.png"),
        loadImage("sprites/baba2.png"),
        loadImage("sprites/baba3.png"),
        loadImage("sprites/baba4.png"),
    },
    walkUp = {
        loadImage("sprites/baba5.png"),
        loadImage("sprites/baba6.png"),
        loadImage("sprites/baba7.png"),
        loadImage("sprites/baba8.png"),
    },
    walkDown = {
        loadImage("sprites/baba9.png"),
        loadImage("sprites/baba10.png"),
        loadImage("sprites/baba11.png"),
        loadImage("sprites/baba12.png"),
    },
    dash = loadImage("sprites/baba13.png"),
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
    object.walkAnimationTime = 0
    object.walkAnimationSpeed = 0.05
    object.drawScale = 0.12

    table.insert(objects, object)
    return object
end

function Player:draw()
    love.graphics.setColor(1, 1, 1)
    local sx, sy = self.collider:getPosition()
    local vx, vy = self.collider:getLinearVelocity()
    if self.isDashing then
        local angle = math.atan2(vy, vx)
        local hFlipScale = 1
        if vx < 0 then
            hFlipScale = -1
            angle = angle + math.pi
        end
        love.graphics.draw(
                sprites.dash,
                sx,
                sy,
                angle,
                self.drawScale * hFlipScale,
                self.drawScale,
                256,
                256
        )
    else
        local d = math.sqrt(vx * vx + vy * vy)
        local animationIndex = math.floor(self.walkAnimationTime) + 1
        local animation
        local hFlipScale = 1
        if math.abs(vx) >= math.abs(vy) or d < 10 then
            animation = sprites.walkRight
            if vx < 0 then hFlipScale = -1 end
        else
            if vy > 0 then
                animation = sprites.walkDown
            else
                animation = sprites.walkUp
            end
        end
        love.graphics.draw(
                animation[animationIndex],
                sx,
                sy,
                0,
                self.drawScale * hFlipScale,
                self.drawScale,
                256,
                256
        )
    end
end

function Player:update(dt)
    local vx, vy = self.collider:getLinearVelocity()
    local dv = math.sqrt(vx * vx + vy * vy)
    self.walkAnimationTime = (self.walkAnimationTime + self.walkAnimationSpeed * dv * dt) % 4
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
