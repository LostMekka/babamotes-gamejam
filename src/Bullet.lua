Bullet = {}


--- @param sourceEntity table entity
--- @param targetEntity table entity or { x, y }
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
        customOnEndOfLife,
        debugColor
)
    if not sourceEntity then error("source entity must be set") end
    local object = {}
    setmetatable(object, self)
    self.__index = self

    local tx, ty
    if targetEntity.collider then
        tx, ty = targetEntity.collider:getPosition()
    else
        tx, ty = targetEntity.x, targetEntity.y
    end
    local sx, sy = sourceEntity.collider:getPosition()
    local dx, dy = tx - sx, ty - sy
    local d = math.sqrt(dx * dx + dy * dy)
    if d == 0 then
        print("warning: bullet created with source position == target position. falling back to 0 degree shooting angle")
        d = 1
        dx = 1
        dy = 0
    end
    
    object = Bullet:new_dir(
        sourceEntity,
        (dx / d * velocity),
        (dy / d * velocity),
        maxLifetime,
        damage,
        radius,
        linearDamping,
        customUpdate,
        customOnHit,
        customOnEndOfLife,
        debugColor
)
    return object
end

function Bullet:new_dir(
    sourceEntity,
    velocityX,
    velocityY,
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

local velocity = math.sqrt(math.pow(velocityX, 2) + math.pow(velocityY, 2))

local sx, sy = sourceEntity.collider:getPosition()
local sourceR = sourceEntity.radius or 5

object.type = "bullet"
object.belongsToPlayer = sourceEntity.belongsToPlayer
object.alive = true
object.debugColor = { 0.7, 0, 0.5 }
if debugColor ~= nil then object.debugColor = debugColor end
object.sourceEntity = sourceEntity
object.targetEntity = targetEntity
object.velocity = velocity
object.maxLifetime = maxLifetime
object.currLifetime = 0
object.damage = damage
object.radius = radius
object.linearDamping = linearDamping
object.customUpdate = customUpdate
object.customOnHit = customOnHit
object.customOnEndOfLife = customOnEndOfLife
object.collider = world:newCircleCollider(sx + velocityX / velocity * sourceR, sy + velocityY / velocity * sourceR, radius)
object.collider:setBullet(true)
object.collider:setMass(1)
object.collider:setRestitution(0.5)
object.collider:setLinearDamping(linearDamping or 0)
object.collider:setLinearVelocity(velocityX, velocityY)
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
