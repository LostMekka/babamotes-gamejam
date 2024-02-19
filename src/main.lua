function love.draw()
    -- love.graphics.print(scroll_x, 400-scroll_x, 300-scroll_y)
    for o,obj in pairs(objects) do
        love.graphics.rectangle("fill",obj.x-scroll_x,obj.y-scroll_y,24,24)
    end
end
