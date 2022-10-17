local com = require("common")
local tok = require("tokenizer")
local err = require("error_handler")

local oldpath = package.path
package.path = './love-struct-master/?.lua;' .. package.path
local DAT = require("init")
package.path = oldpath

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
      {{"separator", "{"}, {"EXP"}, {"separator", "}"}},
      {{"FOR"}},
      {{"VAR_DECLARE"}},
    }
  }
}

local Tree = DAT.tree
local newTree = Tree(1)

function parser.parseToken()

end

return parser