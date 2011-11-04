<cfcomponent name="icsobservers">
	
	<cffunction name="init">
		<cfargument name="requestObject" required="true">
		<cfset variables.requestObject = arguments.requestObject>
		<cfreturn this>
	</cffunction>

	<cffunction name="isCreditCartProcessingModule">
		<cfargument name="observed" required="true">
		<cfset var s = structnew()>
		<cfset s.name = "ICS">
		<cfset s.path = "modules.ics_payments.models.ccpay">
		<cfset arrayappend(arguments.observed, s)>
		<cfreturn arguments.observed>
	</cffunction>
	
</cfcomponent>