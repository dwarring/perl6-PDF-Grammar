#!/usr/bin/env perl6
use v6;
use Test;

use PDF::Grammar::FDF;

my $fdf-small = '%FDF-1.2
%âãÏÓ
1 0 obj
<</FDF
    << /F (small.pdf) /Fields [<</T(barcode)/V(*TEST-1234*)>>] >>
>>
endobj
trailer
<</Root 1 0 R>>
%%EOF';

my $fdf-medium = '%FDF-1.2
%âãÏÓ
1 0 obj<</FDF<</F(Document.pdf)
/ID[<7a0631678ed475f0898815f0a818cfa1><bef7724317b311718e8675b677ef9b4e>]
/Fields[<</T(Street)/V(345 Park Ave.)>><</T(City)/V(San Jose)>>]>>>>
endobj
trailer
<</Root 1 0 R>>
%%EOF';

my $fdf-body = q:to/END_END_END/;
%FDF-1.2
%âãÏÓ
1 0 obj
<</FDF<</F(file.pdf)/Fields[<</T(barcode)/V(*TEST-1234*)>><</T(binding)/V(Perfect)>><</T(chicklet)>><</T(date)/V(E0909)>><</T(link)/V(LINK )>><</T(java)/V(false)>><</Kids[<</T(label)/V(Click )>>]/T(javalogo)>><</T(lblbinding)/V(binding)>><</T(lblpages)/V(pages)>><</T(logoback)/V(h)>><</T(pages)/V(100)>><</T(pages2)/V(100)>><</T(printed)/V(Printed)>><</T(printnote)/V(printer note)>><</Kids[<</T(label)/V(Printed)>>]/T(recycled)>><</T(revision)/V(2)>><</T(server)/V(SERVER)>><</Kids[<</T(lines)/V(1)>>]/T(spine)>><</T(spine1)/V(TEST's Great Document)>><</T(spine1outline)/V( )>><</T(spine2)/V(Spine Title 2)>><</T(spine2outline)/V( )>><</T(spine3)/V(Spine Title 3)>><</T(spine3outline)/V( )>><</Kids[<</T(lines)/V(1)>>]/T(spinesub)>><</T(spinesub1)/V(System VALUE)>><</T(spinesub1outline)/V( )>><</T(spinesub2)/V(SpineSub-title2)>><</T(spinesub2outline)/V( )>><</T(spinesub3)/V(SpineSub-title3)>><</T(spinesub3outline)/V( )>><</T(state)/V(submit)>><</T(templatepn)/V(TEMPLATE)>><</T(thick)/V(1.8)>><</T(title1)/V(TITLE1 FOR TEST)>><</T(title2)/V( asfasdfasdf)>><</T(title3)/V(System VALUE 2)>><</T(title4)/V(Volume TEST)>><</T(xoffset)/V(0)>><</T(yoffset)/V(0)>>]/ID[<6D8B89AFD4447F4C31D5A7CC958E2132><B2E3BAB4C29B024EB10BFB11C43DCCE1>]/UF(file.pdf)>>/Type/Catalog>>
endobj
trailer
<</Root 1 0 R>>
%%EOF
END_END_END

for (small => $fdf-small, medium => $fdf-medium, real => $fdf-body) {
    my $p = PDF::Grammar::FDF.parse($_.value);

    ok($p, "fdf parse " ~ $_.key)
        or diag $_.value; 
}

done;
