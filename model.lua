local GameField = require "GameField";
local FieldView = require "FieldView";
local CommandReceiver = require "CommandReceiver";
local Commands = require "Commands";
local CombinationsChecker = require("CombinationsChecker");
math.randomseed(os.time());

local gameField;
local fieldView;
local commandReceiver;

local width = 10;
local height = 10;
local cellTypes = {"A", "B", "C", "D", "E", "F"};

function init()
  commandReceiver = CommandReceiver:new(
    {
      Commands.MoveCommand:new(move),
      Commands.Command:new()
    });
  gameField = GameField:new(width, height, cellTypes);
  fieldView = FieldView:new(gameField);
  gameField:Init();
  dump();
  checkForCombinations();
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
  
  for k, v in pairs(gameField.cellsCount) do
    print(k..": "..v);
  end;
  checkForCombinations();
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

function checkForCombinations()
  while (not CombinationsChecker.CheckCombinationPossibility(gameField)) do
    gameField:Mix();
    dump();
  end;
end;

init();
waitInput();

return {
  move = move
};