<cfcomponent name="Galleries" extends="resources.abstractController">

	<cffunction name="print">
        
		<cfset var tmp = structnew()>
		<cfset var cio = "">
		<cfset var tbl = this.getUtility("table").init(requestObject)>
		<cfset var cols = tbl.getColumns()>
		<cfset var tblatts = structnew()>
		
		<cfset tbl.setName("printableList")>
		
		<cfset variables.cartModel = createObject("component","modules.cart.models.cart").init(requestObject)>
		<cfset cio = variables.cartModel.getCartItemsObj()>
		<!------><cfset tblatts['class'] = 'cartprint'>

		<cfset tbl.setTableAttributes(tblatts)>
		
		<cfset tmp.title = "Item ##">
		<cfset tmp.field = "productid">
				
		<cfset arrayappend(cols, tmp)>
		
		<cfset var tmp = structnew()>
		<cfset tmp.title = "Title">
		<cfset tmp.field = "title">
		
		<cfset arrayappend(cols, tmp)>

		<cfset var tmp = structnew()>
		<cfset tmp.title = "Price">
		<cfset tmp.field = "price">
		<cfset tmp.attributes = structnew()>
		<cfset tmp.attributes.align = "right">
        
        <cfset tmp.tblformats = structnew()>
		<cfset tmp.tblformats['price_total'] = 'money'>
		<cfset tmp.tblformats['price'] = 'money'>
		<!---<cfset lcl.tblformats['created'] = 'date'>--->

		<cfset tbl.setformats(tmp.tblformats)>
        
		<cfset arrayappend(cols, tmp)>

		<cfset var tmp = structnew()>
		<cfset tmp.attributes = structnew()>
		<cfset tmp.attributes.align = "center">
		<cfset tmp.title = "Quantity">
		<cfset tmp.field = "quantity">
		<cfset arrayappend(cols, tmp)>		

		<cfset var tmp = structnew()>
		<cfset tmp.title = "Total">
		<cfset tmp.field = "price_total">
		<cfset tmp.attributes = structnew()>
		<cfset tmp.attributes.align = "right">
		<cfset arrayappend(cols, tmp)>

		<cfset tbl.setColumns(cols)>
		<cfset tbl.setData(cio.getCartItems())>

		<!--- export items here --->
		
		<cfset requestObject.notifyObservers("cart.cartList", tbl)>

		<cfset variables.cartItemsTableObj = tbl>
		<cfreturn this>
	</cffunction>
	
</cfcomponent>