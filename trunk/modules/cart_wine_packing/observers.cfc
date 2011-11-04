<cfcomponent name="winepackingobservers"  extends="resources.abstractObserver">
	
	<cffunction name="cart_cartLineItems_orderconfirmation">
		<cfargument name="observed" required="true">
		<cfreturn calculatePackaging(observed)>
	</cffunction>
	
	
	<cffunction name="cart_cartLineItems_shippingpayment">
		<cfargument name="observed" required="true">
		<cfreturn calculatePackaging(observed)>
	</cffunction>
	
	<cffunction name="calculatePackaging">
		<cfargument name="observed" required="true">
		<cfset var lcl = structnew()>
		
		<!--- determine if fedex by checking the shippingquoteid, if so continue --->
		<cfset lcl.shippingquoteid = observed.cartObj.getShippingQuoteId()>
	
		<!--- were done if they ahve not chosen a shipping quote --->
		<cfif lcl.shippingquoteid EQ "">
			<cfreturn arguments.observed>
		</cfif>
		
		<cfquery name="lcl.isfedex" datasource="#requestObject.getVar("dsn")#">
			SELECT *
			FROM cartShippingQuotes
			WHERE cartid = <cfqueryparam value="#observed.cartObj.getCartId()#" cfsqltype="cf_sql_varchar">
			AND shippingModule LIKE '%fedex%'
			AND id = <cfqueryparam value="#lcl.shippingquoteid#" cfsqltype="cf_sql_varchar">
		</cfquery>
		
		<cfif lcl.isfedex.recordcount EQ 0>
			<cfreturn arguments.observed>
		</cfif>
		
		<cfif NOT isjson(lcl.isfedex.data)>
			<cfreturn arguments.observed>
		</cfif>
		
		<cfset lcl.data = deserializejson(lcl.isfedex.data)>
		
		<cfset lcl.packagecosts = lcl.data.packageingcost>
		<cfset lcl.totalboxes = arraylen(lcl.data.packages)>
		
		<cfif lcl.packagecosts EQ 0>
			<cfreturn arguments.observed>
		</cfif>
		
		<!--- add an entry to the line items --->
		<cfset lcl.s3 = structnew()>
		<cfset lcl.s3.label = "Packaging Costs">
		<cfset lcl.s3.sortkey = 5>
		<cfset lcl.s3.action = "none">
		<cfset lcl.s3.total = lcl.packagecosts>
		<cfset lcl.s3.more = structnew()>
		<cfset lcl.s3.more.boxestobuy = lcl.totalboxes>
		
		<cfset observed.lineitems.packagingcosts = lcl.s3>
	
		<!--- add package costs to the subtotal  --->
		<cfloop collection="#observed.lineitems#" item="lcl.liidx">
			<cfif lcl.liidx EQ "subtotal">
				<cfset observed.lineitems[lcl.liidx].total = observed.lineitems[lcl.liidx].total + lcl.packagecosts>
			</cfif>
		</cfloop>
		
		<cfreturn observed>
	</cffunction>
</cfcomponent>