TriggerArea = {}


--- @param x number
--- @param y number
--- @param radius number
--- @param maxLifetime number doesnt despawn if this is nil
--- @param targets table list of entities or collision classes
--- @param onCollide function(self, dt, colliding entity, contact) gets called every frame there is a collision (both enter and stay events)
--- @param onEnter function(self, dt, colliding entity, contact) gets called on the enter collision event
--- @param onStay function(self, dt, colliding entity, contact) gets called on the stay collision event
--- @param onExit function(self, dt, colliding entity, contact) gets called on the exit collision event
--- @param customUpdate function(self, dt)
--- @param customOnEndOfLife function(self)
function TriggerArea:new(
    x,
    y,
    radius,
    maxLifetime,
    targets,
    onCollide,
    onEnter,
    onStay,
    onExit,
    customUpdate,
    customOnEndOfLife
)
    local object = {}
    setmetatable(object, self)
    self.__index = self

    object.type = "trigger"
    object.alive = true
    object.debugColor = { 0, 0.1, 1 }
    object.maxLifetime = maxLifetime
    object.currLifetime = 0
    object.radius = radius
    object.customUpdate = customUpdate
    object.onCollide = onCollide
    object.onEnter = onEnter
    object.onStay = onStay
    object.onExit = onExit
    object.customOnEndOfLife = customOnEndOfLife
    object.collider = world:newCircleCollider(x, y, object.radius)
    object.collider:setCollisionClass("trigger")
    object.collider:setType("kinematic")
    object.collider:setObject(object)

    object.targetCollisionClasses = {}
    for _, it in pairs(targets) do
        local class = it
        if type(it) ~= "string" then
            class = it.collider.collision_class
        end
        table.insert(object.targetCollisionClasses, class)
    end

    table.insert(objects, object)
    return object
end

function TriggerArea:update(dt)
    for _, class in pairs(self.targetCollisionClasses) do
        if (self.onCollide or self.onEnter) and self.collider:enter(class) then
            local data = self.collider:getEnterCollisionData(class)
            if self.onCollide then self:onCollide(dt, data.collider:getObject(), data.contact) end
            if self.onEnter then self:onEnter(dt, data.collider:getObject(), data.contact) end
        end
        if (self.onCollide or self.onExit) and self.collider:stay(class) then
            local dataList = self.collider:getStayCollisionData(class)
            for _, data in ipairs(dataList) do
                if self.onCollide then self:onCollide(dt, data.collider:getObject(), data.contact) end
                if self.onExit then self:onExit(dt, data.collider:getObject(), data.contact) end
            end
        end
        if self.onCollide and self.collider:exit(class) then
            local data = self.collider:getExitCollisionData(class)
            self:onCollide(dt, data.collider:getObject(), data.contact)
        end
    end

    if self.maxLifetime then
        self.currLifetime = self.currLifetime + dt
        if self.currLifetime >= self.maxLifetime then
            self:destroy()
            if self.customOnEndOfLife then self:customOnEndOfLife() end
            return
        end
    end

    if self.customUpdate then self:customUpdate(dt) end
end

function TriggerArea:destroy()
    self.collider:destroy()
    self.alive = false
end
