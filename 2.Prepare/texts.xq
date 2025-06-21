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
  for $t in $text/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title
  let $n := if (empty($t/@n)) then "" else string($t/@n)
  let $xml_id := if (empty($text/@xml:id)) then "" else string($text/@xml:id)
  let $ref := if (empty($t/@ref)) then "" else string($t/@ref)
  let $title := $t/text()

  return (
    <row>
      <xml_id>{ $xml_id }</xml_id>
      <n>{ $n }</n>
      <title>{ $title }</title>
      <ref>{ $ref }</ref>
    </row>
  )

return (
  "text_id,title,work_id,reference",
  string-join(
    for $m in $metadata
    return string-join((
      $escape-csv($m/n/text()),
      $escape-csv($m/title/text()),
      $escape-csv($m/xml_id/text()),
      $escape-csv($m/ref/text())
    ), ",")
    , '&#xA;'
  )
)
