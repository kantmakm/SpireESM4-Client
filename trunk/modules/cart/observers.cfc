<cfcomponent name="ajobservers" extends="resources.abstractObserver">

	<!--- 
		this observer checks on login to see if user has created a cart. 
		If so it assigns it to the users id instead of random cookie. 
	--->
	<cffunction name="form_submission_users_loginform">
		<cfargument name="observed" required="true">
		<cfset var lcl = structnew()>

		<cfif requestObject.isFormUrlVarSet("cartid")>
			<cfset lcl.uo = requestObject.getUserObject()>
			<cfset lcl.uid = lcl.uo.getUserId()>
			<cfset lcl.cartObj = createObject("component", "modules.cart.models.cart").init(variables.requestObject)>
			<cfset lcl.cartObj.load(requestObject.getFormUrlVar("cartid"))>
			<cfset lcl.cartItemsObj = lcl.cartObj.getCartItemsObj()>
			<cfset lcl.cartItemsList = lcl.cartItemsObj.getCartItems()>

			<cfif NOT structisempty(lcl.cartItemsList)>
				<!--- determine if there is an existing user cart record assigned to logged in user --->
				<cfquery name="iscartrecord" datasource="#requestObject.getVar("dsn")#">
					SELECT COUNT(*) cnt
					FROM cart 
					WHERE cartid = <cfqueryparam value="#lcl.uid#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfif iscartrecord.cnt>
					<cfquery name="updatecartrecord" datasource="#requestObject.getVar("dsn")#">
						UPDATE cart SET cartid = <cfqueryparam value="#lcl.uid#" cfsqltype="cf_sql_varchar">
						WHERE cartid = <cfqueryparam value="#requestObject.isFormUrlVarSet("cartid")#" cfsqltype="cf_sql_varchar">
					</cfquery>
				</cfif>
				<!--- move the cart items to that user --->
				<cfquery name="updatecartrecord" datasource="#requestObject.getVar("dsn")#" result="m">
					UPDATE cartItems SET cartid = <cfqueryparam value="#lcl.uid#" cfsqltype="cf_sql_varchar">
					WHERE cartid = <cfqueryparam value="#requestObject.getFormUrlVar("cartid")#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfset lcl.uo.setFlash("Your cart items have been transferred to your user account.")>
			</cfif>
		</cfif>
		<cfreturn observed>
	</cffunction>
	
	<!--- 
		this observer checks on registration to see if user has created a cart. 
		If so it assigns it to the users id instead of random cookie. 
	--->
	<cffunction name="form_submissioncomplete_users_newclientform">
		<cfargument name="observed" required="true">

		<cfreturn form_submission_users_loginform(observed)>
	</cffunction>	
	
	<cffunction name="form_validation_cart_billingdeliveryinfo">
		<cfargument name="observed" required="true">		
		<cfreturn checkIfCartEmpty(observed)>
	</cffunction>	
	
	<cffunction name="form_validation_cart_shippingpaymentinfo">
		<cfargument name="observed" required="true">	
		<cfreturn checkIfCartEmpty(observed)>
	</cffunction>
	
	<cffunction name="checkIfCartEmpty">
		<cfargument name="observed" required="true">
		<cfset var lcl = structnew()>
		<cfset lcl.jsonobj = createObject("component","utilities.json").init(requestObject)>
		
		<!--- cartObj --->
		<cfset lcl.cartObj = createObject("component","modules.cart.models.cart").init(requestObject)>
		<cfset lcl.cartObj.load()>
		<cfset lcl.cartItemsObj = lcl.cartObj.getCartItemsObj()>		
		<cfset lcl.ci = lcl.cartItemsObj.getCartItems()>

		<cfif structisempty(lcl.ci)>
			<!--- <cfset session.user.setflash("You must have at least one item in your cart to check out.")>
			<cflocation url="/cart/" addtoken="false"> --->
			
			<cfset observed.addError("cart", 'You must have at least one item in your <strong><a href="/cart/">Shopping Cart</a></strong> to check out.')>
		</cfif>
		
		<cfreturn observed>
	</cffunction>
</cfcomponent>