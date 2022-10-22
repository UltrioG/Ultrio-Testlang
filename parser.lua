local com = require("common")
local tok = require("tokenizer")
local err = require("error_handler")

local parser = {
  grammar = {
    -- EVAL = {  -- Any value will be considered an EVAL
    --   {{"literal"}},
    --   {{"identifier"}},
    --   {{"EVAL"}, {"operator"}, {"EVAL"}},
    --   {{"EVAL"}, {"separator", ","}, {"EVAL"}}
    -- },
    -- WRAPPED_EVAL = {
    --   {{"separator", "{"}, {"EVAL"}, {"separator", "}"}},
    --   {{"separator", "("}, {"EVAL"}, {"separator", ")"}}
    -- },
    -- VAR_DECLARE = {
    --   {{"keyword", "var"}, {"identifier"}, {"operator", "="}, {"EVAL"}},
    --   {{"keyword", "var"}, {"identifier"}},
    -- },
    -- FOR = {
    --   {{"keyword", "for"}, {"EXP"}, {"WRAPPED_EVAL"}, {"EXP"}, {"EXP"}}
    -- },
    -- FUNCTION_CALL = {
    --   {{"identifier"}, {"separator", "("}, {"EVAL"}, {"separator", ")"}}
    -- },
    -- EXP = {
    --   {{"VAR_DECLARE"}},
    --   {{"FOR"}},
    --   {{"separator", "{"}, {"EXP"}, {"separator", "}"}},
    -- }
    for_word = {
      {{"keyword", "for"}}
    },
    recursive_test = {
      {{"for_word"}}
    }
  }
}

function parser.tokenFollowsTerminalObject(token, terminal)
	-- Checks whether a token matches a terminal object.
  -- If matches, return how many tokens long that object is.
	local result = token[4] == terminal[1]
	if terminal[2] then result = result and terminal[2] == token[5] end
	return result and 1 or false
end

function parser.tokensFollowGrammar(tokens, startIndex, grammar, name)
  local success, err = pcall(function()
    local tokens = com.cloneTable(tokens)
    local grammarIndex = 1
  	local tokenIndex = startIndex
    
    while grammar[grammarIndex] do
		  local grammarUnit = grammar[grammarIndex]
  		-- double negation casts non-nil-nor-false to true
  		local isTerminal = not not com.indexOf(tok.tokenTypes, grammarUnit[1])
  		local TokenIndexIncrement = 1
  
  		if isTerminal then
  			local tokenFollows = parser.tokenFollowsTerminalObject(
            tokens[tokenIndex], grammar[grammarIndex]
          )
  			if not tokenFollows then return false end
        else
  			local subTokens = com.subTable(tokens, tokenIndex, #tokens)
  			local nonTerminalSubtokensLength = 0
        local queuedIdenticalGrammarRule = false
  			for grammarRuleType, grammarRuleSet in pairs(parser.grammar) do
  				for grammarRuleIndex, grammarRule in ipairs(grammarRuleSet) do
            print(grammarRuleType, com.stringTable(grammarRule))
  					if name == grammarRuleType then
                print("Potential infinite recursion, skipping")
                queuedIdenticalGrammarRule = true
            else
              local L = parser.tokensFollowGrammar(
                  subTokens, 1, grammarRule, grammarRuleType
                )
    					nonTerminalSubtokensLength = L
              print(nonTerminalSubtokensLength)
    					if L then break end
            end
          end
        end
        if queuedIdenticalGrammarRule then
          local L = parser.tokensFollowGrammar(
                subTokens, 1, grammar, name
              )
            nonTerminalSubtokensLength = L
            print(nonTerminalSubtokensLength)
          end
  			if not nonTerminalSubtokensLength then return false end
        tokenIndex = tokenIndex + nonTerminalSubtokensLength
  		end
  		tokenIndex = tokenIndex + TokenIndexIncrement
  		grammarIndex = grammarIndex + 1
  	end

    return tokenIndex
  end)

  if success then return err else
    
  end
end

function parser.parseTokens(tokens)
  local expressions = com.cloneTable(tokens)
  for i, v in ipairs(expressions) do
    
  end
end

return parser