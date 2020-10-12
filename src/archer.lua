Arrow = require('src.arrow')
Bow = require('src.bow')
Categories = require('src.categories')

Archer = {}

Archer.JUMP_MAX_HEIGHT = 900

function Archer:new(world, x, y)
  local that = {}

  that.world = world

  that.h = 72
  that.w = 72

  -- TODO: Make the player be a standing rectangle, instead of a square

  that.speed = 1

  that.body = love.physics.newBody(that.world, x, y, "dynamic")
  that.shape = love.physics.newRectangleShape(that.w, that.h)
  that.fixture = love.physics.newFixture(that.body, that.shape)
  that.fixture:setCategory(Categories.player)
  that.fixture:setMask(Categories.ignore)

  that.flightTime = 0

  that.bow = nil

  self.__index = self
  return setmetatable(that, self)
end

function Archer:isOnAir()
  return #self.body:getContacts() == 0
end

function Archer:updateMovement(dt)
  local mx, my = 0, 0

  if love.keyboard.isDown('a') then mx = -1 end
  if love.keyboard.isDown('d') then mx =  1 end

  local dx = mx * dt * self.speed * love.physics.getMeter()
  local dy = my * dt * self.speed * love.physics.getMeter()

  self.body:applyLinearImpulse(dx, dy)

  if love.keyboard.isDown('space') and (not self:isOnAir() or self.flightTime > 0) then
    self.body:setY(self.body:getY() - Archer.JUMP_MAX_HEIGHT * dt)
    self.flightTime = self.flightTime + dt
  else
    self.flightTime = 0
  end
end

function Archer:update(dt)
  if self.bow == nil then
    self.bow = Bow:new(self.world, self)
  end

  self:updateMovement(dt)
  self.bow:update(dt)
end

function Archer:draw()
  local cx, cy = self.body:getWorldCenter()

  -- Move to debug when with sprites
  love.graphics.push()
  love.graphics.translate(self.body:getPosition())
  love.graphics.polygon('line', self.shape:getPoints())
  love.graphics.pop()

  self.bow:draw()

  if DEBUG then
    Util.log(cx, cy, {
      con = #self.body:getContacts(),
      fireDelay = self.bow.delay,
      fireStrength = self.bow.pullStrength,
      arrow = #self.bow.arrows,
      position = cx .. ', ' .. cy,
      rope = self.bow.rope and not self.bow.rope:isDestroyed() and self.bow.rope:getMaxLength() or 0,
      mass = self.body:getMass()
    })
  end
end

return Archer
