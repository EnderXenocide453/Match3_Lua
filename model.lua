local GameField = require "GameField";
local FieldView = require "FieldView";
math.randomseed(os.time());

local gameField;
local fieldView;

function init()
  gameField = GameField:new(10, 10, {"A", "B", "C", "D", "E", "F"});
  fieldView = FieldView:new(gameField);
  gameField:Init();
  dump();
end;

function tick()
  repeat
    gameField:DestroyCells();
    gameField:UpdateCells();
    dump();
  until(#gameField.combinations == 0)
end;

function dump()
  fieldView:DrawField();
end;

init();
tick();
--[[Tests
gameField:ClearCell(5, 5);
gameField:ClearCell(5, 4);
gameField:ClearCell(5, 3);
fieldView:DrawField();
gameField:UpdateCells();
fieldView:DrawField();
gameField:ClearCell(5, 5);
gameField:ClearCell(6, 5);
gameField:ClearCell(7, 5);
fieldView:DrawField();
gameField:UpdateCells();
fieldView:DrawField();
gameField:ClearCell(1, 9);
gameField:ClearCell(2, 9);
gameField:ClearCell(3, 9);
fieldView:DrawField();
gameField:UpdateCells();
fieldView:DrawField();]]