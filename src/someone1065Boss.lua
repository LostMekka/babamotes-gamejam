require("Hammer")

someone1065Boss = {}

function someone1065Boss:new(startX, startY)
    local object = {}
    setmetatable(object, self)
    self.__index = self

    object.type = "enemy"
    object.alive = true
    object.belongsToPlayer = true
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
--[[    if Hammer.alive then
        local px, py = Hammer.collider:getPosition()
    else]]
        local px, py = player.collider:getPosition()
--[[    end]]
    local x, y = self.collider:getPosition()
    local speed = 10
    self.collider:applyForce((px - x) * speed, (py - y) * speed)

    self.shootTimer = self.shootTimer + dt
    if not self.hammer and not self.hammer.alive then
        Hammer:new(
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
    end
end
