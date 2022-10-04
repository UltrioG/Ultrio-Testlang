local com = require("common")
local tok = require("tokenizer")

local parser = {
  grammar = {
    EVAL = {  -- Any value will be considered an EVAL
      {{"literal"}},
      {{"identifier"}},
      {{"EVAL"}, {"operator"}, {"EVAL"}},
      {{"EVAL"}, {"separator", ","}, {"EVAL"}}
    },
    VAR_DECLARE = {
      {{"keyword", "var"}, {"identifier"}}
    },
    FOR = {
      {{"keyword", "for"}, {"EXP"}, {"EVAL"}, {"EXP"}, {"EXP"}}
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