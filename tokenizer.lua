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
      literal = {"if", "while", "for", "return", "local", "var", "notation"},
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

function tokenizer.splitToLines(str)
  local lines = {}
  for line in str:gmatch("[^\r\n]+") do
    table.insert(lines, line)
  end
  return lines
end

function tokenizer.tokenizeLine(str)
  local tokens = {}
  local inComment = false
  for tokenType, matchSet in pairs(tokenizer.tokens) do
    for matchType, matchString in pairs(matchSet) do
      
    end
  end
end

return tokenizer