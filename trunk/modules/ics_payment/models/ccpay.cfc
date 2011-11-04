<cfcomponent name="ccapy">
	
	<cffunction name="init">
		<cfargument name="requestObject">
		<cfset variables.requestObject = arguments.requestObject>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="setBillingInfo">
		<cfargument name="binfo">
		<cfset variables.billinginfo = binfo>
	</cffunction>
	
	<cffunction name="setPaymentInfo">
		<cfargument name="pinfo">
		<cfset variables.paymentinfo = pinfo>
	</cffunction>
	
	<cffunction name="setPaymentAmount">
		<cfargument name="amt">
		<cfset variables.paymentamount = amt>
	</cffunction>
	
	<cffunction name="alreadyprocessed">
		<cfargument name="pmtinfo" required="true">
		
		<cfset var lcl = structnew()>
		<cfif structkeyexists(pmtinfo, "auth_result") AND pmtinfo.auth_result NEQ "approved">
			<cfreturn false>
		</cfif>
		
		<!--- determine if credit cards match --->
		<cfif NOT structkeyexists(pmtinfo, 'auth_requestxmltext')>
			<cfreturn false>
		</cfif>
				
		<cfset lcl.l4digits = refindnocase("[0-9]{4}<\/ACCT_NUM>", pmtinfo.auth_requestxmltext)>
		
		<cfif lcl.l4digits EQ 0>
			<cfreturn false>
		</cfif>
		
		<cfset lcl.l4digits = mid(pmtinfo.auth_requestxmltext, lcl.l4digits, 4)>

		<cfif lcl.l4digits NEQ right(pmtinfo.PMTINFO_CARD_NUMBER, 4)>
			<cfreturn false>
		</cfif>		

		<cfif NOT structkeyexists(pmtinfo, 'auth_trans_amount') OR pmtinfo.auth_trans_amount NEQ variables.paymentamount>
			<cfreturn false>
		</cfif>
		
		<cfreturn true>
	</cffunction>
	
	<cffunction name="auth">
		<cfset var lcl = structnew()>
		
		<!--- check cart in valid state --->
		<cfif NOT (structkeyexists(variables, "billinginfo") 
					AND structkeyexists(variables, "paymentinfo") 
						AND structkeyexists(variables, "paymentamount")
					)>
			<cfthrow message="biinfo, amt, and pmtinfo required">
		</cfif>
		
		<!--- check ipcharge fields required present --->
		<cfloop list="ipchargeurl,ipchargemerchantkey,ipchargeclientcode,ipchargeusername,ipchargepassword" index="lcl.idx">
			<cfif NOT variables.requestObject.isVarSet(lcl.idx)>
				<cfthrow message="ipchargevar #lcl.idx# not set">
			</cfif>
		</cfloop>
		
		<cfset structappend(lcl, variables.billinginfo)>
		<cfset structappend(lcl, variables.paymentinfo)>
		<cfset lcl.paymentamount = variables.paymentamount>

		<!--- setup xml to submit to auth --->
		<cfoutput>
		<cfsavecontent variable="lcl.xml">
			<TRANSACTION>
			    <CLIENT_ID>#requestobject.getVar("ipchargeclientcode")#</CLIENT_ID>
			    <USER_ID>#requestobject.getVar("ipchargeusername")#</USER_ID>
			    <USER_PW>#requestobject.getVar("ipchargepassword")#</USER_PW>
			    <FUNCTION_TYPE>PAYMENT</FUNCTION_TYPE>
			    <COMMAND>PRE_AUTH</COMMAND>
			    <PAYMENT_TYPE>CREDIT</PAYMENT_TYPE>
			    <ACCT_NUM>#session.cc#</ACCT_NUM>
			    <EXP_MONTH>#numberformat(getToken(lcl.pmtinfo_expiration_date,1,"/"),"00")#</EXP_MONTH>
			    <EXP_YEAR>#right(getToken(lcl.pmtinfo_expiration_date,2,"/"),2)#</EXP_YEAR>
			    <TRANS_AMOUNT>#iif(requestObject.isVarSet("debugpayment"), 1.00, trim(numberformat(lcl.paymentamount, 9999999999999.00)))#</TRANS_AMOUNT>
			    <MERCHANTKEY>#requestobject.getVar("ipchargemerchantkey")#</MERCHANTKEY>
			    <CUSTOMER_ZIP>#lcl.billing_postalcode#</CUSTOMER_ZIP>
				<CUSTOMER_STREET>#lcl.billing_line1# #lcl.billing_line2#</CUSTOMER_STREET>
				<INVOICE>#randrange(100000, 999999)#</INVOICE>
				<CVV2>#lcl.pmtinfo_cvv_number#</CVV2>
			</TRANSACTION>
		</cfsavecontent>
		</cfoutput>

		<cfhttp 
			method="post" 
				port="443"
					result="lcl.results" 
						url="#requestObject.getVar("ipchargeurl")#"
							>
			<cfhttpparam name="Content-Type" type="HEADER" value="text/xml" />
			<cfhttpparam type="BODY" value="#lcl.xml#"/>
		</cfhttp>
		
		<!---
		<cfdump var=#lcl.xml#>
		<cfdump var=#lcl.results#>
		<cfabort>--->

		<cfif NOT left(lcl.results.statuscode, 3) EQ 200>
			<cfif requestObject.getVar('debug',0)>
				<cfoutput>#requestObject.getVar("ipchargeurl")#</cfoutput>
				<cfdump var=#xmlparse(lcl.xml)#>
				<cfdump var=#lcl.results#>
				<cfabort>
			</cfif>
			<cfthrow message="Error posting auth">
		</cfif>
		
		<cfset lcl.resultsstring = rereplace(lcl.results.filecontent, "<ACCT_NUM>[0-9]{12}","<ACCT_NUM>************")>
		
		<cfset lcl.resultxml = xmlparse(lcl.resultsstring)>
		
		<cfif isdefined("lcl.resultxml.response.result.xmltext") AND lcl.resultxml.response.result.xmltext EQ "declined">
			<cfthrow message="#lcl.resultxml.response.response_text.xmltext#">
		</cfif>
		
		<cfif isdefined("lcl.resultxml.response.result.xmltext") AND lcl.resultxml.response.result.xmltext EQ "error">
			<cfthrow message="There was an error processing(#lcl.resultxml.response.result_code.xmltext#)">
		</cfif>
		
		<cfif NOT isdefined("lcl.resultxml.response.troutd")>
			<cfthrow message="Troutd not found in response">
		</cfif>

		<cfset lcl.rdata = structnew()>
		<cfloop array="#lcl.resultxml.response.xmlchildren#" index="lcl.ridx">
			<cfset lcl.rdata["auth_" & lcl.ridx.xmlname] = lcl.ridx.xmltext>
		</cfloop>
		
		<!--- save xml request and response text for recordkeeping --->
		<cfset lcl.rdata.auth_responsetext = xmlformat(lcl.results.filecontent)>
		<cfset lcl.rdata.auth_requestxmltext = rereplace(lcl.xml, "<ACCT_NUM>[0-9]{12}","<ACCT_NUM>************")>
		
		<cfreturn lcl.rdata>
	</cffunction>
	
	<cffunction name="capture">
		<cfset var lcl = structnew()>
	
		<!--- 
			CAPTURE HANDLED OFFSITE for APPLEJACK
			<cfif NOT (structkeyexists(variables, "billinginfo") AND structkeyexists(variables, "paymentinfo") AND structkeyexists(variables, "paymentamount"))>
				<cfthrow message="biinfo, amt, and pmtinfo required">
			</cfif>
			<cfset structappend(lcl, variables.billinginfo)>
			<cfset structappend(lcl, variables.paymentinfo)>
			<cfset lcl.paymentamount = variables.paymentamount>
		 --->
		 
		<cfreturn lcl>
	</cffunction>
	
</cfcomponent>