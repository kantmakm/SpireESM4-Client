<cfcomponent name="cartLineItems" output="false" extends="resources.page">
	<cffunction name="preobjectLoad">
		<cfset var lcl = structnew()>
		<!--- This is an ajax call that updates the shipping quote id and returns html for the cart line items table --->
		<cfset lcl.cartObj = createObject("component", "modules.cart.models.cart").init(variables.requestObject)>
		<cfset lcl.cartObj.load()>
		
		<cfif requestObject.isFormUrlVarSet("shippingquoteid")>
			<cfset lcl.cartObj.setShippingQuoteId(requestObject.getFormUrlVar("shippingquoteid"))>
			<cfset lcl.cartObj.save()>
			<!--- <cfset lcl.cartObj.load()> --->
		</cfif>
		
		<cfset lcl.LineItems = lcl.cartObj.getCartLineItems('shippingpayment')>
		
		<cfset lcl.tbl = createObject("component","utilities.forms2.table").init(requestObject)>
		<cfset lcl.tbl.setName("cartshippingpaymenttotals")>
		<cfset lcl.tbl.addClass("cartshippingpaymenttotals")>
		
		<cfloop array="#lcl.lineitems#" index="lcl.idx">
			<cfset lcl.tr = lcl.tbl.addItem("tablerow")>
			<cfset lcl.tr.addClass(lcl.idx.name)>
			<cfset lcl.tr.setName(lcl.idx.name & "_row")>
			
			<cfset lcl.td = lcl.tr.addItem("tablecolumn")>
			<cfset lcl.td.setName(lcl.idx.name & "_col")>
			
			<cfset lcl.tdhtml = lcl.td.addItem("html")>
			<cfset lcl.tdhtml.setName(lcl.idx.name & "_label")>
			<cfset lcl.tdhtml.setHTML(lcl.idx.label)>
			
			<cfset lcl.td = lcl.tr.addItem("tablecolumn")>
			<cfset lcl.td.setName(lcl.idx.name & "_col")>
			
			<cfset lcl.tdhtml = lcl.td.addItem("html")>
			<cfset lcl.tdhtml.setName(lcl.idx.name & "_value")>
			<cfset lcl.tdhtml.setHTML(dollarformat(lcl.idx.total))>
		</cfloop>
		
		<cfcontent reset="true"><cfoutput>#lcl.tbl.showHTML()#</cfoutput><cfabort>
	</cffunction>
</cfcomponent>