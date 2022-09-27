local parser = {
  LOCAL_VAR_DEF = {
    {{"keyword", "local"}, {"keyword", "var"}, {"identifier"}, {"operator", "="}, {"EXP"}},
  },
  VAR_DEF = {
    {{"keyword", "var"}, {"identifier"}, {"operator", "="}, {"EXP"}},
    {{"keyword", "var"}, {"identifier"}},
  },
  FOR = {
    {{"keyword", "for"}, {"EXP"}, {"EXP"}, {"EXP"}, {"EXP"}}
  },
  IF = {
    {{"keyword", "if"}, {"EXP"}, {"EXP"}}
  },
  WHILE = {
    {{"keyword", "while"}, {"EXP"}, {"EXP"}}
  },
  RETURN = {
    {{"keyword", "return"}, {"EXP"}}
  },
  INCDEC = {
    {{"identifier"}, {"operator", "++"}},
    {{"identifier"}, {"operator", "--"}}
  },
  DELTA = {
    {{"identifier"}, {"operator"}, {"EXP"}},
  },
  EXP = {
    {{"separator", "{"}, {"EXP"}, {"separator", "}"}},
    {{"FOR"}},
    {{"VAR_DEF"}},

    {{"literal"}},
    {{"identifier"}},
  },
}

return parser