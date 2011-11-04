<cfcomponent name="orderitems" extends="resources.abstractmodel">

	<cffunction name="init">
		<cfargument name="requestObject" required="true">
		<cfset variables.requestObject = arguments.requestObject>
		<cfset startorm("orderPayments")>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="load">
		<cfargument name="orderid" required="true">
		<cfset var lcl = structnew()>
		<cfset lcl.oi = this.getByOrderId(orderid)>

		<cfif lcl.oi.recordcount EQ 0>
			<cfthrow message="Order object not found for #orderid#">
		</cfif>
		
		<cfset lcl.orderobj = createObject("component", lcl.oi.paymentmodule & '_display').init(requestObject)>
		<cfset lcl.orderObj.setInfo(deserializejson(lcl.oi.paymentDetails))>
		<cfset lcl.orderObj.setPaymentAmount(lcl.oi.paymentamount)>
		
		<cfreturn lcl.orderObj>
	</cffunction>
	
	<cffunction name="process_capture">
		<cfargument name="orderObj" required="true">
		<cfargument name="cartObj" required="true">
		<cfargument name="pmtamt" required="true">

		<cfset var lcl = structnew()>
		<cfset lcl.jsonobj = createObject("component","utilities.json").init(requestObject)>
		
		<!--- TODO : switch this from hardcoded to dynamic via observers --->
		<cfset lcl.pmtObj = createObject("component", "modules.ics_payment.models.ccpay").init(requestObject)>
		
		
		
		<cfset lcl.pmtObj.setBillingInfo(lcl.jsonobj.decode(cartObj.getBillingAddressInfo()))>
		
		<cfset lcl.pmtObj.setPaymentAmount(pmtamt)>
		
		<cfset lcl.pmtdetails = lcl.jsonobj.decode(cartObj.getPaymentInfo())>
		
		<!--- capture $, get back xaction details --->
		<cfset lcl.pmtdetails_from_capture = lcl.pmtObj.capture()>

		<!--- merge with previous details from cart --->
		<cfset structappend(lcl.pmtdetails, lcl.pmtdetails_from_capture)>

		<!--- save info via orm --->
		<cfset this.setPaymentModule("modules.ics_payment.models.ccpay")>
		<cfset this.setPaymentAmount(pmtamt)>		
		<cfset this.setOrderId(orderObj.getId())>		
		<cfset this.setPaymentDetails(lcl.jsonobj.encode(lcl.pmtdetails))>
		
		<cfif NOT this.save()>
			<cfdump var=#this.getValidator().getErrors()#>
			<cfabort>
		</cfif>
	</cffunction>
	
	<cffunction name="process_auth">
		<cfargument name="cartObj" required="true">

		<cfset var lcl = structnew()>
		<cfset var status = structnew()>
		
		<cfset lcl.jsonobj = createObject("component","utilities.json").init(requestObject)>
		<cfset status.ok = 1>
	
		<!--- TODO : switch this from hardcoded to dynamic --->
		<cfset lcl.pmtObj = createObject("component", "modules.ics_payment.models.ccpay").init(requestObject)>
		
		<cfset lcl.pmtObj.setBillingInfo(deserializejson(cartObj.getBillingAddressInfo()))>

		<!--- get exising info --->
		<cfset lcl.pmtinfo = cartObj.getPaymentInfo()>
		<cfset lcl.pmtinfo = lcl.jsonobj.decode(lcl.pmtinfo)>
		
		<cfset lcl.pmtObj.setPaymentInfo(lcl.pmtinfo)>
		<cfset lcl.pmtObj.setPaymentAmount(cartObj.getCurrentTotal())>
		
		<!--- exit if already done --->
		<cfif lcl.pmtObj.alreadyprocessed(lcl.pmtinfo)>
			<cfset status.pmtinfo = lcl.pmtinfo>
			<cfreturn status>
		</cfif>
		
		<!--- auth, get back payment details --->
		<cftry>
			<cfset lcl.authinfo = lcl.pmtObj.auth()>
			<cfset structappend(lcl.pmtinfo, lcl.authinfo)>
			<cfset status.pmtinfo = lcl.pmtinfo>
			<cfcatch>
				<cfset status.ok = 0>
				<cfset status.message = "Error requesting authorization : #cfcatch.message#">
				<cfreturn status>
			</cfcatch>
		</cftry>
		
		<!--- save xaction details back to db via orm --->
		<cfset cartObj.setPaymentInfo(serializeJson(lcl.pmtinfo))>
		<cfif NOT cartObj.save()>
			<cfdump var=#cartObj.getValidator().getErrors()#>
			<cfabort>
		</cfif>
		
		<cfreturn status>
	</cffunction>

</cfcomponent>
