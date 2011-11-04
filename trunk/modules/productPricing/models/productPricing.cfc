<cfcomponent name="productPricing" extends="resources.abstractmodel">

	<cffunction name="init">
		<cfargument name="requestObject" required="true">
		<cfset variables.requestObject = arguments.requestObject>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="setPricedObj">
		<cfargument name="pricedObj" required="true">

		<cfset var priceq = "">
		<cfset var li = "">
		<cfset var lpriceinfo = structnew()>
		<cfset var t = "">
	
		<cfset variables.pricedObj = arguments.pricedObj>
		
		<cfquery name="priceq" datasource="#requestObject.getVar("dsn")#">
			SELECT pp.*
			FROM productPrices pp
			INNER JOIN productPriceTypes ppt ON ppt.type = pp.type
			WHERE pp.productid = <cfqueryparam value="#variables.pricedObj.getId()#" cfsqltype="cf_sql_varchar">
			ORDER BY ppt.sortkey
		</cfquery>
		
		<!--- Make pricing structures into system --->
		<cfoutput query="priceq">
			<cfset t = structnew()>
			<cfloop list="#priceq.columnlist#" index="li">
				<cfset t[li] = priceq[li][priceq.currentrow]>
			</cfloop>
			<cfset lpriceinfo[priceq.type] = t>
		</cfoutput>
		
		<!--- determine default price --->
		<cfset variables.defaultpricetype = "">
		<cfloop query="priceq">
			<cfif priceq.isdefault eq 1>
				<cfset variables.defaultpricetype = priceq.type>
				<cfbreak>
			</cfif>
		</cfloop>
		
		<cfset variables.priceq = priceq>
		<cfset variables.priceinfo = lpriceinfo>
	</cffunction>

	<cffunction name="pricelist">
		<cfreturn variables.priceq/>
	</cffunction>
	
	<cffunction name="hasType">
		<cfargument name="type" required="true">
		<cfreturn structkeyexists(variables.priceinfo, arguments.type) AND variables.priceinfo[arguments.type].price NEQ 0>
	</cffunction>
	
	<cffunction name="getTypePrice">
		<cfargument name="type" required="true">
		<cfif NOT variables.hasType(type)>
			<cfthrow message="Product does not have type #type#">
		</cfif>
		<cfreturn variables.priceinfo[type]>
	</cffunction>
	
	<cffunction name="getDefaultPriceType">
		<cfreturn variables.defaultpricetype>
	</cffunction>
	
	
	<cffunction name="showListForm">
		<cfset var c = "">
		<cfsavecontent variable="c">
		<cfinclude template="../templates/listform.cfm">
		</cfsavecontent>
		<cfreturn c>
	</cffunction>
	
	<cffunction name="showDetailForm">
		<cfset var c = "">
		<cfsavecontent variable="c">
		<cfinclude template="../templates/detailform.cfm">
		</cfsavecontent>
		<cfreturn c>
	</cffunction>
	
	<cffunction name="dump">
		<cfset var lcl = structnew()>
		<cfset var i = "">
		<cfloop list="priceq,priceinfo,pricedobj" index="i">
			<cfset lcl[i] = variables[i]>
		</cfloop>
		<cfdump var=#lcl#>
		<cfabort>
	</cffunction>
	
</cfcomponent>
