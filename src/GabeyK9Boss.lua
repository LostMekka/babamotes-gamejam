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
gk9Updates = {
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    nil,
    function(self, dt)
        if not player.alive then return end
        if self.timers ~= nil then
            self.timers:update(dt)
        end
        if self.canBounce == nil then
            self.canBounce = false
            self.timers = TimerArray:new()
            self.timers:setTimer(
                    "bouncing",
                    0.5,
                    true,
                    function() self.canBounce = true end
            )
        elseif self.canBounce and self.alive then
            self.canBounce = false
            local tx, ty = player.collider:getPosition()
            local sx, sy = self.collider:getPosition()
            local dx, dy = tx - sx, ty - sy
            local d = math.sqrt(dx * dx + dy * dy)
            if d == 0 then
                d = 1
                dx = 1
                dy = 0
            end
            velocityX = (dx / d * 400)
            velocityY = (dy / d * 400)
            self.collider:setLinearVelocity(velocityX, velocityY)
        end
    end
}
gk9OnHits = {
    function(self)
        if not player.alive then return end

        local px, py = player.collider:getPosition()
        local x, y = self.collider:getPosition()
        local dx, dy = px - x, py - y
        local d = math.sqrt(dx * dx + dy * dy)
        local minD = 50
        local speed = 17000
        if d < minD then
            player.collider:applyForce(d / dx * speed, d / dy * speed)
        end
    end,
}
gk9EOLs = {
    nil,
    nil,
    nil,
    nil,
    function(self)
        if not boss.alive then return end

        local x, y = self.collider:getPosition()
        boss.collider:setPosition(x, y)
    end,
    function(self)
        local x, y = self.collider:getPosition()
        local rnd = math.random(1,8)
        for i=1,5 do
            local velX = math.cos(i*math.pi*0.4)*400
            local velY = math.sin(i*math.pi*0.4)*400
            if rnd == 7 then
                velX = velX * 2
                velY = velY * 2
            end
            local dmg = 1
            if rnd == 1 then
                dmg = 3
            end
            local maxLife = 2
            if rnd == 5 or rnd == 6 then
                maxLife = 0.5
            end
            Bullet:new_dir(
                    self,
                    velX,
                    velY,
                    maxLife,
                    dmg,
                    5,
                    0,
                    gk9Updates[rnd],
                    gk9OnHits[rnd],
                    gk9EOLs[rnd],
                    gk9BulletColors[rnd]
            )
        end
    end,
}

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
            local j = i + offset
            local velX = math.cos(j*math.pi/4)*400
            local velY = math.sin(j*math.pi/4)*400
            if i == 7 then
                velX = velX * 2
                velY = velY * 2
            end
            local dmg = 1
            if i == 1 then
                dmg = 3
            end
            local maxLife = 2
            if i == 5 or i == 6 then
                maxLife = 0.5
            end
            Bullet:new_dir(
                    self,
                    velX,
                    velY,
                    maxLife,
                    dmg,
                    5,
                    0,
                    gk9Updates[i],
                    gk9OnHits[i],
                    gk9EOLs[i],
                    gk9BulletColors[i]
            )
        end
    end
end
