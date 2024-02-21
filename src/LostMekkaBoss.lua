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

    object.canShoot = false
    object.timers = TimerArray:new()
    object.timers:setTimer(
            "shooting",
            object.shootInterval,
            -1,
            function() object.canShoot = true end
    )

    object.minionCount = 0
    object.bossPhase = 0
    object.spawnSequence = nil

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
    self.isShielded = self.minionCount >= 5
    self.timers:update(dt)
    if not player or not player.alive then return end

    local currPhase = math.floor((1 - self.hp / self.maxHp) * 4) + 1
    if self.bossPhase ~= currPhase then
        self.bossPhase = currPhase
        self:onBossPhaseStart()
    end

    if self.spawnSequence then self.spawnSequence:update(dt) end

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

    --if self.canShoot then
    --    self.canShoot = false
    --    LostMekkaMinion:new(x + dx / d * 20, y + dy / d * 20)
    --    --Bullet:new(
    --    --        self,
    --    --        player,
    --    --        400,
    --    --        3,
    --    --        1,
    --    --        5,
    --    --        0,
    --    --        nil,
    --    --        nil,
    --    --        nil
    --    --)
    --end
end

function LostMekkaBoss:minionSpawnerCoroutine(context, waveCount)
    for _ = 1, waveCount do
        context:delay(1)
        for _ = 1, 10 do
            self:spawnMinion()
            context:delay(0.05)
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
    local spawnWaves = 3 * self.bossPhase
    self.spawnSequence = ActionSequence:new(function(context)
        self:minionSpawnerCoroutine(context, spawnWaves)
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
