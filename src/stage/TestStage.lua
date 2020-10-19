Wall = require('src.wall')
Crate = require('src.crate')
Stage = require('src.stage')
Player = require('src.archer')
RectWall = require('src.rectwall')

TestStage = {}

function TestStage:new(world)
  local that = {}

  that.super = Stage:new(world)

  that.super.walls = {
    Wall:new(0,    800, 1400, 800),
    Wall:new(0,    0,   0,    800),
    Wall:new(1400, 0,   1400, 800)
  }

  that.super.rectWalls = {
    RectWall:new(500,  300, 200, 200),
    RectWall:new(1200, 400, 150, 150)
  }

  that.super.crates = {
    Crate:new(World, 500, 200, 50,  50),
    Crate:new(World, 800, 400, 100, 100),
    Crate:new(World, 850, 100, 100, 100),
    Crate:new(World, 900, 400, 100, 100)
  }

  self.__index = self
  return setmetatable(that, self)
end

function TestStage:start()
  self.super.player = Player:new(self.super.world, self, 300, 300)
end

function TestStage:update(dt)
  self.super:update(dt)
end

function TestStage:draw()
  self.super:draw()
end

return TestStage
