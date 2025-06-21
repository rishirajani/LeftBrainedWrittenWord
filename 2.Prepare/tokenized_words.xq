xquery version "3.1";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace functx = "http://www.functx.com";

declare function functx:substring-after-if-contains 
  ( $arg as xs:string? ,
    $delim as xs:string )  as xs:string? {
       
   if (contains($arg,$delim))
   then substring-after($arg,$delim)
   else $arg
 } ;

declare function functx:name-test 
  ( $testname as xs:string? ,
    $names as xs:string* )  as xs:boolean {
       
$testname = $names
or
$names = '*'
or
functx:substring-after-if-contains($testname,':') =
   (for $name in $names
   return substring-after($name,'*:'))
or
substring-before($testname,':') =
   (for $name in $names[contains(.,':*')]
   return substring-before($name,':*'))
 } ;

declare function functx:remove-elements 
  ( $elements as element()* ,
    $names as xs:string* )  as element()* {
       
   for $element in $elements
   return element
     {node-name($element)}
     {$element/@*,
      $element/node()[not(functx:name-test(name(),$names))] }
 };
 
 
 
 declare function local:remove-special-chars($token as xs:string) as xs:string {
  let $punctuation-start := '[\p{Ps}\p{Pe}\p{Pc}\p{Pd}\p{Ps}\p{Pe}\p{Po}\p{Ps}\p{Pe}\p{Pi}\p{Pf}\p{Po}\p{Pd}\p{Pc}]'
  let $cleaned-token :=
    replace(
      replace($token, concat('^', $punctuation-start, '+'), '', 'i'),
      concat($punctuation-start, '+$'), '', 'i'
    )
  return $cleaned-token
};
 
declare function functx:remove-elements-not-contents 
  ( $nodes as node()* ,
    $names as xs:string* )  as node()* {
       
   for $node in $nodes
   return
    if ($node instance of element())
    then if (functx:name-test(name($node),$names))
         then functx:remove-elements-not-contents($node/node(), $names)
         else element {node-name($node)}
              {$node/@*,
              functx:remove-elements-not-contents($node/node(),$names)}
    else if ($node instance of document-node())
    then functx:remove-elements-not-contents($node/node(), $names)
    else $node
 } ;

let $ordered_texts :=
  for $text in collection('HC')//tei:TEI[@n="E3"]
  let $measure := $text/tei:teiHeader/tei:fileDesc/tei:extent/tei:measure
  let $text_type := $text/tei:teiHeader/tei:profileDesc/tei:textClass[@default="true"]/tei:catRef[@n="T"]/@target
  where exists($measure/@quantity) and not(contains($text_type, "let"))
  order by xs:integer($measure/@quantity) ascending
  return $text

let $escape-csv :=
  function($value as xs:string?) as xs:string {
    let $escaped := if (empty($value)) then "" else replace($value, '"', '""', "i")
    return concat('"', $escaped, '"')
  }

let $enclose-parentheses :=
  function($value as xs:string?) as xs:string {
    let $value-str := if (empty($value)) then "" else normalize-space($value)
    return if (starts-with($value-str, '(')) then $escape-csv($value-str) else $value-str
  }

let $metadata :=
  for $text in $ordered_texts
  let $text_ref := $text/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/@ref
  let $divs := $text/tei:text/tei:body/tei:div

  for $div in $divs
  let $xml_id := if (empty($text/@xml:id)) then "" else string($text/@xml:id)
  let $type := if (empty($div/@type)) then "" else string($div/@type)
  let $n := if (empty($div/@n)) then "" else string($div/@n)
  let $div_ref := if (empty($div/@xml:id)) then string($text_ref) else concat("#", string($div/@xml:id))

  let $headers :=
    for $h at $header_order in $div/tei:head
    return <header_order>{ $header_order }</header_order>

  let $page_indexes :=
    for $pb at $page_index in $div//tei:pb
    return <page_index>{ $page_index }</page_index>

  let $paragraphs_with_speakers :=
    for $sp at $paragraph_order in $div//tei:sp
    let $speaker := normalize-space(string($sp/tei:speaker))
    for $p in functx:remove-elements-not-contents(functx:remove-elements-not-contents($sp/tei:p, 'hi'), 'note')
    let $page_index :=
      let $p_pages := $sp/preceding-sibling::tei:pb/@n
      return if (empty($p_pages)) then $page_indexes[count($page_indexes)]/text() else $p_pages[last()]
    let $header_order :=
      let $preceding_headers := $sp/preceding-sibling::tei:head
      return if (empty($preceding_headers)) then if (empty($headers)) then "" else count($headers) else count($preceding_headers)
    for $l at $l_index in $p/tei:lb
    let $words := tokenize(string-join($l/following-sibling::text()[1], " "), '\s+')
    for $w at $word_index in $words
    let $cleaned_word := local:remove-special-chars($w)
    where $cleaned_word != ""
    return (
      <row>
        <reference>{ $div_ref }</reference>
        <section_id>{ $n }</section_id>
        <page_index>{ $page_index }</page_index>
        <header_order>{ $header_order }</header_order>
        <paragraph_order>{ $paragraph_order }</paragraph_order>
        <speaker>{ $speaker }</speaker>
        <line_index>{ $l_index }</line_index>
        <word_index>{ $word_index }</word_index>
        <word>{ $cleaned_word }</word>
      </row>
    )

  let $paragraphs :=
    for $p at $paragraph_order in functx:remove-elements-not-contents(functx:remove-elements-not-contents($div/tei:p, 'hi'), 'note')
    let $page_index :=
      let $p_pages := $p/preceding-sibling::tei:pb/@n
      return if (empty($p_pages)) then $page_indexes[count($page_indexes)]/text() else $p_pages[last()]
    let $header_order :=
      let $preceding_headers := $p/preceding-sibling::tei:head
      return if (empty($preceding_headers)) then if (empty($headers)) then "" else count($headers) else count($preceding_headers)
    let $speaker := $p/@speaker
    for $l at $l_index in $p/tei:lb
    let $words := tokenize(string-join($l/following-sibling::text()[1], " "), '\s+')
    for $w at $word_index in $words
    let $cleaned_word := local:remove-special-chars($w)
    where $cleaned_word != ""
    return (
      <row>
        <reference>{ $div_ref }</reference>
        <section_id>{ $n }</section_id>
        <page_index>{ $page_index }</page_index>
        <header_order>{ $header_order }</header_order>
        <paragraph_order>{ $paragraph_order }</paragraph_order>
        <speaker>{ $speaker }</speaker>
        <line_index>{ $l_index }</line_index>
        <word_index>{ $word_index }</word_index>
        <word>{ $cleaned_word }</word>
      </row>
    )
   return ($paragraphs, $paragraphs_with_speakers)

return (
  "reference,section_id,page_index,header_index,paragraph_index,speaker,line_index,word_index,word",
  string-join(
    for $m in $metadata
    return string-join((
      $escape-csv($m/reference/text()),
      $escape-csv($m/section_id/text()),
      $escape-csv($m/page_index/@n),
      $escape-csv($m/header_order/text()),
      $escape-csv($m/paragraph_order/text()),
      $escape-csv($m/speaker/text()),
      $escape-csv($m/line_index/text()),
      $escape-csv($m/word_index/text()),
      $escape-csv($m/word/text())
    ), ",")
    , '&#xA;'
  )
)