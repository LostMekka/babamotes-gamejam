require("sounds")
require("entityHelpers")
require("timers")
require("ActionSequence")
require("Bullet")

IiiAaa123Boss = {
    type = "enemy",
    belongsToPlayer = false,
    maxHp = 400,
    radius = 25,
    shootInterval = 0.5,
    alive = true,
    mass = 200,
    debugColor = { 1, 0, 0 }
}

local sounds = {
    hit = PolyVoiceSound:new("sfx/hit.wav"),
    shot = PolyVoiceSound:new("sfx/shot2.wav"),
    explode = PolyVoiceSound:new("sfx/explode.wav", 0.45),
    bossDead = PolyVoiceSound:new("sfx/bossdead.wav"),
}

local function angleOf(x, y, maxRandomOffset)
    return math.atan2(y, x) + maxRandomOffset * (2 * math.random() - 1)
end

local function randomOffset(maxRandomOffset)
    return maxRandomOffset * (2 * math.random() - 1)
end

function IiiAaa123Boss:angleTo(target, maxRandomOffset)
    local sx, sy = self.collider:getPosition()
    local tx, ty = target.collider:getPosition()
    return math.atan2(ty - sy, tx - sx) + maxRandomOffset * (2 * math.random() - 1)
end

function IiiAaa123Boss:new(startX, startY)
    local object = {}
    setmetatable(object, self)
    self.__index = self

    object.collider = world:newCircleCollider(startX, startY, object.radius)
    object.collider:setCollisionClass("enemy")
    object.collider:setLinearDamping(playerMovementDamping)
    object.collider:setMass(object.mass)
    object.collider:setObject(object)

    addHpComponentToEntity(object, object.maxHp)

    object.timers = TimerArray:new()

    object.bossPhase = 0
    object.actionSequences = {
        ActionSequence:new(function(context) object:lavaAttackCoroutine(context) end),
        ActionSequence:new(function(context) object:lavaSpewingCoroutine(context) end),
        ActionSequence:new(function(context) object:lavaSpewing2Coroutine(context) end),
        ActionSequence:new(function(context) object:boomerangShootingCoroutine(context) end),
    }

    table.insert(objects, object)
    return object
end

function IiiAaa123Boss:draw()
end

function IiiAaa123Boss:update(dt)
    local currPhase = math.floor((1 - self.hp / self.maxHp) * 2) + 1
    if self.bossPhase ~= currPhase then
        self.bossPhase = currPhase
        self:onBossPhaseStart()
    end
    self.timers:update(dt)

    if not player or not player.alive then return end

    for _, sequence in ipairs(self.actionSequences) do
        sequence:update(dt)
    end

    if not self.isStunned and not self.doesZoningAttack then
        local px, py = player.collider:getPosition()
        local x, y = self.collider:getPosition()
        local dx, dy = px - x, py - y
        local d = math.sqrt(dx * dx + dy * dy)
        local minDistance = 150
        local maxDistance = 350
        local moveForce = 150 * self.mass
        if d < minDistance then
            self.collider:applyForce(dx / d * -moveForce, dy / d * -moveForce)
        elseif d > maxDistance then
            self.collider:applyForce(dx / d * moveForce, dy / d * moveForce)
        end
    end
end

local dotAmount = 10

function IiiAaa123Boss:createLavaArea(x, y, splashSize, splashDuration)
    local area = TriggerArea:new(
            x, y, splashSize or 30, splashDuration or 10,
            { player },
            function(_, dt)
                player:damage(dt * dotAmount)
            end,
            nil,
            nil,
            nil,
            nil
    )
    area.colorFrequency = 2.2 + 0.9 * math.random()
    area.colorOffset = 100 * math.random()
    area.debugColor = { 1, 0, 0 }
    function area:customUpdate(dt)
        local t = love.timer.getTime()
        local color = love.math.noise((t + self.colorOffset) * self.colorFrequency)
        area.debugColor = { 1 - 0.05 * color, 0.4 + 0.6 * color, 0, 0.5 }
    end
end

function IiiAaa123Boss:createLavaProjectile(source, target, velocity, splashSize, splashDuration)
    local minVelocity = 50
    local bullet = Bullet:new(
            source, target,
            velocity, 99999,
            10, 17, 1
    )
    bullet.parent = self
    bullet.colorFrequency = 1.2 + 0.8 * math.random()
    bullet.colorOffset = 100 * math.random()
    bullet.debugColor = { 1, 0, 0 }
    function bullet:customUpdate(dt)
        local t = love.timer.getTime()
        local color = love.math.noise((t + self.colorOffset) * self.colorFrequency)
        if color <= 0.5 then
            bullet.debugColor = { color + 0.5, 0, 0 }
        else
            bullet.debugColor = { 1, color - 0.5, color - 0.5 }
        end
        local vx, vy = self.collider:getLinearVelocity()
        if vx*vx + vy*vy <= minVelocity*minVelocity then
            self:customOnEndOfLife()
            self:destroy()
        end
    end
    function bullet:customOnHit()
        self:customOnEndOfLife()
    end
    function bullet:customOnEndOfLife()
        local sx, sy = self.collider:getPosition()
        self.parent:createLavaArea(sx, sy, splashSize, splashDuration)
        worldViewport.screenShakeAmount = 4
        sounds.explode:play()
    end
end

function IiiAaa123Boss:createBoomerangProjectile(source, target, velocity, counterForce)
    local bullet = Bullet:new(
            source, target,
            velocity, 20,
            5, 12
    )
    bullet.parent = self
    bullet.debugColor = { 0, 0, 0 }
    bullet.collider:setAngularVelocity(10)
    function bullet:customUpdate(dt)
        if not self.counterForce then
            local vx, vy = self.collider:getLinearVelocity()
            local angle = angleOf(vx, vy, 0.4)
            self.counterForce = { -counterForce * math.cos(angle), -counterForce * math.sin(angle) }
        end
        self.collider:applyForce(unpack(self.counterForce))
    end
end

function IiiAaa123Boss:lavaAttackCoroutine(context)
    while true do
        context:delay(1 + randomOffset(0.2))
        local angle = self:angleTo(player, 0.2)
        local velocity = 400 + 200 * math.random()
        self:createLavaProjectile(self, { angle = angle }, velocity, 35)
        sounds.shot:play()
    end
end

function IiiAaa123Boss:lavaSpewingCoroutine(context)
    while true do
        context:delay(0.5 + 1.2 / self.bossPhase)
        local angle = math.random() * 2 * math.pi
        local velocity = 150 + 500 * math.random()
        self:createLavaProjectile(self, { angle = angle }, velocity, 45)
        sounds.shot:play()
    end
end

function IiiAaa123Boss:lavaSpewing2Coroutine(context)
    while true do
        context:delay(3.1)
        if self.bossPhase >= 2 then
            local angle = self:angleTo(player, 0.8 * math.pi) + math.pi
            for _ = 1, 6 do
                local velocity = 200 + 600 * math.random()
                self:createLavaProjectile(self, { angle = angle + randomOffset(0.30) }, velocity, 50)
            end
            sounds.shot:play()
        end
    end
end

function IiiAaa123Boss:boomerangShootingCoroutine(context)
    while true do
        context:delay(1.64)
        if self.bossPhase >= 2 then
            for _ = 1, math.random(3, 6) do
                local angle = self:angleTo(player, 0.8)
                local velocity = 250 + 300 * math.random()
                self:createBoomerangProjectile(self, { angle = angle }, velocity, 150)
                sounds.shot:play()
                context:delay(0.2)
            end
        end
    end
end

function IiiAaa123Boss:onBossPhaseStart()
    if self.bossPhase >= 2 then self:explode(0.8) end
end

function IiiAaa123Boss:onHit()
    sounds.hit:play()
end

function IiiAaa123Boss:explode(splashDurationMultiplier)
    worldViewport.screenShakeAmount = 20
    for range = 1, 3 do
        for angle = 1, 20 do
            self:createLavaProjectile(
                    self,
                    { angle = 2 * math.pi / 10 * angle + randomOffset(0.2) },
                    range * (100 + 150 * math.random()),
                    55,
                    (splashDurationMultiplier or 1) * (5 + 5 * math.random())
            )
        end
    end
end

function IiiAaa123Boss:onDeath()
    self:explode(0.6)
    -- TODO: mark this boss as defeated
    spawnPortalToHubWorld(self.collider:getPosition())
    sounds.bossDead:play()
end
