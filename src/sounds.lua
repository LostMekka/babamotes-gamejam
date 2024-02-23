PolyVoiceSound = {}
function PolyVoiceSound:new(path, defaultVolume)
    local o = {}
    setmetatable(o, self)
    self.__index = self
    o.sources = {}
    o.index = 1
    o.defaultVolume = defaultVolume or 1
    for _ = 1, 10 do
        table.insert(o.sources, love.audio.newSource(path, "static"))
    end
    return o
end

function PolyVoiceSound:play(volume)
    local sound = self.sources[self.index]
    sound:setVolume(volume or self.defaultVolume)
    sound:play()
    self.index = self.index + 1
    if self.index > #self.sources then self.index = 1 end
end
