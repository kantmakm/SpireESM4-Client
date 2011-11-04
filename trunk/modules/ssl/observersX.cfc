<cfcomponent name="ordersobservers" extends="resources.abstractobserver">
	
	<cffunction name="pagestart">
		<cfargument name="observed" required="true">
	
		<cfset var urlsrequiringssl = arraynew(1)>
		<cfset var lcl = structnew()>

		<cfif cgi.SERVER_PORT EQ 443>
			<cfreturn observed>
		</cfif>

		<cfset lcl.thispath = requestObject.getFormUrlVar("path")>

		<cfset arrayappend(urlsrequiringssl, "cart/billingdelivery")>
		<cfset arrayappend(urlsrequiringssl, "cart/shippingpayment")>
		<cfset arrayappend(urlsrequiringssl, "cart/orderconfirmation")>
		
		<cfset lcl.relocateto = "#requestObject.getVar("sslpath")##lcl.thispath#">

		<cfset lcl.urlvars= duplicate(url)>
		
		<cfset structdelete(lcl.urlvars, 'path')>
		
		<cfloop collection="#lcl.urlvars#" item="lcl.itm">
			<cfif find("?", lcl.relocateto)>
				<cfset lcl.relocateto = lcl.relocateto & "&">
			<cfelse>
				<cfset lcl.relocateto = lcl.relocateto & "?">					
			</cfif>
			<cfset lcl.relocateto = lcl.relocateto & lcl.itm & '=' & urlencodedformat(lcl.urlvars[lcl.itm])>
		</cfloop>

		<cfloop array="#urlsrequiringssl#" index="lcl.path">
			<cfif left(lcl.thispath, len(lcl.path)) EQ lcl.path>
				<cflocation url="#lcl.relocateto#" addtoken="false">
			</cfif>
		</cfloop>

		<cfreturn observed>
	</cffunction>

</cfcomponent>