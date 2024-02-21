require("entityHelpers")
require("timers")
require("Bullet")
require("math")

GabeyK9Boss = {
    type = "enemy",
    belongsToPlayer = false,
    maxHp = 100,
    radius = 15,
    shootInterval = 1.5,
    alive = true,
    mass = 10,
    debugColor = { 0, 1, 1 }
}

gk9BulletColors = {{1,0.2,0.2}, {1,0.6,0.2}, {1,1,0.2}, {0.2,1,0.2}, {0.2,1,1}, {0.2,0.2,1}, {0.6,0.2,1}, {1,0.2,0.6}}

function GabeyK9Boss:new(startX, startY)
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

function GabeyK9Boss:update(dt)
    self.timers:update(dt)
    if not player.alive then return end

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
        local offset = math.random(0,7)
        for i=1,8 do
            velX = math.cos((i+offset)*math.pi/4)*400
            velY = math.sin((i+offset)*math.pi/4)*400
            Bullet:new_dir(
                    self,
                    velX,
                    velY,
                    1,
                    1,
                    5,
                    0,
                    nil,
                    nil,
                    nil,
                    gk9BulletColors[i]
            )
        end
    end
end
