Bullet = {}


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
function Bullet:new(
        sourceEntity,
        targetEntity,
        velocity,
        maxLifetime,
        damage,
        radius,
        linearDamping,
        customUpdate,
        customOnHit,
        customOnEndOfLife
)
    local object = {}
    setmetatable(object, self)
    self.__index = self

    local sx, sy = sourceEntity.collider:getPosition()
    local tx, ty = targetEntity.collider:getPosition()
    local dx, dy = tx - sx, ty - sy
    local d = math.sqrt(dx * dx + dy * dy)

    object.type = "bullet"
    object.belongsToPlayer = sourceEntity.belongsToPlayer
    object.alive = true
    object.debugColor = { 0.7, 0, 0.5 }
    object.sourceEntity = sourceEntity or error("aaa")
    object.targetEntity = targetEntity
    object.targetCollisionClass = targetEntity.collider.collision_class
    object.velocity = velocity
    object.maxLifetime = maxLifetime
    object.currLifetime = 0
    object.damage = damage
    object.radius = radius
    object.linearDamping = linearDamping
    object.customUpdate = customUpdate
    object.customOnHit = customOnHit
    object.customOnEndOfLife = customOnEndOfLife
    object.collider = world:newCircleCollider(sx, sy, radius) -- TODO: add some distance so not every shot comes from the center
    object.collider:setCollisionClass("enemyBullet")
    object.collider:setBullet(true)
    object.collider:setMass(1)
    object.collider:setRestitution(0.5)
    object.collider:setLinearDamping(linearDamping or 0)
    object.collider:setLinearVelocity(dx / d * velocity, dy / d * velocity)
    object.collider:setObject(object)

    table.insert(objects, object)
    return object
end

function Bullet:update(dt)
    if self.collider:enter(self.targetCollisionClass) then
        local collision = self.collider:getEnterCollisionData(self.targetCollisionClass)
        local hitObject = collision.collider:getObject()
        if hitObject.damage then hitObject:damage(self.damage) end
        self:destroy()
        if self.customOnHit then self:customOnHit() end
    end

    self.currLifetime = self.currLifetime + dt
    if self.currLifetime >= self.maxLifetime then
        self:destroy()
        if self.customOnEndOfLife then self:customOnEndOfLife() end
        return
    end

    if self.customUpdate then self:customUpdate(dt) end
end

function Bullet:destroy()
    self.collider:destroy()
    self.alive = false
end
