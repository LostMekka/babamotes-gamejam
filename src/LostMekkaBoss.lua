require("Bullet")

LostMekkaBoss = {}

function LostMekkaBoss:new(startX, startY)
    local object = {}
    setmetatable(object, self)
    self.__index = self

    object.type = "enemy"
    object.alive = true
    object.belongsToPlayer = true
    object.debugColor = { 1, 0, 0 }
    object.radius = 25
    object.collider = world:newCircleCollider(startX, startY, object.radius)
    object.collider:setCollisionClass("enemy")
    object.collider:setLinearDamping(playerMovementDamping)
    object.collider:setObject(object)

    object.shootInterval = 0.5
    object.shootTimer = 0

    table.insert(objects, object)
    return object
end

function LostMekkaBoss:update(dt)
    local px, py = player.collider:getPosition()
    local x, y = self.collider:getPosition()
    local speed = 10
    self.collider:applyForce((px - x) * speed, (py - y) * speed)

    self.shootTimer = self.shootTimer + dt
    if self.shootTimer >= self.shootInterval then
        self.shootTimer = self.shootTimer - self.shootInterval
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
    end
end
