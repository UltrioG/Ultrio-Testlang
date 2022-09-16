local tok = require("tokenizer")
local err = require("error_handler")
local com = require("common")

-- Interpretation
local fileName = --[[io.read("*l")]] "code.utlang"
local handle = assert(io.open(fileName, "r"))

local fileLines = tok.splitToLines(handle:read("*all"))
com.printTable(fileLines)
for lineCount, lineContent in ipairs(fileLines) do
  tok.tokenizeLine(lineContent)
end

handle:close()

-- Runtime