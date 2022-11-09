local handler = {
  errorCodes = {
    "UnspecifiedError",
    "SyntaxError",
    "ParsingError",
    "RuntimeError",
		"ArgumentError",
		"UnimplementedError"
  },
  fatalFlavor = {
    "Ow, that kinda hurt.",
    "Please, PLEASE don't let that happen again. I don't like it.",
    "OWIEOWIEOWIEOWIEOWIE",
    "Please, think of the consequences of your code.",
    "I'm scared. Every mistake you make hurts me.",
    "The worst thing about mistakes are that most of them are unforseen.",
    "Minor spelling mistake :boowomp:",
  }
}

function handler:fatal(errCode, msg)
  local errCode = errCode or 1
	local msg = msg or ""
  io.stderr:write(
    "\n\n"..self.errorCodes[errCode]..":\n"..msg
    .."\n\n{[{[( > "..self.fatalFlavor[math.random(#self.fatalFlavor)].." < )]}]}\n"
  )
end

function handler:assert(v, errCode, msg)
  if not v then self:fatal(errCode, msg) end
end

return handler