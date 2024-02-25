function addHpComponentToEntity(entity, maxHp)
    entity.maxHp = maxHp
    entity.hp = maxHp
    function entity:damage(amount, isDoT)
        if self.filterDamage then
            local damageAccepted = self:filterDamage(amount, self.hp <= amount, isDoT)
            if not damageAccepted then return end
        end
        self.hp = self.hp - amount
        if self.hp <= 0 then
            self.hp = 0
            self.alive = false
            if self.onDeath then self:onDeath() end
            if not self.collider:isDestroyed() then self.collider:destroy() end
        else
            if self.onHit then self:onHit(amount, isDoT) end
        end
    end
end
