local GridCell = require("GridCell");

local GameField = {};
GameField.__index = GameField;
GameFieldIndex = GameField.__index;

function GameField:new(width, height, cellTypes)
	local obj = {
		width = width,
		height = height,
		cellTypes = cellTypes
	};
  
  obj.grid = {};
  for x = 1, width do
    obj.grid[x] = {};
		for y = 1, height do
			obj.grid[x][y] = GridCell:new(cellTypes);
		end
	end

	setmetatable(obj, self);

	return obj;
end

--Заполнение поля
function GameField:Init()
	for x = 1, self.width do
		for y = 1, self.height do
			self:GenerateCell(x, y);
		end
	end
end

--Перемешивание
function GameField:Mix()

end

--Генерация подходящей ячейки в координатах X и Y
function GameField:GenerateCell(x, y)
	local possibleTypes = self.grid[x][y].possibleTypes;
	local cellType = possibleTypes[math.random(1, #possibleTypes)];
  self.grid[x][y]:SetType(cellType);
  
  if (x > 1 and x < self.width and self.grid[x-1][y].cellType == cellType) then
    self.grid[x+1][y]:RemovePossibleType(cellType);
	end;
  if (y > 1 and y < self.height and self.grid[x][y-1].cellType == cellType) then
    self.grid[x][y+1]:RemovePossibleType(cellType);
	end;
end

function GameField:ClearCell(x, y)
  if (x > 0 and x <= self.width and y > 0 and y < self.height) then
    self.grid[x][y]:SetType("empty");
  end;
end

function GameField:UpdateCell(x, y)
  if (x > 0 and x <= self.width and y > 0 and y < self.height) then
    for i = y, 1, -1 do
      if (self.grid[x][i].cellType ~= "empty") then      
        goto continue;
      end;
      for j = i - 1, 1, -1 do
        if (self.grid[x][j].cellType ~= "empty") then
          self.grid[x][i]:SetType(self.grid[x][j].cellType);
          self:ClearCell(x, j);
          break;
        end;
        if (j == 1) then
          self.grid[x][i]:SetType(self.cellTypes[math.random(1, #self.cellTypes)]);
        end;
      end;
      ::continue::
    end;
    
    if (self.grid[x][1].cellType == "empty") then
      self.grid[x][1]:SetType(self.cellTypes[math.random(1, #self.cellTypes)]);
    end;
  end;
end

return GameField;
