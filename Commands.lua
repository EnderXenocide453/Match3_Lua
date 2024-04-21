--"Абстракция" команды
local Command = {};
Command.__index = Command;

function Command:new(name)
  local obj = { name = name }
  
  setmetatable(obj, self);
  return obj;
end;

--Попытка вызова
function Command:TryExecute(args)
  return false;
end;

--Команда для взаимодействия с полем
local MoveCommand = {};
MoveCommand.__index = MoveCommand;
setmetatable(MoveCommand, Command);

function MoveCommand:new(moveFunc)
  local obj = Command:new("m");
  obj.moveFunc = moveFunc;
  setmetatable(obj, self);
  return obj;
end;

--Вызывает попытку перемещения ячейки в модели по указанным аргументам
function MoveCommand:TryExecute(args)
  local x = tonumber(args[1]);
  local y = tonumber(args[2]);
  local dir = args[3];
  
  if (x == nil or y == nil or dir == nil) then
    return false;
  end;
  
  local from = {x = x, y = y};
  local to = {x = x, y = y};
  
  if (dir == "l") then
    to.x = to.x - 1;
  elseif (dir == "r") then
    to.x = to.x + 1;
  elseif (dir == "u") then
    to.y = to.y - 1;
  elseif (dir == "d") then
    to.y = to.y + 1;
  else
    return false;
  end;
  
  self.moveFunc(from, to);
  
  return true;
end;

--Команда вызова функции без аргументов
local CallCommand = {};
CallCommand.__index = CallCommand;
setmetatable(CallCommand, Command);

function CallCommand:new(name, func)
  local obj = Command:new(name);
  obj.func = func;
  setmetatable(obj, self);
  return obj;
end;

--Вызывает попытку перемещения ячейки в модели по указанным аргументам
function CallCommand:TryExecute(args)
  if (#args > 0) then return false; end;
  
  self.func();
  return true;
end;
return {
  Command = Command,
  MoveCommand = MoveCommand,
  CallCommand = CallCommand
}