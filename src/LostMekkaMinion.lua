require("entityHelpers")
require("sounds")
require("timers")
require("Bullet")

LostMekkaMinion = {
    mass = 0.6,
    type = "enemy",
    belongsToPlayer = false,
    maxHp = 3,
    alive = true,
    debugColor = { 1, 0.2, 0.2 }
}

local sounds = {
    hit = PolyVoiceSound:new("sfx/hit.wav"),
    death = PolyVoiceSound:new("sfx/bat.wav", 0.5),
}

local sprites = {
    loadImage("sprites/lostmekka_minion1.png"),
    loadImage("sprites/lostmekka_minion2.png"),
    loadImage("sprites/lostmekka_minion3.png"),
    loadImage("sprites/lostmekka_minion4.png"),
    loadImage("sprites/lostmekka_minion5.png"),
    loadImage("sprites/lostmekka_minion6.png"),
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
    object.onDeathCallback = onDeath
    object.collider = world:newCircleCollider(startX, startY, object.radius)
    object.collider:setCollisionClass("enemy")
    object.collider:setLinearDamping(playerMovementDamping)
    object.collider:setMass(object.mass)
    object.collider:setObject(object)

    addHpComponentToEntity(object, object.maxHp)
    object.moveTime = random(0, maxMoveTime)
    object.animationTime = random(0, 5.9)
    object.animationSpeed = 5
    object.drawScale = object.radius / 32

    table.insert(objects, object)
    return object
end

function LostMekkaMinion:draw()
    love.graphics.setColor(1, 1, 1)
    local animationIndex = math.floor(self.animationTime) + 1
    local sx, sy = self.collider:getPosition()
    love.graphics.draw(
            sprites[animationIndex],
            sx,
            sy,
            0,
            self.drawScale,
            self.drawScale,
            32,
            32
    )
end

function LostMekkaMinion:update(dt)
    self.moveTime = (self.moveTime + dt) % maxMoveTime
    local f = 1 / self.sizeModifier
    local t = self.moveTime
    self.animationTime = (self.animationTime + self.animationSpeed * dt * (1 + love.math.noise((t + 2000) * f * 3.5))) % 6
    if not player or not player.alive then return end

    local px, py = player.collider:getPosition()
    local sx, sy = self.collider:getPosition()
    local angleNoise = love.math.noise(t * f)
    local angle = math.atan2(py - sy, px - sx) + ((angleNoise - 0.5) ^ 3) * 180
    local forceNoise = love.math.noise((t + 5000) * f * 2.5)
    local force = (forceNoise ^ 2.5) * 6000 * self.mass + 100
    self.collider:applyForce(math.cos(angle) * force, math.sin(angle) * force)

    if self.collider:enter("player") then
        local data = self.collider:getEnterCollisionData("player")
        data.collider:getObject():damage(dt * 100)
    end
end

function LostMekkaMinion:onHit()
    sounds.hit:play()
end

function LostMekkaMinion:onDeath(...)
    sounds.death:play()
    self.onDeathCallback(...)
end
