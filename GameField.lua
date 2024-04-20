emptySymbol = " ";
local GridCell = require("GridCell");

local GameField = {};
GameField.__index = GameField;
GameFieldIndex = GameField.__index;

function GameField:new(width, height, cellTypes)
	local obj = {
		width = width,
		height = height,
		cellTypes = cellTypes,
    combinations = {},
    updateQueue = {}
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

function GameField:SetCell(x, y, cellType)
  --Если не выходит за рамки и не такой же
  if (x > 0 and x <= self.width and y > 0 and y <= self.height and self.grid[x][y].cellType ~= cellType) then
    self.grid[x][y]:SetType(cellType);
    self:AddToUpdateQueue(x, y);
  end;
end

function GameField:ClearCell(x, y)
  self:SetCell(x, y, emptySymbol);
end

function GameField:TrySwap(from, to)
  if (from == to) then
    return false;
  end;
  
  local fromType = self.grid[from.x][from.y].cellType;
  local toType = self.grid[to.x][to.y].cellType;
  
  self:SetCell(from.x, from.y, toType);
  self:SetCell(to.x, to.y, fromType);
  
  self:CheckCombinations();
  --Если нет комбинаций, перемещение невозможно
  if (#self.combinations == 0) then
    self:SetCell(from.x, from.y, fromType);
    self:SetCell(to.x, to.y, toType);
    
    return false;
  end;
  
  return true;
end

function GameField:AddToUpdateQueue(x, y)
  if (self.updateQueue[x] == nil or self.updateQueue[x] < y) then
    self.updateQueue[x] = y;
  end;
end

function GameField:DestroyCells()
  if (self.combinations == nil or #self.combinations == 0) then
    return false;
  end;
  
  for _, combo in pairs(self.combinations) do
    if (combo.left ~= nil) then 
      for x = combo.left, combo.right do
        self:ClearCell(x, combo.y);
      end;
    end;
    if (combo.up ~= nil) then 
      for y = combo.up, combo.down do
        self:ClearCell(combo.x, y);
      end;
    end;
  end;
  
  self.combinations = {};
  
  return true;
end

function GameField:UpdateCells()
  for x, y in pairs(self.updateQueue) do
    self:UpdateCell(x, y)
  end;
  
  self:CheckCombinations();
  
  self.updateQueue = {};
end

function GameField:UpdateCell(x, y)
  if (x > 0 and x <= self.width and y > 0 and y <= self.height) then
    for i = y, 1, -1 do
      if (self.grid[x][i].cellType ~= emptySymbol) then      
        goto continue;
      end;
      for j = i - 1, 1, -1 do
        if (self.grid[x][j].cellType ~= emptySymbol) then
          self:SetCell(x, i, self.grid[x][j].cellType);
          self:ClearCell(x, j);
          break;
        end;
        if (j == 1) then
          self:SetCell(x, i, self.cellTypes[math.random(1, #self.cellTypes)]);
        end;
      end;
      ::continue::
    end;
    
    if (self.grid[x][1].cellType == emptySymbol) then
      self:SetCell(x, 1, self.cellTypes[math.random(1, #self.cellTypes)]);
    end;
  end;
end

function GameField:CheckCombinations()
  self.combinations = {};
  
  for x, depth in pairs(self.updateQueue) do
    for y = 1, depth do
      local combination = self:CheckCombination(x, y, self.grid);
      if (combination ~= nil) then
        self.combinations[#self.combinations + 1] = combination;
      end;
    end;
  end;
end;

function GameField:CheckCombination(x, y, grid)
  local combination = {
    count = 1,
    x = x,
    y = y
  };
  
  if (grid[x][y] == nil or grid[x][y].cellType == emptySymbol) then
    return combination;
  end;
  
  --Поиск по горизонтали
  --Проход влево пока он возможен
  local left = x;
  while left > 1 do
    if (grid[x][y].cellType ~= grid[left - 1][y].cellType) then
      break;
    end;
    left = left - 1;
  end;
  --Проход вправо
  local right = x;
  while right < self.width do
    if (grid[x][y].cellType ~= grid[right + 1][y].cellType) then
      break;
    end;
    right = right + 1;
  end;
  --Если совпадений достаточно для комбинации, записываем
  if (right - left) >= 2 then
    combination.count = combination.count + right - left;
    combination.left = left;
    combination.right = right;
  end;
  
  --Проход по вертикали
  --Проход влево пока он возможен
  local up = y;
  while up > 1 do
    if (grid[x][y].cellType ~= grid[x][up - 1].cellType) then
      break;
    end;
    up = up - 1;
  end;
  --Проход вправо
  local down = y;
  while down < self.height do
    if (grid[x][y].cellType ~= grid[x][down + 1].cellType) then
      break;
    end;
    down = down + 1;
  end;
  --Если совпадений достаточно для комбинации, записываем
  if (down - up) >= 2 then
    combination.count = combination.count + down - up;
    combination.up = up;
    combination.down = down;
  end;
  
  if (combination.count > 1) then
    return combination;
  end;
  return nil;
end;

return GameField;
