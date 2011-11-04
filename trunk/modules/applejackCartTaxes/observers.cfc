<cfcomponent name="ajobservers" extends="resources.abstractObserver">
	
	<cfset this.executeorder_cart_cartLineItems_cart_order = 20>
	<cffunction name="cart_cartLineItems_cart">
		<cfargument name="observed" required="true">
		<cfreturn calculateTax(observed)>
	</cffunction>
	
	<cfset this.executeorder_cart_cartLineItems_shippingpayment = 20>
	<cffunction name="cart_cartLineItems_shippingpayment">
		<cfargument name="observed" required="true">
		<cfreturn calculateTax(observed)>
	</cffunction>
	
	<cfset this.executeorder_cart_cartLineItems_orderconfirmation = 20>
	<cffunction name="cart_cartLineItems_orderconfirmation">
		<cfargument name="observed" required="true">
		<cfreturn calculateTax(observed)>
	</cffunction>
	
	<cffunction name="calculatetax" access="private">
		<cfargument name="observed" required="true">
		
		<cfset var userObj = requestObject.getUserObject()>
		<cfset var items = observed.cartObj.getCartItemsObj().getCartItems()>
		<cfset var zip = "">
		<cfset var lcl = structnew()>

		<cfif structisempty(items)>
			<cfreturn observed>
		</cfif>
		
		<cfset lcl.taxes = structnew()>
		<!--- 
			sorry, a bit convoluted. 
			info is stored n cart as json, 
			must deserialize, 
			then see if var is set to determine state
		 --->
		
		<!--- 
			determine shipping quote. 
			this plays in if they do local pickup where we need to swap to denver prices 
		--->
		<cfset lcl.shippingQuoteId = observed.cartObj.getShippingQuoteId()>
		<cfset lcl.islocalpickup = 0>
		
		<cfif lcl.shippingQuoteId NEQ "">
			<cfset lcl.quoteObj = createObject("component","modules.cart_shipping.models.cartShippingQuotes").init(requestObject)>
			<cfset lcl.quoteObj.load(lcl.shippingQuoteId)>
			<cfif findnocase("in store pickup", lcl.quoteObj.getOptionLabel())>
				<cfset lcl.islocalpickup = 1>
			</cfif>
		</cfif>
		
		<cfif lcl.islocalpickup>
			<cfset lcl.deliveryinfocity = "Wheat Ridge">
			<cfset lcl.deliveryinfostate = "Co">
			<cfset lcl.deliveryinfozip = "80033">
		<cfelseif observed.cartObj.hasField("deliveryaddressinfo")>
			<cfset lcl.deliveryinfo = observed.cartObj.getDeliveryAddressInfo()>
			<cfif left(lcl.deliveryinfo,1) EQ "{">
				<cfset lcl.deliveryinfo = deserializejson(lcl.deliveryinfo)>
				
				<cfif structkeyexists(lcl.deliveryinfo, "delivery_state")>
					<cfset lcl.deliveryinfostate = lcl.deliveryinfo.delivery_state>
				<cfelse>
					<cfset lcl.deliveryinfostate = "">
				</cfif>
				
				<cfif structkeyexists(lcl.deliveryinfo, "delivery_city")>
					<cfset lcl.deliveryinfocity = lcl.deliveryinfo.delivery_city>
				<cfelse>
					<cfset lcl.deliveryinfocity = "">
				</cfif>
			
				<cfif structkeyexists(lcl.deliveryinfo, "delivery_zip")>
					<cfset lcl.deliveryinfozip = lcl.deliveryinfo.delivery_zip>
				<cfelse>
					<cfset lcl.deliveryinfozip = "">
				</cfif>
			<cfelse>
				<cfset lcl.deliveryinfocity = "">
				<cfset lcl.deliveryinfostate = "">
				<cfset lcl.deliveryinfozip = "">
			</cfif>
		<cfelse>
			<cfset lcl.deliveryinfocity = "">
			<cfset lcl.deliveryinfostate = "">
			<cfset lcl.deliveryinfozip = "">
		</cfif>
		
		<!--- Only if in co, add state tax --->
		<cfif NOT lcl.islocalpickup AND lcl.deliveryinfostate NEQ "CO">
			<cfreturn observed>
		</cfif>

		<!--- determine taxable amount --->
		<cfset lcl.taxable = observed.lineitems.subtotal['total']>
		
		<cfif isdefined("observed.lineitems.shipping.total")>
			<cfset lcl.taxable = lcl.taxable + observed.lineitems.shipping.total>
		</cfif>
		
		<!--- 
		<cfset lcl.s = structnew()>
		<cfset lcl.s.label = "State Tax">
		<cfset lcl.s.sortkey = 45>
		<cfset lcl.s.action = "add">
		<cfset lcl.s.total = 0.029 * lcl.taxable>
		<cfset observed.lineitems.statetax = lcl.s>
		 --->
		 
		<cfset lcl.s = structnew()>
		<cfset lcl.s.label = "Tax">
		<cfset lcl.s.sortkey = 45>
		<cfset lcl.s.action = "add">
		<cfset lcl.s.total = 0.029 * lcl.taxable>
		<cfset lcl.s.more.state = 0.029 * lcl.taxable>
		<cfset lcl.s.more.code = "X">
		
		<cfset observed.lineitems.tax = lcl.s>
		
		<!--- If using aj shipping add city taxes --->
		<cfset lcl.shipid = lcl.shippingQuoteId>

		<cfif lcl.shipid EQ "">
			<cfreturn observed>
		</cfif>
		
		<cfquery name="lcl.m" datasource="#requestobject.getVar("dsn")#">
			SELECT *
			FROM cartShippingQuotes
			WHERE 
				id = <cfqueryparam value="#lcl.shipid#" cfsqltype="cf_sql_varchar">
				AND cartid = <cfqueryparam value="#observed.cartObj.getCartId()#" cfsqltype="cf_sql_varchar">
				AND shippingModule = 'modules.applejack.models.shipping'
		</cfquery>
		
		<cfif lcl.m.recordcount EQ 0>
			<cfreturn observed>
		</cfif>
		
		<cfif lcl.deliveryinfocity EQ 'carbondale'>
			<cfset lcl.s.more.code = "D">
			<cfset lcl.citytax = 0.035>
		<cfelseif lcl.deliveryinfocity EQ 'vail'>
			<cfset lcl.s.more.code = "V">
			<cfset lcl.citytax = 0.04>
		<cfelseif lcl.deliveryinfocity EQ 'denver'>
			<cfset lcl.s.more.code = "A">
			<cfset lcl.citytax = 0.04>
			<cfset lcl.rtdtax = 0.012>
		<cfelseif lcl.deliveryinfocity EQ 'lakewood'>
			<cfset lcl.s.more.code = "L">
			<cfset lcl.citytax = 0.03>
			<cfset lcl.rtdtax = 0.017>
		<cfelseif lcl.deliveryinfocity EQ 'avon'>
			<cfset lcl.s.more.code = "E">
			<cfset lcl.citytax = 0.04>
		<cfelseif lcl.deliveryinfocity EQ 'aspen'>
			<cfset lcl.s.more.code = "B">
			<cfset lcl.citytax = 0.021>
		<cfelse>
			<cfset lcl.s.more.code = "Y">
			<cfset lcl.citytax = 0.03>
			<cfset lcl.rtdtax = 0.017>
		</cfif>
		
		<cfset lcl.s.total = lcl.s.total + lcl.citytax * lcl.taxable>
		<cfset lcl.s.more.city = lcl.citytax * lcl.taxable>
		
		<cfif structkeyexists(lcl, "rtdtax")>
			<cfset lcl.s.total = lcl.s.total + lcl.rtdtax * lcl.taxable>
			<cfset lcl.s.more.rtd = lcl.rtdtax * lcl.taxable>
		</cfif>

		<cfreturn observed>
	</cffunction>

</cfcomponent>