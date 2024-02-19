function love.draw()
    -- love.graphics.print(scroll_x, 400-scroll_x, 300-scroll_y)
    for o,obj in pairs(objects) do
        love.graphics.rectangle("fill",obj.x-scroll_x,obj.y-scroll_y,24,24)
    end
end

function love.load()
    setup()
end

function love.update()
    local player = objects[1]
    dt = love.timer.getDelta()
    if love.keyboard.isScancodeDown("up","w") then
        player.y = player.y - dt*50
    end
    if love.keyboard.isScancodeDown("down","s") then
        player.y = player.y + dt*50
    end
    if love.keyboard.isScancodeDown("left","a") then
        player.x = player.x - dt*50
    end
    if love.keyboard.isScancodeDown("right","d") then
        player.x = player.x + dt*50
    end
    scroll_x = player.x - 400
    scroll_y = player.y - 300
end

function setup()
    objects = {}
    scroll_x = 0
    scroll_y = 0
    newobj("player",0,0) -- always make sure player is at position 1
    newobj("test",40,0)
end

function newobj(type,x,y)
    local newobj = {}
    newobj.type = type
    newobj.x = x
    newobj.y = y
    newobj.alive = true
    table.insert(objects,newobj)
end