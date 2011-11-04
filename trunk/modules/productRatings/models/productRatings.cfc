<cfcomponent name="productRatings" extends="resources.abstractmodel">

	<cffunction name="init">
		<cfargument name="requestObject" required="true">
		<cfset variables.requestObject = arguments.requestObject>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="setRatedObj">
		<cfargument name="pricedObj" required="true">
		<cfset variables.pricedObj = arguments.pricedObj>
	</cffunction>

	<cffunction name="getRatings">
		<cfset var ratingq = "">
		
		<cfquery name="ratingq" datasource="#requestObject.getVar("dsn")#">
			SELECT pr.*, ti.name tiname, ti.description tidescription
			FROM productRatings pr
			INNER JOIN taxonomyItems ti ON ti.id = pr.ratingtype
			WHERE pr.productid = <cfqueryparam value="#variables.pricedObj.getId()#" cfsqltype="cf_sql_varchar">
			ORDER BY pr.rating DESC	
		</cfquery>
	
		<cfreturn ratingq>
	</cffunction>
	
</cfcomponent>
