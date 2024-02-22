require("entityHelpers")
require("timers")
require("ActionSequence")
require("Bullet")
require("LostMekkaMinion")

LostMekkaBoss = {
    type = "enemy",
    belongsToPlayer = false,
    maxHp = 100,
    radius = 25,
    shootInterval = 0.5,
    alive = true,
    mass = 20,
    debugColor = { 1, 0, 0 }
}

function LostMekkaBoss:new(startX, startY)
    local object = {}
    setmetatable(object, self)
    self.__index = self

    object.collider = world:newCircleCollider(startX, startY, object.radius)
    object.collider:setCollisionClass("enemy")
    object.collider:setLinearDamping(playerMovementDamping)
    object.collider:setMass(object.mass)
    object.collider:setObject(object)

    addHpComponentToEntity(
            object,
            object.maxHp,
            function(self, amount) self:onDamageBeforeHealthCheck(amount) end,
            function(self) self:onDeath() end
    )

    object.timers = TimerArray:new()

    object.isStunned = true
    object.isShielded = true
    object.minionCount = 0
    object.wavesToSpawn = 0
    object.bossPhase = 0
    object.actionSequences = {
        ActionSequence:new(function(context) object:shieldCoroutine(context) end),
        ActionSequence:new(function(context) object:minionSpawnerCoroutine(context) end),
        ActionSequence:new(function(context) object:normalAttackCoroutine(context) end),
        ActionSequence:new(function(context) object:zoningAttackCoroutine(context) end),
        ActionSequence:new(function(context) object:stunnedAttackCoroutine(context) end),
        ActionSequence:new(function(context) object:stunnedSpawnCoroutine(context) end)
    }

    table.insert(objects, object)
    return object
end

function LostMekkaBoss:draw()
    if self.isShielded then
        love.graphics.setColor(0.9, 0.95, 1)
        local x, y = self.collider:getPosition()
        for i = 3, 6 do
            love.graphics.circle("line", x, y, self.radius + i)
        end
    end
end

function LostMekkaBoss:update(dt)
    local currPhase = math.floor((1 - self.hp / self.maxHp) * 4) + 1
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
        local moveForce = 500 * self.mass
        if d < minDistance then
            self.collider:applyForce(dx / d * -moveForce, dy / d * -moveForce)
        elseif d > maxDistance then
            self.collider:applyForce(dx / d * moveForce, dy / d * moveForce)
        end
    end
end

function LostMekkaBoss:shieldCoroutine(context)
    while true do
        -- wait for shield to activate
        while not self.isShielded do context:delay() end
        -- wait for stun to wear off
        while self.isStunned do context:delay() end
        -- shield stays on for at least a few seconds before we start to check for deactivation
        context:delay(5)
        -- wait for conditions to deactivate shield
        while self.wavesToSpawn > 0 or self.minionCount >= 5 do context:delay() end
        self.isShielded = false
    end
end

function LostMekkaBoss:minionSpawnerCoroutine(context)
    while true do
        context:delay(1)
        if self.wavesToSpawn > 0 then
            self.wavesToSpawn = self.wavesToSpawn - 1
            for _ = 1, 10 do
                self:spawnMinion()
                context:delay(0.05)
            end
        end
    end
end

function LostMekkaBoss:normalAttackCoroutine(context)
    while true do
        context:delay(0.5 + math.random())
        if not self.isStunned and self.wavesToSpawn <= 0 then
            for _ = 1, self.bossPhase * 5 do
                Bullet:new(
                        self,
                        player,
                        400,
                        3,
                        5,
                        8
                )
                context:delay(0.18)
            end
        end
    end
end

function LostMekkaBoss:zoningAttackCoroutine(context)
    while true do
        context:delay(3 + math.random() * 3)
        if not self.isStunned and self.wavesToSpawn <= 0 and self.bossPhase >= 2 then
            self.doesZoningAttack = true
            local beamCount = (self.bossPhase - 1) * 2
            local burstCount = (self.bossPhase - 1) * 2 + 1
            local bulletCount = 18
            local angleOffset = math.random() * 2 * math.pi
            for burst = 1, burstCount do
                context:delay(0.8)
                local burstOffset = (burst % 2) * math.pi / beamCount
                for _ = 1, bulletCount do
                    context:delay(0.015)
                    for beam = 1, beamCount do
                        local beamOffset = beam * 2 * math.pi / beamCount
                        Bullet:new(
                                self,
                                { angle = angleOffset + burstOffset + beamOffset },
                                230,
                                10,
                                7,
                                6,
                                -0.9
                        )
                    end
                end
            end
            self.doesZoningAttack = false
        end
    end
end

function LostMekkaBoss:stunnedAttackCoroutine(context)
    while true do
        context:delay(0.15)
        if self.isStunned and self.bossPhase > 1 then
            local beamCount = self.bossPhase * 2 + 1
            local rotationSpeed = 3.5
            local angleOffset = (love.timer.getTime() * rotationSpeed) % (2 * math.pi)
            for i = 1, beamCount do
                local angle = angleOffset + i / beamCount * 2 * math.pi
                Bullet:new(
                        self,
                        { angle = angle },
                        100,
                        10,
                        3,
                        5,
                        -0.25
                )
            end
        end
    end
end

function LostMekkaBoss:stunnedSpawnCoroutine(context)
    while true do
        context:delay(0.9)
        if self.isStunned and self.bossPhase >= 3 then
            local spawnCount = (self.bossPhase - 2) * 1
            for _ = 1, spawnCount do
                self:spawnMinion(true)
            end
        end
    end
end

function LostMekkaBoss:spawnMinion(outside)
    local px, py = player.collider:getPosition()
    local x, y
    if outside then
        local angle = math.random() * 2 * math.pi
        local r = 700
        x = px + r * math.cos(angle)
        y = py + r * math.sin(angle)
    else
        local sx, sy = self.collider:getPosition()
        local dx, dy = px - sx, py - sy
        local d = math.sqrt(dx * dx + dy * dy)
        x = sx + dx / d * 20
        y = sy + dy / d * 20
    end
    LostMekkaMinion:new(x, y, function() self.minionCount = self.minionCount - 1 end)
    self.minionCount = self.minionCount + 1
end

function LostMekkaBoss:onBossPhaseStart()
    self.isShielded = true
    self.isStunned = true
    self.timers:setTimer("spawning start", 2 + 4 * (self.bossPhase - 1), 1, function()
        self.wavesToSpawn = 3 * self.bossPhase
        self.isStunned = false
    end)
end

function LostMekkaBoss:onDamageBeforeHealthCheck(damageAmount)
    if self.isShielded then
        -- negate all damage
        self.hp = self.hp + damageAmount
    end
end

function LostMekkaBoss:onDeath()
    -- TODO: mark this boss as defeated
    spawnPortalToHubWorld(self.collider:getPosition())
end
