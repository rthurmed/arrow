Stage = {}

function Stage:new(world)
  local that = {}

  that.world = world

  that.walls = {}
  that.rectWalls = {}
  that.crates = {}

  that.player = nil

  self.__index = self
  return setmetatable(that, self)
end

function Stage:update(dt)
  self.player:update(dt)
end

function Stage:draw()
  for key, wall in pairs(self.walls) do wall:draw() end
  for key, crate in pairs(self.crates) do crate:draw() end
  for key, rectWall in pairs(self.rectWalls) do rectWall:draw() end
  self.player:draw()
end

return Stage
