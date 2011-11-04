<cfcomponent name="cartlistctrl" output="false" extends="resources.abstractSubController">
	<cffunction name="init">
		
		<cfargument name="data" required="true">
		<cfargument name="requestObject" required="true">
		<cfargument name="pageRef" required="true">
		<cfargument name="name" required="true">
		<cfargument name="module" required="true">
		<cfargument name="moduleaction" required="true">
		
		<cfset var lf = createObject("component", "modules.cart.forms.cartlist").init(requestObject)>

		<cfreturn lf>
<!--- 
		<cfset super.init(argumentCollection = arguments)>

		<cfset var tmp = structnew()>
		<cfset var cio = variables.cartModel.getCartItemsObj()>
		<cfset var tbl = this.getUtility("table")>
		<cfset var cols = tbl.getColumns()>
		<cfset var tblatts = structnew()>
		<cfset tblatts['class'] = 'cart'>

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
		<cfset arrayappend(cols, tmp)>

		<cfset var tmp = structnew()>
		<cfset tmp.attributes = structnew()>
		<cfset tmp.attributes.align = "center">
		<cfset tmp.title = "Quantity">
		<cfset tmp.field = "priceform">
		<cfset tmp.format = "<input type=""text"" name=""id_[priceid]"" value=""[quantity]"" size=""2"">">
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

		<cfset variables.cartItemsTableObj = tbl> --->
			
		<cfreturn this>
	</cffunction>
		
	<cffunction name="getCacheLength">
		<cfreturn 0>
	</cffunction>
		
</cfcomponent>