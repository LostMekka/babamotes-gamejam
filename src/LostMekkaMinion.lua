require("entityHelpers")
require("timers")
require("Bullet")

LostMekkaMinion = {
    mass = 2,
    type = "enemy",
    belongsToPlayer = false,
    maxHp = 5,
    alive = true,
    debugColor = { 1, 0.2, 0.2 }
}

local maxMoveTime = 10000

local function random(a, b)
    return math.random() * (b - a) + a
end

function LostMekkaMinion:new(startX, startY, onDeath)
    local object = {}
    setmetatable(object, self)
    self.__index = self

    object.sizeModifier = random(0.85, 1.2)
    object.frequencyModifier = (object.sizeModifier - 1) * 2 + 1
    object.radius = 13.0 * object.sizeModifier
    object.collider = world:newCircleCollider(startX, startY, object.radius)
    object.collider:setCollisionClass("enemy")
    object.collider:setLinearDamping(playerMovementDamping)
    object.collider:setMass(object.mass)
    object.collider:setObject(object)

    addHpComponentToEntity(object, object.maxHp, nil, onDeath)
    object.moveTime = random(0, maxMoveTime)

    table.insert(objects, object)
    return object
end

function LostMekkaMinion:update(dt)
    self.moveTime = (self.moveTime + dt) % maxMoveTime
    if not player or not player.alive then return end

    local px, py = player.collider:getPosition()
    local sx, sy = self.collider:getPosition()
    local f = 1 / self.sizeModifier
    local t = self.moveTime
    local angleNoise = love.math.noise(t * f)
    local angle = math.atan2(py - sy, px - sx) + ((angleNoise - 0.5) ^ 3) * 130
    local forceNoise = love.math.noise((t + 5000) * f * 2.5)
    local force = (forceNoise ^ 2.5) * 12000 + 100
    self.collider:applyForce(math.cos(angle) * force, math.sin(angle) * force)

    if self.collider:enter("player") then
        local data = self.collider:getEnterCollisionData("player")
        data.collider:getObject():damage(dt * 100)
    end
end
