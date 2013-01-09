use v6;

grammar PDF::Grammar {
    # abstract base grammar for PDF Elements, see instances:
    # PDF::Grammar::Body     - Overall PDF Document Structure
    # PDF::Grammar::Content  - Text and Graphics Content
    # 

    # [PDF 1.7] 7.2.2 Character Set + 7.2.3 Comment characters
    # ---------------
    # This <ws> rule treats % as "comment to eol".
    token ws_char {['%' <- eol>* <eol>? | "\n" | "\t" | "\o12" | "\f" | "\r" | " "]}

    token ws {
	<!ww>
	<ws_char>*}

    token eol {"\r\n"  # ms/dos
               | "\n"  #'nix
               | "\r"} # mac-osx

    # [PDF 1.7] 7.3.3  Numeric Objects
    # ---------------
    token integer { ['+' | '-']? \d+ }
    # reals must have at least one digit either before or after the decimal
    # point
    token real { ['+' | '-']? [[\d+\.\d*] | [\d*\.\d+]] }

    rule number { <real> | <integer> }

    token line_continuation {"\\"<eol>}
    token octal_code { <[0..7]> ** 1..3 }
    token char_code  {<[nrtbf\(\)\\]>}
    token escape_seq { '\\'[<octal_code>|<char_code>]? }
    # literal_character - all but '(' ')' '\'
    token literal_chars { <-[\(\)\\\n\r]>+ }
    # nb
    # -- new-lines are acceptable within strings
    # -- nested parenthesis are acceptable - allow recursive substrings
    rule literal_string {'('[<line_continuation>|<eol>|<escape_seq>|<literal_string>|<literal_chars>]*')'}

    # hex strings
    token hex_char {<xdigit>**1..2}
    token hex_string { \<<hex_char>[<hex_char>|<eol>]*\> }

    rule string {<hex_string>|<literal_string>}

    token name_char_number_symbol { '##' }
    # name escapes are strictly two hex characters
    token name_char_escaped { '#'<hex_char> }
    # all printable but '#', '/', '[', ']',
##  not having any luck with the following regex; me? rakudo-star? (2012.11)
##   token name_char_printable { <[\!..\~] - [\[\#\]\//\(\)\<\>]> }
##  .. rather more ungainly...
    token name_chars_printable { <[a..z A..Z 0..9 \! \" \$..\' \*..\. \: \; \= \? \@ _ \^ \' \{ \| \} \~]>+ }

    rule name { '/'[<name_chars_printable>|<name_char_escaped>|<name_char_number_symbol>]+ }

    # [PDF 1.7] 7.3.2  Boolean objects + Null object
    # ---------------
    token bool { ['true' | 'false'] }

    token null { 'null' }

    rule array {\[ <operand>* \]}
    rule dict {'<<' [<name> <operand>]* '>>'}

    # Operand - as permitted in Content streams [PDF 1.7] 7.8.2
    rule operand { <number> | <bool> | <string> | <name> | <array> | <dict> | <null> }
};
