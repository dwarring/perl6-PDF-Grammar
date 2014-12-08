#!/usr/bin/env perl6

use Test;
use PDF::Grammar::PDF;
use PDF::Grammar::PDF::Actions;

use PDF::Grammar::Test;

my $header = '%PDF-1.3';
my $header_ast = 1.3;

my $ind-ref1 =  '3 0 R';
my $ind-ref1_ast = :ind-ref[ 3, 0 ];

my $ind-obj1 = "1 0 obj
<<
/Type /Catalog
/Pages {$ind-ref1}
/Outlines 2 0 R
>>
endobj
";
my $ind-obj1_ast = :ind-obj[ 1, 0, :dict{ Type => :name<Catalog>,
                                         Pages => $ind-ref1_ast,
                                         Outlines => :ind-ref[ 2, 0 ]}];

my $stream-content = 'BT
  /F1 24 Tf  % useless comment
  100 100 Td (Hello, world!) Tj
ET';
my $stream-length = $stream-content.chars;

my $ind-obj2 = "5 0 obj
<< /Length $stream-length >>
stream
$stream-content
endstream
endobj
";
my $ind-obj2_ast = :ind-obj[ 5, 0,
                             :stream{
                                 :dict{Length => :int(68)}, :start(33), :end(101)
                             }];

my $body = $ind-obj1 ~
$ind-obj2 ~
'3 0 obj
<<
  /Type /Outlines
  /Count 0
>>
endobj
4 2 obj
[/PDF /Text]
endobj';

my $body_objects_ast = [$ind-obj1_ast,
                        :ind-obj[ 5, 0, :stream{ :dict{Length => :int(68)},
                                                 :start(98),
                                                 :end(166)}],
                        :ind-obj[ 3, 0, :dict{Type => :name<Outlines>, Count => :int(0) }],
                        :ind-obj[ 4, 2, :array[ :name<PDF>, :name<Text> ]]];

my $xref = "xref
0 8
0000000000 65535 f
0000000009 00000 n
0000000074 00000 n
0000000120 00000 n
0000000179 00000 n
0000000322 00000 n
0000000415 00000 n
0000000445 00000 n
";
my $xref-ast = [{object-first-num => 0,
                 object-count => 8,
                 entries => [{:offset(0), :gen(65535),  :status<f>},
                             {:offset(9), :gen(0), :status<n>},
                             {:offset(74), :gen(0), :status<n>},
                             {:offset(120), :gen(0), :status<n>},
                             {:offset(179), :gen(0), :status<n>},
                             {:offset(322), :gen(0), :status<n>},
                             {:offset(415), :gen(0), :status<n>},
                             {:offset(445), :gen(0), :status<n>}]
               }];

my $trailer = 'trailer
<<
/Size 8
/Root 1 0 R
>>
startxref
553
';

my $trailer_ast = { :dict{ Size => :int(8),
                           Root => :ind-ref[ 1, 0 ]},
                    :offset(553) };

my $body_trailer_ast = {objects => $body_objects_ast, trailer => $trailer_ast};

my $pdf = "$header
$body
$xref$trailer%\%EOF";

my $actions = PDF::Grammar::PDF::Actions.new;

for (
      pdf-header => {input => $header, ast => $header_ast},
      ind-ref => {input => $ind-ref1, ast => $ind-ref1_ast},
      ind-obj => {input => $ind-obj1, ast => $ind-obj1_ast},
      ind-obj => {input => $ind-obj2, ast => $ind-obj2_ast},
      trailer => {input => $trailer, ast => :trailer($trailer_ast)},
      xref => {input => $xref, ast => :xref($xref-ast)},
      body => {input => $body ~ "\n" ~ $trailer, ast => $body_trailer_ast},
      pdf => {input => $pdf, ast => Mu},
    ) {
     my $rule = .key;
     my %expected = %( .value );
     my $input = %expected<input>;

     note to-json($rule => %expected<ast>) if %expected<ast>.defined;

     PDF::Grammar::Test::parse-tests(PDF::Grammar::PDF, $input, :$rule, :$actions, :suite('pdf doc'), :%expected );
}

done;
