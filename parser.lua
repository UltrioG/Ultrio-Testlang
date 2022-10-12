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
      {{"keyword", "var"}, {"identifier"}, {"operator", "="}, {"EVAL"}},
      {{"keyword", "var"}, {"identifier"}},
    },
    FOR = {
      {{"keyword", "for"}, {"EXP"}, {"WRAPPED_EVAL"}, {"EXP"}, {"EXP"}}
    },
    FUNCTION_CALL = {
      {{"identifier"}, {"separator", "("}, {"EVAL"}, {"separator", ")"}}
    },
    EXP = {
      {{"separator", "{"}, {"EXP"}, {"separator", "}"}},
      {{"FOR"}},
      {{"VAR_DECLARE"}},
    }
  }
}

function parser.tokensFollowGrammar(tokens, startIndex, grammar)
  print(
    ("%s @ %i for %s"):format(
      com.stringTable(tokens, nil, "Tokens"),
      startIndex,
      com.stringTable(grammar, nil, "Grammar")
    )
  )
  
  local tokens = com.cloneTable(tokens)
  local follows = true
  local index = startIndex

  while tokens[index] do
    local currentToken = tokens[index]
    local tokenType = currentToken[4]
    local tokenContent = currentToken[5]

    local currentPhrase = grammar[index]
    if not currentPhrase then return follows end
    local grammarType = currentPhrase[1]
    local grammarContent = currentPhrase[2]

    local PhraseTerminal = com.indexOf(tok.tokenTypes, grammarType) ~= nil

    if PhraseTerminal then
      follows = follows and tokenType == grammarType
      if grammarContent then
        follows = follows and tokenContent == grammarContent
      end
      if not follows then return follows end
    else
      for subexpressionType, subexpressionGrammar in pairs(parser.grammar) do
        local subfollows = parser.tokensFollowGrammar(
          com.subTable(tokens, index, #tokens-index+1),
          1,
          subexpressionGrammar
        )
      end
    end

    index = index + 1
  end
  
  return follows
end

function parser.parseTokens(tokens)
  local expressions = com.cloneTable(tokens)
  for i, v in ipairs(expressions) do
    
  end
end

return parser