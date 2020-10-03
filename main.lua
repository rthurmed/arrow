Util = require('util')
Arrow = require('src.arrow')

DEBUG = os.getenv("DEBUG") or false
VOLUME = os.getenv("VOLUME") or 1

function love.load()
  love.keyboard.setKeyRepeat(true)
  math.randomseed(6073061030592339)

  love.physics.setMeter(300)
  World = love.physics.newWorld(0, 9.81*32, true)

  PlayerX, PlayerY = 300, 300
  PlayerSpeed = 200 -- pixel per second

  Arrows = {}

  FireDelay = 1 -- seconds
  FireStrength = 0

  Zoom = 1
  IsFullscreen = false

  LastDt = 0
  TimePassed = 0
end

function love.wheelmoved(x, y)
  Zoom = Zoom + y / 8
end

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

  -- Moving logic
  local mx, my = 0, 0

  if love.keyboard.isDown('w') then my = -1 end
  if love.keyboard.isDown('s') then my =  1 end
  if love.keyboard.isDown('a') then mx = -1 end
  if love.keyboard.isDown('d') then mx =  1 end

  PlayerX = PlayerX + mx * dt * PlayerSpeed
  PlayerY = PlayerY + my * dt * PlayerSpeed

  -- Firing logic
  if FireDelay > 0 then
    FireDelay = FireDelay - dt
    if FireDelay < 0 then
      FireDelay = 0
    end
  end

  if FireDelay <= 0 and love.mouse.isDown(1) then
    FireStrength = FireStrength + dt * 4
    if FireStrength > 1 then
      FireStrength = 1
    end
  end

  if FireStrength > 0 and not love.mouse.isDown(1) then
    local x, y = love.mouse.getPosition()
    table.insert(Arrows, Arrow:new(World, PlayerX, PlayerY, x, y, FireStrength))
    FireStrength = 0
    FireDelay = 1
  end

  for key, arrow in pairs(Arrows) do arrow:update(dt) end

  World:update(dt)
end

function love.draw()
  love.graphics.scale(Zoom)
  love.graphics.setBackgroundColor(120 / 255, 120 / 255, 120 / 255, 1)

  -- Delay Graphic Representation
  local r, g, b, a = love.graphics.getColor()
  love.graphics.setColor(1, 0, 0, 0.25)
  local height = FireDelay * love.graphics.getHeight()
  love.graphics.rectangle('fill', 0, love.graphics.getHeight() - height, love.graphics.getWidth(), height)
  love.graphics.setColor(r, g, b, a)

  for key, arrow in pairs(Arrows) do arrow:draw() end
  love.graphics.circle('fill', PlayerX, PlayerY, 10)

  if DEBUG then
    Util.log(0, 0, {
      arrow = #Arrows,
      dt = LastDt,
      time = TimePassed,
      FireDelay = FireDelay
    })
  end
end
