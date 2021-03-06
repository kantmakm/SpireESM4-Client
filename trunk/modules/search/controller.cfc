<cfcomponent extends="resources.abstractController" ouput="false">
	
    <cffunction name="init" output="false">
		<cfset super.init(argumentcollection = arguments)>
		<cfset variables.data.collectionname = getCollectionName()>
		<cfreturn this>
	</cffunction>
    
    <cffunction name="getCollectionName">
    	<cfset var collectionName = variables.requestObject.getVar('siteurl')>
		<cfset collectionName = replace(collectionName, "http://","", "all")>
        <cfset collectionName = rereplace(collectionName,  "[^a-zA-Z0-9]","","all")>
        <cfreturn collectionName>
    </cffunction>

   <!---  <cffunction name="getPagesForSiteSearch" output="false">
    	<cfargument name="aggregator">
		<cfset var currentPages = "">
		<cfset var indexable = "">
		<cfset var siteurl = variables.requestObject.getVar('siteurl')>
		
		<cfquery name="currentpages" datasource="#variables.requestObject.getVar('dsn')#">
			SELECT id,  urlpath, summary, pagename
			FROM publishedPages 
			WHERE siteid = <cfqueryparam value="#variables.requestObject.getVar('siteid')#:published">
			AND pagename not in ('404', 'Search Results')
            AND searchindexable = 1
			AND expired = 0
			ORDER BY len(urlpath)
		</cfquery>
		
        <cfloop query="currentPages">
        	<cfset indexable = aggregator.newpageindexable()>
            <cfset indexable.setkey(currentpages.id)>
			<cfset indexable.setpath(currentpages.urlpath)>
            <cfset indexable.settitle(currentpages.pagename)>
            <cfset indexable.setdescription(currentpages.summary)>
            <cfset indexable.saveForIndex()>
        </cfloop>
        
	</cffunction> --->
	
	<cffunction name="getCacheLength">
		<cfreturn 0>
	</cffunction>
</cfcomponent>