use PDF::Grammar;

grammar PDF::Grammar::Content
    is PDF::Grammar {
    #
    # A Simple PDF grammar for parsing PDF content, i.e. Graphics and
    # Text operations as described in sections 8 and 9 of [PDF 1.7].
    rule TOP {^ [<op=.instruction>||<op=.suspect>]* $}

    proto rule instruction {*}
    rule instruction:sym<block> {<block>}
    rule instruction:sym<op>    {<op>}

    # ------------------------
    # Blocks
    # ------------------------

    # text blocks: BT ... ET
    rule opBeginText           { (BT) }
    rule opEndText             { (ET) }

    # marked content blocks: BMC ... EMC   or   BDC ... EMC
    rule opBeginMarkedContent  { <name> (BMC)
                               | <name> [<name> | <dict>] (BDC) }
    rule opEndMarkedContent    { (EMC) }

    # image blocks BI ... ID ... EI
    rule opBeginImage          { (BI) }
    token opImageData          { (ID)[\n|' ']* }
    token opEndImage           { (EI) }

    # blocks have limited nesting capability and aren't fully recursive.
    # So theoretically, we only have to deal with a few combinations...

    rule inner-text-block { <opBeginText> <op>* <opEndText> }
    rule inner-marked-content-block { <opBeginMarkedContent> <op>* <opEndMarkedContent> }
    proto rule block {*}
    rule block:sym<text> { <opBeginText> [ <inner-marked-content-block> | <op> ]* <opEndText> }
    rule block:sym<markedContent> { <opBeginMarkedContent> [ <inner-text-block> | <op> ]* <opEndMarkedContent> }
    rule imageDict {
        [<name> <object>]*
    }
    rule block:sym<image> {
        <opBeginImage>
        <imageDict>
        $<start>=<opImageData>[.*?$<end>=[\n|' ']<opEndImage>
           ||.*?$<end>=<opEndImage>
        ]
    }
    # ------------------------
    # Operators and Objects
    # ------------------------

    # operator names courtersy of xpdf / Gfx.cc (http://foolabs.com/xdf/)
    proto rule op {*}
    rule op:sym<BeginExtended>       { (BX) }
    rule op:sym<CloseEOFillStroke>   { (b\*) }
    rule op:sym<CloseFillStroke>     { (b) } 
    rule op:sym<EOFillStroke>        { (B\*) }
    rule op:sym<FillStroke>          { (B) }

    rule op:sym<CurveTo>             { <number>**6 (c) }
    rule op:sym<ConcatMatrix>        { <number>**6 (cm) }
    rule op:sym<SetFillColorSpace>   { <name> (cs) }
    rule op:sym<SetStrokeColorSpace> { <name> (CS) }

    rule op:sym<SetDashPattern>      { <array> <number> (d) }
    rule op:sym<SetCharWidth>        { <number> <number> (d0) }
    rule op:sym<SetCharWidthBBox>    { <number>**6 (d1) }
    rule op:sym<XObject>             { <name> (Do) }
    rule op:sym<MarkPointDict>       { <name> [<name> | <dict>] (DP) }

    rule op:sym<EndExtended>         { (EX) }

    rule op:sym<EOFill>              { (f\*) }
    rule op:sym<Fill>                { (F|f) }

    rule op:sym<SetStrokeGray>       { <number> (G) }
    rule op:sym<SetFillGray>         { <number> (g) }
    rule op:sym<SetGraphicsState>    { <name> (gs) }

    rule op:sym<ClosePath>           { (h) }

    rule op:sym<SetFlatness>         { <number> (i) }

    rule op:sym<SetLineJoin>         { <int> (j) }
    rule op:sym<SetLineCap>          { <int> (J) }

    rule op:sym<SetFillCMYK>         { <number>**4 (k) }
    rule op:sym<SetStrokeCMYK>       { <number>**4 (K) }

    rule op:sym<LineTo>              { <number> <number> (l) }

    rule op:sym<MoveTo>              { <number> <number> (m) }
    rule op:sym<SetMiterLimit>       { <number> (M) }
    rule op:sym<MarkPoint>           { <name> (MP) }

    rule op:sym<EndPath>             { (n) }

    rule op:sym<Save>                { (q) }
    rule op:sym<Restore>             { (Q) }

    rule op:sym<Rectangle>           { <number>**4 (re) }
    rule op:sym<SetFillRGB>          { <number>**3 (rg) }
    rule op:sym<SetStrokeRGB>        { <number>**3 (RG) }
    rule op:sym<SetRenderingIntent>  { <name> (ri) }

    rule op:sym<CloseStroke>         { (s) }
    rule op:sym<Stroke>              { (S) }
    rule op:sym<SetStrokeColor>      { <number>+ (SC) }
    rule op:sym<SetFillColor>        { <number>+ (sc) }
    rule op:sym<SetFillColorN>       { <object>+ (scn) }
    rule op:sym<SetStrokeColorN>     { <object>+ (SCN) }
    rule op:sym<ShFill>              { <name> (sh) }

    rule op:sym<TextNextLine>        { (T\*) }
    rule op:sym<SetCharSpacing>      { <number> (Tc) }
    rule op:sym<TextMove>            { <number> <number> (Td) }
    rule op:sym<TextMoveSet>         { <number> <number> (TD) }
    rule op:sym<SetFont>             { <name> <number> (Tf) }
    rule op:sym<ShowText>            { <string> (Tj) }
    rule op:sym<ShowSpaceText>       { <array> (TJ) }
    rule op:sym<SetTextLeading>      { <number> (TL) }
    rule op:sym<SetTextMatrix>       { <number>**6 (Tm) }
    rule op:sym<SetTextRender>       { <int> (Tr) }
    rule op:sym<SetTextRise>         { <number> (Ts) }
    rule op:sym<SetWordSpacing>      { <number> (Tw) }
    rule op:sym<SetHorizScaling>     { <number> (Tz) }

    rule op:sym<CurveToInitial>      { <number>**4 (v) }

    rule op:sym<EOClip>              { (W\*) }
    rule op:sym<Clip>                { (W) } 
    rule op:sym<SetLineWidth>        { <number> (w) }

    rule op:sym<CurveToFinal>        { <number>**4 (y) }

    rule op:sym<MoveSetShowText>     { <number> <number> <string> (\") } 
    rule op:sym<MoveShowText>        { <string> (\') }

    # catchall for unknown opcodes and arguments
    token op-like { <[a..zA..Z\*\"\']><[\w\*\"\']>* }
    rule suspect  { <object>* (<.op-like>) } 
}
