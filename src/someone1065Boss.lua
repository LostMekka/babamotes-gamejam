require("Hammer")
require("OrbitThing")

someone1065Boss = {}

function someone1065Boss:new(startX, startY)
    local object = {}
    setmetatable(object, self)
    self.__index = self

    object.type = "enemy"
    object.alive = true
    object.belongsToPlayer = false
    object.debugColor = { 0.447, 0.537, 0.855 }
    object.radius = 20
    object.collider = world:newCircleCollider(startX, startY, object.radius)
    object.collider:setCollisionClass("enemy")
    object.collider:setLinearDamping(playerMovementDamping)
    object.collider:setObject(object)

    object.shootInterval = 0.5
    object.shootTimer = 0

    table.insert(objects, object)
    return object
end

function someone1065Boss:update(dt)
    local px, py
    if self.hammer and self.hammer.alive then
        px, py = self.hammer.collider:getPosition()
    else
        px, py = player.collider:getPosition()
    end
    local x, y = self.collider:getPosition()
    local speed = 20
    self.collider:applyForce((px - x) * speed, (py - y) * speed)

    self.shootTimer = self.shootTimer + dt
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
