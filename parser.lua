local com = require("common")
local tok = require("tokenizer")
local err = require("error_handler")

local parser = {
  grammar = {
    EVAL = {  -- Any value will be considered an EVAL
      {{"literal"}},
      {{"identifier"}},
      {{"EVAL"}, {"operator"}, {"EVAL"}},
      {{"EVAL"}, {"separator", ","}, {"EVAL"}}
    },
    WRAPPED_EVAL = {
      {"separator", "{"}, {"EVAL"}, {"separator", "}"},
      {"separator", "("}, {"EVAL"}, {"separator", ")"}
    },
    VAR_DECLARE = {
      {{"keyword", "var"}, {"identifier"}}
    },
    FOR = {
      {{"keyword", "for"}, {"EXP"}, {"WRAPPED_EVAL"}, {"EXP"}, {"EXP"}}
    },
    FUNCTION_CALL = {
      {{"identifier"}, {"separator", "("}, {"EVAL"}, {"separator", ")"}}
    },
    EXP = {
      {{"FOR"}},
      {{"VAR_DECLARE"}}
    }
  }
}

function parser.tokensFollowGrammar(tokens, startIndex, grammar)
  local follows = true
  local success, stringedTokens = pcall(function() return com.stringTable(tokens) end)
  local success2, stringedGrammar = pcall(function() return com.stringTable(grammar) end)
  err:assert(tokens and startIndex and grammar, 2, 
    ("Missing elements in grammar check. ({%s, %s, %s})"):format(
      success and stringedTokens or "NoTable",
      tostring(startIndex),
      success2 and stringedGrammar or "NoTable"
    )
  )
  success, stringedTokens, success2, stringedGrammar = nil, nil, nil, nil
  for i, currentGrammarObject in ipairs(grammar) do
    local currentToken = tokens[startIndex+i-1]
    
    local GOTerminal = com.indexOf(tok.tokenTypes, currentGrammarObject[1]) ~= nil
    if GOTerminal then
      follows = follows and currentToken[4] == currentGrammarObject[1]
      if currentGrammarObject[2] then
        follows = follows and currentToken[5] == currentGrammarObject[2]
      end
      if not follows then return false end
    else
      local foundMatchingGrammar = false
      for _, GOGrammar in ipairs(parser["grammar"][currentGrammarObject[1]]) do
        if parser.tokensFollowGrammar(tokens, startIndex+i-1, GOGrammar) then
          foundMatchingGrammar = true break
        end
      end
      follows = follows and foundMatchingGrammar
      if not follows then return false end
    end
  end
  return follows
end

function parser.parseTokens(tokens)
  local expressions = com.cloneTable(tokens)
  for i, v in ipairs(expressions) do
    
  end
end

return parser