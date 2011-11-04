<cfcomponent name="previousinfo" extends="utilities.forms2">

	<cffunction name="make">
		<cfset var lcl = structnew()>
		<cfif requestObject.isRequestRegistryVarSet("orderObj")>
        	<cfset lcl.orderobj = requestObject.getRequestRegistryVar("orderobj")>
        <cfelse>
        	<cfset lcl.id = requestObject.getFormUrlVar("orderid")>
            <cfset lcl.orderObj = createObject("component", "modules.orders.models.orders").init(requestObject)>
            <cfset lcl.orderObj.load(lcl.id)>
        </cfif>
		<cfset lcl.billingAddressinfo = lcl.orderObj.getBillingAddressInfo()>
		<cfset lcl.deliveryAddressinfo = lcl.orderObj.getDeliveryAddressInfo()>
		<cfset lcl.orderitems = lcl.orderObj.getOrderItems()>
		<cfset lcl.lineitems = lcl.orderObj.getOrderLineItems()>
		<cfset lcl.shippingQuoteInfo = lcl.orderObj.getShippingQuoteInfo()>
		<cfset lcl.pmtObj = createObject("component", "modules.orderPayments.models.orderPayments").init(requestObject).load(lcl.orderObj.getId())>
	

		<!--- <cfset lcl.shippingMethodInfo = deserializejson(variables.cartModel.getShippingMethodInfo())> --->
		<!--- <cfset lcl.paymentInfo = deserializejson(variables.cartModel.getPaymentInfo())> --->

		<cfset lcl.itm = addItem("hidden")>
        <cfset lcl.itm.setName("orderid")>
        <cfset lcl.itm.setDefault(lcl.orderobj.getId())>
		<cfset variables.forminfo.name = "previousorder">
		
		<!--- TABLE > FIRSTROW --->
		<cfset lcl.cols = addItem("table")>
		<cfset lcl.cols.setName("validateordertable")>
		<cfset lcl.cols.addClass("fullwidth")>
		
		<cfset lcl.r = lcl.cols.addItem("tablerow")>
		<cfset lcl.r.setName("r1")>
		
		<!--- COL1 > BILLINGINFO --->
		<cfset lcl.c1 = lcl.r.addItem("tablecolumn")>
		<cfset lcl.c1.setName("col1")>
		
		<cfset lcl.txt = lcl.c1.addItem("section")>
		<cfset lcl.txt.setName('billing_information')>
		<cfset lcl.txt.setLabel('Billing Information:')>
		
		<cfset lcl.txt = lcl.c1.addItem("html")>
		<cfset lcl.txt.setName('billing_info_display')>
		
		<cfoutput>
		<cfsavecontent variable="lcl.billinghtml">
			#lcl.billingaddressinfo.billing_name#<br>
			#lcl.billingaddressinfo.billing_line1#<br>
			<cfif isdefined("lcl.billingaddressinfo.billing_line2") AND lcl.billingaddressinfo.billing_line2 NEQ "">#lcl.billingaddressinfo.billing_line2#<br></cfif>
			#lcl.billingaddressinfo.billing_city#, 
			#lcl.billingaddressinfo.billing_state#, 
			#lcl.billingaddressinfo.billing_postalcode#<br>
			<cfif isdefined("lcl.billingaddressinfo.billing_phone") AND lcl.billingaddressinfo.billing_phone NEQ "">#lcl.billingaddressinfo.billing_phone#<br></cfif>
			#lcl.billingaddressinfo.billing_email#
		</cfsavecontent>
		</cfoutput>
		
		<cfset lcl.txt.setHTML(lcl.billinghtml)>
		
		<!--- COL2 > DELIVERYINFO --->
		<cfset lcl.c2 = lcl.r.addItem("tablecolumn")>
		<cfset lcl.c2.setName("col2")>
		
		<cfset lcl.txt = lcl.c2.addItem("section")>
		<cfset lcl.txt.setName('delivery_information')>
		<cfset lcl.txt.setLabel('Shipping Information:')>
		
		<cfset lcl.txt = lcl.c2.addItem("html")>
		<cfset lcl.txt.setName('delivery_info_display')>
		
		<cfoutput>
		<cfsavecontent variable="lcl.deliveryhtml">
			#lcl.deliveryaddressinfo.delivery_name#<br>
			#lcl.deliveryaddressinfo.delivery_line1#<br>
			<cfif isdefined("lcl.deliveryaddressinfo.delivery_line2") AND lcl.deliveryaddressinfo.delivery_line2 NEQ "">#lcl.deliveryaddressinfo.delivery_line2#<br></cfif>
			#lcl.deliveryaddressinfo.delivery_city#, 
			#lcl.deliveryaddressinfo.delivery_state#, 
			#lcl.deliveryaddressinfo.delivery_postalcode#<br>
			<cfif isdefined("lcl.deliveryaddressinfo.delivery_phone") AND lcl.deliveryaddressinfo.delivery_phone NEQ "">#lcl.deliveryaddressinfo.delivery_phone#</cfif>
		</cfsavecontent>
		</cfoutput>
		
		<cfset lcl.txt.setHTML(lcl.deliveryhtml)>
		
		<!--- COL3 > SHIPPINGOPTION --->

		<cfset lcl.c3 = lcl.r.addItem("tablecolumn")>
		<cfset lcl.c3.setName("col3")>
		
		<cfset lcl.txt = lcl.c3.addItem("section")>
		<cfset lcl.txt.setName('shipping_method')>
		<cfset lcl.txt.setLabel('Delivery Option:')>
		
		<cfset lcl.txt = lcl.c3.addItem("html")>
		<cfset lcl.txt.setName('shipping_info_display')>
		
		<cfset lcl.shippinghtml = lcl.shippingQuoteInfo.modulelabel & '<br>' & lcl.shippingQuoteInfo.optionlabel & ' (#dollarformat(lcl.shippingQuoteInfo.cost)#)'>
			
		<cfset lcl.txt.setHTML(lcl.shippinghtml)>
		
		<!--- COL3 > PAYMENTOPTION --->
		<cfset lcl.c4 = lcl.r.addItem("tablecolumn")>
		<cfset lcl.c4.setName("col1")>
		
		<cfset lcl.txt = lcl.c4.addItem("section")>
		<cfset lcl.txt.setName('payment_method')>
		<cfset lcl.txt.setLabel('Payment Option:')>
		
		<cfset lcl.txt = lcl.c4.addItem("html")>
		<cfset lcl.txt.setName('payment_info_display')>
				
		<cfset lcl.txt.setHTML(lcl.pmtObj.showHTML())>
		
		        
        <cfset lcl.txt = addItem("html")>
		<cfset lcl.txt.setName('hr')>
		<cfset lcl.txt.setHTML('<hr class="fullwidthdottedhr"><br>')>
		
		<cfset lcl.txt = addItem("section")>
		<cfset lcl.txt.setName('cart_list')>
		<cfset lcl.txt.setLabel('Order Summary:')>
		
		<!--- MAKE CART LIST HERE --->

		<cfset lcl.tbl = addAlternateItem(createObject("component", "utilities.table").init(requestObject))>
		<cfset lcl.tbl.setName("orders_previousorder")>
		<cfset lcl.cols = lcl.tbl.getColumns()>
		<cfset lcl.tblatts = structnew()>
		<cfset lcl.tblatts['class'] = 'cart fancytable'>

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
				
		<!--- TOTALS COLUMN --->
		
		<cfset lcl.tbl = addItem("table")>
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
               
        <cfif lcl.orderobj.getMoreJSON() NEQ "">       
        	<cfset lcl.unjson = deserializejson(lcl.orderobj.getmoreJSON())>
            <cfset lcl.cardsavings = lcl.unjson.advantagesavings>
            <cfset lcl.retailprice = lcl.unjson.retailprice>
            
            <cfset lcl.tr = lcl.tbl.addItem("tablerow")>
			<cfset lcl.tr.addClass("retailprice")>
			<cfset lcl.tr.setName("retailprice_row")>
			
			<cfset lcl.td = lcl.tr.addItem("tablecolumn")>
			<cfset lcl.td.setName("retailprice_col")>
			
			<cfset lcl.tdhtml = lcl.td.addItem("html")>
			<cfset lcl.tdhtml.setName("retailprice_label")>
			<cfset lcl.tdhtml.setHTML("Order Retail Price")>
			
			<cfset lcl.td = lcl.tr.addItem("tablecolumn")>
			<cfset lcl.td.setName("retailpricevalue_col")>
			
			<cfset lcl.tdhtml = lcl.td.addItem("html")>
			<cfset lcl.tdhtml.setName("retailprice_value")>
			<cfset lcl.tdhtml.setHTML(dollarformat(lcl.retailprice))>
            
            <cfif lcl.cardsavings gt 0>
				<cfset lcl.tr = lcl.tbl.addItem("tablerow")>
                <cfset lcl.tr.addClass("cardsavings")>
                <cfset lcl.tr.setName("cardsavings_row")>
                
                <cfset lcl.td = lcl.tr.addItem("tablecolumn")>
                <cfset lcl.td.setName("cardsavings_col")>
                
                <cfset lcl.tdhtml = lcl.td.addItem("html")>
                <cfset lcl.tdhtml.setName("cardsavings_label")>
                <cfset lcl.tdhtml.setHTML("Advantage Card Savings")>
                
                <cfset lcl.td = lcl.tr.addItem("tablecolumn")>
                <cfset lcl.td.setName("cardsavingsvalue_col")>
                
                <cfset lcl.tdhtml = lcl.td.addItem("html")>
                <cfset lcl.tdhtml.setName("cardsavings_value")>
                <cfset lcl.tdhtml.setHTML(dollarformat(lcl.cardsavings))>
            </cfif>
        </cfif>
               
        <cfset lcl.txt = addItem("html")>
		<cfset lcl.txt.setName('hr')>
		<cfset lcl.txt.setHTML('<hr class="fullwidthdottedhr">')>
        
        <cfset lcl.txt = addItem("imagebtn")>
        <cfset lcl.txt.setSource('/ui/images/cart/reorderBtn.png')>
		<cfset lcl.txt.setName('action')>
		<cfset lcl.txt.setFormStyle("float","right")>
        <cfset lcl.txt.setFormStyle("padding","10px 0 0 0")>
		<cfset lcl.txt.setDefault('Reorder')>
        
<!---		<cfset lcl.sbm = addItem("submit")>
		<cfset lcl.sbm.setDefault('Reorder')>
		<cfset lcl.sbm.setName('reorder')>--->
		
	</cffunction>
	
	<cffunction name="validate">
		<cfargument name="clear" default="false">
		<!--- submit is a reorder action - no validation required --->
        <cfset var vdtr = super.validate(clear)>
		<cfreturn vdtr>
	</cffunction>
	
	<cffunction name="submit">
		<cfargument name="vdtr" required="true">
		<cfset var lcl = structnew()>
	 	<!--- * clear current cart and load with previous info --->
        
        <!--- get previous order info --->
        <cfif requestObject.isRequestRegistryVarSet("orderObj")>
        	<cfset lcl.orderobj = requestObject.getRequestRegistryVar("orderobj")>
        <cfelse>
        	<cfset lcl.id = requestObject.getFormUrlVar("orderid")>
            <cfset lcl.orderObj = createObject("component", "modules.orders.models.orders").init(requestObject)>
            <cfset lcl.orderObj.load(lcl.id)>
        </cfif>
        
        <!--- clear current cart items, if any --->
		<cfset lcl.cartModel = createObject("component","modules.cart.models.cart").init(requestObject)>
		<cfset lcl.cartModel.load()>
		<cfset lcl.cartItemsModel = lcl.cartModel.getCartItemsObj()>
		<cfset lcl.cartItemsModel.clearCartItems()>
        
        <!--- fill cart with order list --->
        <cfset lcl.prevOrderItems = lcl.orderObj.getOrderItems()>
        <cfoutput query="lcl.prevOrderItems">
        	<cfset lcl.cartItemsModel.addCartItem(productpriceitemid, quantity)>
        </cfoutput>      
	 	<cfreturn vdtr>
	</cffunction>
	
	<cffunction name="onsuccessinfo">
		<cfset var lcl = structnew()>
		<cfset var s = structnew()>
		<cfset s.relocate = "/cart/">
		<cfset s.message = "Your cart was reloaded with the previous order. To complete it click the checkout button.">
		<cfreturn s>
	</cffunction>
	
</cfcomponent>