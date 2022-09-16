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
      literal = {"if", "while", "for", "return", "local"},
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
        "(%b'')", '(%b"")',
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
        "[^%w_]([%a_][%w_]-)[^%w_]"
      }
    }
  }
}

function tokenizer:getAllOccPos(s, sub, lit)
  local occurences = {}
  local first, last = 0, 0
  local element = 0
  while true do
    element = element + 1
    first, last = s:find(sub, first+1, lit)
    if not first then break end
    if element > 1 then
      if occurences[element-1] then
        if occurences[element-1][2] < first then
          -- No repeat check
          table.insert(occurences, {first, last})
        end
      end
    else
      table.insert(occurences, {first, last})
    end
  end
  return occurences
end

function tokenizer:getAllOccPosAndVal(s, sub, lit)
  local occurences = {}
  local first, last, token = 0, 0, ""
  local element = 0
  while true do
    element = element + 1
    first, last, token = s:find(sub, first+1, lit)
    if not first then break end
    if element > 1 then
      if occurences[element-1] then
        if occurences[element-1][3] < first+1 then
          -- No repeat check
          table.insert(occurences, {first+1, token, last})
          -- Add 1 because for some reason first is the character
          -- before the first character of the match
        end
      end
    else
      table.insert(occurences, {first+1, token, last})
    end
  end
  table.foreach(occurences, function(_, v) table.foreach(v, print) end)
  return occurences
end

function tokenizer:findUnclosedString(code)
  local code = code:gsub('%b""', ""):gsub("%b''", "")
  local unclosedSingleQuote = code:find("'[^']*$")
  local unclosedDoubleQuote = code:find('"[^"]*$')
  if unclosedSingleQuote or unclosedDoubleQuote then
    return unclosedDoubleQuote or unclosedSingleQuote
  else
    return nil
  end
end

function tokenizer:removeComment(code)
  return code:gsub("/%*.-%*/", " ")
end

function tokenizer:removeStartEndWhites(code)
  return code:gsub("^%s*", ""):gsub("%S%s-$","%1")
end

function tokenizer:tokenize(code, handle)
  local code = self:removeStartEndWhites(self:removeComment(code))  -- Remove all comments
  
  local tokensFound = {}

  local unclosedStrPos = self:findUnclosedString(code)
  if unclosedStrPos then
    EHand:fatal(2, ([[
    Character %i: Unclosed string detected.
    Code in area:
        %s
    ]]):format(unclosedStrPos, code:sub(unclosedStrPos-20, unclosedStrPos+20)))
  end
  
  for token, contents in pairs(self.tokens) do
    for matchType, matcher in pairs(contents) do
      print(("Parsing %s of %s..."):format(matchType, token))
      if matchType == "literal" then
        for _, lit in ipairs(matcher) do
          for _, v in ipairs(self:getAllOccPos(code, lit, true)) do
            table.insert(tokensFound, {token, v[1], lit})
          end
        end
      elseif matchType == "pattern" then
        for _, pat in ipairs(matcher) do
          for _, v in ipairs(self:getAllOccPosAndVal(code, pat)) do
            
            local isIdent = true
            if token == "identifier" then
              -- Check if it's a keyword
              for _, kw in ipairs(self.tokens.keyword.literal) do
                if kw == v[2] then isIdent = false end
              end
            end
            if isIdent then table.insert(tokensFound, {token, v[1], v[2]}) end
          end
        end
      end
    end
  end

  -- Sort by position
  table.sort(tokensFound, function(a, b) return a[2] < b[2] end)
  
  return tokensFound
end

return tokenizer