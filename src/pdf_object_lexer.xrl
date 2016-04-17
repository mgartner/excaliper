Definitions.
INT          = [0-9]+
FLOAT        = [0-9]+\.[0-9]+
WHITESPACE   = [\s\t\n\r]+
BRACKET      = (<<|>>|\[|\])

Rules.

stream         : {end_token, {stream}}.
endobj         : {end_token, {endobj}}.
xref           : {end_token, {xref}}.
{WHITESPACE}   : skip_token.
{BRACKET}      : skip_token.
{INT}          : {token, {number, list_to_integer(TokenChars)}}.
{FLOAT}        : {token, {number, list_to_float(TokenChars)}}.
\/MediaBox     : {token, {media_box}}.
\/CropBox      : {token, {crop_box}}.
\/Type         : {token, {type}}.
\/Page         : {token, {page}}.
\/Pages        : {token, {pages}}.
.              : skip_token.

Erlang code.
