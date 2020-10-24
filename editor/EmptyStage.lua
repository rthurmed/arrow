Stage = require('src.stage')

EmptyStage = {}

function EmptyStage:new(world)
  local that = {}

  that.super = Stage:new(world)

  self.__index = self
  return setmetatable(that, self)
end

function EmptyStage:update(dt)
  self.super:update(dt)
end

function EmptyStage:draw()
  self.super:draw()
end

function EmptyStage:start()
  self.super:start()
end

function EmptyStage:kill()
  self.super:kill()
end

return EmptyStage