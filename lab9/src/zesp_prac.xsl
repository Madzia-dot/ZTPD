<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

    <xsl:template match="/">
        <html>
            <body>
                <h1>ZESPOŁY:</h1>
                <ol>
                    <xsl:apply-templates select="ZESPOLY/ROW" mode="lista"/>
                </ol>

                <xsl:apply-templates select="ZESPOLY/ROW" mode="szczegoly"/>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="ROW" mode="lista">
        <li>
            <a href="#ID{ID_ZESP}">
                <xsl:value-of select="NAZWA"/>
            </a>
        </li>
    </xsl:template>

    <xsl:template match="ROW" mode="szczegoly">
        <hr/>
        <div id="ID{ID_ZESP}">
            <strong>NAZWA: </strong> <xsl:value-of select="NAZWA"/><br/>
            <strong>ADRES: </strong> <xsl:value-of select="ADRES"/>
        </div>
        <xsl:if test="count(PRACOWNICY/ROW) > 0">
        <table border="1">
            <tr>
                <th>Nazwisko</th>
                <th>Etat</th>
                <th>Zatrudniony</th>
                <th>Placa pod.</th>
                <th>Id szefa</th>
            </tr>
            <xsl:apply-templates select="PRACOWNICY/ROW" mode="pracownik">
                <xsl:sort select="NAZWISKO"/>
            </xsl:apply-templates>
        </table>
        </xsl:if>
        <p>Liczba pracowników: <xsl:value-of select="count(PRACOWNICY/ROW)"/></p>
    </xsl:template>
    <xsl:template match="ROW" mode="pracownik">
        <tr>
            <td><xsl:value-of select="NAZWISKO"/></td>
            <td><xsl:value-of select="ETAT"/></td>
            <td><xsl:value-of select="ZATRUDNIONY"/></td>
            <td><xsl:value-of select="PLACA_POD"/></td>
            <td>
                <xsl:variable name="v_id_szefa" select="ID_SZEFA"/>
                <xsl:choose>
                    <xsl:when test="string-length($v_id_szefa) > 0">
                        <xsl:value-of select="//ROW[ID_PRAC = $v_id_szefa]/NAZWISKO"/>
                    </xsl:when>
                    <xsl:otherwise>brak</xsl:otherwise>
                </xsl:choose>
            </td>
        </tr>
    </xsl:template>
</xsl:stylesheet>
