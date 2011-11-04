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
	
	<cffunction name="calculatePackages">
		<cfset var lcl = structnew()>
		
		<!--- <cfset lcl.cartItems = variables.cartObject.getCartItemsObj().getCartItems()>
		<cfset lcl.prodObj = createObject("modules.productCatalog.models.product").init(requestObject)>
		<cfset lcl.weight = 0> --->
	
		<!--- get the items --->
		<cfquery name="lcl.itemsincart" datasource="#requestObject.getVar("dsn")#">
			SELECT 	ci.quantity,
					p.sizeDescription, p.unitsperpack, p.unitspercase,
					pp.type, pp.price, pp.price_member, pp.price_sale, pp.productid
			FROM cartItems ci
			INNER JOIN productPrices pp ON pp.id = ci.productPriceItemId
			INNER JOIN products p ON pp.productid = p.id
			WHERE ci.cartid = <cfqueryparam value="#variables.cartObject.getCartId()#" cfsqltype="cf_sql_varchar">
		</cfquery>

		<!--- prefab the quantity vars --->
		<cfset lcl.itemgroups = structnew()>
		<!--- <cfset lcl.itemgroups["1.5L"] = 0>
		<cfset lcl.itemgroups["750ml"] = 0> --->
		
		<!--- this loop builds an array of all the individucal bottles, their size and id  --->
		<cfloop query="lcl.itemsincart">
			<cfset lcl.thisitemsize = lcl.itemsincart.sizedescription>
			<!--- <cfif listfindnocase("750ml,1.5L", lcl.thisitemsize)> --->
				<!--- make new size container if not in existence --->
				<cfif NOT structkeyexists(lcl.itemgroups, lcl.thisitemsize)>
					<cfset lcl.itemgroups[lcl.thisitemsize] = arraynew(1)>
				</cfif>
				<!--- populate size container --->
				<cfif listfindnocase("pack,case", lcl.itemsincart.type)>
					<cfloop from="1" to="#lcl.itemsincart.quantity * lcl.itemsincart["unitsper" & lcl.itemsincart.type][lcl.itemsincart.currentrow]#" index="lcl.i">
						<cfset lcl.item = structnew()>
						<cfset lcl.item.itemid = productid>
						<cfset lcl.item.value = lcl.itemsincart.price / lcl.itemsincart["unitsper" & lcl.itemsincart.type][lcl.itemsincart.currentrow]>
						<cfset arrayappend(lcl.itemgroups[lcl.thisitemsize], lcl.item)>
					</cfloop>
					<!--- <cfset lcl.itemgroups[lcl.thisitemsize] = lcl.itemgroups[lcl.thisitemsize] + lcl.itemsincart.quantity * lcl.itemsincart["unitsper" & lcl.itemsincart.type][lcl.itemsincart.currentrow]> --->
				<cfelse>
					<cfloop from="1" to="#lcl.itemsincart.quantity#" index="lcl.i">
						<cfset lcl.item = structnew()>
						<cfset lcl.item.itemid = productid>
						<cfset lcl.item.value = lcl.itemsincart.price>
						<cfset arrayappend(lcl.itemgroups[lcl.thisitemsize], lcl.item)>
					</cfloop>
					<!--- <cfset lcl.itemgroups[lcl.thisitemsize] = lcl.itemgroups[lcl.thisitemsize] + lcl.itemsincart.quantity> --->
				</cfif>
			
			<!--- </cfif> --->
		</cfloop>

		<!---<cfdump var=#lcl.itemgroups#>--->
	
		<!--- handle the 750s first --->
		<!--- setup the box packaging structure --->
		<!--- <cfset lcl.boxes = arraynew(1)>
		<cfset lcl.temp = structnew()>
		<cfset lcl.temp.holds = 12>
		<cfset lcl.temp.price = 9.99>
		<cfset arrayappend(lcl.boxes,lcl.temp)>
		
		<cfset lcl.temp = structnew()>
		<cfset lcl.temp.holds = 6>
		<cfset lcl.temp.price = 9.99>
		<cfset arrayappend(lcl.boxes,lcl.temp)>
		
		<cfset lcl.temp = structnew()>
		<cfset lcl.temp.holds = 3>
		<cfset lcl.temp.price = 9.99>
		<cfset arrayappend(lcl.boxes,lcl.temp)>
		
		<cfset lcl.temp = structnew()>
		<cfset lcl.temp.holds = 2>
		<cfset lcl.temp.price = 9.99>
		<cfset arrayappend(lcl.boxes,lcl.temp)>
		
		<cfset lcl.temp = structnew()>
		<cfset lcl.temp.holds = 1>
		<cfset lcl.temp.price = 9.99>
		<cfset arrayappend(lcl.boxes,lcl.temp)> --->
		<cfset lcl.boxes = listtoarray("1,2,3,6,12")>
		
		<!--- this loop subtracts units from lcl.itemgroups and adds appropriate packaging units to lcl.packages --->
		<cfset lcl.packages = arraynew(1)>
		<!---<cfoutput>--->
		<cfloop collection="#lcl.itemgroups#" item="lcl.itemgroup">
			<!---<p>Processing #lcl.itemgroup#</p>--->
			<cfloop condition="arraylen(lcl.itemgroups[lcl.itemgroup]) GT 0">
				<!---<p>Still #arraylen(lcl.itemgroups[lcl.itemgroup])# bottles remaining</p>--->
				<cfset lcl.bottlesremaining = arraylen(lcl.itemgroups[lcl.itemgroup])>
				<!--- this loop determines the package to use --->
				<cfloop from="1" to="#arraylen(lcl.boxes)#" index="lcl.boxidx">
					<cfset lcl.useidx = lcl.boxidx>
					<cfset lcl.boxcancontain = lcl.boxes[lcl.useidx]>
					<cfset lcl.bottlesinpackage = lcl.boxcancontain>
					<cfif lcl.boxcancontain GTE lcl.bottlesremaining>
						<cfif lcl.boxcancontain GT lcl.bottlesremaining>
							<cfset lcl.bottlesinpackage = lcl.bottlesremaining>
						</cfif>
						<cfbreak>
					</cfif>
				</cfloop>

				<!---<p>Using #lcl.boxidx#</p>--->
				<cfset lcl.package = structnew()>
				<cfset lcl.package.qty = lcl.bottlesinpackage>
				<cfset lcl.package.weight = lcl.package.qty * determineItemWeight(lcl.itemgroup)>
				<cfset lcl.package.value = 0>
				<cfset lcl.package.items = "">
				<cfset lcl.package.packagingcost = 9.99>
				<cfset lcl.package.adultsignaturerequired = 1>
				<cfloop from="1" to="#lcl.bottlesinpackage#" index="lcl.i">
					<!---<p>Adding one item to box</p>--->
					<cfset lcl.package.value = lcl.package.value + lcl.itemgroups[lcl.itemgroup][1].value>
					<cfset lcl.package.items = listappend(lcl.package.items, lcl.itemgroups[lcl.itemgroup][1].itemid)>
					<cfset arraydeleteat(lcl.itemgroups[lcl.itemgroup],1)>
				</cfloop>
				<!---<p>Adding package to group</p>--->
				<cfset arrayappend(lcl.packages, lcl.package)>
			</cfloop>
		</cfloop>
		<!---</cfoutput>
		<cfdump var=#lcl.packages#><cfabort>--->
		<cfreturn lcl.packages>
	</cffunction>
	
	<cffunction name="determineitemweight">
		<cfargument name="size_description" required="true">
		<cfset var lcl = structnew()>
		<cfset lcl.size_description = arguments.size_description>
		<cfif refindnocase("oz$", lcl.size_description)>
			<cfset lcl.oz = mid(lcl.size_description, 1, len(lcl.size_description)-2)>
			<cfset lcl.unitweight = lcl.oz * .15>
		<cfelseif refindnocase("ml$", lcl.size_description)>
			<cfset lcl.ml = mid(lcl.size_description, 1, len(lcl.size_description)-2)>
			<cfset lcl.unitweight = lcl.ml * .0054>
		<cfelseif refindnocase("gal$", lcl.size_description)>
			<cfset lcl.gal = mid(lcl.size_description, 1, len(lcl.size_description)-3)>
			<!--- e.g. 1/2gal --->
			<cfif find("/", lcl.gal) AND len(lcl.gal) gte 3>
				<cfset lcl.gal = Evaluate(lcl.gal)>
			</cfif>
			<cfif IsNumeric(lcl.gal)>
				<cfset lcl.unitweight = lcl.gal * 15>
			<cfelse>
				<cfset lcl.unitweight = 15>
			</cfif>
		<cfelseif refindnocase("bl$", lcl.size_description)>
			<cfset lcl.barrel = mid(lcl.size_description, 1, len(lcl.size_description)-2)>
			<!--- e.g. 1/2bl --->
			<cfif find("/", lcl.barrel) AND len(lcl.barrel) gte 3>
				<cfset lcl.barrel = Evaluate(lcl.barrel)>
			</cfif>
			<cfif IsNumeric(lcl.barrel)>
				<cfset lcl.unitweight = lcl.barrel * 100>
			<cfelse>
				<cfset lcl.unitweight = 100>
			</cfif>
		<cfelseif refindnocase("l$", lcl.size_description)>
			<cfset lcl.liters = mid(lcl.size_description, 1, len(lcl.size_description)-1)>
			<cfset lcl.unitweight = lcl.liters * 5.5>
		<cfelseif lcl.size_description EQ "keg">
			<cfset lcl.unitweight = 100>
		<cfelseif lcl.size_description EQ "qt">
			<cfset lcl.unitweight = 5>
		<cfelse>
			<cfset lcl.unitweight = 4>
		</cfif>
		<cfreturn lcl.unitweight>
	</cffunction>
</cfcomponent>