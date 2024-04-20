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
    if (gameField:DestroyCells()) then
      print("----Cells destroyed----");
      dump();
      print("-----------------------");
    end;
    gameField:UpdateCells();
    dump();
  until(#gameField.combinations == 0)
  
  waitInput();
end;

function dump()
  fieldView:DrawField();
end;

function move(from, to)
  if (gameField:TrySwap(from, to)) then
    print("Move "..from.x..":"..from.y.." to "..to.x..":"..to.y);
  else
    print("Can't move");
  end;
  tick();
end;

function waitInput()
  print("Enter command...");
  while commandReceiver:ReceiveCommand() == false do
    print("Wrong command!");
  print("Enter command...");
  end;
end;

init();
waitInput();

return {
  move = move
};