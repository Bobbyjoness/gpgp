local TileLayer = Class:extend()

function TileLayer:new(data)
  self.tiles = {}
  self.selectedA = Vector(1, 1)
  self.selectedB = Vector(1, 1)
  self:load(data)
end

function TileLayer:place(a, b)
  self:remove(a, b)
  self:withPlacementResult(a, b, function(posX, posY, tileX, tileY)
    table.insert(self.tiles, {
      posX  = posX,
      posY  = posY,
      tileX = tileX,
      tileY = tileY,
    })
  end)
end

--gets each position and tile coordinate that would result from a selection
function TileLayer:withPlacementResult(va, vb, f, min)
  local a = va:clone()
  local b = vb:clone()

  local smallerX, biggerX = math.smaller(a.x, b.x)
  local smallerY, biggerY = math.smaller(a.y, b.y)

  if min then
    if biggerX < smallerX + (self.selectedB.x - self.selectedA.x) then
      biggerX = smallerX + self.selectedB.x - self.selectedA.x
    end
    if biggerY < smallerY + (self.selectedB.y - self.selectedA.y) then
      biggerY = smallerY + self.selectedB.y - self.selectedA.y
    end
  end

  for posX = smallerX, biggerX do
    for posY = smallerY, biggerY do
      tileX = self.selectedA.x + posX - smallerX
      tileY = self.selectedA.y + posY - smallerY
      --wrap tiles
      while tileX > self.selectedB.x do
        tileX = tileX - (self.selectedB.x - self.selectedA.x) - 1
      end
      while tileY > self.selectedB.y do
        tileY = tileY - (self.selectedB.y - self.selectedA.y) - 1
      end
      f(posX, posY, tileX, tileY)
    end
  end
end

function TileLayer:remove(a, b)
  for i = a.x, b.x, math.sign(b.x - a.x) do
    for j = a.y, b.y, math.sign(b.y - a.y) do
      for n, tile in pairs(self.tiles) do
        if tile.posX == i and tile.posY == j then
          table.remove(self.tiles, n)
        end
      end
    end
  end
end

function TileLayer:load(data)
  self.data = data
  self.name = data.name
  for _, tileset in pairs(Project.tilesets) do
    if tileset.name == data.tileset then
      self.tileset = tileset
      break
    end
  end
  --SEE GEOMETRY-LAYER.LUA FOR A POTENTIAL PROBLEM WITH THIS
  self.tiles = self.data.tiles or {}
end

function TileLayer:save()
  return {
    name    = self.name,
    type    = 'tile',
    tileset = self.tileset.name,
    tiles   = self.tiles,
  }
end

function TileLayer:openPalette()
  require('lib.gamestate').push(require('state.tile-palette'), self)
end

function TileLayer:drawCursorImage(a, b)
  self:withPlacementResult(a, b, function(posX, posY, tileX, tileY)
    self.tileset:drawTile(posX, posY, tileX, tileY)
  end, true)
end

function TileLayer:draw(alpha)
  love.graphics.setColor(255, 255, 255, alpha)
  for _, tile in pairs(self.tiles) do
    self.tileset:drawTile(tile.posX, tile.posY, tile.tileX, tile.tileY)
  end
end

return TileLayer
