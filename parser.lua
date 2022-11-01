local com = require("common")
local tok = require("tokenizer")
local err = require("error_handler")

local parser = {
  grammar = {
		VAL = {
			{{"identifier"}},
			{{"literal"}},
		},
		SUFFIX_OP = {
			{{"identifier"}, {"operator", "++"}},
			{{"identifier"}, {"operator", "--"}},
		},
    EVAL = {  -- Any "value" will be considered an EVAL
			{{"VAL"}, {"operator"}, {"EVAL"}},
      {{"VAL"}},
		},
    WRAPPED_EVAL = {
      {{"separator", "{"}, {"EVAL"}, {"separator", "}"}},
      {{"separator", "("}, {"EVAL"}, {"separator", ")"}},
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
      {{"separator", "{"}, {"separator", "}"}},
      {{"separator", "{"}, {"EXP"}, {"separator", "}"}},
			{{"SUFFIX_OP"}},
      {{"VAR_DECLARE"}},
      {{"FOR"}},
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
	local length = 0
	local GMi = 1
	local dT = 1
	
	while true do
		local t = tokens[TKi]
		local g = grammar[GMi]
		
		if not g then return length end
		if not t then return false end
		
		local formattedT = tok.keyifyToken(t)
		
		-- print(("Checking whether %s:%s matches with %s%s."):format(
		-- 		formattedT.tokenContent,
		-- 		formattedT.tokenType,
		-- 		g[1],
		-- 		g[2] and "("..g[2]..")" or ""
		-- 	))
		
		if parser.grammarUnitIsTerminal(g) then
			local termMatchResult = parser.tokenFollowsTerminalObject(t, g)
			-- print(not not termMatchResult)
			if not termMatchResult then return false end
			length = length + 1
			dT = 1
		else
			-- print(("%s is not a terminal, recursing."):format(g[1]))
			local subparseResult = parser.tokensFollowGrammarRuleset(tokens, TKi, parser.grammar[g[1]])
			-- print(g[1], subparseResult)
			if not subparseResult then return false end
			length = length + subparseResult
			dT = subparseResult
		end
		TKi = TKi + dT
		GMi = GMi + 1
	end
end

function parser.tokensFollowGrammarRuleset(tokens, startIndex, grammar)
	local ret = false
	for i, grammarRule in pairs(grammar) do
		ret = ret or parser.tokensFollowGrammarRule(tokens, startIndex, grammarRule)
		if not not ret then break end
	end
	return ret
end

function parser.parseTokens(tokens)

end

return parser