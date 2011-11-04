<cfset lcl.path = variables.requestObject.getformurlvar('path')>
<cfset lcl.tclass = arraynew(1)>
<cfset lcl.dhtmlnav = pageref.getMainMenu()>

<ul id="nav" >
<cfoutput query="lcl.dhtmlnav">
   	<cfset arrayclear(lcl.tclass)>
   	<cfif lcl.dhtmlnav.currentrow EQ 1><cfset arrayappend(lcl.tclass, 'first')></cfif>
   <cfif refindnocase("^#lcl.dhtmlnav.displayurlpath#", lcl.path)><cfset arrayappend(lcl.tclass, 'itemOn')></cfif>
	<li <cfif arraylen(lcl.tclass)>class="#arraytolist(lcl.tclass," ")#"</cfif>>
		<a href="#lcl.dhtmlnav.displayurlpath#" title="#replace(lcl.dhtmlnav.pagename, '&', '&amp;', 'ALL')#">#replace(lcl.dhtmlnav.pagename, '&', '&amp;', 'ALL')#</a>
	</li>
</cfoutput>
</ul>