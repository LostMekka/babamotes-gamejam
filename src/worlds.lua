require("images")

require("TriggerArea")
require("Portal")
require("Bullet")
require("Player")
require("LostMekkaBoss")
require("someone1065Boss")

objects = {}
world = nil

local function createNewWorld()
    local wf = require("libs/windfield")
    if world then world:destroy() end
    objects = {}
    world = wf.newWorld()
    world:addCollisionClass("player")
    world:addCollisionClass("enemy")
    world:addCollisionClass("playerBullet", { ignores = { "playerBullet", "player" } })
    world:addCollisionClass("enemyBullet", { ignores = { "playerBullet", "enemyBullet", "enemy" } })
    world:addCollisionClass("trigger", { ignores = { "trigger", "player", "enemy", "playerBullet", "enemyBullet" } })
    return world
end

function setupTestWorld()
    createNewWorld()
    scroll_x = 0
    scroll_y = 0
    player = Player:new(0, 0)
    createTestEnemy(40, 0)
    createTestEnemy(80, 0)
    createTestEnemy(120, 0)

    -- TODO: only one boss should exist per world
    boss = LostMekkaBoss:new(0, 80)
    boss = someone1065Boss:new(120, 80)

    test_ground_1 = TriggerArea:new(
            200, 200, 30, nil,
            { player },
            function(_, dt)
                player:damage(dt * 10)
            end
    )

    portal = Portal:new(-100, 0, 20, function() player.hp = player.hp + 666 end)
end

function createTestEnemy(x, y)
    local self = {}
    self.type = "enemy"
    self.alive = true
    self.debugColor = { 1, 0, 0 }
    self.collider = world:newCircleCollider(x, y, 12)
    self.collider:setCollisionClass("enemy")
    self.collider:setLinearDamping(playerMovementDamping)
    self.collider:setObject(self)
    table.insert(objects, self)
    return self
end
