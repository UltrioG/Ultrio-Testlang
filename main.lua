local tok = require("tokenizer")
local err = require("error_handler")
local com = require("common")

-- Tokenization
local fileName = --[[io.read("*l")]] "code.utlang"
local handle = assert(io.open(fileName, "r"))

local fileLines = {}
for line in handle:lines() do
  table.insert(fileLines, line)
end
com.printTable(fileLines)
local tokens = {}
for lineCount, lineContent in ipairs(fileLines) do
  for i, v in ipairs(tok.tokenizeLine(lineContent, lineCount)) do
    table.insert(tokens, v)
  end
end
local simplifiedTokens = {}
local tokenValues = {}
for _, v in ipairs(tokens) do
  table.insert(simplifiedTokens, v[4])
  table.insert(tokenValues, v[5])
end
com.printTable(simplifiedTokens)
com.printTable(tokenValues)

-- Parsing

-- Runtime