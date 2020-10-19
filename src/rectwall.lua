Categories = require('src.categories')

RectWall = {}

function RectWall:new(x, y, w, h)
  local that = {}

  that.body = love.physics.newBody(World, x, y, "static")
  that.shape = love.physics.newRectangleShape(w, h)
  that.fixture = love.physics.newFixture(that.body, that.shape)
  that.fixture:setCategory(Categories.wall)

  self.__index = self
  return setmetatable(that, self)
end

function RectWall:draw()
  love.graphics.push()
  love.graphics.translate(self.body:getPosition())
  love.graphics.polygon('line', self.shape:getPoints())
  love.graphics.pop()
end

return RectWall