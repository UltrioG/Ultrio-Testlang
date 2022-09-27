--[[
Language design:
  UTLang is pretty much a joke.
  There is next to no syntactical sugar.

  Datatypes:
    complex: Complex numbers, the only type of numbers.
      Notation: 0.0+0.0i; -0.0+0.0i; 0.0-0.0i; -0.0-0.0i
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
      literal = {"if", "while", "for", "return", "local", "var"},
      pattern = {}
    },
    separator = {
      literal = {"{", "}", "[", "]", "(", ")"},
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
        "(%-?%d+%.%d+%s*[%+%-]%s*%d+%.%d+i)", "(%-?%d+%.%d+i%s*[%+%-]%s*%d+%.%d+)",
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
        "^([%a_][%w_]-)[^%w_\"']",
        "[^%w_\"']([%a_][%w_]-)$",
        "^([%a_][%w_]-)$",
        "[^%w_\"']([%w_])[^%w_\"']"
      }
    }
  }
}

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
end

function tokenizer.tokenizeLine(line, lineCount, inComment)
  if inComment and not tokenizer.hasCommentClose(line) then return {}, true end
  local proxyLine, changed = tokenizer.removeComments(line)
  if tokenizer.hasUnclosedComment(line) and not tokenizer.hasCommentClose(line) then
    return {}, true
  end
  local tokens = {}
  
  for tokenType, matchGroup in pairs(tokenizer.tokens) do
    for matchType, matchSet in pairs(matchGroup) do
      for _, matchString in pairs(matchSet) do
        -- TODO: Fix annoying string.find indexing bug
        local litMatch = matchType == "literal"
        local first = 0
        local last = 0
        local match = ""
        while true do
          first, last, match = proxyLine:find(matchString, last+1, litMatch)
          if not first then break end
          if litMatch then match = proxyLine:sub(first, last) end
          if tokenType == "identifier" and tokenizer.isSpecialWord(match) then break end
          table.insert(
            tokens, {first, last, lineCount, tokenType, match or proxyLine:sub(first, last)}
          )
        end
      end
    end
  end
  
  table.sort(tokens, function(a, b)
      return a[1] < b[1]
    end)
  
  return tokens, false
end

return tokenizer