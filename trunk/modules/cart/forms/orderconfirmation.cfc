<cfcomponent name="clientinfo" extends="utilities.forms2">

	<cffunction name="make">
		<cfset var lcl = structnew()>
		<cfset var uo = requestObject.getUserObject()>
		
		<cfif NOT uo.isloggedin()>
			<cfset uo.setFlash("Your session has expired. Please relogin. Your cart will still be available.")>
			<cflocation url="/user/login/?returnto=/cart/" addtoken="false">
		</cfif>
		
		<cfset variables.cartModel = createObject("component","modules.cart.models.cart").init(requestObject)>
		<cfset variables.cartModel.load()>
		<cfset variables.cartItemsModel = cartModel.getCartItemsObj()>
		
		<cfset lcl.deliveryAddressinfo = variables.cartModel.getDeliveryAddressInfo()>
		<cfset lcl.billingAddressinfo = variables.cartModel.getBillingAddressInfo()>

		<cfif NOT (isJSON(lcl.deliveryAddressInfo) AND isJSON(lcl.deliveryAddressInfo))>
			<cfset uo.setFlash("There was an error, please enter your shipping information")>
			<cflocation url="/cart/billingdelivery/" addtoken="false">
		</cfif>
		
		<cfset lcl.deliveryAddressinfo = deserializejson(lcl.deliveryAddressinfo)>
		<cfset lcl.billingAddressinfo = deserializejson(lcl.billingAddressinfo)>
		
		<cfset lcl.shippingQuoteObj = createObject("component","modules.cart_shipping.models.cartShippingQuotes").init(requestObject)>
		<cfset lcl.shippingQuoteObj.load(variables.cartModel.getShippingQuoteId())>
		<cfset lcl.paymentInfo = deserializejson(variables.cartModel.getPaymentInfo())>

		<cfset lcl.totalslineitems = cartModel.getCartLineItems('orderconfirmation')>
		
		<cfset variables.forminfo.name = "checkoutvalidateorderform">
		
		<!--- TABLE > FIRSTROW --->
		<cfset lcl.cols = addItem("table")>
		<cfset lcl.cols.setName("validateordertable")>
        <cfset lcl.cols.addClass("fullwidth")>
		
		<cfset lcl.r = lcl.cols.addItem("tablerow")>
		<cfset lcl.r.setName("r1")>
		
		<!--- COL1 > BILLINGINFO --->
		<cfset lcl.c1 = lcl.r.addItem("tablecolumn")>
		<cfset lcl.c1.setName("col1")>
		<cfset lcl.c1.addClass("tablefontstyle")>
        
		<cfset lcl.txt = lcl.c1.addItem("section")>
		<cfset lcl.txt.setName('billing_information')>
		<cfset lcl.txt.setLabel('<h3 style="display:inline">Billing Information:</h3> <a style="display:inline" href="/cart/billingdelivery">(Edit)</a>')>
		
		<cfset lcl.txt = lcl.c1.addItem("html")>
		<cfset lcl.txt.setName('billing_info_display')>
		
		<cfoutput>
		<cfsavecontent variable="lcl.billinghtml">
			<label>#lcl.billingaddressinfo.billing_name#</label>
			<label>#lcl.billingaddressinfo.billing_line1#</label>
			<cfif lcl.billingaddressinfo.billing_line2 NEQ ""><label>#lcl.billingaddressinfo.billing_line2#</label></cfif>
			<label>#lcl.billingaddressinfo.billing_city#, 
			#lcl.billingaddressinfo.billing_state#, 
			#lcl.billingaddressinfo.billing_postalcode#</label>
			<label>#lcl.billingaddressinfo.billing_phone#</label>
			<label>#lcl.billingaddressinfo.billing_email#</label>
		</cfsavecontent>
		</cfoutput>
		
		<cfset lcl.txt.setHTML(lcl.billinghtml)>
		
		<!--- COL2 > DELIVERYINFO --->
		<cfset lcl.c2 = lcl.r.addItem("tablecolumn")>
		<cfset lcl.c2.setName("col2")>
		
		<cfset lcl.txt = lcl.c2.addItem("section")>
		<cfset lcl.txt.setName('delivery_information')>
		<cfset lcl.txt.setLabel('Shipping Information: <a href="/cart/billingdelivery">(Edit)</a>')>
		
		<cfset lcl.txt = lcl.c2.addItem("html")>
		<cfset lcl.txt.setName('delivery_info_display')>
		
		<cfoutput>
		<cfsavecontent variable="lcl.deliveryhtml">
			<label>#lcl.deliveryaddressinfo.delivery_name#</label>
			<label>#lcl.deliveryaddressinfo.delivery_line1#</label>
			<cfif lcl.deliveryaddressinfo.delivery_line2 NEQ ""><label>#lcl.deliveryaddressinfo.delivery_line2#</label></cfif>
			<label>#lcl.deliveryaddressinfo.delivery_city#, 
			#lcl.deliveryaddressinfo.delivery_state#,
			#lcl.deliveryaddressinfo.delivery_postalcode#</label>
			<label>#lcl.deliveryaddressinfo.delivery_phone#</label>
		</cfsavecontent>
		</cfoutput>
		
		<cfset lcl.txt.setHTML(lcl.deliveryhtml)>
		
		<!--- COL3 > SHIPPINGOPTION --->
		<cfset lcl.c3 = lcl.r.addItem("tablecolumn")>
		<cfset lcl.c3.setName("col3")>
		
		<cfset lcl.txt = lcl.c3.addItem("section")>
		<cfset lcl.txt.setName('shipping_method')>
		<cfset lcl.txt.setLabel('Delivery Option: <a href="/cart/shippingpayment">(Edit)</a>')>
		
		<cfset lcl.txt = lcl.c3.addItem("html")>
		<cfset lcl.txt.setName('shipping_info_display')>
		
		<cfoutput>
		<cfsavecontent variable="lcl.shippinghtml">
			<label>#lcl.shippingQuoteObj.getModuleLabel()#</label>
			<label>#lcl.shippingQuoteObj.getOptionLabel()#</label>
		</cfsavecontent>
		</cfoutput>
		<cfset lcl.txt.setHTML(lcl.shippinghtml)>
		
		<!--- COL3 > PAYMENTOPTION --->
		<cfset lcl.c4 = lcl.r.addItem("tablecolumn")>
		<cfset lcl.c4.setName("col1")>
		
		<cfset lcl.txt = lcl.c4.addItem("section")>
		<cfset lcl.txt.setName('payment_method')>
		<cfset lcl.txt.setLabel('Payment Option: <a href="/cart/shippingpayment">(Edit)</a>')>
		
		<cfset lcl.txt = lcl.c4.addItem("html")>
		<cfset lcl.txt.setName('payment_info_display')>
		
		<cfoutput>
		<cfsavecontent variable="lcl.paymenthtml">
			<label>#lcl.paymentinfo.pmtinfo_card_type#</label>
			<label>#lcl.paymentinfo.pmtinfo_card_number#</label>
			<label>#lcl.paymentinfo.pmtinfo_expiration_date#</label>
		</cfsavecontent>
		</cfoutput>
		
		<cfset lcl.txt.setHTML(lcl.paymenthtml)>

       	<cfset lcl.txt = addItem("html")>
		<cfset lcl.txt.setName('hr')>
		<cfset lcl.txt.setHTML('<br class="clear"/><hr class="fullwidthdottedhr"><br>')>
		
		<cfset lcl.txt = addItem("section")>
		<cfset lcl.txt.setName('cart_list')>
		<cfset lcl.txt.setLabel('Order Summary: <a href="/cart">(Edit)</a>')>
		
		<!--- MAKE CART LIST HERE --->

		<cfset lcl.tbl = addAlternateItem(createObject("component", "utilities.table").init(requestObject))>
		<cfset lcl.tbl.setName("cartlist_orderconfirmation")>
		<cfset lcl.cols = lcl.tbl.getColumns()>
		<cfset lcl.tblatts = structnew()>
		<cfset lcl.tblatts['class'] = 'cart fancytable'>

		<cfset lcl.tbl.setTableAttributes(lcl.tblatts)>
		
		<cfset lcl.tblformats = structnew()>
		<cfset lcl.tblformats['price_total'] = 'money'>
		<cfset lcl.tblformats['price'] = 'money'>
		<!---<cfset lcl.tblformats['created'] = 'date'>--->

		<cfset lcl.tbl.setformats(lcl.tblformats)>
		
		<cfset lcl.tmp = structnew()>
		<cfset lcl.tmp.title = "Item ##">
		<cfset lcl.tmp.field = "productid">
				
		<cfset arrayappend(lcl.cols, lcl.tmp)>
		
		<cfset lcl.tmp = structnew()>
		<cfset lcl.tmp.title = "Description">
		<cfset lcl.tmp.field = "title">
		<cfset lcl.tmp.format = "<a href=""[producturl]"">[title]</a>">
		
		<cfset arrayappend(lcl.cols, lcl.tmp)>

		<cfset lcl.tmp = structnew()>
		<cfset lcl.tmp.title = "Price">
		<cfset lcl.tmp.field = "price">
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
		<cfset lcl.tmp.field = "price_total">
		<cfset lcl.tmp.attributes = structnew()>
		<cfset lcl.tmp.attributes.align = "right">
		<cfset arrayappend(lcl.cols, lcl.tmp)>

		<cfset lcl.tbl.setColumns(lcl.cols)>
		<cfset lcl.tbl.setData(cartItemsModel.getCartItems())>
				
		<!--- TOTALS COLUMN --->
		
		<cfset lcl.tbl = addItem("table")>
		<cfset lcl.tbl.setName("cartshippingpaymenttotals")>
		<cfset lcl.tbl.addClass("cartshippingpaymenttotals")>
		
		<cfloop array="#lcl.totalslineitems#" index="lcl.idx">
			<cfset lcl.tr = lcl.tbl.addItem("tablerow")>
			<cfset lcl.tr.addClass(lcl.idx.name)>
			<cfset lcl.tr.setName(lcl.idx.name & "_row")>
			
			<cfset lcl.td = lcl.tr.addItem("tablecolumn")>
			<cfset lcl.td.setName(lcl.idx.name & "_col")>

			<cfset lcl.tdhtml = lcl.td.addItem("html")>
			<cfset lcl.tdhtml.setName(lcl.idx.name & "_label")>
			<cfset lcl.tdhtml.setHTML(lcl.idx.label & ":")>
			
			<cfset lcl.td = lcl.tr.addItem("tablecolumn")>
			<cfset lcl.td.setName(lcl.idx.name & "_col")>
			
			<cfset lcl.tdhtml = lcl.td.addItem("html")>
			<cfset lcl.tdhtml.setName(lcl.idx.name & "_value")>
            <cfset lcl.tdhtml.addClassToForm("alignd")>
			<cfset lcl.tdhtml.setHTML(dollarformat(lcl.idx.total))>
		</cfloop>

		<cfset lcl.msgdiv = addItem("div")>
        <cfset lcl.msgdiv.setName("msgdiv")>
        <cfset lcl.msgdiv.addClass("freediv")>
		<cfset lcl.txt = lcl.msgdiv.addItem("html")>
		<cfset lcl.txt.setName('verification_display')>
		
		<cfset var msg = createObject("component","modules.messaging.models.messaging").init(requestObject)>
		<cfset msg.setupMessage("Cart Special Instructions", structnew())>
        <cfset lcl.txt.setHTML(msg.getMessage().message)>
		
        <cfset lcl.txt = additem("html")>
        <cfset lcl.txt.setName('orderH3')>
        <cfset lcl.txt.setHTML('<h3 class="sectionlabel" style="clear:both;text-align:left;">Order or Delivery Notes:</h3>')>
        
		<cfset lcl.txt = addItem("textarea")>
        <cfset lcl.txt.setName('ordernotestxt')>
        <cfset lcl.txt.addClassToForm('ordernotes')>
        <cfset lcl.txt.setLabel('')>
        <cfset lcl.txt.setValidationLabel('Order Notes Text')>
        <cfset lcl.txt.setDefault('')>          
        <cfset lcl.txt.setId('txtOrderNotes')>
        
 		<cfset lcl.txt = addItem("html")>
		<cfset lcl.txt.setName('hr3')>
		<cfset lcl.txt.setHTML('<br class="clear"/><hr class="fullwidthdottedhr"><br>')>
        
        <cfset lcl.sbm = addItem("imagebtn")>
        <cfset lcl.sbm.setSource('/ui/images/cart/processOrderBtn.png')>
		<cfset lcl.sbm.setName('processorder')>
        <cfset lcl.sbm.setFormStyle('float','right')>
        <cfset lcl.sbm.setFormStyle('margin-right','0px')>
		<cfset lcl.sbm.setDefault('PROCESS ORDER')>
		
	</cffunction>
	
	<cffunction name="validate">
		<cfargument name="clear" default="false">
		<cfset var vdtr = super.validate(clear)>
		
		<cfif NOT vdtr.passValidation()>
			<cfreturn vdtr>
		</cfif>
		
		<cfset variables.cartModel.setDelivery_notes(requestObject.getFormUrlvar("ordernotestxt"))>
		
		<cfif NOT variables.cartModel.save()>
			<cfreturn variables.cartModel.getValidator()>
		</cfif>		

		<cfreturn vdtr>
	</cffunction>
	
	<cffunction name="submit">
		<cfargument name="vdtr" required="true">
		
		<cfset var lcl = structnew()>
		
		<cfset lcl.order = createObject("component", "modules.orders.models.orders").init(requestObject)>
		
		<cfset lcl.order.process(variables.cartModel)>
		
		<cfset requestObject.getUserObject().saveData("orderid", lcl.order.getId())>
		
		<cfreturn vdtr>
	</cffunction>
	
	<cffunction name="onsuccessinfo">
		<cfset var lcl = structnew()>
		<cfset var s = structnew()>
		<!--- Here we use the checkout order to determine the current page and go to the next one --->
		<cfset lcl.cart = createObject("component", "modules.cart.models.cart").init(requestObject)>
		<cfset lcl.order = lcl.cart.checkoutorder()>
		<cfset lcl.cpage = requestObject.getFormUrlVar("submitfrom")>
		
		<cfloop from="1" to="#arraylen(lcl.order)#" index="lcl.i">
			<cfif lcl.order[lcl.i].page & '/' EQ lcl.cpage AND arraylen(lcl.order) NEQ lcl.i>
				<cfset s.relocate = lcl.order[lcl.i + 1].page>
				<cfbreak>
			</cfif>
		</cfloop>
	
		<cfset s.message = "Excellent. your order is in progress.">
		
		<cfreturn s>
	</cffunction>
</cfcomponent>