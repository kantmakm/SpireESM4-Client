<cfset lcl.itemspercol = 13>
<cfset lcl.link = requestObject.getFormUrlVar("linkpath","linkpathneeded")>
<cfset lcl.cols = ceiling(variables.taxonomylist.recordcount / lcl.itemspercol)>
<h2>More Options</h2>
<table>
<cfoutput query="variables.taxonomylist">
	<cfif variables.taxonomylist.currentrow MOD lcl.cols EQ 1><tr></cfif>
	<td><a href="/#lcl.link#/#safename#">#taxonomyitemname#</a></td>
	<cfif variables.taxonomylist.currentrow MOD lcl.cols EQ 0></tr></cfif>
</cfoutput>
</table>
