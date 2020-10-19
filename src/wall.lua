Categories = require('src.categories')

Wall = {}

function Wall:new(x1, y1, x2, y2)
  local that = {}

  that.body = love.physics.newBody(World, 0, 0, "static")
  that.shape = love.physics.newEdgeShape(x1, y1, x2, y2)
  that.fixture = love.physics.newFixture(that.body, that.shape)
  that.fixture:setCategory(Categories.wall)

  self.__index = self
  return setmetatable(that, self)
end

function Wall:draw()
  love.graphics.line(self.shape:getPoints())
end

return Wall