Util = require('util')
Log = require('log')

Arrow = require('src.arrow')
Archer = require('src.archer')

DEBUG = os.getenv("DEBUG") or false
VOLUME = os.getenv("VOLUME") or 1

function love.load()
  love.keyboard.setKeyRepeat(true)
  math.randomseed(6073061030592339)

  love.physics.setMeter(300)
  World = love.physics.newWorld(0, 9.81*32, true)

  PlayerX, PlayerY = 300, 300

  Player = Archer:new(World, PlayerX, PlayerY)

  FloorBody = love.physics.newBody(World, 0, 0, "static")
  FloorShape = love.physics.newEdgeShape(0, love.graphics.getHeight() - 100, love.graphics.getWidth(), love.graphics.getHeight() - 100)
  FloorFixture = love.physics.newFixture(FloorBody, FloorShape)

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

  -- Delay Graphic Representation
  local r, g, b, a = love.graphics.getColor()
  love.graphics.setColor(1, 0, 0, 0.25)
  local height = Player.fireDelay * love.graphics.getHeight()
  love.graphics.rectangle('fill', 0, love.graphics.getHeight() - height, love.graphics.getWidth(), height)
  love.graphics.setColor(r, g, b, a)

  Player:draw()

  local mousex, mousey = love.mouse.getPosition()
  love.graphics.circle('line', mousex, mousey, Player.fireStrength * 20)

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
