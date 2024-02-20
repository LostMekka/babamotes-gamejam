TimerArray = {}

function TimerArray:new()
    local o = {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function TimerArray:setTimer(name, time, recurring, callback)
    if type(name) ~= "string" then error("timer name must be a string") end
    if type(time) ~= "number" or time <= 0 then error("timer time must be a number and greater than zero") end
    if type(callback) ~= "function" then error("timer callback must be a function") end
    self[name] = { maxTime = time, time = time, recurring = recurring, callback = callback }
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
        timer.time = timer.time - dt
        if timer.time <= 0 then
            timer.callback()
            if timer.recurring then
                timer.time = timer.time + timer.maxTime
            else
                self[name] = nil
            end
        end
    end
end
