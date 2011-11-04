<cfcomponent name="clientinfo" extends="utilities.forms2">

	<cffunction name="make">
		<cfset var lcl = structnew()>

		<cfset var uo = requestObject.getUserObject()>
		<cfset var statesQ = createObject("component", "utilities.worldinfo").init(requestObject).getStates()>
		<cfif NOT uo.isloggedin()>
			<cfset uo.setFlash("Your session has expired. Please relogin. Your cart will still be available.")>
			<cflocation url="/user/login/?returnto=/cart/" addtoken="false">
		</cfif>
	
		<cfset lcl.idata = setupInitData()>
			
		<cfset variables.forminfo.name = "checkoutclientinfoform">
        
<!---        <cfset lcl.stepitem = addItem("image")>
        <cfset lcl.stepitem.setSource("/ui/images/cart/cartStep1.png")>
        <cfset lcl.stepitem.setName("step1Image")>
        <cfset lcl.stepitem.setFormStyle("padding-bottom","20px")>
        <cfset lcl.stepitem.showHTML()>--->
        
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
		<cfset lcl.txt.setHTML('<h3>Your Current Billing Address</h3>')>
		
		<cfset lcl.txt = lcl.c1.addItem("Text")>
		<cfset lcl.txt.setName('billing_name')>
		<cfset lcl.txt.setLabel('Name')>
		<cfset lcl.txt.setValidationLabel('Billing Name')>
		<cfset lcl.txt.setRequired()>
		<cfset lcl.txt.maxlength(100)>
		<cfset lcl.txt.setDefault(lcl.idata.billing_name)>
		
		<cfset lcl.txt = lcl.c1.addItem("Text")>
		<cfset lcl.txt.setName('billing_line1')>
		<cfset lcl.txt.setLabel('Address')>
		<cfset lcl.txt.setValidationLabel('Billing Address')>
		<cfset lcl.txt.setRequired()>
		<cfset lcl.txt.maxlength(100)>
		<cfset lcl.txt.setDefault(lcl.idata.billing_line1)>
		
		<cfset lcl.txt = lcl.c1.addItem("Text")>
		<cfset lcl.txt.setName('billing_line2')>
		<cfset lcl.txt.setLabel('')>
		<cfset lcl.txt.maxlength(100)>
		<cfset lcl.txt.setDefault(lcl.idata.billing_line2)>
		
		<cfset lcl.txt = lcl.c1.addItem("Text")>
		<cfset lcl.txt.setName('billing_city')>
		<cfset lcl.txt.setLabel('City')>
		<cfset lcl.txt.setValidationLabel('Billing City')>
		<cfset lcl.txt.setRequired()>
		<cfset lcl.txt.maxlength(500)>
		<cfset lcl.txt.setDefault(lcl.idata.billing_city)>
		
		<cfset lcl.txt = lcl.c1.addItem("select")>
		<cfset lcl.txt.setName('billing_state')>
		<cfset lcl.txt.setLabel('State')>
		<cfset lcl.txt.setValidationLabel('Billing State')>
		<cfset lcl.txt.setRequired()>
		<cfset lcl.data = structnew()>
		<cfset lcl.data.query = statesQ>
		<cfset lcl.data.labelsfield="name">
		<cfset lcl.data.valuesfield="abbrev">
		<cfset lcl.txt.setData(lcl.data)>
		<cfset lcl.txt.setDefault(lcl.idata.billing_state)>
		
		<cfset lcl.txt = lcl.c1.addItem("Text")>
		<cfset lcl.txt.setName('billing_postalcode')>
		<cfset lcl.txt.setLabel('Zip')>
		<cfset lcl.txt.setValidationLabel('Billing Zip')>
		<cfset lcl.txt.setRequired()>
		<cfset lcl.txt.addValidation("iszip")>
		<cfset lcl.txt.setDefault(lcl.idata.billing_postalcode)>
		
		<cfset lcl.txt = lcl.c1.addItem("Text")>
		<cfset lcl.txt.setName('billing_phone')>
		<cfset lcl.txt.setValidationLabel('Billing Phone')>
		<cfset lcl.txt.setLabel('Phone')>
		<cfset lcl.txt.setRequired()>
		<cfset lcl.txt.maxlength(12)>
		<cfset lcl.txt.addValidation("isvalidphone")>		
		<cfset lcl.txt.setDefault(lcl.idata.billing_phone)>
		
		
		<cfset lcl.txt = lcl.c1.addItem("Text")>
		<cfset lcl.txt.setName('billing_email')>
		<cfset lcl.txt.setLabel('Email')>
		<cfset lcl.txt.setValidationLabel('Billing Email')>
		<cfset lcl.txt.setRequired()>
		<cfset lcl.txt.maxlength(40)>
		<cfset lcl.txt.addValidation("validemail")>
		<cfset lcl.txt.setDefault(lcl.idata.billing_email)>
		
		
		<!--- col2 --->
		<cfset lcl.c2 = lcl.r.addItem("tablecolumn")>
		<cfset lcl.c2.setName("col2")>
		<cfset lcl.txt = lcl.c2.addItem("html")>
		<cfset lcl.txt.setName('col2title')>
		<cfset lcl.txt.setHTML('<h3>Shipping/Delivery Address</h3>')>
		
		<cfset lcl.txt = lcl.c2.addItem("Text")>
		<cfset lcl.txt.setName('delivery_name')>
		<cfset lcl.txt.setLabel('Name')>
		<cfset lcl.txt.setValidationLabel('Delivery Name')>
		<cfset lcl.txt.setRequired()>
		<cfset lcl.txt.maxlength(100)>
		<cfset lcl.txt.setDefault(lcl.idata.delivery_name)>
	
		<cfset lcl.txt = lcl.c2.addItem("Text")>
		<cfset lcl.txt.setName('delivery_line1')>
		<cfset lcl.txt.setLabel('Address')>
		<cfset lcl.txt.setValidationLabel('Delivery Address')>
		<cfset lcl.txt.setRequired()>
		<cfset lcl.txt.maxlength(100)>
		<cfset lcl.txt.setDefault(lcl.idata.delivery_line1)>
		
		<cfset lcl.txt = lcl.c2.addItem("Text")>
		<cfset lcl.txt.setName('delivery_line2')>
		<cfset lcl.txt.setLabel('')>
		<cfset lcl.txt.maxlength(100)>
		<cfset lcl.txt.setDefault(lcl.idata.delivery_line2)>

		<cfset lcl.txt = lcl.c2.addItem("Text")>
		<cfset lcl.txt.setName('delivery_city')>
		<cfset lcl.txt.setLabel('City')>
		<cfset lcl.txt.setValidationLabel('Delivery City')>
		<cfset lcl.txt.setRequired()>
		<cfset lcl.txt.maxlength(500)>
		<cfset lcl.txt.setDefault(lcl.idata.delivery_city)>
		
		<cfset lcl.txt = lcl.c2.addItem("select")>
		<cfset lcl.txt.setName('delivery_state')>
		<cfset lcl.txt.setLabel('State')>
		<cfset lcl.txt.setValidationLabel('Delivery State')>
		<cfset lcl.txt.setRequired()>
		<cfset lcl.data = structnew()>
		<cfset lcl.data.query = statesQ>
		<cfset lcl.data.labelsfield="name">
		<cfset lcl.data.valuesfield="abbrev">
		<cfset lcl.txt.setData(lcl.data)>
		<cfset lcl.txt.setDefault(lcl.idata.delivery_state)>
		
		<cfset lcl.txt = lcl.c2.addItem("Text")>
		<cfset lcl.txt.setName('delivery_postalcode')>
		<cfset lcl.txt.setLabel('Zip')>
		<cfset lcl.txt.setValidationLabel('Delivery Zip')>
		<cfset lcl.txt.setRequired()>
		<cfset lcl.txt.addValidation("iszip")>
		<cfset lcl.txt.setDefault(lcl.idata.delivery_postalcode)>
		
		
		<cfset lcl.txt = lcl.c2.addItem("Text")>
		<cfset lcl.txt.setName('delivery_phone')>
		<cfset lcl.txt.setLabel('Phone')>
		<cfset lcl.txt.setRequired()>
		<cfset lcl.txt.maxlength(12)>
		<cfset lcl.txt.addValidation("isvalidphone")>	
		<cfset lcl.txt.setValidationLabel('Delivery Phone')>
		<cfset lcl.txt.setDefault(lcl.idata.delivery_phone)>
		
		<cfset lcl.txt = lcl.c2.addItem("select")>
		<cfset lcl.txt.setName('delivery_isbusinessaddress')>
		<cfset lcl.txt.setLabel('Type of address')>
		<cfset lcl.data = structnew()>
		<cfset lcl.data.query = querynew("value,text")>
		<cfset queryaddrow(lcl.data.query)>
		<cfset querysetcell(lcl.data.query, 'value', 1)>
		<cfset querysetcell(lcl.data.query, 'text', "Business")>
		<cfset queryaddrow(lcl.data.query)>
		<cfset querysetcell(lcl.data.query, 'value', 0)>
		<cfset querysetcell(lcl.data.query, 'text', "Home")>
		<cfset lcl.data.labelsfield="text">
		<cfset lcl.data.valuesfield="value">
		<cfset lcl.txt.setData(lcl.data)>
		<cfset lcl.txt.setDefault(lcl.idata.delivery_isbusinessaddress)>

	<!---	<cfset lcl.sbm = addItem("submit")>
		<cfset lcl.sbm.setDefault('NEXT STEP')>
		<cfset lcl.sbm.setName('nextstep')>--->
        
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
        <cfset lcl.sbm.setFormStyle('padding-right','0px')>
		<cfset lcl.sbm.setDefault('NEXT STEP')>
	</cffunction>
	
	<cffunction name="setupInitData">
		<cfset var lcl = structnew()>
		<cfset lcl.rinfo = structnew()>
		
		<!--- if cart obj already has this info use that --->
		<cfset lcl.cartObj = createObject("component", "modules.cart.models.cart").init(variables.requestObject)>
		<cfset lcl.cartObj.load()>
		<cfset lcl.bai = lcl.cartObj.getBillingAddressInfo()>
		
		<cfif lcl.bai NEQ "">
			<cfset lcl.bai = deserializejson(lcl.bai)>
			<cfset structappend(lcl.rinfo, lcl.bai)>
			<cfset lcl.sai = deserializejson(lcl.cartObj.getDeliveryAddressInfo())>
			<cfset structappend(lcl.rinfo, lcl.sai)>
			<cfparam name="lcl.rinfo.delivery_isbusinessaddress" default="0">
			<cfreturn lcl.rinfo>
		</cfif>
		
		<!--- else --->
		<!--- use user addy for billinginfo  --->
		<cfset uo = requestobject.getUserObject()>
		<cfset lcl.userinfo = uo.exportUserData()>
		<cfloop collection="#lcl.userinfo#" item="lcl.uitm">
			<cfset lcl.rinfo["billing_#lcl.uitm#"] = lcl.userinfo[lcl.uitm]>
		</cfloop>
		<cfset lcl.rinfo.billing_name = lcl.userinfo.fname & ' ' & lcl.userinfo.lname>
		<cfset lcl.rinfo.billing_phone = lcl.userinfo.homephone>
		
		<!--- check if user has shipping info, load that if found, othrewise repurpose billinginfo --->
		<cfloop collection="#lcl.userinfo#" item="lcl.uitm">
			<cfset lcl.rinfo["delivery_#lcl.uitm#"] = lcl.userinfo[lcl.uitm]>
		</cfloop>
		<cfset lcl.rinfo.delivery_name = lcl.userinfo.fname & ' ' & lcl.userinfo.lname>
		<cfset lcl.rinfo.delivery_phone = lcl.userinfo.homephone>
		<cfset lcl.rinfo.delivery_isbusinessaddress = 1>
		<cfreturn lcl.rinfo>
	</cffunction>
	
	<cffunction name="validate">
		<cfargument name="clear" default="false">
	
		<cfset var vdtr = super.validate(clear)>
					
		<cfreturn vdtr>
	</cffunction>
	
	<cffunction name="submit">
		<cfargument name="vdtr" required="true">
		<!--- check if cart record exists , if not create it, else update it with all the fields  --->
		<cfset var lcl = structnew()>
		<cfset lcl.jsonobj = createObject("component","utilities.json").init(requestObject)>
		<cfset lcl.forminfo = requestObject.getAllFormUrlVars()>
	
		<!--- make billing and shipping structures --->
		<cfset lcl.billinginfo = structnew()>
		<cfset lcl.deliveryinfo = structnew()>
		<cfloop collection="#lcl.forminfo#" item="lcl.itm">
			<cfif left(lcl.itm, 7) EQ "billing">
				<cfset lcl.billinginfo[lcl.itm] = lcl.forminfo[lcl.itm]>
			<cfelseif left(lcl.itm, 8) EQ "delivery">
				<cfset lcl.deliveryinfo[lcl.itm] = lcl.forminfo[lcl.itm]>
			</cfif>
		</cfloop>
		
		<cfset lcl.cart = createObject("component", "modules.cart.models.cart").init(requestObject)>

		<cfset lcl.cart.setBillingAddressInfo(lcl.jsonobj.encode(lcl.billinginfo))>
		<cfset lcl.cart.setDeliveryAddressInfo(lcl.jsonobj.encode(lcl.deliveryinfo))>
		
		<cfset lcl.iscart = lcl.cart.getByCartId(lcl.cart.getCartId())>
		<cfset lcl.cart.setCartId(lcl.cart.getCartId())>

		<cfif lcl.iscart.recordcount>
			<cfset lcl.cart.setId(lcl.iscart.Id)>
		</cfif>
		
		<cfset lcl.cart.save()>
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
	
		<cfset s.message = "Thanks for that. Now please choose a shipping option.">
		
		<cfreturn s>
	</cffunction>
</cfcomponent>