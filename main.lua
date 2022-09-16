local tok = require("tokenizer")


-- Interpretation
local handle = assert(io.open("code.utlang", "r"))
local code = handle:read("*all")

for i in code:gsub("/%*.-%*/", " "):gmatch("[^%w_]([%a_][%w_]-)[^%w_]") do print(i) end

local offset = 1
for _, v in ipairs(tok:tokenize(code, handle)) do
  local code = tok:removeComment(code)
  print(("(%s, %i, %q), area %i: %q"):format(v[1], v[2], v[3], offset, code:sub(v[2]-offset, v[2]+offset+#v[3])))
  print()
end

handle:close()

-- Runtime