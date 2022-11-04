-- -- --[[

-- -- REMEMBER TO CHECK THE GITHUB PAGE!!!

-- -- --]]
local tok = require("tokenizer")
local par = require("parser")
local err = require("error_handler")
local com = require("common")

math.randomseed(os.time())

local fileName = --[[io.read("*l")]] "code.utlang"
local handle = assert(io.open(fileName, "r"))

local fileLines = {}
for line in handle:lines() do
  table.insert(fileLines, line)
end

-- Tokenization

local tokens = {}
local tokenSet, inComment = nil, false
for lineCount, lineContent in ipairs(fileLines) do
  tokenSet, inComment = tok.tokenizeLine(lineContent, lineCount, inComment)
  if not inComment then
    for i, v in ipairs(tokenSet) do
      table.insert(tokens, v)
    end
  end
end
local simplifiedTokens = {}
local tokenValues = {}
for _, v in ipairs(tokens) do
  table.insert(simplifiedTokens, v[4])
  table.insert(tokenValues, v[5])
end

-- Parsing
local expressions = par.parseTokens(tokens)

print(
  "SEP -----",
  par.tokensFollowGrammarRuleset(
    tokens,
    1,
    par.grammar.EXP
  )
)

-- Runtime

-- print(com.stringTable({"hi!"}, nil, "test"))