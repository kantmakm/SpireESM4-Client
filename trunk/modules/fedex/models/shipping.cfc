<cfcomponent name="fedexshipping">
	
	<cffunction name="init">
		<cfargument name="requestObject" required="true">
		<cfset variables.requestObject = arguments.requestObject>
		<cfset variables.rates = arraynew(1)>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="setCartObj">
		<cfargument name="cartobj" required="true">
		
		<cfset var lcl = structnew()>
		
		<cfset variables.cartObj = arguments.cartObj>
		
		<!--- get destination --->
		<cfset variables.quoteinput = deserializeJson(cartObj.getDeliveryAddressInfo())>
	
		<!--- get items - determine weight, size --->
		<cfset variables.fedexPackagesObj = createObject("component", "modules.applejack.models.packagesCalculator").init(requestobject)>
		<cfset variables.fedexPackagesObj.setCartObj(arguments.cartObj)>
		<cfset variables.quoteinput.packages = arraynew(1)>
		<cfset arrayappend(variables.quoteinput.packages, structnew())>
		
		<cfset variables.quoteinput.packages = variables.fedexPackagesObj.calculatePackages()>
	
		<!---
		<cfdump var="#variables.fedexPackagesObj.calculatePackages()#">
		<cfabort>
		
		<cfset variables.quoteinput.packages[1].Weight = variables.fedexPackagesObj.calculatePackages()>
		<!--- <cfset variables.quoteinput.calculatedWeight = > --->

		<!--- get value --->
		<cfset variables.quoteinput.packages[1].Value = variables.cartObj.getCurrentSubTotal()>
		
		<cfset variables.quoteinput.packages[1].adultsignaturerequired = 1>
		--->
		<cfset variables.quoteinput.calculatedWeight = 0>
		<cfset variables.quoteinput.packageValue = 0>
		<cfset variables.quoteinput.packageingcost = 0>
		
		<cfloop array="#variables.quoteinput.packages#" index="lcl.mpackage">
			<cfset variables.quoteinput.calculatedWeight = variables.quoteinput.calculatedWeight + lcl.mpackage.weight>
			<cfset variables.quoteinput.packageValue = variables.quoteinput.packageValue + lcl.mpackage.value>
			<cfset variables.quoteinput.packageingcost = variables.quoteinput.packageingcost + lcl.mpackage.packagingcost>
		</cfloop>
		
		<cfparam name="variables.quoteinput.delivery_isbusinessaddress" default="0">
		<cfset variables.quoteinput.deliverytype = iif(variables.quoteinput.delivery_isbusinessaddress EQ 1, DE("business"), DE("home"))>
		
		<!--- make request to ws --->	
		<cfinvoke component="#this#" method="getRates" returnvariable="lcl.rates">
			<!---VALIDATION -- YOU MUST FILL THIS IN WITH YOUR INFORMATION FROM FEDEX--->
	        <cfinvokeargument name="myKey" value="#requestObject.getVar("fedexkey")#">
	        <cfinvokeargument name="myPassword" value="#requestObject.getVar("fedexpassword")#">
	        <cfinvokeargument name="myAccountNo" value="#requestObject.getVar("fedexaccntno")#">
	        <cfinvokeargument name="myMeterNo" value="#requestObject.getVar("fedexmeterno")#">
	        <cfinvokeargument name="sandbox" value="#requestObject.getVar("debug", 0)#">
	    	<!---Shipper (Sender) Details--->
	    	<cfinvokeargument name="shipperAddress1" value="#requestObject.getVar("fedexshipfromaddy1")#">
	        <cfinvokeargument name="shipperAddress2"  value="#requestObject.getVar("fedexshipfromaddy2")#">
	        <cfinvokeargument name="shipperCity" value="#requestObject.getVar("fedexshipfromcity")#">
	        <cfinvokeargument name="shipperState" value="#requestObject.getVar("fedexshipfromstate")#">
	        <cfinvokeargument name="shipperZip" value="#requestObject.getVar("fedexshipfromzip")#">
	        <cfinvokeargument name="shipperCountry" value="#requestObject.getVar("fedexshipfromcountry","us")#">
	        <!---Ship To (Recipient) Details--->
	        <cfinvokeargument name="shiptoAddress1" value="#variables.quoteinput.delivery_line1#">
	        <cfinvokeargument name="shiptoAddress2" value="#variables.quoteinput.delivery_line2#">
	        <cfinvokeargument name="shiptoCity" value="#variables.quoteinput.delivery_city#">
	        <cfinvokeargument name="shiptoState" value="#variables.quoteinput.delivery_state#">
	        <cfinvokeargument name="shiptoZip" value="#variables.quoteinput.delivery_postalcode#">
	        <cfinvokeargument name="shiptoCountry" value="US">
			<cfinvokeargument name="shiptoAddytype" value="#variables.quoteinput.deliverytype#">
	        <!---Package Details--->
	        <cfinvokeargument name="packages" value="#variables.quoteinput.packages#">
			<cfinvokeargument name="pkgWeight" value="#variables.quoteinput.calculatedWeight#">
	        <cfinvokeargument name="pkgValue" value="#variables.quoteinput.packagevalue#">
	        <cfinvokeargument name="SignatureOptionDetail" value="ADULT">
		</cfinvoke>

		<cfif NOT lcl.rates.status AND (NOT isdefined("lcl.rates.notifications") OR arraylen(lcl.rates.notifications) EQ 0)>
			<cfset session.user.clearFlash()>
			<cfset session.user.setFlash("There was an error obtaining the fedex quote.")>
			<cfreturn>
		<cfelseif NOT lcl.rates.status AND isdefined("lcl.rates.notifications")>
			<cfset session.user.clearFlash()>
			<cfset session.user.setFlash("Fedex Shipping error : " & lcl.rates.notifications[1].msg & " Please return to the billing and shipping page and fix the error")>
			<cfreturn>
		</cfif>
	
		<cfloop array="#lcl.rates.rates#" index="lcl.rateidx">
			<cfset lcl.s = structnew()>
			<!---<cfset lcl.s.cost = lcl.rateidx.cost + variables.quoteinput.packageingcost>--->
			<cfset lcl.s.cost = lcl.rateidx.cost>
			<cfset lcl.s.optionlabel = lcase(replace(lcl.rateidx.type,"_"," ","all"))>
			<cfset lcl.s.data = variables.quoteinput>
			<cfset arrayappend(variables.rates, lcl.s)>
		</cfloop>
				
	</cffunction>
	
	<cffunction name="getLabel">
		<cfreturn "Fedex Shipping (#variables.quoteinput.calculatedWeight#lbs) to a #iif(isdefined("variables.quoteinput.delivery_isbusinessaddress") AND variables.quoteinput.delivery_isbusinessaddress eq 1,DE("business"), DE("home"))# address in zip code #variables.quoteinput.delivery_postalcode#.<br/>(Incurs #dollarformat(variables.quoteinput.packageingcost)# in packaging costs.)">
	</cffunction>
	
	<cffunction name="getOptions">
		<cfreturn variables.rates>
	</cffunction>
	
	<cffunction name="getRates" access="public" returntype="struct">
    	<!---VALIDATION -- YOU MUST FILL THIS IN WITH YOUR INFORMATION FROM FEDEX--->
        <cfargument name="myKey" type="string" required="no" default="<!---YOURKEY--->">
        <cfargument name="myPassword" type="string" required="no" default="<!---YOURPASSWORD--->">
        <cfargument name="myAccountNo" type="string" required="no" default="<!---YOURACCOUNTNO--->">
        <cfargument name="myMeterNo" type="string" required="no" default="<!---YOURMETERNO--->">
        <cfargument name="sandbox" type="boolean" required="no" default="true">
    	<!---Shipper (Sender) Details--->
    	<cfargument name="shipperAddress1" type="string" required="yes">
        <cfargument name="shipperAddress2" type="string" required="no" default="">
        <cfargument name="shipperCity" type="string" required="yes">
        <cfargument name="shipperState" type="string" required="yes">
        <cfargument name="shipperZip" type="string" required="yes">
        <cfargument name="shipperCountry" type="string" required="no" default="US">
        <!---Ship To (Recipient) Details--->
        <cfargument name="shiptoAddress1" type="string" required="yes">
        <cfargument name="shiptoAddress2" type="string" required="no" default="">
        <cfargument name="shiptoCity" type="string" required="yes">
        <cfargument name="shiptoState" type="string" required="yes">
        <cfargument name="shiptoZip" type="string" required="yes">
        <cfargument name="shiptoCountry" type="string" required="yes" default="US">
		<cfargument name="shiptoAddytype" type="string" default="home">
        <!---Package Details--->
		<cfargument name="packages" type="array" required="true">
		<cfargument name="pkgWeight" type="numeric" required="yes">
        <cfargument name="pkgValue" type="numeric" required="yes">
        <cfargument name="SignatureOptionDetail" type="string" required="yes" default="ADULT">
        <!---Build the XML Packet to send to FedEx--->
		
		
		<cfsavecontent variable="XMLPacket"><cfoutput>
        <ns:RateRequest xmlns:ns="http://fedex.com/ws/rate/v5" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <ns:WebAuthenticationDetail>
                <ns:UserCredential>
                    <ns:Key>#arguments.myKey#</ns:Key>
                    <ns:Password>#arguments.myPassword#</ns:Password>
                </ns:UserCredential>
            </ns:WebAuthenticationDetail>
            <ns:ClientDetail>
                <ns:AccountNumber>#arguments.myAccountNo#</ns:AccountNumber>
                <ns:MeterNumber>#arguments.myMeterNo#</ns:MeterNumber>
            </ns:ClientDetail>
            <ns:Version>
                <ns:ServiceId>crs</ns:ServiceId>
                <ns:Major>5</ns:Major>
                <ns:Intermediate>0</ns:Intermediate>
                <ns:Minor>0</ns:Minor>
            </ns:Version>
            <ns:RequestedShipment>
                <ns:ShipTimestamp>#DateFormat(Now(),'yyyy-mm-dd')#T#TimeFormat(Now(),'hh:mm:ss')#</ns:ShipTimestamp>
                <ns:DropoffType>REQUEST_COURIER</ns:DropoffType>
                <ns:PackagingType>YOUR_PACKAGING</ns:PackagingType>
                <ns:TotalWeight>
                    <ns:Units>LB</ns:Units>
                    <ns:Value>#arguments.pkgWeight#</ns:Value>
                </ns:TotalWeight>
                <ns:TotalInsuredValue>
                    <ns:Currency>USD</ns:Currency>
                    <ns:Amount>#arguments.pkgValue#</ns:Amount>
                </ns:TotalInsuredValue>
                <ns:Shipper>
                    <ns:Address>
                        <ns:StreetLines>#arguments.shipperAddress1#</ns:StreetLines>
                        <ns:City>#arguments.shipperCity#</ns:City>
                        <ns:StateOrProvinceCode>#arguments.shipperState#</ns:StateOrProvinceCode>
                        <ns:PostalCode>#arguments.shipperZip#</ns:PostalCode>
                        <ns:CountryCode>#arguments.shipperCountry#</ns:CountryCode>
                    </ns:Address>
                </ns:Shipper>
                <ns:Recipient>
                    <ns:Address>
                        <ns:StreetLines>#arguments.shiptoaddress1#</ns:StreetLines>
                        <ns:City>#arguments.shiptocity#</ns:City>
                        <ns:StateOrProvinceCode>#arguments.shiptostate#</ns:StateOrProvinceCode>
                        <ns:PostalCode>#arguments.shiptozip#</ns:PostalCode>
                        <ns:CountryCode>#arguments.shiptocountry#</ns:CountryCode>
						<cfif arguments.shiptoAddytype EQ "home"><ns:Residential>true</ns:Residential></cfif>
                    </ns:Address>
                </ns:Recipient>
<!--- <ns:SpecialServicesRequested>
  <ns:SpecialServiceTypes>HOME_DELIVERY_PREMIUM</ns:SpecialServiceTypes>
  <ns:HomeDeliveryPremiumDetail>
	<ns:HomeDeliveryPremiumType>DATE_CERTAIN</ns:HomeDeliveryPremiumType>
  </ns:HomeDeliveryPremiumDetail>
</ns:SpecialServicesRequested> --->
                <ns:RateRequestTypes>ACCOUNT</ns:RateRequestTypes>
                <ns:PackageCount>1</ns:PackageCount>
                <ns:PackageDetail>INDIVIDUAL_PACKAGES</ns:PackageDetail>
                <cfloop from="1" to="#arraylen(arguments.packages)#" index="lcl.packageIndx">
				<ns:RequestedPackages>
                    <ns:SequenceNumber>#lcl.packageIndx#</ns:SequenceNumber>
                    <!--- <ns:InsuredValue>
                        <ns:Currency>USD</ns:Currency>
                        <ns:Amount>#arguments.packages[lcl.packageIndx].Value#</ns:Amount>
                    </ns:InsuredValue> --->
                    <ns:Weight>
                        <ns:Units>LB</ns:Units>
                        <ns:Value>#arguments.packages[lcl.packageIndx].Weight#</ns:Value>
                    </ns:Weight>
					<cfif structkeyexists(arguments.packages[lcl.packageIndx],"adultsignaturerequired")>
						<ns:SpecialServicesRequested>
							<ns:SpecialServiceTypes>SIGNATURE_OPTION</ns:SpecialServiceTypes>
							<ns:SignatureOptionDetail>
								<ns:OptionType>ADULT</ns:OptionType>
							</ns:SignatureOptionDetail>
						</ns:SpecialServicesRequested>	
					</cfif>			
                </ns:RequestedPackages>
				</cfloop>
            </ns:RequestedShipment>
        </ns:RateRequest>
        </cfoutput></cfsavecontent>
		<!---
		<cfsavecontent variable="xmplpacket">
		        <ns:RateRequest xmlns:ns="http://fedex.com/ws/rate/v5" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <ns:WebAuthenticationDetail>
                <ns:UserCredential>
                    <ns:Key>eQKV9FAu7noeCN6x</ns:Key>
                    <ns:Password>tFdza16jqVEyvPtwdZFpkjknl</ns:Password>
                </ns:UserCredential>
            </ns:WebAuthenticationDetail>

            <ns:ClientDetail>
                <ns:AccountNumber>510087909</ns:AccountNumber>
                <ns:MeterNumber>100022555</ns:MeterNumber>
            </ns:ClientDetail>
            <ns:Version>
                <ns:ServiceId>crs</ns:ServiceId>
                <ns:Major>5</ns:Major>

                <ns:Intermediate>0</ns:Intermediate>
                <ns:Minor>0</ns:Minor>
            </ns:Version>
            <ns:RequestedShipment>
                <ns:ShipTimestamp>2010-09-22T12:39:35</ns:ShipTimestamp>
                <ns:DropoffType>REGULAR_PICKUP</ns:DropoffType>
                <ns:PackagingType>YOUR_PACKAGING</ns:PackagingType>
                <ns:TotalWeight>
                    <ns:Units>LB</ns:Units>
                    <ns:Value>5</ns:Value>
                </ns:TotalWeight>
                <ns:TotalInsuredValue>
                    <ns:Currency>USD</ns:Currency>
                    <ns:Amount>4.99</ns:Amount>
                </ns:TotalInsuredValue>
                <ns:Shipper>
                    <ns:Address>
                        <ns:StreetLines>3320 YOUNGFIELD ST</ns:StreetLines>
                        <ns:City>Wheat Ridge</ns:City>
                        <ns:StateOrProvinceCode>CO</ns:StateOrProvinceCode>
                        <ns:PostalCode>80033</ns:PostalCode>

                        <ns:CountryCode>us</ns:CountryCode>
                    </ns:Address>
                </ns:Shipper>
                <ns:Recipient>
                    <ns:Address>
                        <ns:StreetLines>Myadd1</ns:StreetLines>
                        <ns:City>Colorado Springs</ns:City>

                        <ns:StateOrProvinceCode>CO</ns:StateOrProvinceCode>
                        <ns:PostalCode>80925</ns:PostalCode>
                        <ns:CountryCode>US</ns:CountryCode>
						<ns:Residential>true</ns:Residential>
                    </ns:Address>
                </ns:Recipient>
<ns:SpecialServicesRequested>
  <ns:SpecialServiceTypes>HOME_DELIVERY_PREMIUM</ns:SpecialServiceTypes>
  <ns:HomeDeliveryPremiumDetail>
	<ns:HomeDeliveryPremiumType>DATE_CERTAIN</ns:HomeDeliveryPremiumType>
  </ns:HomeDeliveryPremiumDetail>
</ns:SpecialServicesRequested>
                <ns:RateRequestTypes>ACCOUNT</ns:RateRequestTypes>
                <ns:PackageCount>1</ns:PackageCount>

                <ns:PackageDetail>INDIVIDUAL_PACKAGES</ns:PackageDetail>
                <ns:RequestedPackages>
                    <ns:SequenceNumber>1</ns:SequenceNumber>
                    <ns:InsuredValue>
                        <ns:Currency>USD</ns:Currency>
                        <ns:Amount>4.99</ns:Amount>
                    </ns:InsuredValue>
                    <ns:Weight>
                        <ns:Units>LB</ns:Units>
                        <ns:Value>4.05</ns:Value>
                    </ns:Weight>
					<ns:SpecialServicesRequested>
						<ns:SpecialServiceTypes>SIGNATURE_OPTION</ns:SpecialServiceTypes>
						<ns:SignatureOptionDetail>
							<ns:OptionType>ADULT</ns:OptionType>
						</ns:SignatureOptionDetail>
					</ns:SpecialServicesRequested>				
                </ns:RequestedPackages>
            </ns:RequestedShipment>
        </ns:RateRequest>
        </cfsavecontent>
		--->
        <cfif arguments.sandbox>
        	<cfset fedexurl = "https://gatewaybeta.fedex.com/xml">
        <cfelse>
        	<cfset fedexurl = "https://gateway.fedex.com/xml">
        </cfif>
		
        <cfhttp url="#fedexurl#" port="443" method ="POST" throwonerror="yes"> 
            <cfhttpparam name="name" type="XML" value="#XMLPacket#"> 
        </cfhttp>
		
		<cftry>
	        <cfset xmlfile = XmlParse(CFHTTP.FileContent)>
	
			<!---Build the Struct for Return--->
	        <cfset fedexReply = StructNew()>
	        <cfset fedexReply = structnew()>
			<cfset fedexReply.status = 1>
			<cfset fedexReply.rates = ArrayNew(1)>
			<cfset fedexReply.notifications = Arraynew(1)>
	       	<!---Did you pass bad info or malformed XML?--->
	       	<cfif isDefined('xmlfile.Fault')>
				<cfset fedexReply.status = 0>
	           	<cfset fedexReply.error = 1>
			<cfelse>
				<!---Did FedEx reply with an error?--->
				<cfloop from="1" to="#arrayLen(xmlfile.RateReply.Notifications)#" index="n">
					<cfset fedexReply.notifications[n] = structNew()>
					<cfset fedexReply.notifications[n].status = xmlfile.RateReply.Notifications[n].Severity.xmltext>
					<cfset fedexReply.notifications[n].msg = xmlfile.RateReply.Notifications[n].Message.xmltext>
					<cfif fedexReply.notifications[n].status contains "Error">
						<cfset fedexReply.status = 0>
					</cfif>
				</cfloop>
							
				<cfif fedexReply.status AND isdefined("xmlfile.RateReply.RateReplyDetails")>
					<cfloop from="1" to="#arrayLen(xmlfile.RateReply.RateReplyDetails)#" index="r">
						<cfset fedexReply.rates[r] = StructNew()>
						<cfset fedexReply.rates[r].type = xmlfile.RateReply.RateReplyDetails[r].ServiceType.xmltext>
						<cfset fedexReply.rates[r].cost = xmlfile.RateReply.RateReplyDetails[r].RatedShipmentDetails.ShipmentRateDetail.TotalNetCharge.Amount.xmltext>
					</cfloop>
				</cfif>
			</cfif>

			<cfif arraylen(fedexReply.notifications)>
				<cfloop array="#fedexReply.notifications#" index="lcl.notification">
					<cfif trim(lcl.notification.msg) EQ "There are no valid services available.">
						<cfset requestObject.getUserObject().setFlash("Fedex is unable to ship this package as configured.  Please call us so that we can help you determine the best shipping method.")>
					</cfif>
				</cfloop>	
			</cfif>
			
			<cfcatch>
				<cfset e = "Fedex error\n Sent #xmlpacket# \n got : #CFHTTP.FileContent#\n error : #cfcatch.message#">
				<cflog file="#replace(requestObject.getVar("sitename")," ", "", "ALL")#_Site" text="#e#" type="fedex issue">
				<cfrethrow>
			</cfcatch>
		</cftry>
		<cfreturn fedexReply>
	</cffunction>
	
</cfcomponent>