Arrow = require('src.arrow')
Categories = require('src.categories')

Archer = {}

Archer.ROPE_PULL_SPEED = 400
Archer.ROPE_MIN_LENGTH = 100
Archer.ROPE_MAX_LENGTH = 1200
Archer.JUMP_MAX_HEIGHT = 1000

function Archer:new(world, x, y)
  local that = {}

  that.world = world

  that.h = 72
  that.w = 72

  that.speed = 100

  that.body = love.physics.newBody(that.world, x, y, "dynamic")
  that.shape = love.physics.newRectangleShape(that.w, that.h)
  that.fixture = love.physics.newFixture(that.body, that.shape)
  that.fixture:setCategory(Categories.player)

  that.bow = {
    i0 = love.graphics.newImage('assets/bow0.png'),
    i50 = love.graphics.newImage('assets/bow50.png'),
    i100 = love.graphics.newImage('assets/bow100.png')
  }

  that.arrows = {}
  that.fireDelay = 1 -- seconds
  that.fireStrength = 0

  that.rope = nil

  self.__index = self
  return setmetatable(that, self)
end

function Archer:updateMovement(dt)
  local mx, my, ry = 0, 0 , 0

  if love.keyboard.isDown('w') then ry = -1 end
  if love.keyboard.isDown('s') then ry =  1 end
  if love.keyboard.isDown('a') then mx = -1 end
  if love.keyboard.isDown('d') then mx =  1 end

  local dx = mx * dt * self.speed
  local dy = my * dt * self.speed

  self.body:applyLinearImpulse(dx, dy)

  if love.keyboard.isDown('space') then
    self.body:setY(self.body:getY() - Archer.JUMP_MAX_HEIGHT * dt)
  end

  if love.keyboard.isDown('q') and self.rope ~= nil and not self.rope:isDestroyed() then
    self.rope:destroy()
  end

  if self.rope ~= nil and not self.rope:isDestroyed() then
    local nlen = self.rope:getMaxLength() + ry * dt * Archer.ROPE_PULL_SPEED

    if nlen > Archer.ROPE_MIN_LENGTH and nlen < Archer.ROPE_MAX_LENGTH then
      self.rope:setMaxLength(nlen)
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
    self.fireStrength = self.fireStrength + dt * 4
    if self.fireStrength > 1 then
      self.fireStrength = 1
    end
  end

  if self.fireStrength > 0 and not love.mouse.isDown(1) then
    local mousex, mousey = GetRelativeMouse()
    local playerx, playery = self.body:getWorldCenter()

    local arrow = Arrow:new(World, playerx, playery, mousex, mousey, self.fireStrength)
    table.insert(self.arrows, arrow)

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
      rope = self.rope and not self.rope:isDestroyed() and self.rope:getMaxLength() or 0
    })
  end
end

return Archer
