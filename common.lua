local mod = {}

function mod.indexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

function mod.printTable(t, layer)
  local t = mod.cloneTable(t)
  local layer = layer or 0
  io.write("\n")
  for _ = 1, layer do io.write("\t") end
  io.write(tostring(t))
  io.write(": {\n")
  for k, v in pairs(t) do
    for i = 0, layer do io.write("\t") end
    io.write(tostring(k))
    io.write(" = ")
    if type(v) == "table" then
      mod.printTable(v, layer + 1)
    elseif type(v) == "string" then
      io.write('"'..v..'"')
    else
      io.write(tostring(v))
    end
    io.write(",\n")
  end
  for i = 1, layer do io.write("\t") end
  io.write("}\n")
end

function mod.stringTable(t, layer)
  local t = mod.cloneTable(t)
  local layer = layer or 0
  local str = ""
  str = str..("\n")
  for _ = 1, layer do str = str..("\t") end
  str = str..(tostring(t))
  str = str..(": {\n")
  for k, v in pairs(t) do
    for _ = 0, layer do str = str..("\t") end
    str = str..(tostring(k))
    str = str..(" = ")
    if type(v) == "table" then
      str = str..mod.stringTable(v, layer + 1)
    elseif type(v) == "string" then
      str = str..('"'..v..'"')
    else
      str = str..(tostring(v))
    end
    str = str..(",\n")
  end
  for _ = 1, layer do str = str..("\t") end
  str = str..("}\n")
  return str
end

function mod.literal_pattern(text)
  assert(type(text) == "string")
  return text:gsub("([^%w])", "%%%1")
end

function mod.cloneTable(t)
  local out = {}
  for k, v in pairs(t) do out[k] = v end
  return out
end

function mod.subTable(t)
  local newT = {}
  for i = 2, #t do
    table.insert(newT, t[i])
  end
  return newT
end

return mod