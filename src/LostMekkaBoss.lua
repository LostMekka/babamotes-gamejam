local LostMekkaBoss = {}

function LostMekkaBoss.new(startX, startY)
    local object = {}
    object.type = "enemy"
    object.alive = true
    object.debugColor = { 1, 0, 0 }
    object.radius = 20
    object.collider = world:newCircleCollider(startX, startY, object.radius)
    object.collider:setCollisionClass("enemy")
    object.collider:setLinearDamping(playerMovementDamping)
    object.collider:setObject(object)

    object.update = function(self, dt)
        local px, py = player.collider:getPosition()
        local x, y = self.collider:getPosition()
        local speed = 10
        self.collider:applyForce((px - x) * speed, (py - y) * speed)
    end

    table.insert(objects, object)
    return object
end

return LostMekkaBoss
