Util = require('util')
TestStage = require('src.stage.TestStage')

DEBUG = os.getenv("DEBUG") or false
VOLUME = os.getenv("VOLUME") or 1

function love.load()
  love.keyboard.setKeyRepeat(true)
  love.mouse.setRelativeMode(true)
  math.randomseed(6073061030592339)

  love.physics.setMeter(180)
  World = love.physics.newWorld(0, 9.81 * love.physics.getMeter(), true)

  StageInst = TestStage:new(World)
  StageInst:start()

  Zoom = 1
  IsFullscreen = false

  LastDt = 0
  TimePassed = 0

  Paused = false

  LastMouseX = 0
  LastMouseY = 0
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

  if key == 'r' then
    StageInst:kill()
    StageInst:start()
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

  StageInst:update(dt)
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
  StageInst:draw()

  love.graphics.pop()

  -- Pause text
  if Paused then
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle('fill', 0, love.graphics.getHeight() / 2 - 20, love.graphics.getWidth(), 35)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf('PAUSED', 0, love.graphics.getHeight() / 2 - 10, love.graphics.getWidth(), 'center')
  end

  love.graphics.setColor(1, 1, 1, 1)

  if DEBUG then
    Util.log(0, 0, {
      dt = LastDt,
      time = TimePassed,
      FPS = love.timer.getFPS()
    })
  end
end


function GetCameraPosition()
  local px, py = StageInst.super.player.body:getPosition()
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
