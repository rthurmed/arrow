Arrow = require('src.arrow')
Categories = require('src.categories')

Archer = {}

Archer.ROPE_PULL_SPEED = 800
Archer.ROPE_MIN_LENGTH = 100
Archer.ROPE_MAX_LENGTH = 1200
Archer.JUMP_MAX_HEIGHT = 900

Archer.STRENGTH_PULL_TIME = 1 -- seconds for max power

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

  that.bow = {
    i0 = love.graphics.newImage('assets/bow0.png'),
    i50 = love.graphics.newImage('assets/bow50.png'),
    i100 = love.graphics.newImage('assets/bow100.png')
  }

  that.arrows = {}
  that.fireDelay = 1 -- seconds
  that.fireStrength = 0

  that.flightTime = 0

  that.rope = nil
  that.lastArrow = nil
  that.isRopeArrowFlying = false

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

function Archer:updateRope(dt)
  local ry = 0

  if love.keyboard.isDown('w') then ry = -1 end
  if love.keyboard.isDown('s') then ry =  1 end

  if love.keyboard.isDown('q') and self.rope ~= nil and not self.rope:isDestroyed() then
    self.rope:destroy()
    self.isRopeArrowFlying = false
  end

  if self.rope ~= nil and not self.rope:isDestroyed() then
    local nlen = self.rope:getMaxLength() + ry * dt * Archer.ROPE_PULL_SPEED

    if nlen < Archer.ROPE_MIN_LENGTH then
      nlen = Archer.ROPE_MIN_LENGTH
    end

    if nlen > Archer.ROPE_MAX_LENGTH then
      nlen = Archer.ROPE_MAX_LENGTH
    end

    self.rope:setMaxLength(nlen)

    -- Executed when the rope arrow weld itself to a wall
    if self.isRopeArrowFlying and not self.lastArrow.flying then
      local px, py = self.body:getPosition()
      local ax, ay = self.lastArrow.body:getPosition()
      local distance = Util.distance(px, py, ax, ay)

      self.rope:setMaxLength(distance)
      self.isRopeArrowFlying = false
    end
  end
end

function Archer:updateShooting(dt)
  if self.fireDelay > 0 then
    self.fireDelay = self.fireDelay - dt
    if self.fireDelay < 0 then
      self.fireDelay = 0
    end
  end

  if self.fireDelay <= 0 and love.mouse.isDown(1) then
    self.fireStrength = self.fireStrength + dt
    if self.fireStrength > Archer.STRENGTH_PULL_TIME then
      self.fireStrength = Archer.STRENGTH_PULL_TIME
    end
  end

  if self.fireStrength > 0 and not love.mouse.isDown(1) then
    local mousex, mousey = GetRelativeMouse()
    local playerx, playery = self.body:getWorldCenter()

    local arrow = Arrow:new(World, playerx, playery, mousex, mousey, self.fireStrength / Archer.STRENGTH_PULL_TIME)
    table.insert(self.arrows, arrow)

    self.lastArrow = arrow
    self.isRopeArrowFlying = true

    if self.rope ~= nil and not self.rope:isDestroyed() then
      self.rope:destroy()
    end

    self.rope = love.physics.newRopeJoint(self.body, arrow.body, playerx, playery, playerx, playery, 1000, false)

    self.fireStrength = 0
    self.fireDelay = 1
  end

  for key, arrow in pairs(self.arrows) do arrow:update(dt) end
end

function Archer:update(dt)
  self:updateMovement(dt)
  self:updateRope(dt)
  self:updateShooting(dt)
end

function Archer:draw()
  local cx, cy = self.body:getWorldCenter()
  local mx, my = GetRelativeMouse()
  local halfw = self.w / 2
  local angle = math.atan2((my - cy), (mx - cx)) + math.rad(45)

  for key, arrow in pairs(self.arrows) do arrow:draw() end

  -- Move to debug when with sprites
  love.graphics.push()
  love.graphics.translate(self.body:getPosition())
  love.graphics.polygon('line', self.shape:getPoints())
  love.graphics.pop()

  local bowImage = self.bow.i0

  if self.fireStrength > 1 / 2 then
    bowImage = self.bow.i50
  end

  if self.fireStrength >= 1 then
    bowImage = self.bow.i100
  end

  love.graphics.draw(bowImage, cx, cy, angle, 1, 1, halfw, halfw)

  if self.rope ~= nil and not self.rope:isDestroyed() then
    love.graphics.line(self.rope:getAnchors())
  end

  if DEBUG then
    Util.log(cx, cy, {
      con = #self.body:getContacts(),
      fireDelay = self.fireDelay,
      fireStrength = self.fireStrength,
      arrow = #self.arrows,
      position = cx .. ', ' .. cy,
      rope = self.rope and not self.rope:isDestroyed() and self.rope:getMaxLength() or 0,
      mass = self.body:getMass()
    })
  end
end

return Archer
