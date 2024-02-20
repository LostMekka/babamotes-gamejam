require("timers")
require("Bullet")

LostMekkaBoss = {
    type = "enemy",
    belongsToPlayer = false,
    maxHp = 100,
    radius = 25,
    shootInterval = 0.5,
    alive = true,
    mass = 10,
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

    object.hp = object.maxHp
    object.canShoot = false
    object.timers = TimerArray:new()
    object.timers:setTimer(
            "shooting",
            object.shootInterval,
            true,
            function() object.canShoot = true end
    )

    table.insert(objects, object)
    return object
end

function LostMekkaBoss:update(dt)
    self.timers:update(dt)

    local px, py = player.collider:getPosition()
    local x, y = self.collider:getPosition()
    local dx, dy = px - x, py - y
    local d = math.sqrt(dx * dx + dy * dy)
    local minD = 150
    local speed = 5000
    if d > minD then
        self.collider:applyForce(dx / d * speed, dy / d * speed)
    end

    if self.canShoot then
        self.canShoot = false
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

function LostMekkaBoss:damage(amount)
    self.hp = self.hp - amount
    if self.hp <= 0 then
        self.hp = 0
        self.alive = false
        -- TODO: mark this boss as defeated
        spawnPortalToHubWorld(self.collider:getPosition())
        self.collider:destroy()
    end
end
