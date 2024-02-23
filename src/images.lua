local images = {}

function drawimage(path, x, y, sx_, sy_)
    local sx = sx_ or 1
    local sy = sy_ or sx
    local image = loadImage(path)
    love.graphics.draw(image, x, y, 0, sx, sy)
end

function loadImage(path)
    if images[path] then return images[path] end
    local image = love.graphics.newImage(path)
    images[path] = image
    return image
end
