local Utils = require("Utils");

local CommandReceiver = {};
CommandReceiver.__index = CommandReceiver;

function CommandReceiver:new(commands)
  local obj = {
    commands = {}
  };
  
  for _,command in pairs(commands) do 
    obj.commands[command.name] = command;
  end;
  
  setmetatable(obj, self);
  return obj;
end;

function CommandReceiver:ReceiveCommand()
  local commandLine = io.read();
  local args = Utils.split(commandLine);
  
  local command = self.commands[args[1]];
  if (command == nil) then
    return false;
  end;
  
  table.remove(args, 1);
  
  return command:TryExecute(args);
end;

return CommandReceiver;