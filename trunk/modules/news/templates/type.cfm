<cfoutput>
<div class="newsList">
<cfif variables.newsItem.hasRssFeed EQ 1>
	<p class="newsFeed">
		<a class="rssiconlink" href="/rss/news/#variables.newsItem.id#/">#variables.newsItem.title# RSS Feed</a>
	</p>
</cfif>
<cfif variables.newslist.recordcount>
	<ul>
	<cfloop query="variables.newslist">
		<li>
			<p class="newsTitle">
			<cfif variables.newslist.linkpageid NEQ "">
				<cfset lcl.link = "{{link[#variables.requestObject.getVar("siteid")#][#variables.newslist.linkpageid#]}}">
			<cfelse>
				<cfset lcl.link = "/NewsAndEvents/News/#id#/">
			</cfif>
			<a href="#lcl.link#">#getUtility('string').APDateFormat(itemdate)#:</a> #title#
			<cfif variables.newslist.assetid NEQ "">
				<a href="{{asset[#variables.newslist.assetid#]}}" target="_blank">(MP3)</a>
			</cfif>
			</p>
			<div>#description#</div>
		</li>
	</cfloop>
	</ul>
	#variables.pager.showPageLinks()#
	<br class="clear"/>
<cfelse>
	<p>There are currently no items to show.</p>
</cfif>
</div>

</cfoutput>