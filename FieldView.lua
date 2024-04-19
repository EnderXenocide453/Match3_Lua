local GameField = require "GameField";

local FieldView = {};
FieldView.__index = FieldView;

function FieldView:new(field)
  if (field.__index ~= GameField.__index) then
    error("FieldView can't contain type "..type(field));
    return;
  end;
  
  local obj = { field = field };
  
  setmetatable(obj, self);
  return obj;
end;

function FieldView:DrawField()
  local drawedField = "\t";
  local numFormat = "%02d";
  
  for x = 1, self.field.width do
    drawedField = drawedField.." "..string.format(numFormat, x);
  end;
  
  for y = 1, self.field.height do
    drawedField = drawedField.."\n"..string.format(numFormat, y);
    for x = 1, self.field.width do
      drawedField = drawedField.." |"..self.field.grid[x][y].cellType;
    end;
  end;
  
  print(drawedField);
end;

return FieldView;