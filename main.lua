local tok = require("tokenizer")
local err = require("error_handler")

-- Interpretation
local fileName = io.read("*l")
local handle = assert(io.open(fileName, "r"))



handle:close()

-- Runtime