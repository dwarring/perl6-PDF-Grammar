use PDF::Grammar::Actions;

class PDF::Grammar::Function::Actions
    is PDF::Grammar::Actions {

    method TOP($/) { make $<expression>.ast }

    method expression($/) {
        my @expr = $<statement>».ast;
        make (:@expr);
    }

    method statement:sym<conditional>($/) { make $<conditional>.ast; }
    method statement:sym<if>($/)          { make $<if>.ast; }
    method statement:sym<object>($/)      { make $<object>.ast}
    method statement:sym<unexpected>($/)  { make ('??' => $<unexpected>.ast); }
    method unknown($/)    { make ('??' => ~$/); }

    method illegal-object:sym<dict>($/)  { make '??' => $<dict>.ast }
    method illegal-object:sym<array>($/) { make '??' => $<array>.ast }
    method illegal-object:sym<name>($/)  { make '??' => $<name>.ast }
    method illegal-object:sym<null>($/)  { make '??' => Any }

    method int($/)  {
        my $int = do with $<radix-num> {
            # radix notation
            my $radix = $<int>.Int;
            my $sign = $radix < 0 ?? -1 !! 1;
            $sign * .Str.parse-base($radix.abs);
        }
        else {
            # simple integer
            $/.Int;
        }
        make $.lite ?? $int !! :$int;
    }
    method object:sym<ps-op>($/)     { make 'op' => $<ps-op>.ast }
    # extended postcript operators
    method ps-op:sym<arithmetic>($/) { make ~$<op> }
    method ps-op:sym<bitwise>($/)    { make ~$<op> }
    method ps-op:sym<stack>($/)      { make ~$<op> }

    method conditional:sym<if>($/) {
	my $if = $<if-expr>.ast;
	make 'cond' => { :$if }
    }

    method conditional:sym<ifelse>($/) {
	my $if = $<if-expr>.ast;
	my $else = $<else-expr>.ast;
	make 'cond' => { :$if, :$else }
    }

}
