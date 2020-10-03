Arrow = {}

Arrow.DECAY = math.rad(30)
Arrow.MAX_FORCE = 3000

function Arrow:new(world, x, y, dx, dy, strength)
  local that = {}

  that.world = world

  that.angle = math.atan2((dy - y), (dx - x))
  that.force = strength and strength * Arrow.MAX_FORCE or Arrow.MAX_FORCE

  that.dx = math.cos(that.angle) * that.force
  that.dy = math.sin(that.angle) * that.force

  that.h = 137
  that.w = 17

  that.body = love.physics.newBody(that.world, x, y, "dynamic")
  that.body:setMassData(8, 137, that.body:getMass(), that.body:getInertia())
  that.shape = love.physics.newRectangleShape(that.w, that.h)
  that.fixture = love.physics.newFixture(that.body, that.shape)

  that.image = love.graphics.newImage('assets/arrow.png')

  self.__index = self
  return setmetatable(that, self)
end

function Arrow:update(dt)
  local x, y = self.body:getPosition()

  self.angle = self.angle + Arrow.DECAY * dt
  self.dx = math.cos(self.angle) * self.force
  self.dy = math.sin(self.angle) * self.force

  self.body:setX(x + (self.dx * dt))
  self.body:setY(y + (self.dy * dt))
end

function Arrow:draw()
  local cx, cy = self.body:getPosition()
  local nx, ny = cx + self.dx / 2, cy + self.dy / 2
  local rotation = self.angle + math.rad(90)

  love.graphics.draw(self.image, cx, cy, rotation, 1, 1)

  if DEBUG then
    love.graphics.points(cx, cy)
    love.graphics.line(cx, cy, nx, ny)
  end
end

return Arrow
