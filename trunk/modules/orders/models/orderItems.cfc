<cfcomponent name="orderitems" extends="resources.abstractmodel">

	<cffunction name="init">
		<cfargument name="requestObject" required="true">
		<cfset variables.requestObject = arguments.requestObject>
		<cfset startorm("orderItems")>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="getOrderItems">
		<cfargument name="id" required="true">
		<cfset var lcl = structnew()>
		<cfquery name="lcl.oi" datasource="#requestObject.getVar("dsn")#">
			SELECT pp.productid, oi.title, 
				 oi.productpriceitemid, 
				oi.individualprice, oi.price, oi.quantity, oi.type
			FROM orderItems oi 
			LEFT OUTER JOIN productPrices pp ON oi.productPriceItemId = pp.id
			WHERE oi.orderid = <cfqueryparam value="#arguments.id#" cfsqltype="cf_sql_varchar">
			ORDER BY oi.created
		</cfquery>
		<cfreturn lcl.oi>
	</cffunction>

</cfcomponent>
