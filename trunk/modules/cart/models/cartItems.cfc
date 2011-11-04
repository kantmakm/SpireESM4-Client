<cfcomponent name="products" extends="resources.abstractmodel">

	<cffunction name="init">
		<cfargument name="requestObject" required="true">
		<cfset variables.requestObject = arguments.requestObject>
		<cfset startorm("cartitems")>
		
		<cfreturn this>
	</cffunction>
	
	<cffunction name="setCartObj">
		<cfargument name="cartObj">
		<cfset variables.cartObj = arguments.cartObj>
	</cffunction>
	
    <cffunction name="clearCartItems">
        <cfset var lcl = structnew()>
        <cfset variables.items = structnew()>
        <cfquery name="lcl.clearcartitems" datasource="#requestObject.getVar("dsn")#">
			DELETE 
			FROM cartItems 
			WHERE 
			cartid = <cfqueryparam value="#variables.cartObj.getCartId()#" cfsqltype="cf_sql_varchar">
		</cfquery>
    </cffunction>
    
	<cffunction name="loadCartItems">

		<cfset var items = structnew()>
		<cfset var tmp = "">
		<cfset var itm = "">
				
		<cfquery name="cartitems" datasource="#requestObject.getVar("dsn")#">
			SELECT 	ci.id cartitemid, ci.quantity, ci.productPriceItemId priceId, 
				pp.price, pp.price_member, pp.price_sale, pp.type,
				p.title, p.urlname, p.id productid, ti.safename, tr.relationtype, ti.taxonomyid
			FROM cartItems ci
			INNER JOIN productPrices pp ON ci.productPriceItemId = pp.id
			INNER JOIN products p ON p.id = pp.productid AND p.deleted = 0
			INNER JOIN taxonomyrelations tr ON p.id = tr.relationid AND tr.relationtype = 'products'
			INNER JOIN taxonomyitems ti ON ti.id = tr.taxonomyitemid AND ti.taxonomyid = 'product_categories'
			WHERE 
				ci.cartid = <cfqueryparam value="#variables.cartObj.getCartId()#" cfsqltype="cf_sql_varchar">
		</cfquery>
		
		<cfloop query="cartItems">
			<cfset tmp = structnew()>
			<cfloop list="#cartitems.columnlist#" index="itm">
				<cfset tmp[itm] = cartitems[itm][cartitems.currentrow]>
			</cfloop>
			<cfset tmp.producturl = "/#safename#/product/#urlname#">
			<cfset tmp.price_total = cartitems['quantity'][cartitems.currentrow] * cartitems['price'][cartitems.currentrow]>
			<cfset items[PriceId] = tmp>
		</cfloop>
		
		<cfset variables.items = items>

	</cffunction>
	
	<cffunction name="getCartItems">
		<cfargument name="reload" default="false">
	
		<cfif NOT structkeyexists(variables, "items") OR arguments.reload>
			<cfset loadCartItems()>
		</cfif>

		<cfreturn requestObject.notifyObservers("cart.cartItems", duplicate(variables.items))>
	</cffunction>
	
	<cffunction name="addCartItem">
		<cfargument name="priceid" required="true">
		<cfargument name="quantity" required="true">
		<cfset this.clear()>
		<cfif variables.hasItem(priceid)>
			<cfset this.setId(variables.items[priceid]['priceid'])>
			<cfset this.setQuantity(quantity + variables.items[priceid]['quantity'])>
			<cfset this.save()>
		<cfelse>
			<cfset this.setProductPriceItemId(priceid)>
			<cfset this.setQuantity(quantity)>
			<cfset this.setCartId(variables.cartObj.getCartId())>
			<cfset this.save()>
		</cfif>

	</cffunction>
	
	<cffunction name="hasItem">
		<cfargument name="itmid" required="true">
		<cfreturn structkeyexists(variables.items, itmid)>
	</cffunction>
	
	<cffunction name="getlastitemadded">
		<cfset var cartitems = "">
		<cfquery name="cartitems" datasource="#requestObject.getVar("dsn")#">
			SELECT TOP 1 ci.id cartitemid, ci.quantity, ci.productPriceItemId priceId, 
				pp.price, pp.price_member, pp.price_sale, pp.type,
				p.title, p.urlname, p.id productid
			FROM cartItems ci
			INNER JOIN productPrices pp ON ci.productPriceItemId = pp.id
			INNER JOIN products p ON p.id = pp.productid
			WHERE 
				ci.cartid = <cfqueryparam value="#variables.cartObj.getCartId()#" cfsqltype="cf_sql_varchar">
			ORDER BY ci.modified DESC
		</cfquery>
		
		<cfreturn cartitems>
	</cffunction>
		
</cfcomponent>
