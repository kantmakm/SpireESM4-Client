<cfcomponent name="ajshipping">
	
	<cffunction name="init">
		<cfargument name="requestObject" required="true">
		<cfset variables.requestObject = arguments.requestObject>
		<cfset variables.oos = false>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="setCartObj">
		<cfargument name="cartobj" required="true">
		<cfset var lcl = structnew()>
		<cfset variables.cartObj = arguments.cartobj>
		<cfset variables.shippingOptions = querynew("hi")>
		<!--- get destination --->
		<cfset lcl.di = deserializeJson(variables.cartObj.getDeliveryAddressInfo())>
		
		<cfset variables.cart_value = variables.cartObj.getCurrentSubTotal()>
		<!---
		<cfif lcl.di.delivery_state NEQ "CO">
			<cfset variables.oos = true>
			<cfreturn>
		</cfif>
		--->
		<cfset lcl.postal_code = lcl.di.delivery_postalcode>
		
		<cfquery name="variables.shippingoptions" datasource="#requestobject.getVar("dsn")#">
			SELECT aso.id, aso.label, aso.cost, aso.minimum_cart, '#lcl.postal_code#' tozip, '#lcl.di.delivery_city#' tocity
			FROM ajShippingZips asz
			INNER JOIN ajShippingOptions aso ON aso.id = asz.shippingid
			WHERE asz.zip = <cfqueryparam value="#lcl.postal_code#" cfsqltype="cf_sql_varchar">
		</cfquery>

	</cffunction>
	
	<cffunction name="getLabel">
		<cfreturn "Applejack Delivery">
	</cffunction>
	
	<cffunction name="getOptions">
		<cfset var a = arraynew(1)>
		<cfset var s = structnew()>
		
		<!---<cfif variables.oos>
			<cfreturn arraynew(1)>
		</cfif>--->
		
		<cfset s.optionlabel = "In store pickup<br>(Please specify date/time of pickup in delivery notes)">
		<cfset s.cost = "0">
		<cfset s.id = "NEED ID?">
		<cfset s.data = structnew()>
		<cfset s.data.info = "instore pickup">
		<cfset arrayappend(a, s)>
		
		<cfloop query="variables.shippingoptions">
			<cfset s = structnew()>
			<cfset s.cost = variables.shippingoptions.cost>
			<cfset s.optionlabel = variables.shippingoptions.label>
			<cfset s.isselectable = 1>
			<cfif variables.cart_value LT variables.shippingoptions.minimum_cart>
				<cfset s.optionlabel = s.optionlabel & '(Minimum purchase required is #dollarformat(variables.shippingoptions.minimum_cart)#. Add #dollarformat(variables.shippingoptions.minimum_cart - variables.cart_value)# to activate.)'>
				<cfset s.isselectable = 0>
			</cfif>
			<cfset s.id = variables.shippingoptions.id>
			<cfset s.data = structnew()>
			<cfset s.data.tozip = variables.shippingoptions.tozip>
			<cfset s.data.tocity = variables.shippingoptions.tocity>
			<cfset arrayappend(a, s)>
		</cfloop>

		<cfreturn a>
	</cffunction>
	<!--- 
	<cffunction name="load">
		<cfset var lcl = structnew()>
		<cfsavecontent variable="lcl.str">
			<cfinclude template="shippinginfo.txt">
		</cfsavecontent>
		<cfset lcl.lista = listtoarray(lcl.str,chr(13))>
		<cfset lcl.currentshipoptid = "">
		<cfloop array="#lcl.lista#" index="lcl.idx">
			<cfset lcl.itm = trim(lcl.idx)>
			<cfif lcl.itm EQ "">
				<cfcontinue>
			</cfif>
			<cfif refind("^[0-9]{5}$",lcl.itm)>
				<cfquery name="m" datasource="#requestobject.getVar("dsn")#">
					INSERT INTO ajShippingZips (
						id, zip, shippingid
					) VALUES (
						'#createuuid()#',
						'#lcl.itm#',
						'#lcl.currentshipoptid#'
					)
				</cfquery>
			<cfelse>
				<cfset lcl.str = trim(listfirst(lcl.itm, "-"))>
				<cfquery name="m" datasource="#requestobject.getVar("dsn")#">
					SELECT id 
					FROM ajShippingOptions 
					WHERE label  = <cfqueryparam value="#lcl.str#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfif m.recordcount>
					<cfset lcl.currentshipoptid = m.id>
				<cfelse>
					<cfthrow message="couldnot find #lcl.str#">
				</cfif>
			</cfif>
		</cfloop>
	</cffunction>
	 --->
	<cffunction name="canshiptozip">
		<cfargument name="zip" required="true">
		<cfquery name="m" datasource="#requestobject.getVar("dsn")#">
			SELECT COUNT(*) cnt 
			FROM ajShippingZips 
			WHERE zip  = <cfqueryparam value="#arguments.zip#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfreturn m.cnt>
	</cffunction>
	
</cfcomponent>