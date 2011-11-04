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
		<cfset variables.user = requestObject.getUserObject()>
		<cfset variables.paymentInfo = variables.cartModel.getPaymentInfo()>
		
		<cfif variables.paymentInfo EQ "">
			<cfset variables.paymentInfo = structnew()>
		<cfelse>
			<cfset variables.paymentInfo = deserializejson(variables.paymentInfo)>
		</cfif>
		
		<cfset variables.forminfo.name = "checkoutclientshippingform">
		<cfset request.resetformval = 0>
		
		<cfif isFirstView()>
			<cfset variables.formdata = variables.cartModel.getValues()>
		</cfif>
		
		<!--- DELIVERY OPTIONS --->
		<cfset lcl.cols = addItem("table")>
		<cfset lcl.cols.setName("clientinfotable")>
		<cfset lcl.cols.addClass("fullwidth")>
		
		<cfset lcl.r = lcl.cols.addItem("tablerow")>
		<cfset lcl.r.setName("r1")>
		
		<!--- col1 --->
		<cfset lcl.c1 = lcl.r.addItem("tablecolumn")>
		<cfset lcl.c1.setName("col1")>
		
        <cfset lcl.txt = lcl.c1.addItem("html")>
		<cfset lcl.txt.setName('col1title')>
		<cfset lcl.txt.setHTML('<h3>Shipping/Delivery Options</h3>')>
        
<!---		<cfset lcl.txt = lcl.c1.addItem("section")>
		<cfset lcl.txt.setName('Shipping Delivery Options')>
		<cfset lcl.txt.setLabel('Shipping/Delivery Options')>--->
	
		<cfset lcl.shippingOptions = createObject('component', 'modules.cart_shipping.models.cartShippingModules').init(requestobject).getAvailableShippingOptions(variables.cartModel)>


		<cfloop array="#lcl.shippingoptions#" index="lcl.shippingoption">
		
			<cfset lcl.txt = lcl.c1.addItem("subsection")>
			<cfset lcl.txt.setName(lcl.shippingoption.modulelabel)>
			<cfset lcl.txt.setLabel(lcl.shippingoption.modulelabel)>
			
			<cfset lcl.options = lcl.shippingoption.options>

			<cfloop array="#lcl.options#" index="lcl.soi">
				<cfif NOT structkeyexists(lcl.soi, "isselectable") OR lcl.soi.isselectable EQ 1>
					<cfset lcl.txt = lcl.c1.addItem("radioItem")>
					<cfset lcl.txt.setName('shippingquoteid')>
					<cfset lcl.txt.addClassToForm('shippingMethodRadio')>
	                <Cfset lcl.txt.addClassToWrapper('shippingradio')>
	                <cfset lcl.txt.setformStyle("background","transparent")>   	<!--- IE fixes to remove border, can only be done in style tag --->             
	                <cfset lcl.txt.setformStyle("border","0")> 					<!--- IE fixes to remove border, can only be done in style tag --->
					<cfset lcl.txt.setLabel(lcl.soi.optionlabel & " : " & dollarformat(lcl.soi.cost))>
					<cfset lcl.txt.setValidationLabel('Shipping Method')>
					<cfset lcl.txt.setDefault(lcl.soi.id)>
					<cfset lcl.txt.setId(lcl.soi.id)>
					<cfset lcl.txt.setRequired()>
				<cfelse>
					<cfset lcl.txt = lcl.c1.addItem("html")>
					<cfset lcl.txt.setName('nonselectabletext')>
					<cfset lcl.txt.setHTML("<div>" & lcl.soi.optionlabel & " : " & dollarformat(lcl.soi.cost) & "</div>")>
				</cfif>
			</cfloop>

		</cfloop>
		
		<cfset lcl.js = lcl.c1.addItem("html")>
		<cfset lcl.js.setName("delivery_method_onclick")>
		
		<cfsavecontent variable="lcl.jss">
			<script>
				jQuery(function(){
					jQuery(".shippingMethodRadio").click(function(){
						jQuery.post(
							'/cart/lineitems/', 
							{shippingquoteid:this.value},
							function(data){
								if (data == 'reload') location.reload();
								else jQuery("#lineitemsdiv").html(data);
							}
						);
					})
				});
			</script>
		</cfsavecontent>
		
		<cfset lcl.js.setHTML(lcl.jss)>
				
				
		<!--- TOTALS COLUMN --->
		<cfset lcl.c2 = lcl.r.addItem("tablecolumn")>
		<cfset lcl.c2.setName("col2")>
		<cfset lcl.txt = lcl.c2.addItem("html")>
		<cfset lcl.txt.setName('Order Totals')>
		<cfset lcl.txt.setHTML('<h3>Order Totals:</h3>')>
		
		<cfset lcl.lineitems = cartModel.getCartLineItems('shippingpayment')>
		<!--- <cfset lcl.ctr.> --->
		<cfset lcl.lineitemsdiv = lcl.c2.addItem('div')>
		<cfset lcl.lineitemsdiv.setName("lineitemsdiv")>
		<cfset lcl.tbl = lcl.lineitemsdiv.addItem("table")>
		<cfset lcl.tbl.setName("cartshippingpaymenttotals")>
		<cfset lcl.tbl.addClass("cartshippingpaymenttotals")>
		
		<cfloop array="#lcl.lineitems#" index="lcl.idx">
			<cfset lcl.tr = lcl.tbl.addItem("tablerow")>
			<cfset lcl.tr.addClass(lcl.idx.name)>
			<cfset lcl.tr.setName(lcl.idx.name & "_row")>
			
			<cfset lcl.td = lcl.tr.addItem("tablecolumn")>
			<cfset lcl.td.setName(lcl.idx.name & "_col")>
			
			<cfset lcl.tdhtml = lcl.td.addItem("html")>
			<cfset lcl.tdhtml.setName(lcl.idx.name & "_label")>
			<cfset lcl.tdhtml.setHTML(lcl.idx.label)>
			
			<cfset lcl.td = lcl.tr.addItem("tablecolumn")>
			<cfset lcl.td.setName(lcl.idx.name & "_col")>
			
			<cfset lcl.tdhtml = lcl.td.addItem("html")>
			<cfset lcl.tdhtml.setName(lcl.idx.name & "_value")>
			<cfset lcl.tdhtml.setHTML(dollarformat(lcl.idx.total))>
		</cfloop>

		<cfset lcl.txt = addItem("html")>
		<cfset lcl.txt.setName('hr2')>
		<cfset lcl.txt.setHTML('<hr class="fullwidthdottedhrwithmargins"><br/>')>
		
		<!--- PAYMENT OPTIONS --->
		<!--- 

		<cfset lcl.txt = lcl.c2.addItem("Text")>
		<cfset lcl.txt.setName('delivery_name')>
		<cfset lcl.txt.setLabel('Name')>
		<cfset lcl.txt.setValidationLabel('Delivery Name')>
		<cfset lcl.txt.setRequired()>
		<cfset lcl.txt.maxlength(100)>
		<cfset lcl.txt.setDefault(variables.clientObj.getLName() & ' ' & variables.clientObj.getLName())>
	
		<cfset lcl.txt = lcl.c2.addItem("Text")>
		<cfset lcl.txt.setName('delivery_line1')>
		<cfset lcl.txt.setLabel('Address')>
		<cfset lcl.txt.setValidationLabel('Delivery Address')>
		<cfset lcl.txt.setRequired()>
		<cfset lcl.txt.maxlength(100)>
		<cfset lcl.txt.setDefault(variables.clientObj.getLine1())>
		
		<cfset lcl.txt = lcl.c2.addItem("Text")>
		<cfset lcl.txt.setName('delivery_line2')>
		<cfset lcl.txt.setLabel('')>
		<cfset lcl.txt.maxlength(100)>
		<cfset lcl.txt.setDefault(variables.clientObj.getLine2())>

		<cfset lcl.txt = lcl.c2.addItem("Text")>
		<cfset lcl.txt.setName('delivery_city')>
		<cfset lcl.txt.setLabel('City')>
		<cfset lcl.txt.setValidationLabel('Delivery City')>
		<cfset lcl.txt.setRequired()>
		<cfset lcl.txt.maxlength(500)>
		<cfset lcl.txt.setDefault(variables.clientObj.getCity())>
		
		<cfset lcl.txt = lcl.c2.addItem("select")>
		<cfset lcl.txt.setName('delivery_state')>
		<cfset lcl.txt.setLabel('State')>
		<cfset lcl.txt.setValidationLabel('Delivery State')>
		<cfset lcl.txt.setRequired()>
		<cfset lcl.data = structnew()>
		<cfset lcl.data.list = "AZ,AL">
		<cfset lcl.txt.setListData(lcl.data)>
		<cfset lcl.txt.setDefault(variables.clientObj.getState())>
		
		<cfset lcl.txt = lcl.c2.addItem("Text")>
		<cfset lcl.txt.setName('delivery_postalcode')>
		<cfset lcl.txt.setLabel('Zip')>
		<cfset lcl.txt.setValidationLabel('Delivery Zip')>
		<cfset lcl.txt.setRequired()>
		<cfset lcl.txt.addValidation("iszip")>
		<cfset lcl.txt.setDefault(variables.clientObj.getPostalCode())>
		
		
		<cfset lcl.txt = lcl.c2.addItem("Text")>
		<cfset lcl.txt.setName('delivery_phone')>
		<cfset lcl.txt.setLabel('Phone')>
		<cfset lcl.txt.setValidationLabel('Delivery Phone')>
		<cfset lcl.txt.setDefault(variables.clientObj.getHomePhone())>
 --->
 
 
		<cfset lcl.sct = addItem("section")>
		<cfset lcl.sct.setlabel("Payment Options")>
		<cfset lcl.sct.setName("Payment Options")>
        
        <cfset lcl.div = lcl.sct.addItem("div")>
        <cfset lcl.div.setName("paymentdiv")>
        <cfset lcl.div.addClass("ccdiv")>
               
		<cfset lcl.txt = lcl.div.addItem("select")>
		<cfset lcl.txt.setName('pmtinfo_card_type')>
        <cfset lcl.txt.addClassToWrapper("cardtype")>
		<cfset lcl.txt.setLabel('Card Type:')>
		<cfset lcl.txt.setRequired()>
		<cfset lcl.data = structnew()>
		<cfset lcl.data.list = "Visa,AMEX,Discover,Mastercard">
		<cfset lcl.txt.setData(lcl.data)>
		<cfif structkeyexists(variables.paymentinfo, "pmtinfo_card_type")>
			<cfset lcl.txt.setDefault(variables.paymentinfo.pmtinfo_card_type)>
		</cfif>

		<cfset lcl.txt = lcl.div.addItem("Text")>
		<cfset lcl.txt.setName('pmtinfo_card_number')>
		<cfset lcl.txt.setLabel('Card Number:')>
		<cfset lcl.txt.setRequired()>
		<!--- <cfset lcl.txt.maxlength(16)> --->	
		<cfif isdefined("session.cc") AND structkeyexists(variables.paymentinfo, "pmtinfo_card_number")>
			<cfset lcl.txt.setDefault(variables.paymentinfo.pmtinfo_card_number)>
		</cfif>

		<cfset lcl.txt = lcl.div.addItem("select")>
		<cfset lcl.txt.setName('pmtinfo_expiration_date')>
		<cfset lcl.txt.setLabel('Expiration Date:')>
		<cfset lcl.txt.setRequired()>
		<cfif structkeyexists(variables.paymentinfo, "pmtinfo_expiration_date")>
			<cfset lcl.txt.setDefault(variables.paymentinfo.pmtinfo_expiration_date)>
		</cfif>
	
		<cfset lcl.data = structnew()>
		<cfset lcl.data.query = querynew("value,label")>
		
		<cfloop from="#month(now())#" to="12" index="lcl.moi">
			<cfset queryaddrow(lcl.data.query)>
			<cfset querysetcell(lcl.data.query, "value", lcl.moi & '/' & year(now()))>
			<cfset querysetcell(lcl.data.query, "label", monthasstring(lcl.moi) & ' ' & year(now()))>
		</cfloop>
		<cfloop from="#year(now()) + 1#" to="#year(now()) + 8#" index="lcl.yi">
			<cfloop from="1" to="12" index="lcl.moi">
				<cfset queryaddrow(lcl.data.query)>
				<cfset querysetcell(lcl.data.query, "value", lcl.moi & '/' & lcl.yi)>
				<cfset querysetcell(lcl.data.query, "label", monthasstring(lcl.moi) & ' ' & lcl.yi)>
			</cfloop>
		</cfloop>
		<cfset lcl.txt.setData(lcl.data)>
		<cfif structkeyexists(variables.paymentinfo, "pmtinfo_expiration_date")>
			<cfset lcl.txt.setDefault(variables.paymentinfo.pmtinfo_expiration_date)>
		</cfif>
        
		<cfset lcl.txt = lcl.div.addItem("Text")>
		<cfset lcl.txt.setName('pmtinfo_cvv_number')>
		<cfset lcl.txt.setLabel('CVV Number:')>
		<cfset lcl.txt.setRequired()>
		<cfset lcl.txt.maxlength(4)>
		<cfset lcl.txt.setformstyle("width","40px")>
		<cfif structkeyexists(variables.paymentinfo, "pmtinfo_cvv_number")>
			<cfset lcl.txt.setDefault(variables.paymentinfo.pmtinfo_cvv_number)>
		</cfif>
        
		<cfset lcl.txt = lcl.div.addItem("html")>
        <cfset lcl.txt.setName("whatsthislink")>
        <cfset lcl.txt.setHTML("<div style='float:left;margin:-37px 0 10px 209px;' >The last 3 or 4 digit number on the back of the card or front if AMEX</a>")>
        
        <!--- gift msg items added by observers --->
		<cfset lcl.txt = addItem("html")>
		<cfset lcl.txt.setName('hr2')>
		<cfset lcl.txt.setHTML('<br class="clear"/><hr class="fullwidthdottedhr"><br>')>
        
        <cfset lcl.sbm = addItem("imagebtn")>
        <cfset lcl.sbm.setSource('/ui/images/cart/nextStepBtn.png')>
		<cfset lcl.sbm.setName('nextstep')>
        <cfset lcl.sbm.setFormStyle('width','76px')>
        <cfset lcl.sbm.setFormStyle('height','22px')>
        <cfset lcl.sbm.setFormStyle('float','right')>
        <cfset lcl.sbm.setFormStyle('margin-right','0px')>
		<cfset lcl.sbm.setDefault('NEXT STEP')>

		<cfif requestObject.getVar("debug", 0)>
		<cfset lcl.tc = lcl.c1.addItem("html")>
		<cfset lcl.tc.setName("temp_crap")>    
		<cfsavecontent variable="lcl.tcc">
			TESTINGINFO FOR CC<br>
			AMEX 371449635398431 9997<br>
			DISCOVER 6011000998980019 996<br>
			MASTERCARD 5424180279791765 998<br>
			VISA 4012000033330026  999
		</cfsavecontent>
		
		<cfset lcl.tc.setHTML(lcl.tcc)>
		</cfif>
	</cffunction>
	
	<cffunction name="validate">
		<cfargument name="clear" default="false">
	
		<cfset var vdtr = super.validate(clear)>
		
		<cfif NOT (isdefined("session.cc") AND refind("^[0-9]{11,20}$", session.cc)) OR NOT find("*", requestObject.getFormUrlVar("pmtinfo_card_number",""))>
			<cfif requestObject.getFormUrlVar("pmtinfo_card_type") NEQ "" AND requestObject.getFormUrlVar("pmtinfo_card_number") NEQ "">
				<cfset vdtr.isvalidcreditcard("pmtinfo_card_number", rereplace(requestObject.getFormUrlVar("pmtinfo_card_number"), "[^0-9]", "", "all"),  requestObject.getFormUrlVar("pmtinfo_card_type"),"The credit card number is invalid. Please check it and fix any errors.")>
			</cfif>
		</cfif>

		<cfif requestObject.getFormUrlVar("shippingQuoteID", "") NEQ "" AND requestObject.getFormUrlVar("shippingQuoteID") NEQ variables.cartModel.getShippingQuoteId()>
			<cfset variables.cartModel.setShippingQuoteId(requestObject.getFormUrlVar("shippingQuoteID"))>
			<cfset variables.cartModel.save()>
		</cfif>

		<cfif requestObject.getFormUrlVar("pmtinfo_card_type", "") EQ "mastercard" AND len(requestObject.getFormUrlVar("pmtinfo_cvv_number", "")) NEQ 3>
			<cfset vdtr.addError("pmtinfo_card_type", "The number on the back of the card must be 3 chars long for MASTERCARD")>
		</cfif>
		
		<cfreturn vdtr>
	</cffunction>
	
	<cffunction name="submit">
		<cfargument name="vdtr" required="true">
		<!--- check if cart record exists , if not create it, else update it with all the fields  --->

		<cfset var lcl = structnew()>
		<cfset lcl.jsonobj = createObject("component","utilities.json").init(requestObject)>
		<cfset lcl.forminfo = requestObject.getAllFormUrlVars()>
		
		<cfset lcl.paymentinfo = variables.cartModel.getPaymentInfo()>
		<cfif isjson(lcl.paymentinfo)>
			<cfset lcl.paymentinfo = lcl.jsonobj.decode(lcl.paymentinfo)>
		<cfelse>
			<cfset lcl.paymentinfo = structnew()>
		</cfif>
		
		<cfloop collection="#lcl.forminfo#" item="lcl.itm">
			<cfif left(lcl.itm, 7) EQ "pmtinfo">
				<cfset lcl.paymentinfo[lcl.itm] = lcl.forminfo[lcl.itm]>
			</cfif>
		</cfloop>
		
		<cfif NOT isdefined("session.cc")>
			<cfset session.cc =  rereplace( lcl.paymentinfo['pmtinfo_card_number'], '[^0-9]', "", "all")>
		</cfif>

		<cfset lcl.paymentinfo['pmtinfo_card_number'] =  rereplace( lcl.paymentinfo['pmtinfo_card_number'], '[^0-9\*\-]', "","all")>
		<cfset lcl.paymentinfo['pmtinfo_card_number'] =  rereplace( lcl.paymentinfo['pmtinfo_card_number'], '^([0-9]{4})([0-9]{4})([0-9]{4})([0-9]+)$', "****-****-****-\4")>
		<cfset lcl.paymentinfo.amount = variables.cartModel.getCurrentTotal()>	
		<cfset lcl.shippinginfo = structnew()><!--- prep struct for use later --->

		<cfset lcl.paymentinfo = lcl.jsonobj.encode(lcl.paymentinfo)>
		<cfset lcl.shippinginfo = lcl.jsonobj.encode(lcl.shippinginfo)>
		
		<cfset variables.cartModel.setPaymentInfo(lcl.paymentinfo)>
		<cfset variables.cartModel.setShippingQuoteId(lcl.forminfo.shippingQuoteId)>
				
		<cfset variables.cartModel.save()>
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
	
		<cfset s.message = "Just confirm the order and we'll get started on it.">
		
		<cfreturn s>
	</cffunction>
	
</cfcomponent>