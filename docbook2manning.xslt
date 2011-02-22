<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
</xsl:template>

<!--Remove All "article" tags while leaving children-->
<xsl:template match="article">
        <xsl:apply-templates select="node()"/>
</xsl:template>

<!--Remove "articleinfo" tags and kill children-->
<xsl:template match="articleinfo">
<!--Remove Tag-->
</xsl:template>

<!--Convert outer "section" tag to "chapter"-->
<xsl:template match="/article/section">
		<book xmlns="http://www.manning.com/schemas/book" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:ns="http://www.manning.com/schemas/book">
			<bookinfo><title/><author><firstname /><surname /></author></bookinfo>
			<chapter>
				<xsl:apply-templates select="node()"/>
			</chapter>
		</book>
</xsl:template>

<!-- Copy section, but not its attributes -->
<xsl:template match="section">
	<xsl:copy>
		<xsl:apply-templates select="*|node()"/>
	</xsl:copy>
</xsl:template>

<!--Convert "textobject" to "caption"-->
<xsl:template match="textobject">
	<caption><xsl:apply-templates select="node()"/></caption>
</xsl:template>

<!--Convert "literal" to "code"-->
<xsl:template match="literal">
	<code><xsl:apply-templates select="node()"/></code>
</xsl:template>

<!--Convert "phrase" to "para"-->
<xsl:template match="phrase">
	<para><xsl:apply-templates select="node()"/></para>
</xsl:template>

<!--Remove "numeration" attribute from "orderedlist" elements-->
<xsl:template match="@numeration" />

<xsl:template match="@numeration" />

<!--Convert "screen" to "informalexample"-->
<xsl:template match="screen[not(@*)]">
	<informalexample>
		<programlisting>
			<xsl:apply-templates select="node()"/>
		</programlisting>
	</informalexample>
</xsl:template>

<!--Convert "screen" to "example"-->
<xsl:template match="screen[@language]">
	<example>
		<programlisting>
			<xsl:apply-templates select="node()"/>
		</programlisting>
	</example>
</xsl:template>

<!-- Convert "role" attributes with value "strong" to value "bold"-->
<xsl:template match="@role[.='strong']">
	<xsl:attribute name="role">
		<xsl:text>bold</xsl:text>
	</xsl:attribute>
</xsl:template>

<!-- Remove "float" attribute -->
<xsl:template match="@float" />

<!--Convert "informaltable" to "table"-->
<xsl:template match="informaltable">
	<table>
		<title></title>
		<xsl:apply-templates select="node()"/>
	</table>
</xsl:template>

<!-- Remove "table/col" elements -->
<xsl:template match="informaltable/col" />

<!--Convert "table/caption" to "table/title"-->
<xsl:template match="table/caption">
	<title>
		<xsl:apply-templates select="node()"/>
	</title>
</xsl:template>

<!-- Remove "table/col" elements -->
<xsl:template match="table/col" />

<!--Convert "thead/tr" to "thead/row"-->
<xsl:template match="thead/tr">
	<row>
		<xsl:apply-templates select="node()"/>
	</row>
</xsl:template>


<!--Convert "tbody/tr" to "tbody/row"-->
<xsl:template match="tbody/tr">
	<row>
		<xsl:apply-templates select="node()"/>
	</row>
</xsl:template>

<!--Convert "tr/th" to "tr/entry"-->
<xsl:template match="tr/th">
	<entry>
		<para>
			<xsl:apply-templates select="node()"/>
		</para>
	</entry>
</xsl:template>

<!--Convert "tr/td" to "tr/entry"-->
<xsl:template match="tr/td">
	<entry>
		<para>
			<xsl:apply-templates select="node()"/>
		</para>
	</entry>
</xsl:template>

</xsl:stylesheet>
