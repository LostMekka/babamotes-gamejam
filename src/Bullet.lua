Bullet = {}


--- @param source table entity or { x: number, y: number, radius: number?, belongsToPlayer: boolean }
--- @param target table entity or { x: number, y: number } or { angle: number (in radians) }
--- @param velocity number
--- @param maxLifetime number
--- @param damage number
--- @param radius number
--- @param linearDamping number
--- @param customUpdate function(self, dt)
--- @param customOnHit function(self)
--- @param customOnEndOfLife function(self)
--- @param debugColor table { r, g, b }
function Bullet:new(
        source,
        target,
        velocity,
        maxLifetime,
        damage,
        radius,
        linearDamping,
        customUpdate,
        customOnHit,
        customOnEndOfLife,
        debugColor
)
    if not source then error("source must be set") end
    if not target then error("target must be set") end
    local object = {}
    setmetatable(object, self)
    self.__index = self

    local sx, sy
    if source.collider then
        sx, sy = source.collider:getPosition()
    else
        sx, sy = source.x, source.y
    end
    local dx, dy, d
    if target.collider then
        local tx, ty = target.collider:getPosition()
        dx, dy = tx - sx, ty - sy
        d = math.sqrt(dx * dx + dy * dy)
    elseif type(target.angle) == "number" then
        dx = math.cos(target.angle)
        dy = math.sin(target.angle)
        d = 1
    else
        local tx, ty = target.x, target.y
        dx, dy = tx - sx, ty - sy
        d = math.sqrt(dx * dx + dy * dy)
    end
    if d == 0 then
        print("warning: bullet created with source position == target position. falling back to 0 degree shooting angle")
        d = 1
        dx = 1
        dy = 0
    end
    local sourceR = source.radius or 5

    object.type = "bullet"
    object.belongsToPlayer = source.belongsToPlayer
    object.alive = true
    object.debugColor = debugColor or { 0.7, 0, 0.5 }
    object.sourceEntity = source
    object.targetEntity = target
    object.velocity = velocity
    object.maxLifetime = maxLifetime
    object.currLifetime = 0
    object.damage = damage
    object.radius = radius
    object.linearDamping = linearDamping or 0
    object.customUpdate = customUpdate
    object.customOnHit = customOnHit
    object.customOnEndOfLife = customOnEndOfLife
    object.collider = world:newCircleCollider(sx + dx / d * sourceR, sy + dy / d * sourceR, radius)
    object.collider:setBullet(true)
    object.collider:setMass(1)
    object.collider:setRestitution(0.5)
    object.collider:setLinearDamping(linearDamping or 0)
    object.collider:setLinearVelocity(dx / d * velocity, dy / d * velocity)
    object.collider:setObject(object)

    if object.belongsToPlayer then
        object.collider:setCollisionClass("playerBullet")
        object.targetCollisionClass = "enemy"
    else
        object.collider:setCollisionClass("enemyBullet")
        object.targetCollisionClass = "player"
    end

    table.insert(objects, object)
    return object
end

function Bullet:update(dt)
    if self.collider:enter(self.targetCollisionClass) then
        local collision = self.collider:getEnterCollisionData(self.targetCollisionClass)
        local hitObject = collision.collider:getObject()
        -- i encountered a weird bug where hitObject was nil. this should never happen, dunno where that came from.
        -- anyways, better to check that it exists here...
        if hitObject and hitObject.damage then hitObject:damage(self.damage) end
        if self.customOnHit then self:customOnHit() end
        self:destroy()
        return
    end

    self.currLifetime = self.currLifetime + dt
    if self.currLifetime >= self.maxLifetime then
        if self.customOnEndOfLife then self:customOnEndOfLife() end
        self:destroy()
        return
    end

    if self.customUpdate then self:customUpdate(dt) end
end

function Bullet:destroy()
    if not self.collider:isDestroyed() then
        self.collider:destroy()
    end
    self.alive = false
end
