Util = {}

-- https://www.love2d.org/wiki/Tutorial:Animation
function Util.newAnimation(image, width, height, duration)
  local animation = {}
  animation.spriteSheet = image;
  animation.quads = {};

  for y = 0, image:getHeight() - height, height do
      for x = 0, image:getWidth() - width, width do
          table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
      end
  end

  animation.duration = duration or 1
  animation.currentTime = 0

  return animation
end

function Util.advanceAnimationFrame(animation, time)
  animation.currentTime = animation.currentTime + time
  if animation.currentTime >= animation.duration then
    animation.currentTime = animation.currentTime - animation.duration
  end
end

function Util.distance(x1, y1, x2, y2)
  local dx = x1 - x2
  local dy = y1 - y2
  return math.sqrt (dx * dx + dy * dy)
end

function Util.angleBetween(x1, y1, x2, y2)
  return math.atan2((y2 - y1), (x2 - x1))
end

function Util.log(x, y, table)
  local i = 0
  for key, value in pairs(table) do
    love.graphics.print(key .. ': ' .. value, x, y + i * 15)
    i = i + 1
  end
end

return Util
