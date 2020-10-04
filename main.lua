Util = require('util')
Log = require('log')

Arrow = require('src.arrow')
Archer = require('src.archer')

DEBUG = os.getenv("DEBUG") or false
VOLUME = os.getenv("VOLUME") or 1

function love.load()
  love.keyboard.setKeyRepeat(true)
  love.mouse.setRelativeMode(true)
  math.randomseed(6073061030592339)

  love.physics.setMeter(300)
  World = love.physics.newWorld(0, 9.81*32, true)

  PlayerX, PlayerY = 300, 300

  Player = Archer:new(World, PlayerX, PlayerY)

  FloorBody = love.physics.newBody(World, 0, 0, "static")
  FloorShape = love.physics.newEdgeShape(0, 800, 1400, 800)
  FloorFixture = love.physics.newFixture(FloorBody, FloorShape)

  LeftSideBody = love.physics.newBody(World, 0, 0, "static")
  LeftSideShape = love.physics.newEdgeShape(0, 0, 0, 800)
  LeftSideFixture = love.physics.newFixture(LeftSideBody, LeftSideShape)

  RightSideBody = love.physics.newBody(World, 0, 0, "static")
  RightSideShape = love.physics.newEdgeShape(1400, 0, 1400, 800)
  RightSideFixture = love.physics.newFixture(RightSideBody, RightSideShape)

  Zoom = 1
  IsFullscreen = false

  LastDt = 0
  TimePassed = 0

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
end

function love.update(dt)
  LastDt = dt
  TimePassed = TimePassed + dt

  IsFullscreen = love.window.getFullscreen()

  Player:update(dt)

  World:update(dt)
end

function love.draw()
  love.graphics.scale(Zoom)
  love.graphics.setBackgroundColor(120 / 255, 120 / 255, 120 / 255, 1)

  -- Game elements
  love.graphics.push()

  -- Camera
  love.graphics.translate(GetCameraPosition())

  Player:draw()
  love.graphics.line(FloorShape:getPoints())
  love.graphics.line(LeftSideShape:getPoints())
  love.graphics.line(RightSideShape:getPoints())

  local mousex, mousey = GetRelativeMouse()
  love.graphics.circle('line', mousex, mousey, 20)
  love.graphics.circle('fill', mousex, mousey, Player.fireStrength * 20)

  love.graphics.pop()

  -- GUI

  -- Delay Graphic Representation
  local r, g, b, a = love.graphics.getColor()
  love.graphics.setColor(1, 0, 0, 1)
  local height = Player.fireDelay * love.graphics.getHeight()
  love.graphics.rectangle('fill', 0, love.graphics.getHeight() - height, 20, height)
  love.graphics.setColor(r, g, b, a)

  if DEBUG then
    Logger.info = {
      arrow = #Player.arrows,
      dt = LastDt,
      time = TimePassed,
      FireDelay = Player.fireDelay,
      FireStrength = Player.fireStrength,
      FPS = love.timer.getFPS()
    }
    Logger:draw()
  end
end


function GetCameraPosition()
  local px, py = Player.body:getPosition()
  local ww, wh = love.window.getMode()
  return ww / 2 - px, wh / 2 - py
end

function GetRelativeMouse()
  local mousex, mousey = love.mouse.getPosition()
  local dx, dy = GetCameraPosition()
  return mousex - dx, mousey - dy
end
