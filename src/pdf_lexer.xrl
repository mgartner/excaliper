Definitions.
INT        = [0-9]+
FLOAT      = [0-9]+\.[0-9]+
WHITESPACE = [\s\t\n\r]+
BRACKET    = (<<|>>|\[|\])
STRING     = \/?[a-zA-Z\(\)_\/]+[_0-9]*

Rules.

stream        : {end_token, {stream}}.
endobj        : {end_token, {endobj}}.
xref          : {end_token, {xref}}.
[\:\.-]       : skip_token.
{WHITESPACE}  : skip_token.
{BRACKET}     : skip_token.
{STRING}      : {token, {string, TokenChars}}.
{INT}         : {token, {number, list_to_integer(TokenChars)}}.
{FLOAT}       : {token, {number, list_to_float(TokenChars)}}.

Erlang code.
