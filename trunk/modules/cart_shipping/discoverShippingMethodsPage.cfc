<cfcomponent name="product View" extends="resources.page">
	<cffunction name="preobjectLoad">
		<cfset var lcl = structnew()>
		<cfset lcl.m = createobject("component","modules.cart_shipping.models.cartShippingModules").init(requestObject)>
		<cfset lcl.m.discoverModules()>
		<cfabort>
	</cffunction>
</cfcomponent>