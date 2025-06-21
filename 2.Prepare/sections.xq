xquery version "3.1";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

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
  
let $metadata :=
  for $text in $ordered_texts
  let $text_ref := $text/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/@ref
  for $div in $text/tei:text/tei:body/tei:div
  let $xml_id := if (empty($text/@xml:id)) then "" else string($text/@xml:id)
  let $type := if (empty($div/@type)) then "" else string($div/@type)
  let $n := if (empty($div/@n)) then "" else string($div/@n)
  let $div_ref := if (empty($div/@xml:id)) then string($text_ref) else concat("#", string($div/@xml:id))

  return (
    if ($type = "subdivision") then (
      for $subdiv in $div/tei:div
      let $subtype := string($subdiv/@type)
      let $subn := string($subdiv/@n)
      let $combined_type := concat($type, ".", $subtype)
      return (
        <row>
          <n>{ $subn }</n>
          <type>{ $combined_type }</type>
          <div_ref>{ $div_ref }</div_ref>
        </row>
      )
    ) else (
      <row>
        <n>{ $n }</n>
        <type>{ $type }</type>
        <div_ref>{ $div_ref }</div_ref>
      </row>
    )
  )

return (
  "reference,section_id,section_type",
  string-join(
    for $m in $metadata
    return string-join((
      $escape-csv($m/div_ref/text()),
      $escape-csv($m/n/text()),
      $escape-csv($m/type/text())
    ), ",")
    , '&#xA;'
  )
)
