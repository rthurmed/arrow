Util = require('util')
Log = require('log')

Arrow = require('src.arrow')
Archer = require('src.archer')
Crate = require('src.crate')
Categories = require('src.categories')

DEBUG = os.getenv("DEBUG") or false
VOLUME = os.getenv("VOLUME") or 1

function love.load()
  love.keyboard.setKeyRepeat(true)
  love.mouse.setRelativeMode(true)
  math.randomseed(6073061030592339)

  love.physics.setMeter(200)
  World = love.physics.newWorld(0, 9.81*200, false)

  PlayerX, PlayerY = 300, 300

  Player = Archer:new(World, PlayerX, PlayerY)

  FloorBody = love.physics.newBody(World, 0, 0, "static")
  FloorShape = love.physics.newEdgeShape(0, 800, 1400, 800)
  FloorFixture = love.physics.newFixture(FloorBody, FloorShape)
  FloorFixture:setCategory(Categories.wall)

  LeftSideBody = love.physics.newBody(World, 0, 0, "static")
  LeftSideShape = love.physics.newEdgeShape(0, 0, 0, 800)
  LeftSideFixture = love.physics.newFixture(LeftSideBody, LeftSideShape)
  LeftSideFixture:setCategory(Categories.wall)

  RightSideBody = love.physics.newBody(World, 0, 0, "static")
  RightSideShape = love.physics.newEdgeShape(1400, 0, 1400, 800)
  RightSideFixture = love.physics.newFixture(RightSideBody, RightSideShape)
  RightSideFixture:setCategory(Categories.wall)

  MiddleBody = love.physics.newBody(World, 500, 300, "static")
  MiddleShape = love.physics.newRectangleShape(200, 200)
  MiddleFixture = love.physics.newFixture(MiddleBody, MiddleShape)
  MiddleFixture:setCategory(Categories.wall)

  MiddleBody2 = love.physics.newBody(World, 1200, 400, "static")
  MiddleShape2 = love.physics.newRectangleShape(150, 150)
  MiddleFixture2 = love.physics.newFixture(MiddleBody2, MiddleShape2)
  MiddleFixture2:setCategory(Categories.wall)

  Crates = {
    Crate:new(World, 500, 200, 50, 50),
    Crate:new(World, 800, 400, 100, 100),
    Crate:new(World, 850, 100, 100, 100),
    Crate:new(World, 900, 400, 100, 100)
  }

  Zoom = 1
  IsFullscreen = false

  LastDt = 0
  TimePassed = 0

  Paused = false

  LastMouseX = 0
  LastMouseY = 0

  Logger = Log:new()
end

-- function love.wheelmoved(x, y)
--   Zoom = Zoom + y / 8
-- end

function love.keyreleased(key)
  if key == 'escape' then
    love.event.quit()
    return
  end

  if key == 'f11' then
    love.window.setFullscreen(not IsFullscreen, 'desktop')
  end

  if key == 'p' then
    love.mouse.setRelativeMode(Paused)
    Paused = not Paused
  end
end

function love.update(dt)
  if Paused then
    return
  end

  LastDt = dt
  TimePassed = TimePassed + dt

  IsFullscreen = love.window.getFullscreen()

  Player:update(dt)

  World:update(dt)

  if not Paused then
    LastMouseX, LastMouseY = love.mouse.getPosition()
  end
end

function love.draw()
  love.graphics.scale(Zoom)
  love.graphics.setBackgroundColor(66 / 255, 35 / 255, 83 / 255, 1)

  -- Game elements
  love.graphics.push()

  -- Camera
  love.graphics.translate(GetCameraPosition())

  Player:draw()
  love.graphics.line(FloorShape:getPoints())
  love.graphics.line(LeftSideShape:getPoints())
  love.graphics.line(RightSideShape:getPoints())

  love.graphics.push()
  love.graphics.translate(MiddleBody:getPosition())
  love.graphics.polygon('line', MiddleShape:getPoints())
  love.graphics.pop()

  love.graphics.push()
  love.graphics.translate(MiddleBody2:getPosition())
  love.graphics.polygon('line', MiddleShape2:getPoints())
  love.graphics.pop()

  for key, crate in pairs(Crates) do crate:draw() end

  local mousex, mousey = GetRelativeMouse()
  love.graphics.circle('line', mousex, mousey, 23)
  love.graphics.circle('fill', mousex, mousey, Player.fireStrength / Player.STRENGTH_PULL_TIME * 20)

  love.graphics.pop()

  -- GUI

  -- Delay Graphic Representation
  love.graphics.setColor(214 / 255, 37 / 255, 80 / 255, 0.75)
  local height = Player.fireDelay * love.graphics.getHeight()
  love.graphics.rectangle('fill', 0, love.graphics.getHeight() - height, 20, height)

  -- Pause text
  if Paused then
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle('fill', 0, love.graphics.getHeight() / 2 - 20, love.graphics.getWidth(), 35)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf('PAUSED', 0, love.graphics.getHeight() / 2 - 10, love.graphics.getWidth(), 'center')
  end

  love.graphics.setColor(1, 1, 1, 1)

  local px, py = Player.body:getPosition()
  if DEBUG then
    Logger.info = {
      dt = LastDt,
      time = TimePassed,
      FPS = love.timer.getFPS()
    }
    Logger:draw()
  end
end


function GetCameraPosition()
  local px, py = Player.body:getPosition()
  local ww, wh = love.window.getMode()
  local mx, my = LastMouseX, LastMouseY

  local mouseMoveRatio = 1 / 4

  local x = ww / 2 - px - mx * mouseMoveRatio
  local y = wh * 0.7 - py - my * mouseMoveRatio

  return x, y
end

function GetRelativeMouse()
  local mousex, mousey = LastMouseX, LastMouseY
  local dx, dy = GetCameraPosition()
  return mousex - dx, mousey - dy
end
