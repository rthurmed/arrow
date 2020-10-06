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
  that.shape = love.physics.newRectangleShape(that.w, that.w)
  that.fixture = love.physics.newFixture(that.body, that.shape)
  that.fixture:setCategory(Categories.arrow)
  that.fixture:setMask(Categories.player)

  that.body:applyLinearImpulse(that.dx, that.dy)

  self.__index = self
  return setmetatable(that, self)
end

function Arrow:update(dt)
  if self.flying and #self.body:getContacts() > 0 then
    self.flying = false
  end

  if not self.flying then
    return
  end

  self.angle = self.angle + Arrow.DECAY * dt
  Util.advanceAnimationFrame(self.animation, dt)
end

function Arrow:draw()
  local cx, cy = self.body:getPosition()
  local aimx, aimy = cx + self.dx / 2, cy + self.dy / 2
  local halfw = self.w / 2
  local rotation = self.angle + math.rad(90)

  local spriteNum = math.floor(self.animation.currentTime / self.animation.duration * #self.animation.quads) + 1
  love.graphics.draw(self.animation.spriteSheet, self.animation.quads[spriteNum], cx, cy, rotation, 1, 1, halfw, halfw)

  if DEBUG then
    love.graphics.points(cx, cy)
    love.graphics.line(cx, cy, aimx, aimy)

    love.graphics.push()
    love.graphics.translate(self.body:getPosition())
    love.graphics.polygon('line', self.shape:getPoints())
    love.graphics.pop()

    Util.log(cx, cy, {
      con = #self.body:getContacts(),
      force = self.force,
      flying = self.flying and 'flying' or 'not flying'
    })
  end
end

return Arrow
