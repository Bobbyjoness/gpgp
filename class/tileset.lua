local Tileset = Class:extend()

function Tileset:new(data)
  self.data     = data
  self.name     = data.name
  self.image    = love.graphics.newImage('project/images/'..data.image)
  self.tileSize = data.tileSize
end

function Tileset:draw()
  local scale = 1 / self.tileSize
  love.graphics.draw(self.image, 0, 0, 0, 1 / self.tileSize)
end

function Tileset:drawTile(posX, posY, tileX, tileY)
  local x      = (tileX - 1) * self.tileSize
  local y      = (tileY - 1) * self.tileSize
  local w, h   = self.tileSize, self.tileSize
  local sw, sh = self.image:getWidth(), self.image:getHeight()
  local quad   = love.graphics.newQuad(x, y, w, h, sw, sh)
  local scale  = 1 / self.tileSize
  love.graphics.draw(self.image, quad, posX - 1, posY - 1, 0, scale)
end

return Tileset
