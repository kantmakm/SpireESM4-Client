<cfcomponent name="cartupdatectrl" output="false" extends="resources.page">
	<cffunction name="preobjectLoad">
		<cfset var lcl = structnew()>

		<cfset lcl.cartObj = createObject("component", "modules.cart.models.cart").init(variables.requestObject)>
		<cfset lcl.cartObj.load()>
		<cfset lcl.cartItemsObj = lcl.cartObj.getCartItemsObj()>
		
		<cfset lcl.ci = lcl.cartItemsObj.getCartItems()>
		
		<cfloop collection="#lcl.ci#" item="lcl.ciitem">
			<cfif requestObject.isFormUrlVarSet("id_#lcl.ciitem#")>
				<cfset lcl.thisCartItem = lcl.ci[lcl.ciitem]>
				<cfset lcl.qty = int(val(requestObject.getFormUrlVar("id_#lcl.ciitem#")))>
				<cfif lcl.qty EQ 0>
					<cfset lcl.cartItemsObj.delete(lcl.thisCartItem.cartitemid)>
					<cfset session.user.setFlash(lcl.thisCartItem.title & " removed")>
					<cfset requestobject.notifyObservers("cart.item_updated", lcl.cartObj)>
				<cfelseif lcl.qty NEQ lcl.ci[lcl.ciitem].quantity>
					<cfset lcl.cartItemsObj.setID(lcl.thisCartItem.cartitemid)>
					<cfset lcl.cartItemsObj.setQuantity(lcl.qty)>
					<cfset lcl.cartItemsObj.save()>
					<cfset session.user.setFlash(lcl.thisCartItem.title & " qty updated to " & lcl.qty)>
					<cfset requestobject.notifyObservers("cart.item_removed", lcl.cartObj)>
				</cfif>
			</cfif>
		</cfloop>
		
		<cfif NOT requestObject.isFormUrlVarSet("action")>
			action not set<cfabort>
		</cfif>
				
		<cfset lcl.action = listfirst(requestObject.getFormUrlVar("action"), " ")>
			
		<cfswitch expression="#lcl.action#">
			<cfcase value="resume">
				<cfset lcl.lastadded = lcl.cartItemsObj.getLastItemAdded()>
				<cfif isquery(lcl.lastadded) AND lcl.lastadded.recordcount>
					<!--- taxonomy get labels--->
					<cfset lcl.taxobj = createObject("component", "modules.taxonomies.models.taxonomies").init(requestObject)>
					<cfset lcl.taxobj.loadbyid(lcl.lastadded.productid)>
					<cfif lcl.taxobj.hastermid("product_categories")>
						<cflocation url="/#lcl.taxobj.getFirstTermItemName('product_categories')#/catalog" addtoken="false">
					</cfif>
				</cfif>
				<cfset session.user.setflash("We could not determine where you wish to continue shopping")>
				<cflocation url="/cart/" addtoken="false">
			</cfcase>
			
			<cfcase value="checkout">
				<cfset lcl.ci = lcl.cartItemsObj.getCartItems(reload=1)>

				<cfif structisempty(lcl.ci)>
					<cfset session.user.setflash("You must have at least one item in your cart to check out.")>
					<cflocation url="/cart/" addtoken="false">
				</cfif>
				
				<cfset lcl.options = lcl.cartObj.checkoutorder()>
				<cfset lcl.uo = requestObject.getUserObject()>
				<cfif NOT lcl.uo.isLoggedIn()>
					<cfset lcl.uo.setFlash("You must have an account to continue.  Either login or create one to complete the transaction")>
					<cflocation url="/user/create/?relocate=#lcl.options[1].page#" addtoken="false">
				</cfif>
				
				<cflocation url="#lcl.options[1].page#" addtoken="false">
			</cfcase>
			
			<cfdefaultcase>
				<cflocation url="/cart" addtoken="false">			
			</cfdefaultcase>
		</cfswitch>

	</cffunction>
</cfcomponent>