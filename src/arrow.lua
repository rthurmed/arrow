Util = require('util')
Categories = require('src.categories')

Arrow = {}

Arrow.DECAY = math.rad(45)
Arrow.FORCE_DECELERATE = 1 -- per second
Arrow.MAX_FORCE = 20

function Arrow:new(world, x, y, dx, dy, strength)
  local that = {}

  that.world = world

  that.angle = math.atan2((dy - y), (dx - x))
  that.force = strength and strength * Arrow.MAX_FORCE or Arrow.MAX_FORCE

  that.flying = true

  that.dx = math.cos(that.angle) * that.force
  that.dy = math.sin(that.angle) * that.force

  that.h = 64
  that.w = 16

  that.animation = Util.newAnimation(love.graphics.newImage("assets/arrow.png"), that.w, that.h, 1 / 4)

  that.body = love.physics.newBody(that.world, x, y, "dynamic")
  that.shape = love.physics.newCircleShape(that.w / 2)
  that.fixture = love.physics.newFixture(that.body, that.shape)
  that.fixture:setCategory(Categories.arrow)
  that.fixture:setMask(Categories.player, Categories.arrow, Categories.ignore)

  that.body:setAngle(that.angle)
  that.body:applyLinearImpulse(that.dx, that.dy)

  that.joint = nil

  that.lastX = 0
  that.lastY = 0

  self.__index = self
  return setmetatable(that, self)
end

function Arrow:weld()
  local contact = self.body:getContacts()[1]
  local fixtureA, fixtureB = contact:getFixtures()
  local x1, y1, x2, y2 = contact:getPositions()
  if x1 ~= nil then
    self.joint = love.physics.newWeldJoint(fixtureA:getBody(), fixtureB:getBody(), x1, y1, false)
  end
end

function Arrow:update(dt)
  local ax, ay = self.body:getPosition()

  if self.flying and #self.body:getContacts() > 0 then
    self:weld()

    if self.joint ~= nil then
      self.flying = false
      self.fixture:setCategory(Categories.ignore)
    end
  end

  if not self.flying then
    return
  end

  local angle = math.atan2((ay - self.lastY), (ax - self.lastX))
  self.body:setAngle(angle)

  Util.advanceAnimationFrame(self.animation, dt)

  self.lastX, self.lastY = self.body:getPosition()
end

function Arrow:draw()
  local cx, cy = self.body:getPosition()
  local aimx, aimy = cx + self.dx / 2, cy + self.dy / 2
  local halfw = self.w / 2
  local rotation = self.body:getAngle() + math.rad(90)

  local spriteNum = math.floor(self.animation.currentTime / self.animation.duration * #self.animation.quads) + 1
  love.graphics.draw(self.animation.spriteSheet, self.animation.quads[spriteNum], cx, cy, rotation, 1, 1, halfw, halfw)

  if DEBUG then
    love.graphics.points(cx, cy)
    love.graphics.line(cx, cy, aimx, aimy)

    love.graphics.circle('line', cx, cy, self.w / 2)

    Util.log(cx, cy, {
      con = #self.body:getContacts(),
      force = self.force,
      flying = self.flying and 'flying' or 'not flying'
    })
  end
end

return Arrow
