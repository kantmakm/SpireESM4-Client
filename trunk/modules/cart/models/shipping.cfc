<cfcomponent name="products" extends="resources.abstractmodel">

	<cffunction name="init">
		<cfargument name="requestObject" required="true">
		<cfset variables.requestObject = arguments.requestObject>
		<cfset startorm("cartitems")>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getCartItems">
		
	</cffunction>
	
	<cffunction name="addItemToCart">
	
	</cffunction>
	
	<cffunction name="updateCart">
	
	</cffunction>

</cfcomponent>
