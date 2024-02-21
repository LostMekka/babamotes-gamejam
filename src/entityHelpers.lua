function addHpComponentToEntity(entity, maxHp, customOnDamage, customOnDeath)
    entity.maxHp = maxHp
    entity.hp = maxHp
    function entity:damage(amount)
        self.hp = self.hp - amount
        if customOnDamage then customOnDamage(self, amount) end
        if self.hp <= 0 then
            self.hp = 0
            self.alive = false
            if customOnDeath then customOnDeath(self) end
            if not self.collider:isDestroyed() then self.collider:destroy() end
        end
    end
end
