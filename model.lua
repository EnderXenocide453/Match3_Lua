local GameField = require "GameField";
local FieldView = require "FieldView";
local CommandReceiver = require "CommandReceiver";
local Commands = require "Commands";
math.randomseed(os.time());

local gameField;
local fieldView;
local commandReceiver;

function init()
  commandReceiver = CommandReceiver:new(
    {
      Commands.MoveCommand:new(move),
      Commands.Command:new()
    });
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
  
  waitInput();
end;

function dump()
  fieldView:DrawField();
end;

function move(from, to)
  gameField:TrySwap(from, to)
  tick();
end;

function waitInput()
  while commandReceiver:ReceiveCommand() == false do
    print("неверная команда");
  end;
end;

init();
waitInput();

return {
  move = move
};