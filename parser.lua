local com = require("common")
local tok = require("tokenizer")

local parser = {
  grammar = {
    LOCAL_VAR_DEF = {
      {{"keyword", "local"}, {"keyword", "var"}, {"identifier"}, {"operator", "="}, {"EXP"}},
    },
    VAR_DEF = {
      {{"keyword", "var"}, {"identifier"}, {"operator", "="}, {"EXP"}},
      {{"keyword", "var"}, {"identifier"}},
    },
    FOR = {
      {{"keyword", "for"}, {"EXP"}, {"EXP"}, {"EXP"}, {"EXP"}}
    },
    IF = {
      {{"keyword", "if"}, {"EXP"}, {"EXP"}}
    },
    WHILE = {
      {{"keyword", "while"}, {"EXP"}, {"EXP"}}
    },
    RETURN = {
      {{"keyword", "return"}, {"EXP"}}
    },
    INCDEC = {
      {{"identifier"}, {"operator", "++"}},
      {{"identifier"}, {"operator", "--"}}
    },
    DELTA = {
      {{"identifier"}, {"operator"}, {"EXP"}},
    },
    EXP = {
      {{"separator", "{"}, {"EXP"}, {"separator", "}"}},
      {{"FOR"}},
      {{"VAR_DEF"}},
  
      {{"literal"}},
      {{"identifier"}},
    },
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