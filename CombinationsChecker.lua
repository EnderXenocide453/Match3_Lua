function CheckCombinations(gameField)
  local combinations = {};
  
  for x, depth in pairs(gameField.updateQueue) do
    for y = 1, depth do
      local combination = CheckCombination(x, y, gameField.grid);
      if (combination ~= nil) then
        combinations[#combinations + 1] = combination;
      end;
    end;
  end;
  
  return combinations;
end;

function CheckCombination(x, y, grid)
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
  while right < grid.width do
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
  while down < grid.height do
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

function IsCanSwap(gameField, from, to)
  if (from.x < 1 or from.x > gameField.width 
      or from.y < 1 or from.y > gameField.height
      or to.x < 1 or to.x > gameField.width 
      or to.y < 1 or to.y > gameField.height) then
    return false;
  end;
  
  if (from == to) then
    return false;
  end;
  
  local fromType = gameField.grid[from.x][from.y].cellType;
  local toType = gameField.grid[to.x][to.y].cellType;
  
  --Меняем ячейки местами без записи о их движениях
  gameField:SetCell(from.x, from.y, toType, true);
  gameField:SetCell(to.x, to.y, fromType, true);
  
  local canSwap = false;
  if (CheckCombination(from.x, from.y, gameField.grid)) then
    canSwap = true;
  elseif (CheckCombination(to.x, to.y, gameField.grid)) then
    canSwap = true;
  end;
  
  --Возвращаем ячейки на места
  gameField:SetCell(from.x, from.y, fromType, true);
  gameField:SetCell(to.x, to.y, toType, true);
  
  return canSwap;
end;

function CheckCombinationPossibility(gameField)
  for x = 1, gameField.width - 1 do
    for y = 1, gameField.height - 1 do
      if (IsCanSwap(gameField, {x = x, y = y}, {x = x+1, y = y})
          or IsCanSwap(gameField, {x = x, y = y}, {x = x, y = y+1})) then
        return true;
      end;
    end;
  end;
  
  return false;
end;

return {
  CheckCombinations = CheckCombinations,
  CheckCombination = CheckCombination,
  IsCanSwap = IsCanSwap,
  CheckCombinationPossibility = CheckCombinationPossibility
};