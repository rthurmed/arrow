Arrow = require('src.arrow')

Archer = {}

function Archer:new(world, x, y)
  local that = {}

  that.world = world
  that.x = x
  that.y = y

  that.h = 72
  that.w = 72

  that.speed = 200 -- pixel per second

  that.body = love.physics.newBody(that.world, x, y, "dynamic")
  that.shape = love.physics.newRectangleShape(that.w, that.h)
  that.fixture = love.physics.newFixture(that.body, that.shape)

  that.arrows = {}
  that.fireDelay = 1 -- seconds
  that.fireStrength = 0

  self.__index = self
  return setmetatable(that, self)
end

function Archer:updateMovement(dt)
  local mx, my = 0, 0

  if love.keyboard.isDown('w') then my = -1 end
  if love.keyboard.isDown('s') then my =  1 end
  if love.keyboard.isDown('a') then mx = -1 end
  if love.keyboard.isDown('d') then mx =  1 end

  self.x = self.x + mx * dt * self.speed
  self.y = self.y + my * dt * self.speed
end

function Archer:updateShooting(dt)
  if self.fireDelay > 0 then
    self.fireDelay = self.fireDelay - dt
    if self.fireDelay < 0 then
      self.fireDelay = 0
    end
  end

  if self.fireDelay <= 0 and love.mouse.isDown(1) then
    self.fireStrength = self.fireStrength + dt * 4
    if self.fireStrength > 1 then
      self.fireStrength = 1
    end
  end

  if self.fireStrength > 0 and not love.mouse.isDown(1) then
    local mousex, mousey = love.mouse.getPosition()
    table.insert(self.arrows, Arrow:new(World, self.x, self.y, mousex, mousey, self.fireStrength))
    self.fireStrength = 0
    self.fireDelay = 1
  end

  for key, arrow in pairs(self.arrows) do arrow:update(dt) end
end

function Archer:update(dt)
  self:updateMovement(dt)
  self:updateShooting(dt)
end

function Archer:draw()
  for key, arrow in pairs(self.arrows) do arrow:draw() end
  -- draw bow
  love.graphics.circle('fill', self.x, self.y, 20)
end

return Archer