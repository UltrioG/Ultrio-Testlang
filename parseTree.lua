local parser = {
  LOCAL_VAR_DEF = {
    {{"keyword", "local"}, {"keyword", "var"}, {"identifier"}, {"operator", "="}, {"VAL"}},
  },
  VAR_DEF = {
    {{"keyword", "var"}, {"identifier"}, {"operator", "="}, {"VAL"}},
    {{"keyword", "var"}, {"identifier"}},
  },
  FOR = {
    {{"keyword", "for"}, {"EXP"}, {"EXP"}, {"EXP"}, {"EXP"}}
  },
  IF = {
    {{"keyword", "if"}, {"VAL"}, {"EXP"}}
  },
  WHILE = {
    {{"keyword", "while"}, {"VAL"}, {"EXP"}}
  },
  RETURN = {
    {{"keyword", "return"}, {"VAL"}}
  },
  INCDEC = {
    {{"identifier"}, {"operator", "++"}},
    {{"identifier"}, {"operator", "--"}}
  },
  DELTA = {
    {{"identifier"}, {"operator"}, {"VAL"}},
  },
  EXP = {
    {{"separator", "{"}, {"EXP"}, {"separator", "}"}},
    {{"FOR"}},
    {{"VAR_DEF"}}
  },
  VAL = {
    {{"literal"}},
    {{"identifier"}}
  },
}

return parser