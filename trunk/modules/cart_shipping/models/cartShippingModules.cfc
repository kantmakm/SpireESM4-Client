<cfcomponent name="Events" extends="resources.abstractModel">

	<cffunction name="init">
		<cfargument name="requestObject" required="true">
		<cfset variables.requestObject = arguments.requestObject>
		<cfset startorm("cartShippingModules")>
		<cfreturn this>	
	</cffunction>
	
	<cffunction name="getAvailableShippingModules">
		<cfset var lcl = structnew()>
		<cfset lcl.more = structnew()>
		<cfset lcl.more.sort = "sortkey">
		<cfset lcl.list = this.getByEnabled(1, lcl.more)>
		<cfset lcl.r = arraynew(1)>
		<cfloop query="lcl.list">
			<cfset arrayappend(lcl.r, path)>
		</cfloop>
		<cfreturn lcl.r>
	</cffunction>
	
	<cffunction name="getAvailableShippingOptions">
		<cfargument name="cartobj" required="true">
		<cfset var lcl = structnew()>
		<cfset lcl.ra = arraynew(1)>
		
		<!--- first see if any are in db, return those if possible --->
		<cfset lcl.shippingQuotesObj = createobject("component", "modules.cart_shipping.models.cartShippingQuotes").init(requestObject)>
		<cfset lcl.mquotes = lcl.shippingQuotesObj.getByCartId(cartObj.getCartId())>

		<cfoutput query="lcl.mquotes" group="modulelabel">
			<cfset lcl.s = structnew()>
			<cfset lcl.s.moduleLabel = lcl.mquotes.moduleLabel>
			<cfset lcl.s.shippingModule = lcl.mquotes.shippingModule>
			<cfset lcl.s.options = arraynew(1)>
			<cfoutput>
				<cfset lcl.s2 = structnew()>
				<cfset lcl.s2.id = lcl.mquotes.id>
				<cfset lcl.s2.optionLabel = lcl.mquotes.optionLabel>
				<cfset lcl.s2.cost = lcl.mquotes.Cost>
				<cfset lcl.s2.isselectable = lcl.mquotes.isselectable>
				<cfset arrayappend(lcl.s.options, lcl.s2)>
			</cfoutput>
			<cfset arrayappend(lcl.ra, lcl.s)>
		</cfoutput>
		
		<cfif lcl.mquotes.recordcount>
			<cfset lcl.observeable = structnew()>
			<cfset lcl.observeable.options = lcl.ra>
			<cfset lcl.observeable.cartObj = arguments.cartObj>
			<cfset lcl.observeable = requestObject.notifyObservers("cart_shipping.shippingoptions", lcl.observeable)>
			<cfreturn lcl.observeable.options>
		</cfif>

		<!--- otherwise, (re)create them --->
		<cfset lcl.aso = getAvailableShippingModules()>

		<cfloop array="#lcl.aso#" index="lcl.idx">
			<cfset lcl.tmp = createObject("component", lcl.idx).init(requestObject)>
			<cfset lcl.tmp.setCartObj(cartObj)>
			<cfset lcl.s = structnew()>
			<cfset lcl.s.options = lcl.tmp.getOptions()> 	
			<cfif arraylen(lcl.s.options)>
				<cfset lcl.s.shippingModule = lcl.idx>
				<cfset lcl.s.moduleLabel = lcl.tmp.getLabel()>
				<cfset arrayappend(lcl.ra, lcl.s)>
			</cfif>
		</cfloop>
		
		
		<!--- and save them for reeuse instead of recreating each page request --->
		<cfset lcl.tmp = structnew()>

		<cfloop array="#lcl.ra#" index="lcl.idx">
			<cfset lcl.tmp.moduleLabel = lcl.idx.modulelabel>
			<cfset lcl.tmp.shippingmodule = lcl.idx.shippingmodule>
			<cfloop array="#lcl.idx.options#" index="lcl.idx2">
				<cfset lcl.shippingQuotesObj.clear()>
				<cfset lcl.shippingQuotesObj.setCartId(cartObj.getCartId())>
				<cfset lcl.shippingQuotesObj.setShippingModule(lcl.tmp.shippingmodule)>
				<cfset lcl.shippingQuotesObj.setModuleLabel(lcl.tmp.modulelabel)>
				<cfset lcl.shippingQuotesObj.setOptionLabel(lcl.idx2.optionlabel)>
				<cfset lcl.shippingQuotesObj.setCost(lcl.idx2.cost)>
				<cfif structkeyexists(lcl.idx2,"isselectable") AND lcl.idx2.isselectable EQ 0>
					<cfset lcl.shippingQuotesObj.setIsSelectable(0)>
				<cfelse>
					<cfset lcl.shippingQuotesObj.setIsSelectable(1)>
				</cfif>
				<cfset lcl.shippingQuotesObj.setData(serializeJson(lcl.idx2.data))>
				<cfif NOT lcl.shippingQuotesObj.save()>
					<cfdump var=#lcl.shippingQuotesObj.getValidator().getErrors()#>
					<cfdump var=#lcl.shippingQuotesObj.dump()#>
					<cfabort>
				</cfif>
				<cfset lcl.idx2.id = lcl.shippingQuotesObj.getId()>
			</cfloop>
		</cfloop>

		<cfset lcl.observeable = structnew()>
		<cfset lcl.observeable.options = lcl.ra>
		<cfset lcl.observeable.cartObj = arguments.cartObj>

		<cfset lcl.observeable = requestObject.notifyObservers("cart_shipping.shippingoptions", lcl.observeable)>

		<cfreturn lcl.observeable.options>
	</cffunction>
	
	<cffunction name="discoverModules">
		<cfset var lcl = structnew()>
		<cfset lcl.o = arraynew(1)>
		<cfset lcl.modules = requestObject.notifyObservers("isCartShippingModule", lcl.o)>

		<cfloop array="#lcl.modules#" index="lcl.idx">
			<cfset lcl.thisone = lcl.idx>
			<cfset lcl.f = this.getByName(lcl.thisone.name)>
			<cfif NOT lcl.f.recordcount>
				<cfset this.clear()>
				<cfset this.setname(lcl.thisone.name)>
				<cfset this.setpath(lcl.thisone.path)>
				<cfset this.setenabled(0)>
				<cfif NOT this.save()>
					<cfdump var=#this.getValidatorObject().getErrors()#>
					<cfabort>				
				</cfif>
			</cfif>
		</cfloop>
	</cffunction>	
	
</cfcomponent>