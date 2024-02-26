require("Hammer")
require("OrbitThing")

someone1065Boss = {
    type = "enemy",
    belongsToPlayer = false,
    maxHp = 100,
    radius = 20,
    alive = true,
    mass = 10,
    debugColor = { 0.447, 0.537, 0.855 }
}

local sounds = {
    bossDead = PolyVoiceSound:new("sfx/bossdead.wav"),
}

local sprites = {
    static = loadImage("sprites/someone1065.png")
}

function someone1065Boss:new(startX, startY)
    local object = {}
    setmetatable(object, self)
    self.__index = self

    object.collider = world:newCircleCollider(startX, startY, object.radius)
    object.collider:setCollisionClass("enemy")
    object.collider:setLinearDamping(playerMovementDamping)
    object.collider:setMass(object.mass)
    object.collider:setObject(object)

    addHpComponentToEntity(object, object.maxHp)

    table.insert(objects, object)
    return object
end

function someone1065Boss:draw()
    love.graphics.setColor(1, 1, 1)
    local sx, sy = self.collider:getPosition()
    love.graphics.draw(
            sprites.static,
            sx,
            sy,
            0,
            self.radius / 24,
            self.radius / 24,
            24,
            24
    )
end

function someone1065Boss:update(dt)
    if not player.alive then return end

    if not CustomDifficulty then
        CustomDifficulty = 1
    end
    if not self.completions then
        self.completions = 0
    end
    local PhaseDifficulty
    if self.hp > 75 then
        PhaseDifficulty = 0
    elseif self.hp > 50 then
        PhaseDifficulty = 0.2
    elseif self.hp > 25 then
        PhaseDifficulty = 0.4
    elseif self.completions < 2 then
        PhaseDifficulty = 0.6
    elseif self.hp > 10 then
        PhaseDifficulty = 0.7
    else
        PhaseDifficulty = 1
    end
    local TotalDifficulty = CustomDifficulty + self.completions + PhaseDifficulty

    local px, py
    if self.hammer and self.hammer.alive then
        px, py = self.hammer.collider:getPosition()
    else
        px, py = player.collider:getPosition()
    end
    local x, y = self.collider:getPosition()
    local speed = 100 + (100 * TotalDifficulty)
    self.collider:applyForce((px - x) * speed, (py - y) * speed)

    if not self.hammer or not self.hammer.alive then
        self.hammer = Hammer:new(
                self,
                player,
                800 + (4 * TotalDifficulty * (100 - self.hp)),
                4.5 - TotalDifficulty,
                1 + (0.01 * TotalDifficulty * (100 - self.hp)),
                10,
                2 + (0.01 * TotalDifficulty * (100 - self.hp)),
                nil,
                nil,
                nil
        )
    end
--[[    if not self.sickle or not self.sickle.alive then
        self.sickle = Sickle:new(
                self,
                player,
                1200,
                3,
                1,
                10,
                3,
                nil,
                nil,
                nil
        )
    end
    Sickle:update()]]
end

function someone1065Boss:onDeath()
    self.completions = self.completions + 1
    -- TODO: mark this boss as defeated
    spawnPortalToHubWorld(self.collider:getPosition())
    sounds.bossDead:play()
end
