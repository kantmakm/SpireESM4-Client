<cfcomponent name="cart" extends="resources.abstractmodel">

	<cffunction name="init">
		<cfargument name="requestObject" required="true">
		<cfset variables.requestObject = arguments.requestObject>
		<cfset startorm("cart")>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="load">
		<cfargument name="id">
		
		<cfset var lcl = structnew()>
		
		<cfif structkeyexists(arguments, "id")>
			<cfset variables.setcartid = arguments.id>
		</cfif>
		
		<cfset lcl.cartr = this.getByCartId(getCartId())>
	
		<cfif lcl.cartr.recordcount EQ 0>
			<cfset variables.itemdata = structnew()>
			<cfset variables.itemdata.cartid = getCartid()>
			<cfset this.save()>
		<cfelse>
			<cfloop list="#lcl.cartr.columnlist#" index="lcl.idx">
				<cfset variables.itemdata[lcl.idx] = lcl.cartr[lcl.idx][1]>
			</cfloop>
		</cfif>
		<cfreturn true>
	</cffunction>
	
	<cffunction name="getCartItemsObj">
		<cfif NOT structkeyexists(variables, "itemsObj")>
			<cfset variables.itemsObj = createObject("component", "modules.cart.models.cartItems").init(requestObject)>
			<cfset variables.itemsObj.setCartObj(this)>
			<cfset variables.itemsObj.loadCartItems()>
		</cfif>
		<cfreturn variables.itemsObj>
	</cffunction>
	
	<cffunction name="destroyCart">    
		<cfset var lcl = structnew()>
		
		<cfset lcl.itemsObj = getCartItemsObj()>
        <cfset lcl.itemsObj.clearCartItems()>
		<cfset this.destroy(this.getID())>
	</cffunction> 
		
	<cffunction name="getCartId">
		<!---get user --->
		<cfif isdefined("variables.itemdata.cartid")>
			<cfreturn variables.itemdata.cartid>
		<cfelseif isdefined("variables.setcartid")>
			<cfreturn variables.setcartid>
		<cfelseif session.user.isloggedin()>
			<!--- if user is logged in, use userid --->
			<cfreturn session.user.getUserId()>
		<cfelseif requestObject.isFormUrlVarSet("cartid")> 
			<!--- if cartid cookie, use that for cartid --->
			<cfreturn requestObject.getFormUrlVar("cartid")>
		<cfelse> 
			<!--- no cartid cookie, make one and use that --->
			<cfset cookie.cartid = createuuid()>
			<cfreturn cookie.cartid>
		</cfif>
	</cffunction>
	
	<cffunction name="checkoutorder">
		<cfset var order = arraynew(1)>
		
		<cfset arrayappend(order,{page="/cart/billingdelivery",label="Billing & Shipping /Delivery Address"})>
		<cfset arrayappend(order,{page="/cart/shippingpayment",label="Shipping/Delivery & Payment Options"})>
		<cfset arrayappend(order,{page="/cart/orderconfirmation",label="Validate Order"})>
		<cfset arrayappend(order,{page="/cart/ordercomplete",label="Order Complete"})>
		
		<cfset requestObject.notifyObservers("cart.cartprocess", order)>
		
		<cfreturn order>
	</cffunction>

	<cffunction name="getCartLineItems">
		<!--- 
			this function creates an array of the line items for a cart relative to the view called.
			It creates an initial array, sends it to the notifiysers for modification, then gives it to caller for processing.
		 --->
		<cfargument name="view" default="cart">
		<cfset var lcl = structnew()>
		<cfset var ci = getCartItemsObj()>
		<cfset cii  = ci.getCartItems()>
		
		<cfset lcl.subtotal = 0>

		<cfloop collection="#cii#" item="lcl.itm">
			<cfset lcl.subtotal = lcl.subtotal + cii[lcl.itm].price_total>
		</cfloop>
		
		<cfset lcl.observed = structnew()>
		<cfset lcl.observed.lineitems = structnew()>
		
		<!--- setup sub total --->
		<cfset lcl.observed.lineitems.subtotal = structnew()>
		<cfset lcl.observed.lineitems.subtotal.sortkey = 10>
		<cfset lcl.observed.lineitems.subtotal.label = "Subtotal">
		<cfset lcl.observed.lineitems.subtotal.total = lcl.subtotal>
		<cfset lcl.observed.lineitems.subtotal.action = "add">
		
		<!--- setup cart total if this is not the cart view --->
		<cfif arguments.view NEQ "cart">
			<cfset lcl.observed.lineitems.ordertotal = structnew()>
			<cfset lcl.observed.lineitems.ordertotal.sortkey = 50>
			<cfset lcl.observed.lineitems.ordertotal.label = "Order Total">
			<cfset lcl.observed.lineitems.ordertotal.total = 0>
			<cfset lcl.observed.lineitems.ordertotal.action = "none">
		</cfif>
		
		<!--- add the cart obj so items can see what is being purchased --->
		<cfset lcl.observed.cartObj = this>
		
		<!--- export for observation --->
		<cfset lcl.observed = requestObject.notifyObservers("cart.cartLineItems_" & arguments.view, lcl.observed)>
		
		<!--- sort for returning --->
		<cfset lcl.observedsorts = structsort(lcl.observed.lineitems,'numeric',"asc","sortkey")>

		<cfset lcl.lineitems = arraynew(1)>
		<cfset lcl.total = 0>

		<!--- calculate total from returned line items --->
		<cfloop array="#lcl.observedsorts#" index="lcl.lineitemkey">
			<cfset lcl.observed.lineitems[lcl.lineitemkey].name = lcl.lineitemkey>
			<cfset arrayappend(lcl.lineitems, lcl.observed.lineitems[lcl.lineitemkey])>
			<cfswitch expression="#lcl.observed.lineitems[lcl.lineitemkey].action#">
				<cfcase value="add">
					<cfset lcl.total = lcl.total + lcl.observed.lineitems[lcl.lineitemkey].total>
				</cfcase>
				<cfcase value="subtract">
					<cfset lcl.total = lcl.total - lcl.observed.lineitems[lcl.lineitemkey].total>
				</cfcase>
			</cfswitch>
		</cfloop>
		
		<cfif arguments.view NEQ "cart">
			<cfloop from="1" to="#arraylen(lcl.lineitems)#" index="lcl.i">
				<cfif lcl.lineitems[lcl.i].name EQ "ordertotal">
					<cfset lcl.lineitems[lcl.i].total = lcl.total>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn lcl.lineitems>
	</cffunction>
	
	<cffunction name="getCurrentSubTotal">
		<cfset var lcl = structnew()>
		<cfset lcl.li = getCartLineItems('shippingpayment')>
		<cfloop array="#lcl.li#" index="lcl.liitm">
			<cfif lcl.liitm.name EQ "subtotal">
				<cfreturn lcl.liitm.total>
			</cfif>
		</cfloop>
		<cfreturn 0>
	</cffunction>
	
	<cffunction name="getCurrentTotal">
		<cfset var lcl = structnew()>
		<cfset lcl.li = getCartLineItems('shippingpayment')>
		<cfloop array="#lcl.li#" index="lcl.liitm">
			<cfif lcl.liitm.name EQ "ordertotal">
				<cfreturn numberformat(lcl.liitm.total,"________________.00")>
			</cfif>
		</cfloop>
		<cfreturn 0>
	</cffunction>
	
</cfcomponent>
