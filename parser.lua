local com = require("common")
local tok = require("tokenizer")
local err = require("error_handler")
local Tree = require("tree")

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

function parser.createBranchAccordingToGrammarRule(tokens, startIndex, grammarRule, grammarName)
	if (not grammarRule) or com.tableEquality(grammarRule, {}) then
		err:fatal(5, "Attempted to test if a set of tokens follow no grammar.")
	end

  -- print(("Upper level name: %s"):format(grammarName))
  
	local tokens = com.cloneTable(tokens)
	local grammar = com.cloneTable(grammarRule)
	local TKi = startIndex
	local length = 0
	local GMi = 1
	local dT = 1
  local branch = Tree:new(#grammarRule, grammarName)
  --[[
  The algorithm:
  For each grammar unit in rule:
  if it is a terminal unit then:
    if the token matches it then:
      return a leaf with value that is that token
    otherwise:
      return false, 0 (i.e. it does not match the gramamr rule)
  if not, see which grammar rule in the ruleset dictated by the grammar unit matches the current token
  if none of the unwrapped grammar rule matches, then return false, 0
  at this point, we should have a matching branch
  return it and how many leaves it has (i.e. how many tokens it has)
  ]]
	
	while true do
		local t = tokens[TKi]
		local g = grammar[GMi]
    
		if not g then print("Out of grammar, returning...", length) return branch, length end
		if not t then return false, 0 end

    print(("(GMi, TKi) = (%i, %i)"):format(GMi, TKi))
    
		local formattedT = tok.keyifyToken(t)
		
		print(("Checking whether %s:%s matches with %s%s."):format(
				formattedT.tokenContent,
				formattedT.tokenType,
				g[1],
				g[2] and "("..g[2]..")" or ""
			))
    
		if parser.grammarUnitIsTerminal(g) then
			local termMatchResult = parser.tokenFollowsTerminalObject(t, g)
			print(not not termMatchResult)
			if not termMatchResult then return false, 0 end
			length = length + 1
      Tree:new(1, {g[1], t[5]}, branch, GMi)
			dT = 1
		else
			print(("%s is not a terminal, recursing."):format(g[1]))
			local subparseResult,sublength = parser.createBranchAccordingToGrammarRuleset(tokens, TKi, parser.grammar[g[1]], g[1])
			print(g[1], sublength)
			if com.falsify(subparseResult) then return false, 0 end
			length = length + sublength
			dT = sublength
      subparseResult:move(branch, GMi)
		end
		TKi = TKi + dT
		GMi = GMi + 1
	end
end

function parser.createBranchAccordingToGrammarRuleset(tokens, startIndex, grammar, grammarName)
	local ret = Tree:new()
  local length = 0
	for i, grammarRule in pairs(grammar) do
    local subBranch, sublength = parser.createBranchAccordingToGrammarRule(tokens, startIndex, grammarRule, grammarName)
    if com.falsify(subBranch) then
      
    else
      local nilnot = not com.falsify(ret)
  		ret = nilnot and ret or subBranch
      length = length + sublength
  		if not nilnot then break end
    end
  end
	return ret, length
end

function parser.parseTokens(tokens)
  local tokens = com.cloneTable(tokens)
  local programRoot = Tree:new()
  local index = 1
  local expCounter = 1
  
  while index <= #tokens do
    local expBranch, expLen = parser.createBranchAccordingToGrammarRuleset(
      tokens,
      index,
      parser.grammar.EXP,
      "Expression"
    )
    if com.falsify(expBranch) then break end
    print(("Found an expression! Expression: %s"):format(expBranch[1]:get()))
    expBranch:move(programRoot, expCounter)
    expCounter = expCounter + 1
    index = index + expLen
  end

  err:assert(index >= #tokens, 2, "Dangling tokens near EOF!")

  return programRoot
end

return parser