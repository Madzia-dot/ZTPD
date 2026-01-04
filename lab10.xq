(:
doc("db/bib/bib.xml")//author/last
:)
 
 (:
 for $b in doc("db/bib/bib.xml")//book
for $t in $b/title
for $a in $b/author
return <ksiazka>
  {$t}
  {$a}
</ksiazka>
 :)

(:for $b in doc("db/bib/bib.xml")//book
for $t in $b/title
for $a in $b/author
return <ksiazka>
  <autor>{$a/last/text()}{$a/first/text()}</autor>
  <tytul>{$t/text()}</tytul>
</ksiazka> :)
(:

for $b in doc("db/bib/bib.xml")//book
for $t in $b/title
for $a in $b/author
return <ksiazka>
  <autor>{$a/last || ' ' || $a/first}</autor>
  <tytul>{$t/text()}</tytul>
</ksiazka>
:)

(: 
<wynik>
{
  for $b in doc("db/bib/bib.xml")//book
  for $t in $b/title
  for $a in $b/author
  return <ksiazka>
    <autor>{$a/last || ' ' || $a/first}</autor>
    <tytul>{$t/text()}</tytul>
  </ksiazka>
}
</wynik>
:)


(:
<imiona>
{
  doc("db/bib/bib.xml")//book[title="Data on the Web"]/author/first
}
</imiona>

:)
(:
<DataOnTheWeb>
{ doc("db/bib/bib.xml")//book[title="Data on the Web"] }
</DataOnTheWeb>
:)
(:
<DataOnTheWeb>
{
  for $b in doc("db/bib/bib.xml")//book
  where $b/title = "Data on the Web"
  return $b
}
</DataOnTheWeb>

:)
(:
<Data>
{
  for $b in doc("db/bib/bib.xml")//book[contains(title, "Data")]
  for $a in $b/author
  return <nazwisko>{$a/last/text()}</nazwisko>
}
</Data>
:)

(:
<Data>
{
  for $b in doc("db/bib/bib.xml")//book[contains(title, "Data")]
  return (
    $b/title,
    for $a in $b/author
    return <nazwisko>{$a/last/text()}</nazwisko>
  )
}
</Data>

:)
(:
for $b in doc("db/bib/bib.xml")//book
where count($b/author) <= 2
return $b/title

:) 

(:
for $b in doc("db/bib/bib.xml")//book
return <ksiazka>
  {$b/title}
  <autorow>{count($b/author)}</autorow>
</ksiazka>
:)
(:
<przedział>{min(doc("db/bib/bib.xml")//@year)} {max(doc("db/bib/bib.xml")//@year)}</przedział>:)

(:
<różnica>{max(doc("db/bib/bib.xml")//price) - min(doc("db/bib/bib.xml")//price)}</różnica>
:)

(:
<najtańsze>
{
  let $min_price := min(doc("db/bib/bib.xml")//price)
  for $b in doc("db/bib/bib.xml")//book
  where $b/price = $min_price
  return <najtańsza>
    {$b/title}
    {$b/author}
  </najtańsza>
}
</najtańsze>
:)

(:
for $last in distinct-values(doc("db/bib/bib.xml")//author/last)
return <autor>
  <last>{$last}</last>
  {
    for $b in doc("db/bib/bib.xml")//book[author/last = $last]
    return $b/title
  }
</autor>
:)

(:
<wynik>
{
  collection("db/shakespeare")//PLAY/TITLE
}
</wynik>
:)

(:
for $p in collection("db/shakespeare")//PLAY
where some $l in $p//LINE satisfies contains($l, "or not to be")
return $p/TITLE:)
<wynik>
{
  for $p in collection("db/shakespeare")//PLAY
  let $tytul := $p/TITLE
  let $postaci := count($p//PERSONA)
  let $aktow := count($p//ACT)
  let $scen := count($p//SCENE)
  return 
    <sztuka tytul="{$tytul}">
      <postaci>{$postaci}</postaci>
      <aktow>{$aktow}</aktow>
      <scen>{$scen}</scen>
    </sztuka>
}
</wynik>