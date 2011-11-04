<cfcomponent name="add to cart" extends="resources.page">
	<cffunction name="preobjectLoad">
		<cfset var lcl = structNew()>
		<cfset var cartObj = createObject("component", "modules.cart.models.cart").init(variables.requestObject)>
		<cfset var cartItemsObj = "">
		<cfset cartObj.load()>
		<cfset cartItemsObj = cartObj.getCartItemsObj()>

		<cfset lcl.qty = requestObject.getFormUrlVar("quantity",1)>
		
		<cfif NOT (refind("^[0-9]+$", lcl.qty) AND lcl.qty GT 0)>
			<cfset lcl.qty = 1>
		</cfif>
	
		<cfset lcl.priceid = variables.requestObject.getFormUrlVar("priceid", requestObject.getFormUrlVar("default_priceid", 0))>
		
		<cfset cartItemsObj.addCartItem(lcl.priceid, lcl.qty)>
		
		<cfset requestobject.notifyObservers("cart.item_added", cartObj)>
		
		<cfset session.user.setflash("Cart Updated")>
		
		<cflocation url="/cart" addtoken="false">
	</cffunction>
</cfcomponent>