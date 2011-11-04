<cfcomponent name="orderlineitems" extends="resources.abstractmodel">

	<cffunction name="init">
		<cfargument name="requestObject" required="true">
		<cfset variables.requestObject = arguments.requestObject>
		<cfset startorm("orderLineItems")>
		<cfreturn this>
	</cffunction>
	
</cfcomponent>
