TimerArray = {}

function TimerArray:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function TimerArray:setTimer(name, time, count, callback)
    if type(name) ~= "string" then error("timer name must be a string") end
    if type(time) ~= "number" or time <= 0 then error("timer time must be a number and greater than zero") end
    if type(callback) ~= "function" then error("timer callback must be a function") end
    self[name] = { maxTime = time, time = 0, count = count, callback = callback }
end

function TimerArray:updateTimer(name, time, count, callback)
    if type(name) ~= "string" then error("timer name must be a string") end
    if time ~= nil and (type(time) ~= "number" or time <= 0) then error("timer time must be a number and greater than zero") end
    if callback ~= nil and type(callback) ~= "function" then error("timer callback must be a function") end
    local timer = self[name]
    if not timer then return end
    if time then
        timer.maxTime = time
        if timer.time > timer.maxTime then timer.time = timer.maxTime end
    end
    if type(count) == "number" then timer.count = count end
    if callback then timer.callback = callback end
end

function TimerArray:clearTimer(name)
    local timer = self[name]
    self[name] = nil
    return timer ~= nil
end

function TimerArray:clearAll()
    for name, _ in pairs(self) do
        self[name] = nil
    end
end

function TimerArray:hasTimer(name)
    return self[name] ~= nil
end

function TimerArray:getTimeLeft(name)
    local timer = self[name]
    if not timer then return nil end
    return timer.time
end

function TimerArray:update(dt)
    for name, timer in pairs(self) do
        timer.time = timer.time + dt
        if timer.time >= timer.maxTime then
            timer.callback()
            timer.time = timer.time - timer.maxTime
            if timer.count > 1 then
                timer.count = timer.count - 1
            elseif timer.count > 0 then
                self[name] = nil
            end
        end
    end
end
