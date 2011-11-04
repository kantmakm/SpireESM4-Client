<cfcomponent name="giftmessage" extends="resources.abstractmodel">

	<cffunction name="init">
		<cfargument name="requestObject" required="true">
		<cfset variables.requestObject = arguments.requestObject>
		<cfset startorm("giftmessages")>
		<cfreturn this>
	</cffunction>
	
</cfcomponent>
