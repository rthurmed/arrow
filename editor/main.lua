Util = require('util')
EmptyStage = require('editor.EmptyStage')
Wall = require('src.wall')

DrawingTypes = {
  WALL = 'wall'
}

function love.load()
  love.physics.setMeter(180)
  World = love.physics.newWorld(0, 9.81 * love.physics.getMeter(), true)

  StageInst = EmptyStage:new(World)
  StageInst:start()

  WallX1, WallY1 = 0, 0
  WallFirstPoint = false

  DrawingType = DrawingTypes.WALL

  CameraX, CameraY = 0, 0
end

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

  if key == 'return' then
    FinishEditing()
    love.event.quit()
    return
  end
end

function love.mousemoved(x, y, dx, dy, istouch)
  if love.mouse.isDown(3) then
    CameraX = CameraX + dx
    CameraY = CameraY + dy
  end
end

function love.mousepressed(x, y, button)
  local mx, my = GetRelativeMouse()

  if button == 1 then
    WallX1, WallY1 = mx, my
    WallFirstPoint = true
  end
end

function love.mousereleased(x, y, button)
  local mx, my = GetRelativeMouse()

  if button == 1 and  WallFirstPoint then
    local wall = Wall:new(WallX1, WallY1, mx, my)
    table.insert(StageInst.super.walls, wall)
    WallFirstPoint = false
  end
end

function love.update(dt)
  StageInst:update(dt)
end

function love.draw()
  local mx, my = GetRelativeMouse()

  love.graphics.push()
  love.graphics.translate(CameraX, CameraY)

  StageInst:draw()

  if WallFirstPoint then
    love.graphics.line(WallX1, WallY1, mx, my)
  end
  love.graphics.pop()

  Util.log(0, 0, {
    DrawingType = DrawingType,
    WallCount = #StageInst.super.walls
  })
end

function GetRelativeMouse()
  local mx, my = love.mouse.getPosition()

  mx = mx - CameraX
  my = my - CameraY

  return mx, my
end

function FinishEditing()
  print('WALLS')
  for i = 1, #StageInst.super.walls, 1 do
    local x1, y1, x2, y2 = StageInst.super.walls[i].shape:getPoints()
    print(x1 .. ', ' .. y1 .. ', ' .. x2 .. ', ' .. y2)
  end
end