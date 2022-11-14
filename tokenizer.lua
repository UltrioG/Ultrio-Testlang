--[[
Language design:
  UTLang is pretty much a joke.
  There is next to no syntactical sugar.

  Datatypes:
    number:
    Originally complex, it was too terrible even for me,
    so I changed it to real numbers instead
      Notation: 0, 1, 23, 4.56, .78
    string: A basic string of characters. All strings are multiline.
      Notation: 's'; "s"
    boolean: True or false values.
      Notation: true, false

  Comments are notated as /* */
--]]
local EHand = require("error_handler")
local comm = require("common")

local tokenizer = {
  tokens = {
    keyword = {
      literal = {"if", "while", "for", "return", "var"},
      pattern = {}
    },
    separator = {
      literal = {"{", "}", "[", "]", "(", ")", ","},
      pattern = {}
    },
    operator = {
      literal = {
        "-", "^", "%"
      },
      pattern = {
        "[^%*](/)[^%*]", "[^/](%*)[^/]", "[^!<>=](=)[^=]", "[^!<>=](==)[^<>=]", 
        "[^!<>=](<=)[^<>=]", "[^!<>=](>=)[^<>=]", "[^!<>=](<)[^<>=]",
        "[^!<>=](>)[^<>=]", "[^!<>=](!=)[^<>=]", "(!)[^=]",
        "[^!](!&)", "[^!](!|)", "[^!](&)", "[^!](|)",
        "[^%+](%+)[^%+i]-%s",
        "[^%+](%+%+)[^%+]", "[^%+=](%+=)[^%+=]",
        "[^%-](%-)[^%-]",
        "[^%-](%-%-)[^%-]", "[^%-=](%-=)[^%-=]",
      }
    },
    literal = {
      literal = {
        "true",
        "false",
        "null",
      },
      pattern = {
        "%D(%d+)%D", "%D(%d*%.%d+)%D",
        "('[^']-')", '("[^"]-")',
        -- TODO: Errors on unclosed string with "'[^']*$" and '"[^"]*$'
      }
    },
    comment = {
      literal = {},
      pattern = {
        "(/%*.-%*/)"
      }
    },
    identifier = {
      literal = {},
      pattern = {
        "[^%w_\"']([%a_][%w_]-)[^%w_\"']",
      }
    },
  },
  tokenTypes = {}    -- This table will be automatically filled
}

tokenizer.tokenTypes = {}
for k in pairs(tokenizer.tokens) do
  table.insert(tokenizer.tokenTypes, k)
end

function tokenizer.removeComments(str)
  local ret, rep = str:gsub("/%*.-%*/", "")
  return ret, rep > 0
end

function tokenizer.hasUnclosedComment(str)
  return string.match(str, "/%*.-$") ~= nil
end
function tokenizer.hasCommentClose(str)
return string.match(str, "^.-%*/") ~= nil
end

function tokenizer.isSpecialWord(word)
  for _, v in ipairs(tokenizer.tokens.keyword.literal) do
    if v == word then return true end
  end
  for _, v in ipairs(tokenizer.tokens.literal.literal) do
    if v == word then return true end
  end
  for _, v in ipairs(tokenizer.tokens.literal.pattern) do
    if word:find(v) then return true end
  end
	return false
end

function tokenizer.tokenizeLine(line, lineCount, inComment)
  if inComment and not tokenizer.hasCommentClose(line) then return {}, true end
  local proxyLine, changed = tokenizer.removeComments(line)
  if tokenizer.hasUnclosedComment(line) and not tokenizer.hasCommentClose(line) then
    return {}, true
  end
  local tokens = {}
	proxyLine = " "..proxyLine.." "
  
  for tokenType, matchGroup in pairs(tokenizer.tokens) do
    for matchType, matchSet in pairs(matchGroup) do
      for _, matchString in ipairs(matchSet) do
        local litMatch = matchType == "literal"
        local first = 0
        local last = 0
        local match = ""
        while true do
          first, last, match = proxyLine:find(matchString, last+1, litMatch)
          if not first then break end
          if match and not litMatch then
            first, last = proxyLine:find(match, first, true)
					end
          if litMatch then match = proxyLine:sub(first, last) end
          if tokenType == "identifier" and tokenizer.isSpecialWord(match) then
						print("cont")
					else
          	table.insert(
	            tokens, {
	              first-1, last-1, lineCount, tokenType, match or proxyLine:sub(first, last)
	            }
						)
					end
        end
      end
    end
  end
  
  table.sort(tokens, function(a, b)
      return a[1] < b[1]
    end)

	local removed = 0
	
	for i = 1, #tokens do
		if tokens[i+1] == nil then break end
		if tokens[i][2] == tokens[i+1][2] then
			table.remove(tokens, i-removed)
			removed = removed + 1
		end
	end
	
  return tokens, false
end

function tokenizer.keyifyToken(token)
  return {
    first = token[1],
    last = token[2],
    line = token[3],
    tokenType = token[4],
    tokenContent = token[5]
  }
end

return tokenizer