Arrow = require('src.arrow')
Bow = require('src.bow')
Categories = require('src.categories')

Archer = {}

Archer.JUMP_STRENGTH = 60

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

function Archer:isOnGround()
  local px, py = self.body:getPosition()

  -- Search for contact with horizontal surfaces
  for key, contact in pairs(self.body:getContacts()) do
    local x1, y1, x2, y2 = contact:getPositions()
    if contact:isTouching() and x1 ~= nil and y1 ~= nil and x2 ~= nil and y2 ~= nil then
      local angle = math.abs(Util.angleBetween(x1, y1, x2, y2))
      -- 30º of difference are used to include slopes
      if angle < math.rad(180 + 30) and angle > math.rad(180 - 30) and py < y1 then
        return true
      end
    end
  end

  return false
end

function Archer:updateMovement(dt)
  local mx, my = 0, 0

  if love.keyboard.isDown('a') then mx = -1 end
  if love.keyboard.isDown('d') then mx =  1 end

  local dx = mx * dt * self.speed * love.physics.getMeter()
  local dy = my * dt * self.speed * love.physics.getMeter()

  self.body:applyLinearImpulse(dx, dy)

  if love.keyboard.isDown('space') and self:isOnGround() then
    self.body:applyLinearImpulse(0, -Archer.JUMP_STRENGTH)
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
    love.graphics.setColor(1, 0, 0, 1)
    for key, contact in pairs(self.body:getContacts()) do
      if contact:isTouching() then
        local x1, y1, x2, y2 = contact:getPositions()
        if x1 ~= nil and x2 ~= nil then
          love.graphics.line(x1, y1, x2, y2)
          Util.log(x2, y2, {
            angle = Util.angleBetween(x1, y1, x2, y2)
          })
        end
      end
    end
    love.graphics.setColor(1, 1, 1, 1)

    Util.log(cx, cy, {
      con = #self.body:getContacts(),
      fireDelay = self.bow.delay,
      fireStrength = self.bow.pullStrength,
      arrow = #self.bow.arrows,
      position = cx .. ', ' .. cy,
      rope = self.bow.rope and not self.bow.rope:isDestroyed() and self.bow.rope:getMaxLength() or 0,
      mass = self.body:getMass(),
      isOnGround = self:isOnGround() and 1 or 0
    })
  end
end

return Archer
