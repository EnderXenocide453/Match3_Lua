local GameField = require "GameField";
local FieldView = require "FieldView";

local gameField = GameField:new(10, 10, {"A", "B", "C", "D", "E", "F"});
local fieldView = FieldView:new(gameField);
gameField:Init();
fieldView:DrawField();
gameField:ClearCell(5, 5);
gameField:ClearCell(5, 4);
gameField:ClearCell(5, 3);
fieldView:DrawField();
gameField:UpdateCell(5, 5);
fieldView:DrawField();