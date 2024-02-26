Sickle = {}


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
function Sickle:new(
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
    object.debugColor = { 0.3, 0.3, 0.3 }
    object.sourceEntity = sourceEntity or error("aaa")
    object.targetEntity = targetEntity
    object.targetCollisionClass = targetEntity.collider.collision_class
    object.velocity = velocity
    object.maxLifetime = maxLifetime
    object.currLifetime = 0
    object.damage = damage
    object.radius = radius
    object.collider = world:newPolygonCollider({-40,-40,40,-40,40,40,-40,40,0,60,60,60,60,-60,0,-60})
    object.collider:setCollisionClass("enemyBullet")
    object.collider:setType("kinematic")
    object.collider:setObject(object)

    table.insert(objects, object)
    return object
end

function Sickle:update(dt)
    if not self.collider then
        return 0
    end
    if self.collider:enter(self.targetCollisionClass) then
        local collision = self.collider:getEnterCollisionData(self.targetCollisionClass)
        local hitObject = collision.collider:getObject()
        if hitObject.damage then hitObject:damage(self.damage) end
        if self.customOnHit then self:customOnHit() end
    end

    if self.customUpdate then self:customUpdate(dt) end

    love.graphics.polygon("fill",{-40,-40,40,-40,40,40,-40,40,0,60,60,60,60,-60,0,-60})
end
