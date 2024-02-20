require("images")

require("TriggerArea")
require("Portal")
require("Bullet")
require("Player")
require("LostMekkaBoss")
require("someone1065Boss")

objects = {}
world = nil
player = nil
boss = nil

local function createNewWorld()
    local wf = require("libs/windfield")
    if world then world:destroy() end
    objects = {}
    player = nil
    boss = nil
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
    createPlayer()

    -- some generic test enemies to see how collisions work
    createTestEnemy(40, 0)
    createTestEnemy(80, 0)
    createTestEnemy(120, 0)

    -- some test boss instances
    boss = LostMekkaBoss:new(0, 80)
    someone1065Boss:new(120, 80)

    -- a test trigger area that damages the player while staying inside
    TriggerArea:new(
            200, 200, 30, nil,
            { player },
            function(_, dt)
                player:damage(dt * 10)
            end
    )

    -- a test portal that heals the player on enter
    Portal:new(
            -100, 0, 20,
            function() player.hp = player.hp + 666 end,
            "heal"
    )
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

function createPlayer(x, y)
    if player then error("cannot create new player: one already exists!") end
    x = x or 0
    y = y or 0
    scroll_x = x
    scroll_y = y
    player = Player:new(x, y)
end

function createHubWorld()
    createNewWorld()
    createPlayer()
    local portalSize = 30
    local portalDistance = 100
    Portal:new(
            -portalDistance, -portalDistance, portalSize,
            createIiiAaa123BossArenaWorld,
            "IiiAaa123"
    )
    Portal:new(
            -portalDistance, portalDistance, portalSize,
            createGabeyK9BossArenaWorld,
            "GabeyK9"
    )
    Portal:new(
            portalDistance, -portalDistance, portalSize,
            createSomeone1065BossArenaWorld,
            "Someone1065"
    )
    Portal:new(
            portalDistance, portalDistance, portalSize,
            createLostMekkaBossArenaWorld,
            "LostMekka"
    )
end

function createLostMekkaBossArenaWorld()
    createNewWorld()
    createPlayer()
    boss = LostMekkaBoss:new(0, 250)
end

function createSomeone1065BossArenaWorld()
    createNewWorld()
    createPlayer()
    boss = someone1065Boss:new(0, 250)
end

function createGabeyK9BossArenaWorld()
    -- TODO
end

function createIiiAaa123BossArenaWorld()
    -- TODO
end
