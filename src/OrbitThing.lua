Hammer = {}


--- @param sourceEntity table (entity)
--- @param targetEntity table (entity)
--- @param velocity number
--- @param maxLifetime number
--- @param damage number
--- @param radius number
--- @param linearDamping number
--- @param customUpdate function(self, dt)
--- @param customOnHit function(self)
--- @param customOnEndOfLife function(self)
--- @param debugColor table { r, g, b }
function Hammer:new(
        sourceEntity,
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
    if not sourceEntity then error("source entity must be set") end
    local object = {}
    setmetatable(object, self)
    self.__index = self

    local sx, sy = sourceEntity.collider:getPosition()
    local dx, dy, d
    local pvx, pvy = player.collider:getLinearVelocity()
--[[    if target.collider then]]
        local tx, ty = target.collider:getPosition()
        local dx, dy = tx + pvx - sx, ty + pvy - sy
        local d = math.sqrt(dx * dx + dy * dy)
--[[    elseif type(target.angle) == "number" then
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
    end]]
    local sourceR = sourceEntity.radius or 5

    object.type = "bullet"
    object.belongsToPlayer = sourceEntity.belongsToPlayer
    object.alive = true
    object.debugColor = { 1, 0.5, 0 }
    object.sourceEntity = sourceEntity
    object.targetEntity = target
    object.velocity = velocity
    object.maxLifetime = maxLifetime
    object.currLifetime = 0
    object.damage = damage
    object.radius = radius
    object.linearDamping = linearDamping
    object.customUpdate = customUpdate
    object.customOnHit = customOnHit
    object.customOnEndOfLife = customOnEndOfLife
    object.collider = world:newCircleCollider(sx + dx / d * sourceR, sy + dy / d * sourceR, radius)
    object.collider:setCollisionClass("enemyBullet")
    object.collider:setBullet(true)
    object.collider:setMass(1)
    object.collider:setRestitution(0.5)
    object.collider:setLinearDamping(linearDamping or 0)
    object.collider:setLinearVelocity(dx / d * velocity, dy / d * velocity)
    object.collider:setObject(object)
    -- TODO: add collision logic (deal damage and call customOnHit)

    table.insert(objects, object)
    return object
end

function Hammer:update(dt)
    if self.collider:enter(self.targetCollisionClass) then
        local collision = self.collider:getEnterCollisionData(self.targetCollisionClass)
        local hitObject = collision.collider:getObject()
        if hitObject and hitObject.damage then hitObject:damage(self.damage) end
        if self.customOnHit then self:customOnHit(hitObject) end
        return
    end
    if self.collider:stay("enemy") then
        local collision = self.collider:getStayCollisionData("enemy")
        local hitObject = collision.collider:getObject()
        if hitObject and hitObject.damage then hitObject:damage(self.damage) end
        if self.customOnHit then self:customOnHit(hitObject) end
        self:destroy()
        return
    end

    self.alive = true
    self.currLifetime = self.currLifetime + dt
    if self.currLifetime >= self.maxLifetime then
        self:destroy()
        if self.customOnEndOfLife then self:customOnEndOfLife() end
        return
    end
    if self.customUpdate then self:customUpdate(dt) end
end

function Hammer:destroy()
    self.collider:destroy()
    self.alive = false
end
