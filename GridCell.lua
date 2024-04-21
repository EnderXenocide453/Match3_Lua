local GridCell = {};
GridCell.__index = GridCell;
GridCellIndex = GridCell.__index;

function GridCell:new(cellTypes)
  local possibleTypes = {};
  for k, v in pairs(cellTypes) do
    possibleTypes[k] = v;
  end;
  
  local obj = {
    possibleTypes = possibleTypes,
    cellType = emptySymbol;
    --Для реализации особых ячеек здесь также можно разместить ссылку на метод или класс особой ячейки
  };
  
  setmetatable(obj, self);
  return obj;
end;

--Убрать тип из списка возможных
function GridCell:RemovePossibleType(cellType)
  for k, v in pairs(self.possibleTypes) do  
    if (v == cellType) then
      table.remove(self.possibleTypes, k);
    end;
  end;
end;

--Возможно ли размещения типа в ячейке
function GridCell:IsTypePossible(cellType)
  for _, value in pairs(self.possibleTypes) do
    if (value == cellType) then
      return true;
    end;
  end;
  
  return false;
end;

--Установить тип
function GridCell:SetType(cellType)
  self.cellType = cellType;
end;

return GridCell;