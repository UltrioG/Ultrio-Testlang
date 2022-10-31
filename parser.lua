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
      {{"separator", "{"}, {"EVAL"}, {"separator", "}"}},
      {{"separator", "("}, {"EVAL"}, {"separator", ")"}}
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
      {{"VAR_DECLARE"}},
      {{"FOR"}},
      {{"separator", "{"}, {"EXP"}, {"separator", "}"}},
    }
  }
}

function parser.tokenIsTerminal(token)
	return not not com.indexOf(tok.tokenTypes, token[4])
end
function parser.grammarUnitIsTerminal(g)
	return not not com.indexOf(tok.tokenTypes, g[1])
end

function parser.tokenFollowsTerminalObject(token, terminal)
	-- Checks whether a token matches a terminal object. CHECKS CONTENT AS WELL.
  -- If matches, return 1.
	local result = token[4] == terminal[1]
	if terminal[2] then result = result and terminal[2] == token[5] end
	return result and 1 or false
end

function parser.tokensFollowGrammarRule(tokens, startIndex, grammarRule)
	if (not grammarRule) or com.tableEquality(grammarRule, {}) then
		err:fatal(5, "Attempted to test if a set of tokens follow no grammar.")
	end
	
	local tokens = com.cloneTable(tokens)
	local grammar = com.cloneTable(grammarRule)
	local TKi = startIndex
	local GMi = 1
	local dT = 1

	while true do
		local t = tokens[TKi]
		local g = grammar[GMi]

		com.printTable(t, nil, "t")
		com.printTable(g, nil, "g")
		
		if not g then return TKi end
		if not t then return false end
		
		if parser.grammarUnitIsTerminal(g) then
			local termMatchResult = parser.tokenFollowsTerminalObject(t, g)
			print("TMR:", termMatchResult)
			if not termMatchResult then return false end
			dT = 1
		else
			print("Is not terminal.")
			local subparseResult = parser.tokensFollowGrammarRuleset(tokens, TKi, parser.grammar[g[1]])
			print(g[1], subparseResult)
			if not subparseResult then return false end
			dT = subparseResult
		end
		TKi = TKi + dT
		GMi = GMi + 1
	end
end

function parser.tokensFollowGrammarRuleset(tokens, startIndex, grammar)
	local ret = false
	for _, grammarRule in pairs(grammar) do
		ret = ret or parser.tokensFollowGrammarRule(tokens, startIndex, grammarRule)
		if ret then break end
	end
	return ret
end

function parser.parseTokens(tokens)
  local expressions = com.cloneTable(tokens)
  for i, v in ipairs(expressions) do
    
  end
end

return parser