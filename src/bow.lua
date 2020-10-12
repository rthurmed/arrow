Bow = {}

Bow.ROPE_PULL_SPEED = 800
Bow.ROPE_MIN_LENGTH = 100
Bow.ROPE_MAX_LENGTH = 1200

Bow.STRENGTH_PULL_TIME = 1 -- seconds for max power

function Bow:new(world, player)
  local that = {}

  that.world = world
  that.player = player

  that.image = {
    i0 = love.graphics.newImage('assets/bow0.png'),
    i50 = love.graphics.newImage('assets/bow50.png'),
    i100 = love.graphics.newImage('assets/bow100.png')
  }

  that.arrows = {}
  that.delay = 1 -- seconds
  that.pullStrength = 0

  that.rope = nil
  that.lastArrow = nil
  that.isRopeArrowFlying = false

  self.__index = self
  return setmetatable(that, self)
end

function Bow:updateRope(dt)
  local ry = 0

  if love.keyboard.isDown('w') then ry = -1 end
  if love.keyboard.isDown('s') then ry =  1 end

  if love.keyboard.isDown('q') and self.rope ~= nil and not self.rope:isDestroyed() then
    self.rope:destroy()
    self.isRopeArrowFlying = false
  end

  if self.rope ~= nil and not self.rope:isDestroyed() then
    local nlen = self.rope:getMaxLength() + ry * dt * Bow.ROPE_PULL_SPEED

    if nlen < Bow.ROPE_MIN_LENGTH then
      nlen = Bow.ROPE_MIN_LENGTH
    end

    if nlen > Bow.ROPE_MAX_LENGTH then
      nlen = Bow.ROPE_MAX_LENGTH
    end

    self.rope:setMaxLength(nlen)

    -- Executed when the rope arrow weld itself to a wall
    if self.isRopeArrowFlying and not self.lastArrow.flying then
      local px, py = self.player.body:getPosition()
      local ax, ay = self.lastArrow.body:getPosition()
      local distance = Util.distance(px, py, ax, ay)

      self.rope:setMaxLength(distance)
      self.isRopeArrowFlying = false
    end
  end
end

function Bow:update(dt)
  self:updateRope(dt)

  -- Update delay
  if self.delay > 0 then
    self.delay = self.delay - dt
    if self.delay < 0 then
      self.delay = 0
    end
  end

  -- Update pull strength
  if self.delay <= 0 and love.mouse.isDown(1) then
    self.pullStrength = self.pullStrength + dt
    if self.pullStrength > Bow.STRENGTH_PULL_TIME then
      self.pullStrength = Bow.STRENGTH_PULL_TIME
    end
  end

  -- Fire action
  if self.pullStrength > 0 and not love.mouse.isDown(1) then
    local mousex, mousey = GetRelativeMouse()
    local playerx, playery = self.player.body:getWorldCenter()

    -- Create the arrow
    local arrow = Arrow:new(World, playerx, playery, mousex, mousey, self.pullStrength / Bow.STRENGTH_PULL_TIME)
    table.insert(self.arrows, arrow)

    self.lastArrow = arrow
    self.isRopeArrowFlying = true

    -- Attach the rope
    if self.rope ~= nil and not self.rope:isDestroyed() then
      self.rope:destroy()
    end

    self.rope = love.physics.newRopeJoint(self.player.body, arrow.body, playerx, playery, playerx, playery, 1000, false)

    self.pullStrength = 0
    self.delay = 1
  end

  for key, arrow in pairs(self.arrows) do arrow:update(dt) end
end

function Bow:draw()
  local cx, cy = self.player.body:getWorldCenter()
  local mx, my = GetRelativeMouse()
  local halfw = self.player.w / 2
  local angle = math.atan2((my - cy), (mx - cx)) + math.rad(45)

  for key, arrow in pairs(self.arrows) do arrow:draw() end

  local bowImage = self.image.i0

  if self.pullStrength > 1 / 2 then
    bowImage = self.image.i50
  end

  if self.pullStrength >= 1 then
    bowImage = self.image.i100
  end

  love.graphics.draw(bowImage, cx, cy, angle, 1, 1, halfw, halfw)

  if self.rope ~= nil and not self.rope:isDestroyed() then
    love.graphics.line(self.rope:getAnchors())
  end
end

return Bow