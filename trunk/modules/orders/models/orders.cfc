<cfcomponent name="order" extends="resources.abstractmodel">

	<cffunction name="init">
		<cfargument name="requestObject" required="true">
		<cfset variables.requestObject = arguments.requestObject>
		<cfset startorm("orders")>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="load">
		<cfargument name="id" required="true">
		<cfset var lcl = structnew()>
		
		<cfset super.load(id)>

		<cfset lcl.itemsObj = createObject("component", "modules.orders.models.orderItems").init(requestObject)>
		<cfset lcl.orderItems = lcl.itemsObj.getOrderItems(arguments.id)>
		<cfset variables.orderItems = requestObject.notifyObservers("orders.orderItems", lcl.orderItems)>
				
		<cfset lcl.lineItemsObj = createObject("component", "modules.orders.models.orderLineItems").init(requestObject)>
		<cfset lcl.s = structnew()>
		<cfset lcl.s.sort = "sortorder">
		<cfset lcl.orderLineItems = lcl.lineItemsObj.getByOrderId(arguments.id, lcl.s)>
		<cfset variables.orderLineItems = requestObject.notifyObservers("orders.orderLineItems", lcl.orderLineItems)>
		
		<cfset lcl.shippingQuoteObj = createObject("component", "modules.cart_shipping.models.cartShippingQuotes").init(requestObject)>
		<cfset variables.shippingQuote = lcl.shippingQuoteObj.getById(this.getShipping_QuoteId())>
		
		<cfset variables.orderPaymentObj = createObject("component", "modules.orderPayments.models.orderPayments").init(requestObject).load(arguments.id)>
	
	</cffunction>
	
<!---     <cffunction name="GetUsersOrders">
    	<cfargument name="id" required="yes">
        <cfset lcl = structnew()>
        <cfquery name="lcl.UserOrders" datasource="#requestObject.getVar("dsn")#">

		</cfquery>
    </cffunction> --->
    
	<cffunction name="getOrderItems">
		<cfif NOT structkeyexists(variables, "orderItems")>
			<cfthrow message="Please load order with id before calling getorderitems">
		</cfif>
		<cfreturn variables.orderitems>
	</cffunction>
	
	<cffunction name="getOrderLineItems">
		<cfif NOT structkeyexists(variables, "orderLineItems")>
			<cfthrow message="Please load order with id before calling getorderlineitems">
		</cfif>
		<cfreturn variables.orderlineitems>
	</cffunction>
	
	<cffunction name="getBillingAddressInfo">
		<cfset var lcl = structnew()>
		<cfset var rs = structnew()>
		<cfloop collection="#variables.itemdata#" item="lcl.itm">
			<cfif left(lcl.itm, 7) EQ "billing">
				<cfset rs[lcl.itm] = variables.itemdata[lcl.itm]>
			</cfif>
		</cfloop>
		<cfreturn rs>
	</cffunction>
	
	<cffunction name="getPaymentObjectInfo">
		<cfreturn variables.orderPaymentObj>
	</cffunction>
	
    <cffunction name="getUserObjInfo">
    	<cfreturn variables.userObj>
    </cffunction>
    
	<cffunction name="getShippingQuoteInfo">
		<cfreturn variables.shippingQuote>
	</cffunction>
	
	<cffunction name="getDeliveryAddressInfo">
		<cfset var lcl = structnew()>
		<cfset var rs = structnew()>
		<cfloop collection="#variables.itemdata#" item="lcl.itm">
			<cfif left(lcl.itm, 8) EQ "delivery">
				<cfset rs[lcl.itm] = variables.itemdata[lcl.itm]>
			</cfif>
		</cfloop>
		<cfreturn rs>
	</cffunction>
		
	<cffunction name="process">
		<cfargument name="cart" required="true">
		<cfset var lcl = structnew()>
		
		<!--- confirm cc is still stored in session. --->
		<cfif not isdefined("session.cc")>
			<cfset session.user.setFlash("The credit card is subject to a short timeout and expired")>
			<cflocation url="/cart/shippingpayment" addtoken="false">
		</cfif>
		<!--- START A TRANSACTION --->
		<cftransaction>
		
			<!--- FIRST GET CART INFO --->
			<cfset lcl.deliveryAddressinfo 	= deserializejson(cart.getDeliveryAddressInfo())>
			<cfset lcl.billingAddressinfo 	= deserializejson(cart.getBillingAddressInfo())>
           
			<cfset lcl.shippingQuoteid	 	= cart.getShippingQuoteId()>
			<cfset lcl.paymentInfo 			= deserializejson(cart.getPaymentInfo())>
			
			<cfset lcl.cartItems = cart.getCartItemsObj().getCartItems()>
			<cfset lcl.cartLineItems = cart.getCartLineItems('orderconfirmation')>
	
			<!--- lets determine items total --->
			<cfset lcl.cartqty = 0>
			<cfloop collection="#lcl.cartItems#" item="lcl.itm">
				<cfset lcl.cartqty = lcl.cartqty + lcl.cartItems[lcl.itm].quantity>
			</cfloop>
			
			<cfset this.setItemsTotal(lcl.cartqty)>
			
			<!--- lets determine price --->
			<cfloop from="1" to="#arraylen(lcl.cartLineItems)#" index="lcl.liidx">
				<cfif lcl.cartLineItems[lcl.liidx].name EQ "ordertotal">
					<cfset lcl.carttotal = lcl.cartLineItems[lcl.liidx].total>
					<cfbreak>
				</cfif>
			</cfloop>
			
			<cfset this.setOrderTotal(lcl.carttotal)>
			
			<cfloop collection="#lcl.deliveryAddressinfo#" item="lcl.key">
				<cfset this.setField(lcl.key, lcl.deliveryAddressInfo[lcl.key])>
			</cfloop>
			
			<cfloop collection="#lcl.billingAddressinfo#" item="lcl.key">
				<cfset this.setField(lcl.key, lcl.billingAddressinfo[lcl.key])>
			</cfloop>
			
			<cfset this.setShipping_QuoteId(lcl.shippingQuoteid)>
			<cfset this.setOrderStatus("new")>
			<cfset this.setUserId(requestObject.getUserObject().getUserId())>
			<cfset this.setDelivery_Notes(cart.getDelivery_Notes())>
			
			<!--- must save here to get id --->
			<cfset this.save()>
			
			<!--- manage order items here --->
			<cfset lcl.orderItems = createObject("component", "modules.orders.models.orderitems").init(requestObject)>

			<cfloop collection="#lcl.cartItems#" item="lcl.itm">
				<cfset lcl.cartItm = lcl.cartItems[lcl.itm]>
				<cfset lcl.orderItems.clear()>
				<cfset lcl.orderItems.setQuantity(lcl.cartItm.quantity)>
				<cfset lcl.orderItems.setTitle(lcl.cartItm.title)>
				<cfset lcl.orderItems.setType(lcl.cartItm.type)>
				<cfset lcl.orderItems.setIndividualPrice(lcl.cartItm.price)>
				<cfset lcl.orderItems.setPrice(lcl.cartItm.price_total)>
				<cfset lcl.orderItems.setOrderId(this.getId())>
				<cfset lcl.orderItems.setProductPriceItemid(lcl.cartItm.priceid)>
				<cfset lcl.orderItems.save()>
			</cfloop>
			
			<!--- manage cart line items here --->
			<cfset lcl.orderLineItems = createObject("component", "modules.orders.models.orderlineitems").init(requestObject)>

			<cfloop from="1" to="#arraylen(lcl.cartLineItems)#" index="lcl.liidx">
				<cfset lcl.litem = lcl.cartLineItems[lcl.liidx]>
				<cfset lcl.orderLineItems.clear()>
				<cfset lcl.orderLineItems.setOrderId(this.getId())>
				<cfset lcl.orderLineItems.setName(lcl.litem.name)>
				<cfset lcl.orderLineItems.setLabel(lcl.litem.label)>
				<cfset lcl.orderLineItems.setTotal(lcl.litem.total)>
				<cfset lcl.orderLineItems.setSortOrder(lcl.liidx)>
				<cfif structkeyexists(lcl.litem, "more") AND isstruct(lcl.litem.more)>
					<cfset lcl.orderLineItems.setMoreJSON(serializejson(lcl.litem.more))>
				</cfif>
				<cfset lcl.orderLineItems.save()>
			</cfloop>
			
			<cfset variables.orderPaymentObj = createObject("component", "modules.orderPayments.models.orderPayments").init(requestObject)>
			
			<cfset variables.orderPaymentObj.process_capture(this, cart, lcl.carttotal)>
			
			<!--- critical core stuff is saved, end transaction and continue with other less critical stuff --->
		
		<!--- reload so we can see that its exactly right and reeuse as if it was just loaded --->
		<cfset load(this.getId())>
		
		<cfset requestObject.notifyObservers("orders.neworder", this)>
					</cftransaction>
		<!--- start sending the messages --->
		<cfset lcl.messageinfo = structnew()>
        <cfset lcl.messageinfo.ordertotal = dollarformat(this.getOrderTotal())>
		<cfset lcl.messageinfo.deliverynotes = this.getDelivery_notes()>
		<cfif lcl.messageinfo.deliverynotes EQ ""><cfset lcl.messageinfo.deliverynotes = "none"></cfif>
		<!--- <cfset structappend(lcl.messageinfo, this.getValues())> --->
		<cfoutput>
		<cfsavecontent variable="lcl.messageinfo.formatted_destination_addy">#this.getDelivery_name()#<br>
#this.getDelivery_line1()#<br>
#this.getDelivery_line2()#<br>
#this.getDelivery_city()#, #this.getDelivery_state()# #this.getDelivery_postalcode()#<br>
#this.getDelivery_phone()#</cfsavecontent>
		
		<cfsavecontent variable="lcl.messageinfo.formatted_billing_addy">#this.getBilling_name()#<br>
#this.getBilling_line1()#<br>
#this.getBilling_line2()#<br>
#this.getBilling_city()#, #this.getBilling_state()# #this.getBilling_postalcode()#<br>
#this.getBilling_phone()#</cfsavecontent>
			
		<cfset lcl.uo = requestObject.getUserObject()>
		<cfset lcl.uoinfo = lcl.uo.getValues()>
		<!--- <cfloop collection="#lcl.uoinfo#" item="lcl.uoitem">
			<cfset lcl.uoinfo['user_' & lcl.uoitem] = lcl.uoinfo[lcl.uoitem]>
			<cfset structdelete(lcl.uoinfo, lcl.uoitem)>
		</cfloop> --->
		
		<cfset lcl.messageinfo.useremail = lcl.uoinfo.email>
		<cfset lcl.messageinfo.userfname = lcl.uoinfo.fname>
		<cfset lcl.messageinfo.userlname = lcl.uoinfo.lname>

		<cfsavecontent variable="lcl.messageinfo.formatted_user_info">#lcl.uoinfo.fname# #lcl.uoinfo.lname# (#lcl.uoinfo.username#)<br>
Cell : #lcl.uoinfo.mobilephone# Home : #lcl.uoinfo.homephone#<br>
#lcl.uoinfo.line1#<br>
#lcl.uoinfo.line2#<br>
#lcl.uoinfo.city#, #lcl.uoinfo.state# #lcl.uoinfo.postalcode#<br>
#lcl.uoinfo.email#</cfsavecontent>
		</cfoutput>
		
		<cfset lcl.messageinfo.orderid = this.getId()>
		
		<cfset lcl.orderitems = getOrderItems()>
		
		<cfset lcl.tbl = createObject("component", "utilities.table").init(requestObject)>
		<cfset lcl.tbl.setName("orders_newordermessage")>
		<cfset lcl.cols = lcl.tbl.getColumns()>
		<cfset lcl.tblatts = structnew()>
		<cfset lcl.tblatts['class'] = 'cart'>

		<cfset lcl.tbl.setTableAttributes(lcl.tblatts)>
		
		<cfset lcl.tblformats = structnew()>
		<cfset lcl.tblformats['price'] = 'money'>
		<cfset lcl.tblformats['individualprice'] = 'money'>
		<cfset lcl.tblformats['created'] = 'date'>

		<cfset lcl.tbl.setformats(lcl.tblformats)>
		
		<cfset lcl.tmp = structnew()>
		<cfset lcl.tmp.title = "Item ##">
		<cfset lcl.tmp.field = "productid">
				
		<cfset arrayappend(lcl.cols, lcl.tmp)>
		
		<cfset lcl.tmp = structnew()>
		<cfset lcl.tmp.title = "Title">
		<cfset lcl.tmp.field = "title">
		
		<cfset arrayappend(lcl.cols, lcl.tmp)>

		<cfset lcl.tmp = structnew()>
		<cfset lcl.tmp.title = "Price">
		<cfset lcl.tmp.field = "individualprice">
		<cfset lcl.tmp.attributes = structnew()>
		<cfset lcl.tmp.attributes.align = "right">
		<cfset arrayappend(lcl.cols, lcl.tmp)>

		<cfset lcl.tmp = structnew()>
		<cfset lcl.tmp.attributes = structnew()>
		<cfset lcl.tmp.attributes.align = "center">
		<cfset lcl.tmp.title = "Quantity">
		<cfset lcl.tmp.field = "quantity">
		<cfset arrayappend(lcl.cols, lcl.tmp)>		

		<cfset lcl.tmp = structnew()>
		<cfset lcl.tmp.title = "Total">
		<cfset lcl.tmp.field = "price">
		<cfset lcl.tmp.attributes = structnew()>
		<cfset lcl.tmp.attributes.align = "right">
		<cfset arrayappend(lcl.cols, lcl.tmp)>

		<cfset lcl.tbl.setColumns(lcl.cols)>
		<cfset lcl.tbl.setData(lcl.orderitems)>
		
		<cfset lcl.messageinfo.cartitems = lcl.tbl.showHTML()>
		
		<!--- now make the line items --->
		<cfset lcl.lineitems = getOrderLineItems()>
		
		<cfset lcl.tbl = createObject("component", "utilities.forms2.table").init(requestObject)>
		<cfset lcl.tbl.setName("previousorder")>
		<cfset lcl.tbl.addClass("cartshippingpaymenttotals")>
		
		<cfloop query="lcl.lineitems">
			<cfset lcl.tr = lcl.tbl.addItem("tablerow")>
			<cfset lcl.tr.addClass(name)>
			<cfset lcl.tr.setName(name & "_row")>
			
			<cfset lcl.td = lcl.tr.addItem("tablecolumn")>
			<cfset lcl.td.setName(name & "_col")>
			
			<cfset lcl.tdhtml = lcl.td.addItem("html")>
			<cfset lcl.tdhtml.setName(name & "_label")>
			<cfset lcl.tdhtml.setHTML(label)>
			
			<cfset lcl.td = lcl.tr.addItem("tablecolumn")>
			<cfset lcl.td.setName(name & "_col")>
			
			<cfset lcl.tdhtml = lcl.td.addItem("html")>
			<cfset lcl.tdhtml.setName(name & "_value")>
			<cfset lcl.tdhtml.setHTML(dollarformat(total))>
		</cfloop>
		
		<cfset lcl.messageinfo.cartlineitems = lcl.tbl.showHTML()>
		
		<cfset structappend(lcl.messageinfo, lcl.uoinfo)>
		
		<cfset lcl.shippingQuoteInfo = getShippingQuoteInfo()>
		<cfset lcl.messageinfo.shippinginfo = lcl.shippingQuoteInfo.modulelabel & ' ' & lcl.shippingQuoteInfo.optionlabel>

		<cfset lcl.msg = createObject("component", "modules.messaging.models.messaging").init(requestObject)>
		<cfset lcl.msg.sendMessage(
			lcl.messageinfo.useremail,
			"New order to Customer",
			lcl.messageinfo
		)>
		
		<cfset lcl.msg.sendMessage(
			requestObject.getVar("ordersadminemail", requestObject.getVar('systememailto')),
			"New order to Admin",
			lcl.messageinfo
		)>

		<cfset structdelete(session,"cc")>
		<cfset cart.destroyCart()> 

	</cffunction>
	
</cfcomponent>
