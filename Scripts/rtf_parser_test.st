#!/Library/bin/stexec

| current_style |

Environment loadModule:'AppKit'.

body   := NSMutableString new.
styles := NSMutableDictionary new.

current_style := 'font:x'.

_makeStyle_ := [ :attr |
    font := attr @ 'NSFont'.
    n = (font description).
    current_style := 'class=' += n.
].

_printLine_ := [ :attr :text |
    _makeStyle_ value:attr.

    body appendString:current_style.
    body appendString:text.
].

path := 'index.rtfd'.
astr := (NSAttributedString  alloc) 
      initWithPath:path documentAttributes:nil.

i    := 0.
sz   := astr length.
p    := NSNumber pointerForRange.

[i < sz] whileTrue: [
    attr := astr attributesAtIndex:i effectiveRange:p.
    r := p rangeValue.

    text := astr string substringWithRange:r.
    i := (r location) + (r length).

    _printLine_ value:attr value:text.
].

Transcript show:body.
