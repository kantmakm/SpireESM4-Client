<cfcomponent name="products" extends="resources.abstractmodel">

	<cffunction name="init">
		<cfargument name="requestObject" required="true">
		<cfset variables.requestObject = arguments.requestObject>
		<cfset startorm("products")>
		<cfreturn this>
	</cffunction>

	<cffunction name="getBreadCrumbs">
    	<cfargument name="urlpath" required="yes">
		<!---
		<cfset var lcl = structNew()>
		<cfset lcl.BreadCrumbs = ''>
		<cfset lcl.productid = listlast(arguments.urlpath, "/")>
		<cfset lcl.urlpath = replaceNoCase(arguments.urlpath, 'productview/#lcl.productid#/', '')>
		
		<cfquery name="lcl.q" datasource="#requestObject.getVar('dsn')#">
			SELECT DISTINCT p.breadcrumbs
			FROM publishedpages p 
			INNER JOIN pageObjects_view po ON p.id = po.pageid 
			WHERE po.module = <cfqueryparam value="ProductCatalog" cfsqltype="CF_SQL_VARCHAR">
				AND po.siteid = <cfqueryparam value="#variables.requestObject.getvar('siteid')#" cfsqltype="cf_sql_varchar">
				AND po.status = <cfqueryparam value="published" cfsqltype="CF_SQL_VARCHAR">
				AND p.siteid = <cfqueryparam value="#variables.requestObject.getvar('siteid')#:published" cfsqltype="cf_sql_varchar">
				AND p.urlpath = <cfqueryparam value="#lcl.urlpath#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery>
		
		<cfif lcl.q.recordcount>
			<cfset lcl.BreadCrumbs = lcl.q.breadcrumbs>
		</cfif>

		<cfreturn lcl.BreadCrumbs>
		--->
		<cfreturn "temp breadcrumb">
	</cffunction>

	<cffunction name="loadProduct">
		<cfargument name="path" required="true">
		<cfset var me = "">
		<cfset var field = "">
		<cfset var tmpdata = structnew()>
		<cfset var more = structnew()>
		<cfset more.active = 1>
		<cfset productrecord = this.getByUrlName(arguments.path, more)>
		
		<cfif productrecord.recordcount EQ 0>
			<cfreturn false>
		</cfif>
		
		<cfloop list="#productrecord.columnlist#" index="field">
			<cfset tmpdata[field] = productrecord[field][1]>
		</cfloop>
				
		<cfset this.setValues(tmpdata)>
		
		<cfreturn true>
	</cffunction>

</cfcomponent>
