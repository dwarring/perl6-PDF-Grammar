#!/usr/bin/env perl6
use v6;
use Test;

use PDF::Grammar::Content;
use PDF::Grammar::Content::Fast;
use PDF::Grammar::Content::Actions;

my $sample_content1 = '/RGB CS';
my $ast1 = [ :CS[ :name<RGB> ]];

my $sample_content2 = '100 125 m 9 0 0 9 476.48 750 Tm';
my $ast2 = [ :m[ :int(100), :int(125) ], :Tm[ :int(9), :int(0), :int(0), :int(9), :real(476.48), :int(750)]];
my $ast2-lite = [ :m[ 100, 125 ], :Tm[ 9, 0, 0, 9, 476.48, 750]];

my $sample_content2a = '[(Hello)(World)]TJ';
my $ast2a = [ :TJ[ :array[ :literal<Hello>, :literal<World> ]] ];

my $sample_content3 = 'BT 100 350 Td [(Using this Guide)-13.5( . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .)-257.1( xiii)]TJ ET';

my $sample_content4 = '/foo <</xKey /yVal>> BDC 50 50 m BT 200 200 Td ET EMC'; 
my $ast4 = [:BDC[ :name<foo>, :dict{xKey => :name<yVal>}], :m[ :int(50), :int(50)], :BT[], :Td[ :int(200), :int(200) ], :ET[], :EMC[] ];

my $sample_content5 = q:to/END4/;
/GS1 gs
BT
  /TT6 1 Tf
  9 0 0 9 476.48 750 Tm
  0 g
  0 Tc
  0 Tw
  (Some random test opcodes)Tj
  1.6111 -1.2222 TD
  (version 10.0)Tj
  -42.5533 -77.3778 TD
  (Doc. Revision 1.0)Tj
  45.04 0 TD
  (Page i)Tj
ET
.25 .085 0 .25 K
2 J 0 j .51 w 3.86 M [] 0 d
1 i 
q 1 0 0 1 540 54 cm 0 0 m
-432 0 l
S
Q
/EmbeddedDocument /MC3 BDC
  q
  66.184 0 0 29 474.55 705.39 cm
  /Im3 Do
  Q
EMC
BT
  /TT2 1 Tf
  22 0 0 22 108 676.53 Tm
  -.01 Tc
  (Contents)Tj
  12 0 0 12 108 641.2 Tm
  0 Tc
  [(Using this Guide)-13.5( . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .)-257.1( xiii)]TJ
  /TT8 1 Tf
  .0909 Tw
  [( ...almost there)]TJ
  -37.9318 -1.2727 TD
  0 Tw
ET
END4

my $sample_content6 = q:to/END5/;    # example from [PDF 1.7] Section 7.8
0.0 G                                   % Set stroking colour to black
1.0 1.0 0.0 rg                          % Set nonstroking colour to yellow
25 175 175 -150 re                      % Construct rectangular path
f                                       % Fill path
/Cs12 cs                                % Set pattern colour space
0.77 0.20 0.00 /P1 scn                  % Set nonstroking colour and pattern
99.92 49.92 m                           % Start new path
99.92 77.52 77.52 99.92 49.92 99.92 c   % Construct lower-left circle
22.32 99.92 -0.08 77.52 -0.08 49.92 c
-0.08 22.32 22.32 -0.08 49.92 -0.08 c
77.52 -0.08 99.92 22.32 99.92 49.92 c
B                                       % Fill and stroke path
0.2 0.8 0.4 /P1 scn                     % Change nonstroking colour
224.96 49.92 m                          % Start new path
224.96 77.52 202.56 99.92 174.96 99.92 c% Construct lower-right circle
147.36 99.92 124.96 77.52 124.96 49.92 c
124.96 22.32 147.36 -0.08 174.96 -0.08 c
202.56 -0.08 224.96 22.32 224.96 49.92 c
B                                       % Fill and stroke path
0.3 0.7 1.0 /P1 scn                     % Change nonstroking colour
87.56 201.70 m                          % Start new path
63.66 187.90 55.46 157.30 69.26 133.4 c % Construct upper circle
83.06 109.50 113.66 101.30 137.56 115.10 c
161.46 128.90 169.66 159.50 155.86 183.40 c
142.06 207.30 111.46 215.50 87.56 201.70 c
B                                       % Fill and Stroke path
0.5 0.2 1.0 /P1 scn                     % Change nonstroking colour
50 50 m                                 % Start new path
175 50 l                                % Construct triangular path
112.5 158.253 l
b                                       % Close, fill, and stroke path
END5

my $unknown_op_content = '10 10 Td 42 dud';
my $unknown_op_ast = ["Td" => ["int" => 10, "int" => 10], "??" => :dud["int" => 42] ];

my $wrong_arg_type_content = '10 (blah) Td';
my $wrong_arg_type_ast = ['??' => :Td["int" => 10, "literal" => 'blah'] ];
my $wrong_arg_type_ast-lite = ['??' => :Td[10, "literal" => 'blah'] ];

my $missing_arg_content = '10 Td';
my $missing_arg_ast = ['??' => :Td["int" => 10] ];

my $extra_arg_content = '10 10 42 Td';
my $extra_arg_ast = ['??' => :Td["int" => 10, int => 10, int => 42] ];

my $sample_content_bx = 'q
0.0648041 0 0 -0.0590057 38.1269989 736.3480072 cm
BX /Sh0 sh EX Q';

my $ast_bx = [
:q[], :cm[ :real(0.0648041), :int(0), :int(0), :real(-0.0590057), :real(38.1269989), :real(736.3480072)],
:BX[],
:sh[ :name<Sh0> ],
:EX[],
:Q[],
];

my $test_image_block = 'BI                  % Begin inline image object
    /W 17           % Width in samples
    /H 17           % Height in samples
    /CS /RGB        % Colour space
    /BPC 8          % Bits per component
    /F [/A85 /LZW]  % Filters
ID                  % Begin image data
J1/gKA>.]AN&J?]-<HW]aRVcg*bb.\eKAdVV%/PcZ
%R.s(4KE3&d&7hb*7[%Ct2HCqC~>
EI';
my $test_image_ast = [:BI[ :dict{BPC => :int(8),
                                      F => :array[ :name<A85>, :name<LZW> ],
                                      H => :int(17),
                                      W => :int(17),
                                      CS => :name<RGB>}],
                            :ID[:encoded("J1/gKA>.]AN\&J?]-<HW]aRVcg*bb.\\eKAdVV\%/PcZ\n\%R.s(4KE3\&d\&7hb*7[\%Ct2HCqC~>")],
                            :EI[]];
my $test_image_null = "
BI
/IM true/W 1/H 1/BPC 1
ID \c0
EI";

my $test_image_null_ast = [:BI[ :dict{BPC => :int(1),
                                      IM => :bool,
                                      H => :int(1),
                                      W => :int(1),
                                      }],
                            :ID[:encoded("\c0")],
                            :EI[]];

my PDF::Grammar::Content::Actions $actions .= new;
my PDF::Grammar::Content::Actions $lite-actions .= new: :lite;

for (:trivial[$sample_content1, $ast1],
     :basic[$sample_content2, $ast2, $ast2-lite],
     :basic-array[$sample_content2a, $ast2a, $ast2a],
     :toc-entry[$sample_content3],
     :text-block[$sample_content4, $ast4],
     :extended[$sample_content_bx, $ast_bx],
     :image-block[$test_image_block, $test_image_ast],
     :image-null[$test_image_null, $test_image_null_ast],
     :unknown-op[$unknown_op_content, $unknown_op_ast],
     :missing-arg[$missing_arg_content, $missing_arg_ast],
     :wrong-arg[$wrong_arg_type_content, $wrong_arg_type_ast, $wrong_arg_type_ast-lite],
     :extra-arg[$extra_arg_content, $extra_arg_ast],
     :pdf-ref-example[$sample_content6],
     :real-word-example[$sample_content5],
     ) {
    my ($test, $spec) = $_.kv;
    my ($str, $expected-ast, $lite-ast) = @$spec;
    for :normal(PDF::Grammar::Content), :fast(PDF::Grammar::Content::Fast) {
        my $speed = .key;
        my $grammar = .value;
        my $p = $grammar.parse($str, :$actions);
        ok $p, "$test $speed - parsed pdf content"
            or do {diag ("unable to parse: $str"); next};

        if $expected-ast {
            cmp-ok $p.ast, 'eqv', $expected-ast, "$test $speed - result as expected";
        }
        if $lite-ast {
            $p = $grammar.parse($str, :actions($lite-actions));
            cmp-ok $p.ast, 'eqv', $lite-ast, "$test $speed (lite) - result as expected";
        }
    }
}

done-testing;
