use v6;

use PDF::Grammar;

# Abstract Grammar for COS (Carousel Object System). This is the serialization format that underpins PDF, and FDF.
grammar PDF::Grammar::COS
    is PDF::Grammar {
    #
    # An experimental Perl6  grammar for describing the basic block
    # structure of PDF documents.
    #
    rule TOP {^<pdf>$}
    rule pdf {<header> [<body>+] }

    # [PDF 1.7] 7.5.2 File Header
    # ---------------
    token header   {'%'<doc-type>'-'$<version>=[\d'.'\d]}
    token doc-type { <alnum>+ }

    # index section is optional - document could have a cross reference stream
    # quite likely if linearized [PDF 1.7] 7.5.8 & Annex F (Linearized PDF)
    rule body     { <ind-obj>+ <index>? <startxref>?}

    rule index    { <xref>? <trailer> }

    rule ind-obj  { <obj-num=.int> <gen-num=.int> obj <object> endobj }

    rule ind-ref  { <obj-num=.int> <gen-num=.int> R }

    # Object extensions:
    # modify <dict> - allow trailing stream anywhere
    rule object:sym<dict>  { <dict> <stream>? }
    # add <indirect-ref> to the list of permitted objects
    rule object:sym<ind-ref>  { <ind-ref> }

    # stream parsing
    token stream-head  {<.ws>stream\n}
    token stream-tail  {\n? endstream <.ws-char>+}
    token stream       {<stream-head>
                        .*?
                        $<stream-tail>=[\n? endstream <.ws-char>+] # inlined <stream-tail> for speed
                       }

    # cross reference table
    rule  xref         { xref\n<xref-section>+ }
    rule  xref-section {<obj-first-num=.int> <obj-count=.int>' '*\n<xref-entry>*}
    rule  xref-entry   {<byte-offset=.int> <gen-number=.int> <obj-status>' '?\n}
    proto token obj-status      {*}
    token obj-status:sym<free>  {f}
    token obj-status:sym<inuse> {n}

    # the trailer contains the position of the cross reference
    # table plus the file trailer dictionary
    rule trailer {
        trailer
        <dict>
    }

    rule startxref {
        startxref\n
        <byte-offset=.int>\n
    }

}