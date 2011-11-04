<cfcomponent name="fedexobservers">
	
	<cffunction name="init">
		<cfargument name="requestObject" required="true">
		<cfset variables.requestObject = arguments.requestObject>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="shipping_options">
		<cfargument name="observed" required="true">
		<cfset var s = structnew()>
		<cfset s.sortorder = 10>
		<cfset s.obj = createObject("component","modules.fedex.models.shipping").init(requestObject)>
		<cfset observed.fedex = s>
		<cfreturn observed>
	</cffunction>
	
	<cffunction name="isCartShippingModule">
		<cfargument name="observed" required="true">
		<cfset var s = structnew()>
		<cfset s.name = "Fedex Shipping">
		<cfset s.path = "modules.fedex.models.shipping">
		<cfset arrayappend(arguments.observed, s)>
		<cfreturn arguments.observed>
	</cffunction>
</cfcomponent>