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

function parser.tokenFollowsTerminalObject(token, terminal)
	-- Checks whether a token matches a terminal object. CHECKS CONTENT AS WELL.
  -- If matches, return 1.
	local result = token[4] == terminal[1]
	if terminal[2] then result = result and terminal[2] == token[5] end
	return result and 1 or false
end

function parser.tokensFollowGrammar(tokens, startIndex, grammar)
	local tokens = com.cloneTable(tokens)
	local TKi = startIndex
	local GMi = 1
	tokens = com.subTable(tokens, TKi, #tokens)

	while true do
		local t = tokens[TKi]
		local g = grammar[GMi]

		if not (t and g) then return TKi end

		local isGATerminal = parser.tokenIsTerminal(g)
		if isGATerminal then
			local gIsMatchingT = parser.tokenFollowsTerminalObject(t, g)
			if not gIsMatchingT then return false end
			GMi = GMi + 1
		else
			-- TODO: Fix the logic here
			local subLength = parser.tokensFollowGrammar(com.subTable(tokens, TKi, #tokens), TKi, g)
			if not subLength then return false end
			GMi = GMi + subLength
		end
		TKi = TKi + 1
	end
end

function parser.parseTokens(tokens)
  local expressions = com.cloneTable(tokens)
  for i, v in ipairs(expressions) do
    
  end
end

return parser