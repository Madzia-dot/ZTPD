(:
for $k in doc('file:///C:/Users/Magdalena/Downloads/XPath-XSLT/XPath-XSLT/swiat.xml')/SWIAT/KONTYNENTY/KONTYNENT
return <KRAJ>
 {$k/NAZWA}
</KRAJ>
:)

(:
for $k in doc('file:///C:/Users/Magdalena/Downloads/XPath-XSLT/XPath-XSLT/swiat.xml')/SWIAT/KRAJE/KRAJ
return <KRAJ>
 {$k/NAZWA, $k/STOLICA}
</KRAJ>

:)

(:
for $k in doc('file:///C:/Users/Magdalena/Downloads/XPath-XSLT/XPath-XSLT/swiat.xml')/SWIAT/KRAJE/KRAJ[starts-with(NAZWA, 'A')]
return <KRAJ>
 {$k/NAZWA, $k/STOLICA}
</KRAJ>
:)

(:
for $k in doc('file:///C:/Users/Magdalena/Downloads/XPath-XSLT/XPath-XSLT/swiat.xml')/SWIAT/KRAJE/KRAJ[substring(NAZWA, 1, 1) = substring(STOLICA, 1, 1)]
return <KRAJ>
 {$k/NAZWA, $k/STOLICA}
</KRAJ>
:)

(:
doc('file:///C:/Users/Magdalena/Downloads/XPath-XSLT/XPath-XSLT/swiat.xml')//KRAJ
:)

(:
doc('file:///C:/Users/Magdalena/Downloads/XPath-XSLT/XPath-XSLT/zesp_prac.xml')//PRACOWNICY/ROW/NAZWISKO
:)

(:
doc('file:///C:/Users/Magdalena/Downloads/XPath-XSLT/XPath-XSLT/zesp_prac.xml')//ZESPOLY/ROW[NAZWA='SYSTEMY EKSPERCKIE']/PRACOWNICY/ROW/NAZWISKO

:)
(:
count(doc('file:///C:/Users/Magdalena/Downloads/XPath-XSLT/XPath-XSLT/zesp_prac.xml')//ZESPOLY/ROW[ID_ZESP=10]/PRACOWNICY/ROW)
:)
(:
doc('file:///C:/Users/Magdalena/Downloads/XPath-XSLT/XPath-XSLT/zesp_prac.xml')//PRACOWNICY/ROW[ID_SZEFA=100]/NAZWISKO
:)

sum(doc('file:///C:/Users/Magdalena/Downloads/XPath-XSLT/XPath-XSLT/zesp_prac.xml')//ZESPOLY/ROW[PRACOWNICY/ROW/NAZWISKO='BRZEZINSKI']/PRACOWNICY/ROW/PLACA_POD)
