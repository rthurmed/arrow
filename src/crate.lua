Crate = {}

function Crate:new(world, x, y, h, w)
  local that = {}

  that.body = love.physics.newBody(world, x, y, "dynamic")
  that.shape = love.physics.newRectangleShape(h, w)
  that.fixture = love.physics.newFixture(that.body, that.shape)
  that.fixture:setCategory(Categories.prop)

  self.__index = self
  return setmetatable(that, self)
end

function Crate:update(dt)
end

function Crate:draw()
  love.graphics.push()
  love.graphics.translate(self.body:getPosition())
  love.graphics.polygon('line', self.shape:getPoints())
  love.graphics.pop()
end

return Crate