<cfcomponent name="clientinfoform" extends="resources.page">
	
    <cffunction name="preObjectLoad">
		<cfset var m = "">
		<cfset m = createObject("component","modules.applejack.models.shipping").init(requestObject)>
		<cfset m.load()>
		<cfabort>
	</cffunction>

</cfcomponent>