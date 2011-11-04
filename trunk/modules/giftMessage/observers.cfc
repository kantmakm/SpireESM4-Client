<cfcomponent name="giftMessageObserver" extends="resources.abstractobserver">
	<!--- display the gift message items on the billing/shipping form --->
    <cffunction name="form_make_checkoutclientshippingform" access="public">
		<cfargument name="observed" required="yes">
        <cfset var lcl= structnew()>
        
        <cfset lcl.cartobj = createObject("component","modules.cart.models.cart").init(requestObject)>
        <cfset lcl.cartid = lcl.cartObj.getCartId()>
        <cfset lcl.giftObj = createObject("component","modules.giftMessage.models.giftmessage").init(requestObject)>
        <cfset lcl.already = lcl.giftObj.getByOrderId(lcl.cartid)>
       	
		<cfset lcl.txt = observed.addItem("html",4)>
		<cfset lcl.txt.setName('hr2')>
		<cfset lcl.txt.setHTML('<hr class="fullwidthdottedhrwithmargins"><br/>')>
		
		<cfset lcl.sct2 = observed.addItem("section",5)>
		<cfset lcl.sct2.setName("Gift Options")>
		
        <cfset lcl.giftdiv = lcl.sct2.addItem("div")>
        <cfset lcl.giftdiv.setName("giftdiv")>
        <cfset lcl.giftdiv.addClass("giftdiv")>
        
		<cfset lcl.txt = lcl.giftdiv.addItem("textarea")>
        <cfset lcl.txt.setName('giftitemtxt')>
        <cfset lcl.txt.addClassToForm('giftMethodtext')>
        <Cfset lcl.txt.addClassToWrapper('gifttext')>
        <cfset lcl.txt.setLabel('Message for Gift:')>
        <cfset lcl.txt.setValidationLabel('gift message text')>
        <cfset lcl.txt.setDefault(lcl.already.messageText)> 
        <cfset lcl.txt.setId('txtGift')> 
        
		<cfreturn observed>
	</cffunction>
    
    <cffunction name="form_validation_cart_shippingpaymentinfo">
    	<cfargument name="observed" required="yes">
		<cfset observed.maxlength("giftMethodText", 500, requestObject.getFormUrlVar("giftitemtxt", ""), "Gift message is too long. Max 500 chars.")>
		<cfreturn observed>
    </cffunction>
	
    <!--- save the gift message data on the billing/shipping form --->
    <cffunction name="form_submissioncomplete_cart_shippingpaymentinfo">
    	<cfargument name="observed" required="yes">
        
		<cfset var lcl = structnew()>
        <cfset lcl.msg = requestObject.getFormUrlVar("giftitemtxt", "")>
        
		<cfset lcl.cartobj = createObject("component","modules.cart.models.cart").init(requestObject)>
        <cfset lcl.cartid = lcl.cartObj.getCartId()>
        
        <cfset lcl.giftObj = createObject("component","modules.giftMessage.models.giftmessage").init(requestObject)>
        <cfset lcl.already = lcl.giftObj.getByOrderId(lcl.cartid)>
       
        <cfif lcl.already.recordcount>
        	<cfset lcl.giftObj.setId(lcl.already.id)>
        </cfif>
        
        <cfset lcl.giftObj.setOrderId(lcl.cartid)>
        
        <cfset lcl.giftObj.setMessageText(lcl.msg)>
        
        <cfset lcl.giftObj.save()>
        
       	<cfreturn observed>
    </cffunction>
    <!--- display the gift message on the cart checkout validate data form --->
    <cffunction name="form_make_checkoutvalidateorderform" access="public">
		<cfargument name="observed" required="yes">
        <cfset var lcl= structnew()>
        
        <cfset lcl.cartobj = createObject("component","modules.cart.models.cart").init(requestObject)>
        <cfset lcl.cartid = lcl.cartObj.getCartId()>
        <cfset lcl.giftObj = createObject("component","modules.giftMessage.models.giftmessage").init(requestObject)>
        <cfset lcl.already = lcl.giftObj.getByOrderId(lcl.cartid)>
        <cfset lcl.references = observed.findByFullPath("checkoutvalidateorderform.validateordertable")>

        <cfset lcl.wholeTable = lcl.references["checkoutvalidateorderform.validateordertable"][1]>
           
        <cfset lcl.r2 = lcl.wholeTable.addItem("tablerow")>
		<cfset lcl.r2.setName("r2")>
		
		<!--- COL1 > GIFT MESSAGE YES/NO --->
		<cfset lcl.c1r2 = lcl.r2.addItem("tablecolumn")>
		<cfset lcl.c1r2.setName("col1r2")>
		<cfset lcl.c1r2.addClass("tablefontstyle")>
        
        <cfset lcl.txt = lcl.c1r2.addItem("section")>
		<cfset lcl.txt.setName('gift_information')>
		<cfset lcl.txt.setLabel('<br><h3 style="display:inline">Gift Options:</h3> <a style="display:inline" href="/cart/shippingpayment">(Edit)</a>')>
        
        <cfset lcl.txt = lcl.c1r2.addItem("html")>
		<cfset lcl.txt.setName('gift_msg_display')>
		
		<cfif len(lcl.already.messagetext)>
             <cfset lcl.txt.setHTML("<label>This order is a gift</label>")>
        <cfelse>
            <cfset lcl.txt.setHTML("<label>This order is not a gift</label>")>
        </cfif>
        
        <!--- COL2 > GIFT MESSAGE TEXT --->
        <cfif len(lcl.already.messagetext)>
			<cfset lcl.c2r2 = lcl.r2.addItem("tablecolumn")>
            <cfset lcl.c2r2.setName("col2r2")>
            <cfset lcl.c2r2.addAttribute("colspan","2")>
            <cfset lcl.c2r2.addClass("tablefontstyle")>
            
            <cfset lcl.txt = lcl.c2r2.addItem("section")>
            <cfset lcl.txt.setName('giftmsg_information')>
            <cfset lcl.txt.setLabel('<br><h3 style="display:inline">Gift Message:</h3> <a style="display:inline" href="/cart/shippingpayment">(Edit)</a>')>
            
            <cfset lcl.txt = lcl.c2r2.addItem("html")>
            <cfset lcl.txt.setName('gift_msg_display')>
    
            <cfset lcl.txt.setHTML("<label>"&lcl.already.messagetext)&"</label>">
            
            <cfset lcl.c3r2 = lcl.r2.addItem("tablecolumn")>
            <cfset lcl.c3r2.setName("col3r2")>
        </cfif>

		<cfreturn observed>
	</cffunction>

<!--- this observer receives a completed order from the site and sets gift message orderid to order's id instead of cart id  --->
	<cffunction name="orders_neworder">
		<cfargument name="observed" required="true">

		<cfset var lcl = structnew()>

    	<cfset lcl.orderid = observed.getField('id')> <!--- get the current order id --->
    
		<cfset lcl.uo = requestObject.getUserObject().getUserid()> <!--- get our current user id --->
       
        <cfset lcl.giftObj = createObject("component","modules.giftMessage.models.giftmessage").init(requestObject)>
        <cfset lcl.already = lcl.giftObj.getByOrderId(lcl.uo)> <!--- get this user's current gift message record --->
       
        <cfif lcl.already.recordcount>
        	<cfset lcl.giftObj.setId(lcl.already.id )> <!--- set to observed order id --->
        	<cfset lcl.giftObj.setOrderId(observed.getId())>
			<cfset lcl.giftObj.save()>
        </cfif>
         
		<cfreturn observed>	
    </cffunction>
    
    <!--- display the gift message on the previous order/reorder form --->
    <cffunction name="form_make_previousorder" access="public">
		<cfargument name="observed" required="yes">
        <cfset var lcl= structnew()>
        <cfif requestObject.isFormUrlVarSet("orderid")>
        	<cfset lcl.orderId = requestObject.getFormUrlVar("orderid")>
        <cfelse>
			<cfset lcl.orderId = requestObject.getRequestRegistryVar("orderobj").getField("id")>
		</cfif>
        
        <cfset lcl.giftObj = createObject("component","modules.giftMessage.models.giftmessage").init(requestObject)>
        
        <cfset lcl.already = lcl.giftObj.getByOrderId(lcl.orderId)>
        <cfset lcl.references = observed.findByFullPath("previousorder.validateordertable")>

        <cfset lcl.wholeTable = lcl.references["previousorder.validateordertable"][1]>
           
        <cfset lcl.r2 = lcl.wholeTable.addItem("tablerow")>
		<cfset lcl.r2.setName("r2")>
		
		<!--- COL1 > GIFT MESSAGE YES/NO --->
		<cfset lcl.c1r2 = lcl.r2.addItem("tablecolumn")>
		<cfset lcl.c1r2.setName("col1r2")>
		<cfset lcl.c1r2.addClass("tablefontstyle")>
        
        <cfset lcl.txt = lcl.c1r2.addItem("section")>
		<cfset lcl.txt.setName('gift_information')>
		<cfset lcl.txt.setLabel('<br><h3 style="display:inline;clear:both;padding-left:0;">Gift Options:</h3> ')>
        
        <cfset lcl.txt = lcl.c1r2.addItem("html")>
		<cfset lcl.txt.setName('gift_msg_display')>
		
		<cfif len(lcl.already.messagetext)>
             <cfset lcl.txt.setHTML("<label>This order was a gift</label>")>
        <cfelse>
            <cfset lcl.txt.setHTML("<label>This order was not a gift</label>")>
        </cfif>
        
        <!--- COL2 > GIFT MESSAGE TEXT --->
        <cfif len(lcl.already.messagetext)>
			<cfset lcl.c2r2 = lcl.r2.addItem("tablecolumn")>
            <cfset lcl.c2r2.setName("col2r2")>
            <cfset lcl.c2r2.addClass("tablefontstyle")>
            
            <cfset lcl.txt = lcl.c2r2.addItem("section")>
            <cfset lcl.txt.setName('giftmsg_information')>
            <cfset lcl.txt.setLabel('<br><h3 style="display:inline">Gift Message:</h3>')>
            
            <cfset lcl.txt = lcl.c2r2.addItem("html")>
            <cfset lcl.txt.setName('gift_msg_display')>
    
            <cfset lcl.txt.setHTML("<label>"&lcl.already.messagetext)&"</label>">
            
            <cfset lcl.c3r2 = lcl.r2.addItem("tablecolumn")>
            <cfset lcl.c3r2.setName("col3r2")>
        </cfif>

		<cfreturn observed>
	</cffunction>

</cfcomponent>