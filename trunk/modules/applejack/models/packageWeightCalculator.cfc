<cfcomponent name="ajproductweightcalculator">
	
	<cffunction name="init">
		<cfargument name="requestObject" required="true">
		<cfset variables.requestObject = arguments.requestObject>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="setCartObj">
		<cfargument name="cartObj" required="true">
		<cfset variables.cartObject = arguments.cartObj>
	</cffunction>
	
	<cffunction name="determineWeight">
		<cfset var lcl = structnew()>
		
		<cfset lcl.cartItems = variables.cartObject.getCartItemsObj().getCartItems()>
		<cfset lcl.prodObj = createObject("modules.productCatalog.models.product").init(requestObject)>
		<cfset lcl.weight = 0>
		
		<cfloop collection="#lcl.cartItems#" item="lcl.itm">
			<cfset lcl.item = lcl.cartItems[lcl.itm]>
			<cfset lcl.prodObj.load(lcl.item.productId)>
			<cfset lcl.quantity = lcl.item.quantity>
			<cfset lcl.size_description = lcl.prodObj.getSizeDescription()>

			<cfif refindnocase("oz$", lcl.size_description)>
				<cfset lcl.oz = mid(lcl.size_description, 1, len(lcl.size_description)-2)>
				<cfset lcl.unitweight = lcl.oz * .25>
			<cfelseif refindnocase("ml$", lcl.size_description)>
				<cfset lcl.ml = mid(lcl.size_description, 1, len(lcl.size_description)-2)>
				<cfset lcl.unitweight = lcl.ml * .0054>
			<cfelseif refindnocase("l$", lcl.size_description)>
				<cfset lcl.liters = mid(lcl.size_description, 1, len(lcl.size_description)-1)>
				<cfset lcl.unitweight = lcl.liters * 5.5>
			<cfelseif lcl.size_description EQ "keg">
				<cfset lcl.unitweight = 100>
			<cfelseif lcl.size_description EQ "gal">
				<cfset lcl.unitweight = 15>
			<cfelseif lcl.size_description EQ "qt">
				<cfset lcl.unitweight = 5>
			<cfelse>
				<cfset lcl.unitweight = 4>
			</cfif>
			
			<cfif lcl.item.type EQ "unit">
				<cfset lcl.unitsperitem = 1>
			<cfelseif lcl.item.type EQ "pack">
				<cfset lcl.unitsperitem = lcl.prodObj.getUnitsPerPack()>
			<cfelseif lcl.item.type EQ "case">
				<cfset lcl.unitsperitem = lcl.prodObj.getUnitsPerCase()>
			</cfif>
			
			<cfset lcl.weight = lcl.weight + (lcl.quantity * lcl.unitsperitem * lcl.unitweight)>
		</cfloop>
		<!---
		 4lbs = 1 bottles x 750ml x
  8lbs = 2 bottles x 750ml x
12lbs = 3 bottles x 750ml x
16lbs = 4 bottles x 750ml x
20lbs = 5 bottles x 750ml x
24lbs = 6 bottles x 750ml x
28lbs = 7 bottles x 750ml x
32lbs = 8 bottles x 750ml x
36lbs = 9 bottles x 750ml x
40lbs =10 bottles x 750ml x
44lbs =11 bottles x 750ml x
48lbs =12 bottles x 750ml x
52lbs =13 bottles x 750ml x
56lbs =14 bottles x 750ml x
60lbs =15 bottles x 750ml x
 
5.5lbs = 1 bottles x 1000ml x
11lbs = 2 bottles x 1000ml x
16.5lbs = 3 bottles x 1000ml x
22lbs = 4 bottles x 1000ml x
27.5lbs = 5 bottles x 1000ml x
33lbs = 6 bottles x 1000ml x
38.5lbs = 7 bottles x 1000ml x
44lbs = 8 bottles x 1000ml x
49.5lbs = 9 bottles x 1000ml x
55lbs = 10 bottles x 1000ml x
60.5lbs = 11 bottles x 1000ml x
66lbs = 12 bottles x 1000ml x
 
 
  8lbs = 1 bottles x 1500ml x
16lbs = 2 bottles x 1500ml x
24lbs = 3 bottles x 1500ml x
32lbs = 4 bottles x 1500ml x
40lbs = 5 bottles x 1500ml x
48lbs = 6 bottles x 1500ml x
 
20lbs = 1 bottles x 3000ml x
--->
		<cfreturn lcl.weight>
	</cffunction>
</cfcomponent>