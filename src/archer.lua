Arrow = require('src.arrow')

Archer = {}

function Archer:new(world, x, y)
  local that = {}

  that.world = world

  that.h = 72
  that.w = 72

  that.speed = 200 -- pixel per second

  that.body = love.physics.newBody(that.world, x, y, "dynamic")
  that.shape = love.physics.newRectangleShape(that.w, that.h)
  that.fixture = love.physics.newFixture(that.body, that.shape)

  that.bow = {
    i0 = love.graphics.newImage('assets/bow0.png'),
    i50 = love.graphics.newImage('assets/bow50.png'),
    i100 = love.graphics.newImage('assets/bow100.png')
  }

  that.arrows = {}
  that.fireDelay = 1 -- seconds
  that.fireStrength = 0

  self.__index = self
  return setmetatable(that, self)
end

function Archer:updateMovement(dt)
  local mx, my = 0, 0

  -- if love.keyboard.isDown('w') then my = -1 end
  -- if love.keyboard.isDown('s') then my =  1 end
  if love.keyboard.isDown('a') then mx = -1 end
  if love.keyboard.isDown('d') then mx =  1 end

  self.body:setX(self.body:getX() + (mx * dt * self.speed))
  self.body:setY(self.body:getY() + (my * dt * self.speed))
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

    table.insert(self.arrows, Arrow:new(World, playerx, playery, mousex, mousey, self.fireStrength))

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
  love.graphics.rectangle('line', cx, cy, self.w, self.h)
  -- self.body:getX(), self.body:getY()

  local bowImage = self.bow.i0

  if self.fireStrength > 1 / 2 then
    bowImage = self.bow.i50
  end

  if self.fireStrength >= 1 then
    bowImage = self.bow.i100
  end

  love.graphics.draw(bowImage, cx, cy, angle, 1, 1, halfw, halfw)
end

return Archer
