function split (inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

function getRandomWithWeights(weightedValues, totalCount)
  if (totalCount == nil) then
    totalCount = 0;
    
    for _,v in pairs(weightedValues) do
      if (type(v) == "number") then
        totalCount = totalCount + v;
      end;
    end;
  end;
  
  local value = math.random() * totalCount;
  for k,v in pairs(weightedValues) do
      if (type(v) == "number") then
        if (value < v) then 
          return k;
        end;
        
        value = value - v;
      end;
    end;
end

function cloneTable(fromTable)
  local clone = {};
  for k, v in pairs(fromTable) do
    clone[k] = v;
  end;
  return clone;
end

function containsValue(checkTable, value)
  for _,v in pairs(checkTable) do
    if (v == value) then
      return true;
    end;
  end;
  return false;
end

return {
  split = split,
  getRandomWithWeights = getRandomWithWeights,
  cloneTable = cloneTable,
  containsValue = containsValue
};