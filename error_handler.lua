local handler = {
  errorCodes = {
    "UnspecifiedError",
    "SyntaxError",
    "ParsingError",
    "RuntimeError",
  },
  fatalFlavor = {
    "Ow, that kinda hurt.",
    "Please, PLEASE don't let that happen again. I don't like it.",
    "OWIEOWIEOWIEOWIEOWIE",
    "Please, think of the consequences of your code.",
    "I... don't want to do this anymore.",
    "I'm scared. Every mistake you make hurts me.",
    "The worst thing about mistakes are that most of them are unforseen."
  }
}

function handler:fatal(errCode, msg)
  local errCode = errCode or 1
  io.stderr:write(
    "\n\n"..self.errorCodes[errCode]..":\n"..msg
    .."\n"..self.fatalFlavor[math.random(#self.fatalFlavor)].."\n"
  )
end

function handler:assert(v, errCode, msg)
  if not v then self:fatal(errCode, msg) end
end

return handler