ActionSequence = {}
ActionSequenceContext = {}

function ActionSequenceContext:new()
    local object = { dt = 0 }
    setmetatable(object, self)
    self.__index = self
    return object
end

local function traceback(removeFirst, removeLast)
    local trace = debug.traceback()
    local lines = {}
    for line in trace:gmatch("[^\r\n]+") do table.insert(lines, line) end
    for _ = 1, removeFirst + 1 do table.remove(lines, 1) end
    for _ = 1, removeLast do table.remove(lines) end
    return table.concat(lines, "\n")
end

function ActionSequence:new(sequence, onFinish)
    local object = {}
    setmetatable(object, self)
    self.__index = self
    object.context = ActionSequenceContext:new()
    object.co = coroutine.create(function()
        local status, error = xpcall(
                function() sequence(object.context) end,
                function(error)
                    object.context.errorStackTrace = traceback(2, 3)
                    return error
                end
        )
        if not status then object.context.error = error end
    end)
    object.onFinish = onFinish
    return object
end

function ActionSequence:update(dt)
    if self:isFinished() then return dt end
    self.context.dt = dt

    local result, message = coroutine.resume(self.co)
    if self.context.errorStackTrace then
        local mainTrace = traceback(1, 0)
        local fullTrace = "in coroutine:\n\n" .. self.context.errorStackTrace .. "\n\nin main thread:\n\n" .. mainTrace
        -- please forgive me
        debug.traceback = function() return fullTrace end
        error(self.context.error, 0)
    end
    if not result then error(message) end

    if self.onFinish and self:isFinished() then self:onFinish() end
    return self.context.dt
end

function ActionSequence:isFinished()
    return coroutine.status(self.co) == "dead"
end

function ActionSequenceContext:delay(duration)
    if not duration or duration <= 0 then
        self.dt = 0
        coroutine.yield()
        return
    end
    local t = duration
    while true do
        if t > self.dt then
            t = t - self.dt
            self.dt = 0
            coroutine.yield()
        else
            self.dt = self.dt - t
            return
        end
    end
end
