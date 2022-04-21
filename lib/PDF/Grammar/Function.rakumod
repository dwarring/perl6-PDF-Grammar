use PDF::Grammar;

grammar PDF::Grammar::Function
    is PDF::Grammar {
    #
    # Simple PDF grammar extensions for parsing PDF Type 4 PostScript
    # Calculator Functions, as described in [PDF 1.7] section 7.10.5
    rule TOP {^ <expression> $}

    rule expression { '{' [<statement>||<statement=.unknown>]* '}' }

    proto rule statement {*}
    rule statement:sym<conditional> { <conditional> }
    rule statement:sym<object>      { <object=.illegal-object>||<object> }

    # illegal in the postscript function subset
    proto rule illegal-object {*}
    rule illegal-object:sym<dict>   { <dict> }
    rule illegal-object:sym<array>  { <array> }
    rule illegal-object:sym<name>   { <name> }
    rule illegal-object:sym<string> { <string> }
    rule illegal-object:sym<null>   { <sym> }

    # postscript integers can be in radix notation
    # - redefine <int>
    token int { $<int>=[< + - >?<digit>+]['#'$<radix-num>=<[0..9 a..z A..Z]>+]? }
    # - postscript operators
    rule object:sym<ps-op> {<ps-op>}

    proto token ps-op {*}

    token ps-op:sym<arithmetic> {
        $<op>=[abs|add|atan|ceiling|cos|cvi|cvr|div|exp|floor
        |idiv|ln|log|mod|mul|neg|round|sin|sqrt|sub|truncate]
    }

    token ps-op:sym<bitwise> {
        $<op>=[and|bitshift|eq|false|ge|gt|le|lt|ne|not|or|true|xor]
    }

    token ps-op:sym<stack> {
        $<op>=[copy|dup|exch|index|pop|roll]
    }

    proto rule conditional {*}
    rule conditional:sym<if>     { <if-expr=.expression> 'if' }
    rule conditional:sym<ifelse> { <if-expr=.expression> <else-expr=.expression> 'ifelse' }

    token unknown { <alpha><[\w]>* }
}
