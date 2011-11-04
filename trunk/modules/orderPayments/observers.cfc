<cfcomponent name="order payment observer" extends="resources.abstractobserver">	
	<cffunction name="form_submission_cart_shippingpaymentinfo">
		<cfargument name="observed" required="true">
		<cfset var lcl = structnew()>
		<cfset lcl.jsonobj = createObject("component","utilities.json").init(requestObject)>
		
		<!--- cartObj --->
		<cfset lcl.cartObj = createObject("component","modules.cart.models.cart").init(requestObject)>
		<cfset lcl.cartObj.load()>
		
		<!--- create pmtobj  --->
		<cfset lcl.pmtObj = createObject("component","modules.orderPayments.models.orderPayments").init(requestObject)>

		<!--- invoke auth --->
		<cfset lcl.status = lcl.pmtObj.process_auth(lcl.cartObj)>

		<cfif lcl.status.ok>
			<!--- save auth info --->
			<cfset lcl.cartObj.setPaymentInfo(lcl.jsonobj.encode(lcl.status.pmtinfo))>
			<cfset lcl.cartObj.save()>
		<cfelse>
			<cfset observed.addError("cart", lcl.status.message)>
		</cfif>
		
		<cfreturn observed>
	</cffunction>
	
</cfcomponent>