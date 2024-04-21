emptySymbol = " ";
local Utils = require("Utils");
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

--Заполнение пустыми ячейками
function GameField:ClearField()
  --Обнуляем количество ячеек
  for _,v in pairs(self.cellTypes) do
    self.cellsCount[v] = 0;
  end;
  self.cellsCount[emptySymbol] = self.width * self.height;
  self.count = self.width * self.height;
  
  --Заполняем поле пустыми ячейками
  for x = 1, self.width do
    self.grid[x] = {};
		for y = 1, self.height do
			self.grid[x][y] = GridCell:new(self.cellTypes);
		end
	end
end;

--Перемешивание
function GameField:Mix()
  --Запоминаем количество ячеек перед очисткой поля
  local cellsCount = Utils.cloneTable(self.cellsCount);
  --Количество неудачных итераций
  local tries = 0;
  --Очищаем поле
  self:ClearField();
  
  ::again::
  --Если неудачных попыток слишком много, генерируем новое поле
  if (tries > 100) then
    self:ClearField();
    self:Init();
    return;
  end;
  
  tries = tries + 1;
  --Создаём копию количества ячеек для манипуляций на этой итерации
  local weights = Utils.cloneTable(cellsCount);
  
  for x = 1, self.width do
		for y = 1, self.height do
      --Пытаемся сгенерировать ячейку
      if (not self:GenerateCellFromWeights(x, y, weights)) then
        --В случае неудачи пробуем перемешать поле снова
        goto again;
      end;
		end
	end
end

--[[
Генерация подходящей ячейки в координатах X и Y
- возвращает булево значение была ли завершена операция
]]
function GameField:GenerateCell(x, y)
	local possibleTypes = self.grid[x][y].possibleTypes;
  --Устанавливаем случайный подходящий тип ячейки
	local cellType = possibleTypes[math.random(1, #possibleTypes)];
  self:SetCell(x, y, cellType, true);
  
  --Если ячейка слева имеет такой же тип, ячейка справа не может иметь идентичный
  if (x > 1 and x < self.width and self.grid[x-1][y].cellType == cellType) then
    self.grid[x+1][y]:RemovePossibleType(cellType);
	end;
  --Если ячейка сверху имеет такой же тип, ячейка снизу не может иметь идентичный
  if (y > 1 and y < self.height and self.grid[x][y-1].cellType == cellType) then
    self.grid[x][y+1]:RemovePossibleType(cellType);
	end;
end

--[[
Генерация ячейки на основе списка количества необходимых ячеек
- возвращает булево значение была ли завершена операция
]]
function GameField:GenerateCellFromWeights(x, y, weights)
  local possibleTypes = {};
  local count = 0;
  --Ищем возможные типы среди списка необходимых
  for k, v in pairs(weights) do
    if (Utils.containsValue(self.grid[x][y].possibleTypes, k)) then
      possibleTypes[k] = v;
      count = count + v;
    end;
  end;
  
  --Если их нет, вохвращаем false
  if (count == 0) then
    return false;
  end;
  
  --Устанавливаем значение ячейки
	local cellType = Utils.getRandomWithWeights(possibleTypes, count);
  self:SetCell(x, y, cellType, true);
  --Уменьшаем необходимое количество
  weights[cellType] = weights[cellType] - 1;
  
  --Если ячейка слева имеет такой же тип, ячейка справа не может иметь идентичный
  if (x > 1 and x < self.width and self.grid[x-1][y].cellType == cellType) then
    self.grid[x+1][y]:RemovePossibleType(cellType);
	end;
  --Если ячейка сверху имеет такой же тип, ячейка снизу не может иметь идентичный
  if (y > 1 and y < self.height and self.grid[x][y-1].cellType == cellType) then
    self.grid[x][y+1]:RemovePossibleType(cellType);
	end;
  
  return true;
end;

--[[
Установка типа ячейки
- withoutUpdate - флаг, при установке которого обновление ячейки не произойдёт
]]
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

--Очистка ячейки. Заполняет ячейку пустым типом
function GameField:ClearCell(x, y)
  self:SetCell(x, y, emptySymbol);
end

--[[
Попытка смены местами ячеек
- from, to - координаты ячеек в формате {x = <int>, y = <int>}
- возвращает true если удалось и false в противном случае
]]
function GameField:TrySwap(from, to)
  --Если смена невозможна
  if (not CombinationsChecker.IsCanSwap(self, from, to)) then
    --Возвращаем false
    return false;
  end;
  
  --Меняем местами значения
  local fromType = self.grid[from.x][from.y].cellType;
  local toType = self.grid[to.x][to.y].cellType;
  
  self:SetCell(from.x, from.y, toType);
  self:SetCell(to.x, to.y, fromType);
  
  return true;
end

--Добавление в очередь на обновление
function GameField:AddToUpdateQueue(x, y)
  --Если колонка X ещё не добавлена в очередь или её глубина меньше новой
  if (self.updateQueue[x] == nil or self.updateQueue[x] < y) then
    --Добавляем колонку/меняем глубину колонки в очереди
    self.updateQueue[x] = y;
  end;
end

--Уничтожить комбинации
function GameField:DestroyCells()
  --Если комбинаций на поле нет, возвращаем false
  if (self.combinations == nil or #self.combinations == 0) then
    return false;
  end;
  
  --Для каждой комбинации
  for _, combo in pairs(self.combinations) do
    --[[
      В зависимости от количества ячеек по вертикали и горизонтали и по тому, удалены ли они уже 
      можно определить какая это комбинация и сгенерировать соответствующую особую ячейку
      При уничтожении ячейки вызывать её особое поведение, если такое имеется
    ]]
    --Удаляем ячейки по горизонтали
    if (combo.left ~= nil) then 
      for x = combo.left, combo.right do
        self:ClearCell(x, combo.y);
      end;
    end;
    --Удаляем ячейки по вертикали
    if (combo.up ~= nil) then 
      for y = combo.up, combo.down do
        self:ClearCell(combo.x, y);
      end;
    end;
  end;
  
  --Обнуляем список комбинаций
  self.combinations = {};
  
  return true;
end

--Обновить поле
function GameField:UpdateCells()
  for x, y in pairs(self.updateQueue) do
    self:UpdateCell(x, y)
  end;
  
  self.combinations = CombinationsChecker.CheckCombinations(self);
  
  self.updateQueue = {};
end

--Обновить конкретную ячейку и все ячейки над ней
function GameField:UpdateCell(x, y)
  if (x > 0 and x <= self.width and y > 0 and y <= self.height) then
    --Проходим ячейки снизу вверх
    for i = y, 1, -1 do
      --Если текущая нижняя ячейка не пуста, пропускаем
      if (self.grid[x][i].cellType ~= emptySymbol) then      
        goto continue;
      end;
      --Проходим по ячейкам выше
      for j = i - 1, 1, -1 do
        --Если ячейка не пустая, помещаем её в нижнюю
        if (self.grid[x][j].cellType ~= emptySymbol) then
          self:SetCell(x, i, self.grid[x][j].cellType);
          self:ClearCell(x, j);
          break;
        end;
        --Если ячейка сверху и она пуста, помещаем в нижнюю ячейку случайное значение
        if (j == 1) then
          self:SetCell(x, i, self.cellTypes[math.random(1, #self.cellTypes)]);
        end;
      end;
      ::continue::
    end;
    
    --Если верхняя ячейка так и не була заполнена, помещаем в неё случайное значение
    if (self.grid[x][1].cellType == emptySymbol) then
      self:SetCell(x, 1, self.cellTypes[math.random(1, #self.cellTypes)]);
    end;
  end;
end

return GameField;
