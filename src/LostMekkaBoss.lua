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

    object.idle = true
    object.isShielded = true
    object.minionCount = 0
    object.wavesToSpawn = 0
    object.bossPhase = 0
    object.shieldSequence = ActionSequence:new(function(context) object:shieldCoroutine(context) end)
    object.spawnSequence = ActionSequence:new(function(context) object:minionSpawnerCoroutine(context) end)
    object.normalAttackSequence = ActionSequence:new(function(context) object:normalAttackCoroutine(context) end)

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

    self.shieldSequence:update(dt)
    self.spawnSequence:update(dt)
    self.normalAttackSequence:update(dt)

    local px, py = player.collider:getPosition()
    local x, y = self.collider:getPosition()
    local dx, dy = px - x, py - y
    local d = math.sqrt(dx * dx + dy * dy)
    local minDistance = 150
    local maxDistance = 350
    local moveForce = 1000 * self.mass
    if d < minDistance then
        self.collider:applyForce(dx / d * -moveForce, dy / d * -moveForce)
    elseif d > maxDistance then
        self.collider:applyForce(dx / d * moveForce, dy / d * moveForce)
    end
end

function LostMekkaBoss:shieldCoroutine(context)
    while true do
        -- wait for shield to activate
        while not self.isShielded do context:delay(0.1) end
        context:delay(5) -- shield stays on for at least a few seconds before we start to check for deactivation
        -- wait for conditions to deactivate shield
        while self.wavesToSpawn > 0 or self.minionCount >= 5 do context:delay(0.1) end
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
        if not self.idle and self.wavesToSpawn <= 0 then
            for _ = 1, self.bossPhase * 5 do
                Bullet:new(
                        self,
                        player,
                        400,
                        3,
                        1,
                        5,
                        0,
                        nil,
                        nil,
                        nil
                )
                context:delay(0.2)
            end
        end
    end
end

function LostMekkaBoss:spawnMinion()
    local px, py = player.collider:getPosition()
    local x, y = self.collider:getPosition()
    local dx, dy = px - x, py - y
    local d = math.sqrt(dx * dx + dy * dy)
    LostMekkaMinion:new(
            x + dx / d * 20,
            y + dy / d * 20,
            function() self.minionCount = self.minionCount - 1 end
    )
    self.minionCount = self.minionCount + 1
end

function LostMekkaBoss:onBossPhaseStart()
    self.isShielded = true
    self.idle = true
    self.timers:setTimer("spawning start", 3, 1, function()
        self.wavesToSpawn = 3 * self.bossPhase
        self.idle = false
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
