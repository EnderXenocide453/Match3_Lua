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
    cellType = "empty"
  };
  
  setmetatable(obj, self);
  return obj;
end;

function GridCell:RemovePossibleType(cellType)
  for k, v in pairs(self.possibleTypes) do  
    if (v == cellType) then
      table.remove(self.possibleTypes, k);
    end;
  end;
end;

function GridCell:IsTypePossible(cellType)
  for _, value in pairs(self.possibleTypes) do
    if (value == cellType) then
      return true;
    end;
  end;
  
  return false;
end;

function GridCell:SetType(cellType)
  self.cellType = cellType;
end;

return GridCell;