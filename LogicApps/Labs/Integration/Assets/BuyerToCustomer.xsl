<?xml version="1.0" encoding="UTF-16"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:var="http://schemas.microsoft.com/BizTalk/2003/var" exclude-result-prefixes="msxsl var s0" version="1.0" xmlns:s0="http://BTSSchemas.BuyersFlatFileSchema">
  <xsl:output omit-xml-declaration="yes" method="xml" version="1.0" />
  <xsl:template match="/">
    <xsl:apply-templates select="/s0:Buyers" />
  </xsl:template>
  <xsl:template match="/s0:Buyers">
    <Customers>
      <xsl:for-each select="Buyer">
        <Customer>
          <FirstName>
            <xsl:value-of select="FirstName/text()" />
          </FirstName>
          <LastName>
            <xsl:value-of select="LastName/text()" />
          </LastName>
          <Address>
            <xsl:value-of select="Address/text()" />
          </Address>
          <City>
            <xsl:value-of select="City/text()" />
          </City>
          <State>
            <xsl:value-of select="State/text()" />
          </State>
          <Zip>
            <xsl:value-of select="Zip/text()" />
          </Zip>
        </Customer>
      </xsl:for-each>
    </Customers>
  </xsl:template>
</xsl:stylesheet>