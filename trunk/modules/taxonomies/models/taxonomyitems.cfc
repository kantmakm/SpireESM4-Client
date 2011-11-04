<cfcomponent name="taxonomy items" extends="resources.abstractmodel" output="false">

	<cffunction name="init" output="false">
		<cfargument name="requestObject" required="true">
		<cfset variables.requestObject = arguments.requestObject>
		<cfset startorm("taxonomyitems")>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="gettaxonomyitemswithrelations">
		<cfargument name="taxonomyid" required="true">
		<cfargument name="more" default="#structnew()#">
		<cfset var lcl = structnew()>
		<cfquery name="lcl.q" datasource="#requestObject.getVar("Dsn")#">
			SELECT DISTINCT safename, ti.name, sortkey
			FROM taxonomyitems ti
			INNER JOIN taxonomyrelations tr ON tr.taxonomyitemid = ti.id
			INNER JOIN products p ON tr.relationid = p.id AND p.deleted = 0
			WHERE ti.taxonomyid = <cfqueryparam value="#arguments.taxonomyid#" cfsqltype="cf_sql_varchar">
			ORDER BY 
			<cfif structkeyexists(more, "sort")>#more.sort#<cfelse>ti.name</cfif>
		</cfquery>
		<cfreturn lcl.q>
	</cffunction>
	
</cfcomponent>