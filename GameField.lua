emptySymbol = " ";
local GridCell = require("GridCell");
local CombinationsChecker = require("CombinationsChecker");

local GameField = {};
GameField.__index = GameField;
GameFieldIndex = GameField.__index;

function GameField:new(width, height, cellTypes)
	local obj = {
		width = width,
		height = height,
		cellTypes = cellTypes,
    combinations = {},
    updateQueue = {},
    cellsCount = {}
	};
  
  obj.grid = {width = width, height = height};
  for x = 1, width do
    obj.grid[x] = {};
		for y = 1, height do
			obj.grid[x][y] = GridCell:new(cellTypes);
		end
	end

	for _,v in pairs(cellTypes) do
    obj.cellsCount[v] = 0;
  end;
  obj.cellsCount[emptySymbol] = width * height;
  obj.count = width * height;
  
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
  print("Mix");
end

--Генерация подходящей ячейки в координатах X и Y
function GameField:GenerateCell(x, y)
	local possibleTypes = self.grid[x][y].possibleTypes;
	local cellType = possibleTypes[math.random(1, #possibleTypes)];
  self:SetCell(x, y, cellType, true);
  
  if (x > 1 and x < self.width and self.grid[x-1][y].cellType == cellType) then
    self.grid[x+1][y]:RemovePossibleType(cellType);
	end;
  if (y > 1 and y < self.height and self.grid[x][y-1].cellType == cellType) then
    self.grid[x][y+1]:RemovePossibleType(cellType);
	end;
end

function GameField:SetCell(x, y, cellType, withoutUpdate)
  --Если не выходит за рамки и не такой же
  if (x > 0 and x <= self.width and y > 0 and y <= self.height and self.grid[x][y].cellType ~= cellType) then
    self.cellsCount[cellType] = self.cellsCount[cellType] + 1;
    self.cellsCount[self.grid[x][y].cellType] = self.cellsCount[self.grid[x][y].cellType] - 1;
    self.grid[x][y]:SetType(cellType);
    if (not withoutUpdate) then
      self:AddToUpdateQueue(x, y);
    end;
  end;
end

function GameField:ClearCell(x, y)
  self:SetCell(x, y, emptySymbol);
end

function GameField:TrySwap(from, to)
  if (not CombinationsChecker.IsCanSwap(self, from, to)) then
    return false;
  end;
  
  local fromType = self.grid[from.x][from.y].cellType;
  local toType = self.grid[to.x][to.y].cellType;
  
  self:SetCell(from.x, from.y, toType);
  self:SetCell(to.x, to.y, fromType);
  
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
  
  self.combinations = CombinationsChecker.CheckCombinations(self);
  
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

return GameField;
