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

function someone1065Boss:new(startX, startY)
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
            nil,
            function(self)
                -- TODO: mark this boss as defeated
                spawnPortalToHubWorld(self.collider:getPosition())
            end
    )

    table.insert(objects, object)
    return object
end

function someone1065Boss:update(dt)
    if not player.alive then return end

    local px, py
    if self.hammer and self.hammer.alive then
        px, py = self.hammer.collider:getPosition()
    else
        px, py = player.collider:getPosition()
    end
    local x, y = self.collider:getPosition()
    local speed = 200
    self.collider:applyForce((px - x) * speed, (py - y) * speed)

    if not self.hammer or not self.hammer.alive then
        self.hammer = Hammer:new(
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
end
