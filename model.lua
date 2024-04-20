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
    dump();
    gameField:UpdateCells();
    dump();
  until(#gameField.combinations == 0)
end;

function dump()
  fieldView:DrawField();
end;

function move(from, to)
  if gameField:TrySwap(from, to) then
    tick();
  end
end;

init();
for i = 1, 100 do
  x = math.random(1, 9);
  y = math.random(1, 10);
  move({x = x, y = y}, {x = x + 1, y = y});
end;
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