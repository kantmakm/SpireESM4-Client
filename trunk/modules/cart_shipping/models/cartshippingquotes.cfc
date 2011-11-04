<cfcomponent name="Events" extends="resources.abstractModel">

	<cffunction name="init">
		<cfargument name="requestObject" required="true">
		<cfset variables.requestObject = arguments.requestObject>
		<cfset startorm("cartShippingQuotes")>
		<cfreturn this>	
	</cffunction>
	
</cfcomponent>