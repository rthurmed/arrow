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
  if self.player ~= nil then    
    self.player:update(dt)
  end
end

function Stage:draw()
  for key, wall in pairs(self.walls) do wall:draw() end
  for key, crate in pairs(self.crates) do crate:draw() end
  for key, rectWall in pairs(self.rectWalls) do rectWall:draw() end

  if self.player ~= nil then
    self.player:draw()
  end
end

function Stage:start()
  --
end

function Stage:kill()
  for key, ent in pairs(self.walls)     do ent.body:setActive(false) end
  for key, ent in pairs(self.crates)    do ent.body:setActive(false) end
  for key, ent in pairs(self.rectWalls) do ent.body:setActive(false) end

  if self.player ~= nil then
    self.player.body:setActive(false)
  end

  for i = 1, #self.walls, 1     do self.walls[i] = nil     end
  for i = 1, #self.crates, 1    do self.crates[i] = nil    end
  for i = 1, #self.rectWalls, 1 do self.rectWalls[i] = nil end
  self.player = nil
end

return Stage
