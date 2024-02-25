require("entityHelpers")
require("timers")
require("Bullet")
require("math")

GabeyK9Boss = {
    type = "enemy",
    belongsToPlayer = false,
    radius = 15,
    shootInterval = 1.5,
    alive = true,
    mass = 10,
}

local sounds = {
    bossDead = PolyVoiceSound:new("sfx/bossdead.wav"),
}

gk9BulletColors = {{1,0.2,0.2}, {1,0.6,0.2}, {1,1,0.2}, {0.2,1,0.2}, {0.2,1,1}, {0.2,0.2,1}, {0.6,0.2,1}, {1,0.2,0.6}}
gk9Updates = {
    nil,
    nil,
    nil,
    function(self, dt)
        self.radius = self.radius + dt*3
    end,
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
                    -1,
                    function() self.canBounce = true end
            )
        elseif self.canBounce and self.alive then
            self.canBounce = false
            if math.random(1,3) ~= 3 then
                local tx, ty = player.collider:getPosition()
                local sx, sy = self.collider:getPosition()
                local dx, dy = tx - sx, ty - sy
                local d = math.sqrt(dx * dx + dy * dy)
                if d == 0 then
                    d = 1
                    dx = 1
                    dy = 0
                end
                velocityX = (dx / d * 250)
                velocityY = (dy / d * 250)
                self.collider:setLinearVelocity(velocityX, velocityY)
            end
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
            player.collider:applyForce(dx / d * speed, dy / d * speed)
        end
    end,
}
gk9EOLs = {
    nil,
    nil,
    nil,
    nil,
    function(self)
        local x, y = self.collider:getPosition()
        if self.origin == 0 then
            GabeyK9Boss:new(x, y, true)
        else
            if not boss.alive then return end
            boss.collider:setPosition(x, y)
        end
    end,
    function(self)
        local x, y = self.collider:getPosition()
        local rnd = math.random(1,8)
        for i=1,5 do
            local vel = 200
            if rnd == 7 then
                vel = vel * 2
            end
            local dmg = 1
            if rnd == 1 then
                dmg = 3
            end
            local maxLife = 2
            if rnd == 5 or rnd == 6 then
                maxLife = 0.5
            end
            new = Bullet:new(
                    self,
                    { angle = i * math.pi * 0.4 },
                    vel,
                    maxLife,
                    dmg,
                    5,
                    0,
                    gk9Updates[rnd],
                    gk9OnHits[rnd],
                    gk9EOLs[rnd],
                    gk9BulletColors[rnd]
            )
            new.origin = 0
        end
    end,
}

function GabeyK9Boss:new(startX, startY, isPhantom)
    local object = {}
    setmetatable(object, self)
    self.__index = self

    object.collider = world:newCircleCollider(startX, startY, object.radius)
    object.collider:setCollisionClass("enemy")
    object.collider:setLinearDamping(playerMovementDamping)
    object.collider:setMass(object.mass)
    object.collider:setObject(object)

    if isPhantom == nil then
        isPhantom = false
    end
    object.isPhantom = isPhantom
    local hp
    if isPhantom then
        object.step = 0
        object.debugColor = { 0, 1, 1, 0.4 }
        hp = 10
    else
        object.debugColor = { 0, 1, 1, 1 }
        hp = 100
    end

    addHpComponentToEntity(object, hp)

    object.canShoot = false
    object.timers = TimerArray:new()
    object.timers:setTimer(
            "shooting",
            object.shootInterval,
            -1,
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
        if self.isPhantom then
            if player.alive then
                if self.step < 1 then
                    self.canShoot = false
                    self.step = self.step + 1
                    local rnd = math.random(1,8)
                    local vel = 250
                    if rnd == 7 then
                        vel = vel * 2
                    end
                    local dmg = 1
                    if rnd == 1 then
                        dmg = 3
                    end
                    if rnd == 3 then
                        dmg = -2
                    end
                    local maxLife = 2
                    if rnd == 5 or rnd == 6 then
                        maxLife = 0.5
                    end
                    new = Bullet:new(
                            self,
                            player,
                            vel,
                            maxLife,
                            dmg,
                            5,
                            0,
                            gk9Updates[rnd],
                            gk9OnHits[rnd],
                            gk9EOLs[rnd],
                            gk9BulletColors[rnd]
                    )
                    new.origin = 0
                else
                    self:destroy()
                end
            end
        else
            self.canShoot = false
            local offset = math.random(0,7)
            for i=1,8 do
                local j = i + offset
                local vel = 250
                if i == 7 then
                    vel = vel * 2
                end
                local dmg = 1
                if i == 1 then
                    dmg = 3
                end
                if i == 3 then
                    dmg = -2
                end
                local maxLife = 2
                if i == 5 or i == 6 then
                    maxLife = 0.5
                end
                Bullet:new(
                        self,
                        { angle = j * math.pi / 4 },
                        vel,
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
end

function GabeyK9Boss:destroy()
    if not self.collider:isDestroyed() then
        self.collider:destroy()
    end
    self.alive = false
end

function GabeyK9Boss:onDeath()
    if not self.isPhantom then
        for _, obj in pairs(objects) do
            if obj.isPhantom then obj:destroy() end
        end
        -- TODO: mark this boss as defeated
        sounds.bossDead:play()
        spawnPortalToHubWorld(self.collider:getPosition())
    end
end
