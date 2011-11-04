<cfif variables.newsitems.recordcount>
<ul class="bullets">
<cfoutput query="variables.newsitems">
<li>
	<cfif variables.newsitems.linkpageid NEQ "">
		<cfset lcl.link = "{{link[#variables.requestObject.getVar("siteid")#][#variables.newsitems.linkpageid#]}}">
	<cfelse>
		<cfset lcl.link = "/NewsAndEvents/News/#id#/">
	</cfif>
<b>#dateformat(itemdate, "mm.dd.yy")#</b> 
<a href="#lcl.link#">#title#</a>
</li></cfoutput>
</ul>
<cfelse>
No news available.
</cfif>