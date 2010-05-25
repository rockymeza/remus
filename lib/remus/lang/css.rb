module Remus::Lexer
    
    class Css < Lexer
      Tokens = {
        :base => [ {
          # punctuation will match { and open a definition
          /\{/ => [ :punctuation, :definition ],
          
          # identifier will match body, div#id, span.class, p#id.class, #id, .class
          /[a-z0-9\.#_-]+/i => :identifier,
          
          # variable will match :pseudo-selector
          /:[a-z0-9_-]+/ => :variable,
        }, [ :global ] ],
        :global => [ {
          # comment will match /* ... */
          /\/\*.*?\*\//m =>  :comment,
          
          # keyword
          /!important|inherit/ => :keyword,
          
          # plain
          /[,\s]+/ => :plain,
        } ],
        :definition => [ {
          # variable will match color:, and ;
          /[\w-]+:|;/i => :variable,
          
          #punctuation will match } and close out
          /\}/ => [ :punctuation, :close ],
          
          # string will match "...", '...', and url(...)
          /(["']).*?\1|url\(.*?\)/i => :string,
          
          # number will match 12, 12px, 12em, 12%, #123asd, #fff
          /[0-9\.\%]+(?:px|em)?{0,1}|#([a-f0-9]{6}|[a-f0-9]{3})/i => :number,
          
          # reserved will match colors, etc.
          # Thanks to W3Schools: http://www.w3schools.com/tags/ref_color_tryit.asp
          /\b(?:aliceblue|antiquewhite|aqua|aquamarine|azure|beige|bisque|black|blanchedalmond|blue|blueviolet|brown|burlywood|cadetblue|chartreuse|chocolate|coral|cornflowerblue|cornsilk|crimson|cyan|darkblue|darkcyan|darkgoldenrod|darkgray|darkgreen|darkkhaki|darkmagenta|darkolivegreen|darkorange|darkorchid|darkred|darksalmon|darkseagreen|darkslateblue|darkslategray|darkturquoise|darkviolet|deeppink|deepskyblue|dimgray|dodgerblue|firebrick|floralwhite|forestgreen|fuchsia|gainsboro|ghostwhite|gold|goldenrod|gray|green|greenyellow|honeydew|hotpink|indianredindigoivory|khaki|lavender|lavenderblush|lawngreen|lemonchiffon|lightblue|lightcoral|lightcyan|lightgoldenrodyellow|lightgrey|lightgreen|lightpink|lightsalmon|lightseagreen|lightskyblue|lightslategray|lightsteelblue|lightyellow|lime|limegreen|linen|magenta|maroon|mediumaquamarine|mediumblue|mediumorchid|mediumpurple|mediumseagreen|mediumslateblue|mediumspringgreen|mediumturquoise|mediumvioletred|midnightblue|mintcream|mistyrose|moccasin|navajowhite|navy|oldlace|olive|olivedrab|orange|orangered|orchid|palegoldenrod|palegreen|paleturquoise|palevioletred|papayawhip|peachpuff|peru|pink|plum|powderblue|purple|red|rosybrown|royalblue|saddlebrown|salmon|sandybrown|seagreen|seashell|sienna|silver|skyblue|slateblue|slategray|snow|springgreen|steelblue|tan|teal|thistle|tomato|turquoise|violet|wheat|white|whitesmoke|yellow|yellowgreen)?\b/i => :reserved,
          
          # Thanks to W3Schools: http://www.w3schools.com/css/css_websafe_fonts.asp
          /\b(?:Georgia|serif|Palatino|Times|Arial|Helvetica|Gadget|cursive|Impact|Charcoal|sans-serif|Tahoma|Geneva|Helvetica|Verdana|Geneva|Courier|monospace|Monaco)?\b/ => :reserved,
          
          # Thanks to Pygments: http://dev.pocoo.org/projects/pygments/browser/pygments/lexers/web.py
          /\b(?:above|absolute|always|armenian|aural|auto|avoid|baseline|behind|below|bidi-override|blink|block|bold|bolder|both|capitalize|center-left|center-right|center|circle|cjk-ideographic|close-quote|collapse|condensed|continuous|crop|crosshair|cross|cursive|dashed|decimal-leading-zero|decimal|default|digits|disc|dotted|double|e-resize|embed|extra-condensed|extra-expanded|expanded|fantasy|far-left|far-right|faster|fast|fixed|georgian|groove|hebrew|help|hidden|hide|higher|high|hiragana-iroha|hiragana|icon|inherit|inline-table|inline|inset|inside|invert|italic|justify|katakana-iroha|katakana|landscape|larger|large|left-side|leftwards|level|lighter|line-through|list-item|loud|lower-alpha|lower-greek|lower-roman|lowercase|ltr|lower|low|medium|message-box|middle|mix|monospace|n-resize|narrower|ne-resize|no-close-quote|no-open-quote|no-repeat|none|normal|nowrap|nw-resize|oblique|once|open-quote|outset|outside|overline|pointer|portrait|px|relative|repeat-x|repeat-y|repeat|rgb|ridge|right-side|rightwards|s-resize|sans-serif|scroll|se-resize|semi-condensed|semi-expanded|separate|serif|show|silent|slow|slower|small-caps|small-caption|smaller|soft|solid|spell-out|square|static|status-bar|super|sw-resize|table-caption|table-cell|table-column|table-column-group|table-footer-group|table-header-group|table-row|table-row-group|text|text-bottom|text-top|thick|thin|transparent|ultra-condensed|ultra-expanded|underline|upper-alpha|upper-latin|upper-roman|uppercase|visible|w-resize|wait|wider|x-fast|x-high|x-large|x-loud|x-low|x-small|x-soft|xx-large|xx-small|yes)?\b/ => :reserved,
          
          # plain
          /[\w-]+/i => :plain,
        }, [ :global ] ]
      }
    end
    
end
