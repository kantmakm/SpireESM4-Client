<cfcomponent name="vznobserver" extends="resources.abstractObserver" output="false">
	<!--- this observer receives a completed order from the site and submits it to vzn --->
	<cffunction name="orders_neworder">
		<cfargument name="observed" required="true">
		<cfset var lcl = structnew()>
	
		<cfset lcl.uo = requestObject.getUserObject()>
		<cfset lcl.billingAddressinfo = observed.getBillingAddressInfo()>
		<cfset lcl.deliveryAddressinfo = observed.getDeliveryAddressInfo()>
		<cfset lcl.orderitems = observed.getOrderItems()>
		<cfset lcl.lineitems = observed.getOrderLineItems()>
		<cfset lcl.shippingQuoteInfo = observed.getShippingQuoteInfo()>
		<cfset lcl.pmtObj = observed.getPaymentObjectInfo()><!--- createObject("component", "modules.orderPayments.models.orderPayments").init(requestObject).load(observed.getId())> --->

		<!--- see if there is a line item called tax, if so it may have morejson populated - use to add tax values --->
		<cfloop query="lcl.lineitems">
			<cfif lcl.lineitems.name EQ "tax">
				<cfif left(lcl.lineitems.morejson,1) EQ "{">
					<cfset lcl.taxesstruct = deserializejson(lcl.lineitems.morejson)>
					<cfset lcl.taxtotal = lcl.lineitems.total>
				</cfif>
			</cfif>
			<cfif lcl.lineitems.name EQ 'packagingcosts'>
				<cfif left(lcl.lineitems.morejson,1) EQ "{">
					<cfset lcl.packagemore = deserializejson(lcl.lineitems.morejson)>
					<cfset lcl.packagecount = lcl.packagemore.boxestobuy>
				</cfif>
			</cfif>
		</cfloop>
		
		<cfset lcl.notes = "">
		<cfif isdefined("lcl.shippingQuoteInfo") AND lcl.shippingQuoteInfo.recordcount>
			<cfset lcl.notes = lcl.notes & "Shipping: #lcl.shippingquoteinfo.optionLabel# $#lcl.shippingquoteinfo.cost#">
		</cfif>
		<cfset lcl.notes = lcl.notes & "\nCustomer: #observed.getDelivery_Notes()#">
		
		<cfset lcl.delivery_fname = listfirst(lcl.deliveryAddressInfo.delivery_name," ")>
		<cfset lcl.delivery_lname = listlast(lcl.deliveryAddressInfo.delivery_name," ")>
		
		<cfoutput>
		<cfsavecontent variable="lcl.xml">
			<order>
				<api-version>1</api-version>
				<alt-customer-num>#lcl.uo.getUserId()#</alt-customer-num>
				<alt-num>#observed.getId()#</alt-num>
				<orderred>#dateformat(now(), "yyyy-mm-dd")#</orderred>
				<notes>#xmlformat(lcl.notes)#</notes>
				<customer-email>#xmlformat(ucase(lcl.uo.getEmail()))#</customer-email>
				<first-name>#xmlformat(ucase(lcl.uo.getFirstName()))#</first-name>
				<last-name>#xmlformat(ucase(lcl.uo.getLastName()))#</last-name>
				<phone>#xmlformat(lcl.billingAddressInfo.billing_phone)#</phone> 
				<billing-address>
					<address1>#xmlformat(ucase(lcl.billingAddressInfo.billing_line1))#</address1>
					<address2>#xmlformat(ucase(lcl.billingAddressInfo.billing_line2))#</address2>
					<city>#xmlformat(ucase(lcl.billingAddressInfo.billing_city))#</city>
					<state>#xmlformat(ucase(lcl.billingAddressInfo.billing_state))#</state>
					<zip-code>#xmlformat(ucase(lcl.billingAddressInfo.billing_postalcode))#</zip-code>
				</billing-address>
				<shipping-address>
					<shipping-first-name>#xmlformat(ucase(lcl.delivery_fname))#</shipping-first-name>
	    			<shipping-last-name>#xmlformat(ucase(lcl.delivery_lname))#</shipping-last-name>
				    <shipping-phone>#xmlformat(ucase(lcl.deliveryAddressInfo.delivery_phone))#</shipping-phone>
				    <address1>#xmlformat(ucase(lcl.deliveryAddressInfo.delivery_line1))#</address1>
					<address2>#xmlformat(ucase(lcl.deliveryAddressInfo.delivery_line2))#</address2>
				    <city>#xmlformat(ucase(lcl.deliveryAddressInfo.delivery_city))#</city>
				    <state>#xmlformat(ucase(lcl.deliveryAddressInfo.delivery_state))#</state>
				    <zip-code>#xmlformat(ucase(lcl.deliveryAddressInfo.delivery_postalcode))#</zip-code>
				</shipping-address>
				<items>
					<cfloop query="lcl.orderitems">
					<item>
						<item-num>#pad5(lcl.orderitems.productid)#</item-num>
						<cfscript>
							writeoutput("<size>");
							if (lcl.orderitems.type EQ 'unit') writeoutput("bottle");
							else writeoutput(lcl.orderitems.type);
							writeoutput("</size>");
						</cfscript>
						<quantity>#lcl.orderitems.quantity#</quantity>
						<price>#lcl.orderitems.price#</price>
					</item>
					</cfloop>
					<cfif isdefined("lcl.shippingQuoteInfo") AND lcl.shippingQuoteInfo.recordcount>
						<item>
							<item-num>shipping</item-num>
							<price>#lcl.shippingQuoteInfo.cost#</price>
						</item>
					</cfif>
					<cfif structkeyexists(lcl, "packagecount")>
						<item>
							<item-num>14562</item-num>
							<quantity>#lcl.packagecount#</quantity>
							<price>#9.99 * lcl.packagecount#</price>
						</item>
					</cfif>
				</items>
				<cfif isdefined("lcl.taxesstruct")>
				<tax>
					<cfif structkeyexists(lcl.taxesstruct, "code")>
						 <code>#lcl.taxesstruct.code#</code>
					</cfif>
					<cfif structkeyexists(lcl.taxesstruct, "rtd")>
						 <county>#trim(numberformat(lcl.taxesstruct.rtd,"9999999999.00"))#</county>
					</cfif>
					<cfif structkeyexists(lcl.taxesstruct, "city")>
						 <city>#trim(numberformat(lcl.taxesstruct.city,"9999999999.00"))#</city>
					</cfif>
					<cfif structkeyexists(lcl.taxesstruct, "state")>
						 <state>#trim(numberformat(lcl.taxesstruct.state,"9999999999.00"))#</state>
					</cfif>
				</tax>
				</cfif>
				<preauths>
					<preauth>
						<cardnum>#lcl.pmtObj.getField("pmtinfo_card_number")#</cardnum>
						<expdate>#lcl.pmtObj.getField("pmtinfo_expiration_date")#</expdate>
						<amount>#lcl.pmtObj.getField("paymentAmount")#</amount>
						<authorized>1</authorized>
						<transaction-id>#lcl.pmtObj.getField("auth_troutd")#</transaction-id>
						<response-text>#lcl.pmtObj.getField("auth_responsetext")#</response-text>
						<cfscript>
							writeoutput("<cardtype>");
							lcl.cardtype = lcl.pmtObj.getField("pmtinfo_card_type");
							if (lcl.cardtype EQ "mastercard") writeoutput("MC");
							else if (lcl.cardtype EQ "american express") writeoutput("AMEX");
							else if (lcl.cardtype EQ "discovery") writeoutput("DISC");
							else writeoutput(lcase(lcl.cardtype));
							writeoutput("</cardtype>");
						</cfscript>
					</preauth>
				</preauths>
			</order>
		</cfsavecontent>

		</cfoutput>
		<!--- <order>

		  <api-version>1</api-version>
		  <vision-customer-num>543210</vision-customer-num>
		  <alt-customer-num>34a56</alt-customer-num>
		  <alt-num>x123123a</alt-num>
		  <orderred>2008-01-12</orderred>
		  <notes>Please rush my order.</notes>
		  <customer-email>adler@vznlink.com</customer-email>
		
		  <first-name>John</first-name>
		  <last-name>Smith</last-name>
		  <phone>732-555-0909</phone>
		  
		  <billing-address>
		    <address1>123 Main Street</address1>
		    <address2>Apt #2</address2>
		    <city>Montclair</city>
		    <state>NJ</state>
		    <zip-code>07042</zip-code>
		  </billing-address>
		
		  <shipping-address>
		    <address1>123 River Road</address1>
		    <city>Rumson</city>
		    <state>NJ</state>
		    <zip-code>07760</zip-code>
		  </shipping-address>
		
		  <items>
		    <item>
		      <item-num>00812</item-num>
		      <size>CASE</size>
		      <quantity>7</quantity>
		      <price>8.95</price>
		      <tax>.64</tax>
		    </item>
		    <item>
		      <item-num>00484</item-num>
		      <quantity>6</quantity>
		    </item>
		    <item>
		      <item-num>00484</item-num>
		      <size>CASE</size>
		    </item>
		    <item>
		      <item-num>shipping</item-num>
		      <price>4.95</price>
		      <tax>0.34</tax>
		    </item>
		  </items>
		
		  <tenders>
		   <tender>
		     <amount>14.94</amount>
		     <tender-id>4</tender-id>
		   </tender>
		  </tenders>
		
		</order> --->

		<cfhttp 
			method="post" 
				port="443"
					result="lcl.results" 
						url="#requestObject.getVar("vznorderurl")#"
							username="#requestObject.getVar("vznusername")#"
								password="#requestObject.getVar("vznpassword")#">
			<cfhttpparam name="Content-Type" type="HEADER" value="application/x-www-form-urlencoded" />
			<cfhttpparam type="BODY" value="#lcl.xml#" />
		</cfhttp>

		<cfif NOT left(lcl.results.statuscode, 3) EQ 201>
			<cfif requestObject.getVar('debug',0)>
				<cfdump var=#xmlparse(lcl.xml)#>
				<cfdump var=#lcl.results#>
				<cfabort>
			</cfif>
			<cfthrow message="Error posting order">
		</cfif>
		
		<cfset lcl.moreinfo = observed.getMoreJson()>
		<cfset lcl.moreinfo = deserializejson(lcl.moreinfo)>

		<cfset lcl.moreinfo.postedvznxml = lcl.xml>

		<cfset lcl.moreinfo = serializejson(lcl.moreinfo)>
		
		<cfset observed.setMoreJSON(lcl.moreinfo)>
		
		<cfif NOT observed.save()>
			<cfset lcl.errorsstring = observed.getValidator().getFormattedErrors()>
			<cfset requestObject.log("serious", "Could not save vzn info " & lcl.errorsstring)>
			<cfthrow message="Could'nt save vzn info">
		</cfif>
		
		<cfreturn observed>
	</cffunction>
	
	<cffunction name="pad5" output="false">
		<cfargument name="str" required="true">
		<cfset arguments.str = repeatstring("0", 5-len(str)) & arguments.str>
		<cfreturn trim(arguments.str)>
	</cffunction>
	
</cfcomponent>