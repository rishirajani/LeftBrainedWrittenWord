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
  
let $concat-distinct :=
  function($nodes as node()*) as xs:string {
    let $distinct-values := distinct-values(
      for $n in $nodes
      return normalize-space(string($n))
    )
    return string-join($distinct-values, "|")
  }

let $metadata :=
  for $text in $ordered_texts
  let $xml_id := if (empty($text/@xml:id)) then "" else string($text/@xml:id)
  let $n := if (empty($text/@n)) then "" else string($text/@n)
  
  (: Concatenate titles from all biblStruct elements :)
  
  let $titles := $text/tei:teiHeader/tei:fileDesc/tei:sourceDesc//tei:biblStruct/tei:monogr/tei:title
  let $concatenated_titles := $concat-distinct($titles)

  let $author :=
    let $rolename := if (empty($text/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/tei:roleName)) then "" else string($text/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/tei:roleName)    
    let $forename := if (empty($text/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/tei:forename)) then $text/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/text() else string($text/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/tei:forename)
    let $surname := if (empty($text/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/tei:surname)) then "" else string($text/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/tei:surname)
    return normalize-space(concat($rolename, " ", $forename, " ", $surname))
  
  let $measure_quantity := if (empty($text/tei:teiHeader/tei:fileDesc/tei:extent/tei:measure/@quantity)) then "" else string($text/tei:teiHeader/tei:fileDesc/tei:extent/tei:measure/@quantity)
  let $measure_unit := if (empty($text/tei:teiHeader/tei:fileDesc/tei:extent/tei:measure/@unit)) then "" else string($text/tei:teiHeader/tei:fileDesc/tei:extent/tei:measure/@unit)
  let $creation_dates := if (empty($text/tei:teiHeader/tei:profileDesc/tei:creation/tei:date[@type="original"])) then "" else string-join($text/tei:teiHeader/tei:profileDesc/tei:creation/tei:date[@type="original"], ", ")
  let $text_type := if (empty($text/tei:teiHeader/tei:profileDesc/tei:textClass[@default="true"]/tei:catRef[@n="T"]/@target)) then "" else string($text/tei:teiHeader/tei:profileDesc/tei:textClass[@default="true"]/tei:catRef[@n="T"]/@target)

  return (
    <row>
      <xml_id>{ $xml_id }</xml_id>
      <n>{ $n }</n>
      <title>{ $concatenated_titles }</title>
      <author>{ $author }</author>
      <measure_quantity>{ $measure_quantity }</measure_quantity>
      <measure_unit>{ $measure_unit }</measure_unit>
      <creation_dates>{ $creation_dates }</creation_dates>
      <text_type>{ $text_type }</text_type>
    </row>
  )

return (
  "work_id,era_code,title,author,measure_quantity,measure_unit,creation_dates,text_type",
  string-join(
    for $m in $metadata
    return string-join((
      $escape-csv($m/xml_id/text()),
      $escape-csv($m/n/text()),
      $escape-csv($m/title/text()),
      $escape-csv($m/author/text()),
      $escape-csv($m/measure_quantity/text()),
      $escape-csv($m/measure_unit/text()),
      $escape-csv($m/creation_dates/text()),
      $escape-csv($m/text_type/text())
    ), ",")
    , '&#xA;'
  )
)
