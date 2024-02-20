GroundObject = {}


--- @param sourceEntity table (entity)
--- @param targetEntities table (entities)
--- @param maxLifetime number
--- @param radius number
--- @param customUpdate function(self, dt)
--- @param customOnEndOfLife function(self)
function GroundObject:new(
    x,
    y,
    targetEntities,
    maxLifetime,
    radius,
    onCollide,
    customUpdate,
    -- customOnHit,
    customOnEndOfLife
)
    local object = {}
    setmetatable(object, self)
    self.__index = self

    object.type = "groundObject"
    object.alive = true
    object.debugColor = { 0, 0.1, 1 }
    object.targetEntities = targetEntities
    
    object.targetCollisionClasses = {}
    for e,entity in pairs(targetEntities) do
        table.insert(object.targetCollisionClasses, entity.collider.collision_class)
    end
    object.maxLifetime = maxLifetime
    object.currLifetime = 0
    object.radius = radius
    object.customUpdate = customUpdate
    object.onCollide = onCollide
    -- object.customOnHit = customOnHit
    object.customOnEndOfLife = customOnEndOfLife
    object.collider = world:newCircleCollider(x, y, radius) -- TODO: add some distance so not every shot comes from the center
    object.collider:setCollisionClass("groundObject")
    object.collider:setObject(object)

    table.insert(objects, object)
    return object
end

function GroundObject:update(dt)
    for c,class in pairs(self.targetCollisionClasses) do
        if self.collider:enter(class) then
            self:onCollide(class)
        end
    end

    self.currLifetime = self.currLifetime + dt
    if self.currLifetime >= self.maxLifetime then
        self:destroy()
        if self.customOnEndOfLife then self:customOnEndOfLife() end
        return
    end

    if self.customUpdate then self:customUpdate(dt) end
end

function GroundObject:destroy()
    self.collider:destroy()
    self.alive = false
end
