function addHpComponentToEntity(entity, maxHp)
    entity.maxHp = maxHp
    entity.hp = maxHp
    function entity:damage(amount)
        self.hp = self.hp - amount
        if self.onDamageBeforeHealthCheck then self:onDamageBeforeHealthCheck(amount) end
        if self.hp <= 0 then
            self.hp = 0
            self.alive = false
            if self.onDeath then self:onDeath() end
            if not self.collider:isDestroyed() then self.collider:destroy() end
        end
    end
end
