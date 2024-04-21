local Utils = require("Utils");

local CommandReceiver = {};
CommandReceiver.__index = CommandReceiver;

function CommandReceiver:new(commands)
  local obj = {
    commands = {}
  };
  
  --Заполнение таблицы команд, где имя команды - ключ
  for _,command in pairs(commands) do 
    obj.commands[command.name] = command;
  end;
  
  setmetatable(obj, self);
  return obj;
end;

--Получение команды
function CommandReceiver:ReceiveCommand()
  local commandLine = io.read();
  --Разделяем команду по пробелам
  local args = Utils.split(commandLine);
  
  --Получаем команду по первому слову строки
  local command = self.commands[args[1]];
  --Если такой команды нет - возвращаем false
  if (command == nil) then
    return false;
  end;
  
  --Убираем имя команды из аргументов
  table.remove(args, 1);
  
  --Пытаемся вызвать команду с переданными аргументами
  return command:TryExecute(args);
end;

return CommandReceiver;