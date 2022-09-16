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
  local layer = layer or 0
  io.write("\n")
  for i = 1, layer do io.write("\t") end
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
  io.write("}")
end

return mod