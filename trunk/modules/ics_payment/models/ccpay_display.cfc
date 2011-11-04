<cfcomponent name="ccapy">
	
	<cffunction name="init">
		<cfargument name="requestObject">
		<cfset variables.requestObject = arguments.requestObject>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="setInfo">
		<cfargument name="info" required="true">
		<cfset variables.info = info>
	</cffunction>
	
	<cffunction name="setPaymentAmount">
		<cfargument name="amt" required="true">
		<cfset variables.info.paymentamount = amt>
	</cffunction>
	
	<cffunction name="showhtml">
		<cfset var lcl = structnew()>
		<cfoutput>
		<cfsavecontent variable="lcl.html">
			#variables.info.pmtinfo_card_type#<br>
			#variables.info.pmtinfo_card_number#<br>
			#variables.info.pmtinfo_expiration_date#
		</cfsavecontent>
		</cfoutput>
		<cfreturn lcl.html>		
	</cffunction>
	
	<cffunction name="getField" output="false">
		<cfargument name="name" type="string">
		<cfif NOT isFieldSet(arguments.name)>
			<cfthrow message="field #arguments.name# not set.">
		</cfif>
		<cfreturn variables.info[name]>
	</cffunction>
	
	<cffunction name="isfieldset">
		<cfargument name="name">
		<cfreturn structkeyexists(variables.info, name)>
	</cffunction>
	
	<cffunction name="dump">
		<cfdump var=#variables.info#>
		<cfabort>
	</cffunction>
	
</cfcomponent>