Util = require('util')

Log = {}

function Log:new(x, y)
  local that = {}

  that.x = x or 0
  that.y = y or 0
  that.info = {}

  self.__index = self
  return setmetatable(that, self)
end

function Log:draw()
  Util.log(self.x, self.y, self.info)
end

return Log