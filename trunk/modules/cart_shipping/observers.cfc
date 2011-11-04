<cfcomponent name="ajobservers">
	
	<cffunction name="init">
		<cfargument name="requestObject" required="true">
		<cfset variables.requestObject = arguments.requestObject>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="cart_cartLineItems_shippingpayment">
		<cfargument name="observed" required="true">
		
		<cfset var userObj = requestObject.getUserObject()>
		<cfset var quoteObj = createObject("component","modules.cart_shipping.models.cartShippingQuotes").init(requestObject)>
		<cfset var lcl = structnew()>
		
		<cfif observed.cartObj.getShippingQuoteId() EQ "" OR NOT quoteObj.load(observed.cartObj.getShippingQuoteId())>
			<cfreturn observed>
		</cfif>
		
		<cfset lcl.s = structnew()>
		<cfset lcl.s.label = "Shipping/Delivery Total">
		<cfset lcl.s.sortkey = 40>
		<cfset lcl.s.action = "add">
		<cfset lcl.s.total = quoteObj.getCost()>
		<cfset observed.lineitems.shipping = lcl.s>
			
		<cfreturn observed>
	</cffunction>
	
	<cffunction name="cart_cartLineItems_orderconfirmation">
		<cfargument name="observed" required="true">
		
		<cfset var userObj = requestObject.getUserObject()>
		<cfset var quoteObj = createObject("component","modules.cart_shipping.models.cartShippingQuotes").init(requestObject)>
		<cfset var lcl = structnew()>
		
		<cfif NOT quoteObj.load(observed.cartObj.getShippingQuoteId())>
			<cfthrow message="shipping not set!">
		</cfif>
		
		<cfset lcl.s = structnew()>
		<cfset lcl.s.label = "Shipping Total">
		<cfset lcl.s.sortkey = 40>
		<cfset lcl.s.action = "add">
		<cfset lcl.s.total = quoteObj.getCost()>
		<cfset observed.lineitems.shipping = lcl.s>
			
		<cfreturn observed>
	</cffunction>
	
	<cffunction name="cart_item_added">
		<cfargument name="observed" required="true">
		<cfset clearshippingquotes(observed)>
		<cfreturn observed>
	</cffunction>
	
	<cffunction name="cart_item_updated">
		<cfargument name="observed" required="true">
		<cfset clearshippingquotes(observed)>
		<cfreturn observed>
	</cffunction>
	
	<cffunction name="cart_item_removed">
		<cfargument name="observed" required="true">
		<cfset clearshippingquotes(observed)>
		<cfreturn observed>
	</cffunction>
	
	<cffunction name="form_submission_cart_billingdeliveryinfo">
		<cfargument name="observed" required="true">
		<cfset var cartObj = createObject("component","modules.cart.models.cart").init(requestObject)>
		<cfset cartObj.load(cartObj.getCartId())>
		<cfset clearshippingquotes(cartObj)>
		<cfreturn observed>
	</cffunction>

	<cffunction name="clearshippingquotes">
		<cfargument name="cartObj">
		<cfset var lcl = structnew()>
		
		<cfset cartObj.setShippingQuoteId("")>
		<cfset cartObj.save()>
		
		<cfquery datasource="#requestObject.getVar("dsn")#" name="clearquotes">
			DELETE FROM cartShippingQuotes WHERE cartid = <cfqueryparam value="#cartObj.getCartId()#" cfsqltype="cf_sql_varchar">
		</cfquery>
		
	</cffunction>
		
</cfcomponent>