<cfcomponent name="ajobservers"  extends="resources.abstractObserver">

    <cffunction name="table_myorders">
    	<cfargument name="observed">
        <!--- add new data to query --->
	
        <cfset lcl = structnew()>
        <cfset lcl.returnQuery = observed.getData()>
        <cfset lcl.advantage = arraynew(1)>
        <cfset lcl.retail  = arraynew(1)>
		
        <cfloop query="lcl.returnQuery">
        	<cfif left(lcl.returnquery.moreJSON,1) EQ "{"> <!--- valid json string --->
				<cfset lcl.deJSON = deserializeJSON(lcl.returnquery.moreJSON)>
                <cfparam name="lcl.deJSON.ADVANTAGESAVINGS" default="0">
                <cfparam name="lcl.deJSON.RETAILPRICE" default="0">
                <cfset arrayappend(lcl.advantage,lcl.deJSON.ADVANTAGESAVINGS)>
                <cfset arrayappend(lcl.retail,lcl.deJSON.RETAILPRICE)>
            <cfelse>
            	<cfset arrayappend(lcl.advantage,0)>
                <cfset arrayappend(lcl.retail,0)>
            </cfif>
            
        </cfloop>
        <cfset queryaddcolumn(lcl.returnQuery,"AdvantageSavings",lcl.advantage)>
        <cfset queryaddcolumn(lcl.returnQuery,"RetailPrice",lcl.retail)>
        
        <!--- add new columns to output --->
        <cfset lcl.cols = observed.getColumns()>

        <cfset lcl.formats = observed.getFormats()>
        <cfset lcl.formats.advantagesavings = "money">
        <cfset lcl.formats.retailprice = "money">
        <!--- add new line and order status to end of order number --->
        <cfset lcl.cols[3].format = lcl.cols[3].format & "<br/><i>([orderstatus])</i>">
		<!--- remove orderstatus and quantity fields --->
        <cfset arraydeleteat(lcl.cols,2)>
      <!--->  <cfset arraydeleteat(lcl.cols,3)> 
		<!--- add our 2 new fields in --->
	
	
		<cfset tmp = structnew()>
        <cfset tmp.FIELD = "AdvantageSavings">
        <cfset tmp.TITLE = "Advantage Card Savings">
        <cfset tmp.attributes.align="center">
        <cfset tmp.tblformats = "money">
        <cfset arrayappend(lcl.cols,tmp)>
        <cfset tmp = structnew()>
        <cfset tmp.FIELD = "RetailPrice">
        <cfset tmp.TITLE = "Retail Price">
        <cfset tmp.attributes.align="center">
        <cfset arrayinsertat(lcl.cols,3,tmp)>--->
        <cfset observed.setColumns(lcl.cols)>

        <cfreturn observed>
    </cffunction>
    
    <cffunction name="orders_neworder">
    	<cfargument name="observed" required="yes">
        
		<cfset var lcl = structnew()>
        
        <cfset lcl.uo = requestObject.getUserObject()>
		<cfset lcl.uid = lcl.uo.getUserId()>
        <cfset lcl.cartObj = createObject("component", "modules.cart.models.cart").init(variables.requestObject)>
        <cfset lcl.cartObj.load(lcl.uid)>
        <cfset lcl.cartItemsObj = lcl.cartObj.getCartItemsObj()>
        <cfset lcl.cartItemsList = lcl.cartItemsObj.getCartItems()>
        		
        <cfset lcl.retailPrice = 0>
        <cfset lcl.advantagePrice = 0>
        <cfset lcl.totalSavings = 0>

        <cfloop collection="#lcl.cartItemsList#" item="items">
            	<cfset lcl.retailPrice = lcl.retailPrice + (lcl.cartItemsList[items].quantity * lcl.cartItemsList[items].price)>
                <cfset lcl.advantagePrice = lcl.advantagePrice + (lcl.cartItemsList[items].quantity * lcl.cartItemsList[items].price_member)>
        </cfloop>
        
        <cfset lcl.totalSavings = lcl.retailPrice - lcl.advantagePrice>

		<cfset lcl.toJSON = structnew()>
        <cfset lcl.toJSON.retailPrice = lcl.retailPrice>
        <cfset lcl.toJSON.advantageSavings = lcl.totalSavings>
        <cfset observed.setmoreJSON(serializeJSON(lcl.toJSON))>
        <cfset observed.save()>

       <cfreturn observed >
    </cffunction>
    
	<cffunction name="cart_cartLineItems_cart">
		<cfargument name="observed" required="true">
		
		<cfset var userObj = requestObject.getUserObject()>
		<cfset var items = observed.cartObj.getCartItemsObj().getCartItems()>
		<cfset var lcl = structnew()>
		
		<cfif structisempty(items)>
			<cfreturn observed>
		</cfif>

		<!--- calculate savings --->
		<cfset lcl.salesavings = 0>
		<cfset lcl.membersavings = 0>
		<cfset lcl.membertotal = 0>

		<cfloop collection="#items#" item="item">
			<cfset lcl.thisitem = items[item]>
			
			<!--- sale --->
			<cfif lcl.thisitem.price_sale NEQ 0>
				<cfset lcl.salesavings = lcl.salesavings + lcl.thisitem.quantity * (lcl.thisitem.base_price - lcl.thisitem.price_sale)>
			</cfif>
			
			<!--- member --->
			<cfif lcl.thisitem.price_member NEQ 0>
				<cfif lcl.thisitem.price_sale NEQ 0>
					<cfset lcl.membersavings = lcl.membersavings + lcl.thisitem.quantity * (lcl.thisitem.price_sale - lcl.thisitem.price_member)>
				<cfelse>
					<cfset lcl.membersavings = lcl.membersavings + lcl.thisitem.quantity * (lcl.thisitem.base_price - lcl.thisitem.price_member)>
				</cfif>
			</cfif>
			
			<!--- memberprice --->
			<cfif lcl.thisitem.price_member NEQ 0>
				<cfset lcl.membertotal = lcl.membertotal + lcl.thisitem.quantity * lcl.thisitem.price_member>
			<cfelseif lcl.thisitem.price_sale NEQ 0>
				<cfset lcl.membertotal = lcl.membertotal + lcl.thisitem.quantity * lcl.thisitem.price_sale>
			<cfelse>
				<cfset lcl.membertotal = lcl.membertotal + lcl.thisitem.quantity * lcl.thisitem.base_price>
			</cfif>
		</cfloop>
		
		<cfset lcl.s = structnew()>
        <cfset lcl.s.label = "Total Sale Savings">
        <cfset lcl.s.sortkey = 110>
        <cfset lcl.s.action = "none">
        <cfset lcl.s.total = lcl.salesavings>
        <cfif lcl.salesavings gt 0>    
            <cfset observed.lineitems.salesavings = lcl.s>
		</cfif>
       
		<cfif NOT userObj.isloggedin()>
           	<cfif lcl.membersavings gt 0> 
				<cfset lcl.s2 = structnew()>
	            <cfset lcl.s2.label = "With an <a href=""/Advantage-Card"">Advantage Card</a> your total would be">
	            <cfset lcl.s2.sortkey = 121>
	            <cfset lcl.s2.action = "none">
	            <cfset lcl.s2.total = lcl.membertotal>
                <cfset observed.lineitems.membersavings = lcl.s2>
            </cfif>
            <!--- <cfif lcl.membersavings gt 0>
	            <cfset lcl.s3 = structnew()>
	            <cfset lcl.s3.label = "An Additional Savings of">
	            <cfset lcl.s3.sortkey = 130>
	            <cfset lcl.s3.action = "none">
	            <cfset lcl.s3.total = lcl.membersavings>
                <cfset observed.lineitems.membersavingstotal = lcl.s3>
            </cfif> --->
        <cfelse>
			<cfif abs(lcl.membersavings) gt 0>
	            <cfset lcl.s2 = structnew()>
	            <cfset lcl.s2.label = "Your Advantage Card Saved you">
	            <cfset lcl.s2.sortkey = 120>
	            <cfset lcl.s2.action = "none">
	            <cfset lcl.s2.total = lcl.membersavings>
            	<cfset observed.lineitems.membersavings = lcl.s2>
            </cfif>
        </cfif>
    
		<cfreturn observed>
	</cffunction>
	
	<cffunction name="cart_cartLineItems_shippingpayment">
		<cfargument name="observed" required="true">
		
		<cfset var userObj = requestObject.getUserObject()>
		<cfset var items = observed.cartObj.getCartItemsObj().getCartItems()>
		<cfset var lcl = structnew()>
		
		<cfif structisempty(items)>
			<cfreturn observed>
		</cfif>

		<!--- calculate savings --->
		<cfset lcl.salesavings = 0>
		<cfset lcl.membersavings = 0>
		
		<cfloop collection="#items#" item="item">
			<cfset lcl.thisitem = items[item]>
			<!--- sale --->
			<cfif lcl.thisitem.price_sale NEQ 0>
				<cfset lcl.salesavings = lcl.salesavings + lcl.thisitem.quantity * (lcl.thisitem.base_price - lcl.thisitem.price_sale)>
			</cfif>
			<!--- member --->
			<cfif lcl.thisitem.price_member NEQ 0>
				<cfif lcl.thisitem.price_sale NEQ 0>
					<cfset lcl.membersavings = lcl.membersavings + lcl.thisitem.quantity * (lcl.thisitem.price_sale - lcl.thisitem.price_member)>
				<cfelse>
					<cfset lcl.membersavings = lcl.membersavings + lcl.thisitem.quantity * (lcl.thisitem.base_price - lcl.thisitem.price_member)>
				</cfif>
			</cfif>
		</cfloop>
		
		<cfif lcl.salesavings gt 0> 
			<cfset lcl.s = structnew()>
			<cfset lcl.s.label = "Sale Price Savings on this Order">
			<cfset lcl.s.sortkey = 110>
			<cfset lcl.s.action = "none">
			<cfset lcl.s.total = lcl.salesavings>
			<cfset observed.lineitems.salesavings = lcl.s>
		</cfif>
		
		<cfif lcl.membersavings gt 0> 
			<cfset lcl.s3 = structnew()>
			<cfset lcl.s3.label = "Advantage Price Savings on this Order">
			<cfset lcl.s3.sortkey = 150>
			<cfset lcl.s3.action = "none">
			<cfset lcl.s3.total = lcl.membersavings>
			<cfset lcl.s2.label = "">
			<cfset observed.lineitems.membersavings = lcl.s3>
		</cfif>
		
		<cfif (lcl.membersavings + lcl.salesavings) gt 0> 
			<cfset lcl.s3 = structnew()>
			<cfset lcl.s3.label = "TOTAL SAVINGS">
			<cfset lcl.s3.sortkey = 150>
			<cfset lcl.s3.action = "none">
			<cfset lcl.s3.total = lcl.membersavings + lcl.salesavings>
			<cfset lcl.s2.label = "">
			<cfset observed.lineitems.totalsavings = lcl.s3>
		</cfif>
		<!--- <cfdump var=#items#><cfabort>
		<cfloop collection="#items#" item="item">
			
		</cfloop> --->
		
		<cfreturn observed>
	</cffunction>
	
	<cffunction name="cart_cartitems">
		<cfargument name="observed" required="true">
		
		<cfset var lcl = structnew()>
		<cfset var userloggedin = requestObject.getUserObject().isloggedin()>

		<cfloop collection="#observed#" item="lcl.idx">
			<!--- manage applejack special pricing --->
			<cfset observed[lcl.idx].base_price = observed[lcl.idx].price>
			<cfif userloggedin AND observed[lcl.idx].price_member NEQ "" AND observed[lcl.idx].price_member NEQ 0>
				<cfset observed[lcl.idx].price = observed[lcl.idx].price_member>
			<cfelseif observed[lcl.idx].price_sale NEQ "" AND observed[lcl.idx].price_sale NEQ 0>
				<cfset observed[lcl.idx].price = observed[lcl.idx].price_SALE>
			<cfelse>
				<cfset observed[lcl.idx].price = observed[lcl.idx].price>
			</cfif>
			<cfset observed[lcl.idx].price_total = observed[lcl.idx].price * observed[lcl.idx].quantity>
			<!--- manage applejack title preferences --->
			<cfquery name="lcl.info" datasource="#requestObject.getVar("dsn")#">
				SELECT [sizeDescription] ,[unitsPerCase],[unitsPerPack] FROM products WHERE id = <cfqueryparam value="#observed[lcl.idx].productid#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfif listfind("case,pack", observed[lcl.idx].type)>
				<cfset observed[lcl.idx].title =  observed[lcl.idx].title & " (" & observed[lcl.idx].type & " of " & lcl.info['unitsper' & observed[lcl.idx].type][1] & ")">
			<cfelse>
				<cfset observed[lcl.idx].title =  observed[lcl.idx].title & " (unit)">
			</cfif>
			<cfset observed[lcl.idx].title =  observed[lcl.idx].title & " (" & lcl.info.sizeDescription & ")">
		</cfloop>

		<cfreturn observed>		
	</cffunction>
		
	<cffunction name="table_cartview">
		<cfargument name="observed" required="true">
	
		<cfset var newcol = structnew()>
		<cfset var cols = observed.getColumns()>
		<cfset var data = observed.getData()>
		<cfset var lcl = structnew()>
		<cfset var userloggedin = requestObject.getUserObject().isloggedin()>

		<cfset var lcl.formats = observed.getFormats()>
        
		<cfset lcl.formats['price_member'] = 'money,wrapspan,blankonzero'>

		<cfset observed.setFormats(lcl.formats)>

		<cfset newcol = structnew()>
		<cfset newcol.title = "Advantage Card Price">
		<cfset newcol.field = "price_member">
		<cfset newcol.attributes = structnew()>
		<cfset newcol.attributes.align = "right">
		
		<cfset arrayinsertat(cols, 3, newcol)>

		<cfset cols[4].title = 'Your Price'>
		<cfset cols[4].field = 'price'>

		<cfset observed.setColumns(cols)>
		<cfreturn observed>
	</cffunction>
	
	<cffunction name="table_cartlist_orderconfirmation">
		<cfargument name="observed" required="true">
		<!--- 
			we receive the table object which has the data 
			and the columns of the list for us to modify 
		--->
		<cfset var newcol = structnew()>
		<cfset var cols = observed.getColumns()>
		<cfset var data = observed.getData()>
		<cfset var lcl = structnew()>
		<cfset var userloggedin = requestObject.getUserObject().isloggedin()>

		<!--- <cfset cols[4].title = 'Your Price'>
		<cfset cols[4].field = 'your_price'>
		 --->
		<cfset arraydeleteat(cols, 3)>
		
		<cfset observed.setColumns(cols)>
		<cfreturn observed>
	</cffunction>
	
	<cfset this.executeorder_shipping_options = 4>
	<cffunction name="shipping_options">
		<cfargument name="observed" required="true">
		<cfset var s = structnew()>
		<cfset s.sortorder = 5>
		<cfset s.obj = createObject("component","modules.applejack.models.shipping").init(requestObject)>
		<cfset observed.applejackshipping = s>
		<cfreturn observed>
	</cffunction>
	
	<cffunction name="isCartShippingModule">
		<cfargument name="observed" required="true">
		<cfset var s = structnew()>
		<cfset s.name = "Applejack Shipping">
		<cfset s.path = "modules.applejack.models.shipping">
		<cfset arrayappend(arguments.observed, s)>
		<cfreturn arguments.observed>
	</cffunction>
	
	<cffunction name="moduleoutput_htmlcontent">
		<cfargument name="observed" required="true">
		<!--- <cfif listfindnocase('htmlcontent', observed.module)> --->
			<cfset observed.htmlhead = observed.htmlhead & '<div class="pocntntwrap">
			'>
			<cfset observed.htmlfoot = observed.htmlfoot & '</div>
			'>
		<!--- </cfif> --->
		<cfreturn observed>
	</cffunction>
	
	<cffunction name="moduleoutput_assets">
		<cfargument name="observed" required="true">
		<!--- <cfif listfindnocase('htmlcontent', observed.module)> --->
			<cfset observed.htmlhead = observed.htmlhead & '<div class="pocntntwrap">
			'>
			<cfset observed.htmlfoot = observed.htmlfoot & '</div>
			'>
		<!--- </cfif> --->
		<cfreturn observed>
	</cffunction>
	
	<cffunction name="cart_shipping_shippingoptions">
		<cfargument name="observed" required="true">
		<cfset var lcl = structnew()>

		<cfset lcl.cartObj = observed.cartObj>
		<cfset lcl.deliveryinfo = lcl.cartObj.getDeliveryAddressInfo()>
		
		<cfif left(lcl.deliveryinfo,1) NEQ '{'>
			<cfreturn observed>
		</cfif>
		
		<cfset lcl.deliveryinfo = deserializejson(lcl.deliveryinfo)>
		<cfset lcl.zip = lcl.deliveryinfo.delivery_postalcode>
	
		<cfif lcl.zip EQ "">
			<cfreturn observed>
		</cfif>
		
		<cfset lcl.ajdelivery = createObject("component","modules.applejack.models.shipping").init(requestObject)>

		<cfif lcl.ajdelivery.canShipToZip(lcl.zip)> 	
			<cfloop from="1" to="#arraylen(observed.options)#" index="lcl.idx">
				<cfset lcl.thisoption = observed.options[lcl.idx]>
				<cfif structkeyexists(lcl.thisoption, "shippingmodule") AND findnocase("fedex", lcl.thisoption.shippingmodule)>
					<cfset arraydeleteat(observed.options, lcl.idx)>
					<cfbreak>
				</cfif>
			</cfloop>
		</cfif>

		<cfreturn observed>
	</cffunction>
	
	<cffunction name="form_make_fullsearchform">
		<cfargument name="observed" required="true">
		
		<cfset var lcl = structnew()>
		<cfset lcl.taxobj = createObject("component", "modules.taxonomies.models.taxonomyitems").init(requestObject)>
		
		<cfset lcl.div = observed.addItem("section",2)>
		<cfset lcl.div.setName("ajdiv")>
		<cfset lcl.div.setLabel("Catalog")>
		
		<cfset lcl.txt = observed.addItem("hidden")>
		<cfset lcl.txt.setName("sort")>
		<cfset lcl.txt.setDefault(requestObject.getFormUrlVar("sort",""))>
		
		<cfset lcl.txt = observed.addItem("hidden")>
		<cfset lcl.txt.setName("ipp")>
		<cfset lcl.txt.setDefault(requestObject.getFormUrlVar("ipp",""))>
		
		<cfset lcl.tbl = lcl.div.addItem("table")>
		<cfset lcl.tbl.setName("producttype")>
		
		<cfset lcl.tblrow1 = lcl.tbl.addItem("tablerow")>
		<cfset lcl.tblrow1.setName("typerow1")>
		
		<cfset lcl.tblr1c1 = lcl.tblrow1.addItem("tablecolumn")>
		<cfset lcl.tblr1c1.setName("winetd")>
		
		<cfset lcl.txt = lcl.tblr1c1.addItem("checkboxitem")>
		<cfset lcl.txt.setName('product_category')>
		<cfset lcl.txt.setLabel('Wine')>
		<cfset lcl.txt.setDefault("wine")>
		<cfset lcl.txt.setChecked(listfindnocase(requestObject.getFormUrlVar("product_category",""), 'wine'))>
		
		<cfset lcl.tblr1c2 = lcl.tblrow1.addItem("tablecolumn")>
		<cfset lcl.tblr1c2.setName("spiritstd")>
		
		<cfset lcl.txt = lcl.tblr1c2.addItem("checkboxitem")>
		<cfset lcl.txt.setName('product_category')>
		<cfset lcl.txt.setLabel('Spirits')>
		<cfset lcl.txt.setDefault("spirits")>
		<cfset lcl.txt.setChecked(listfindnocase(requestObject.getFormUrlVar("product_category",""), 'spirits'))>
		
		<cfset lcl.tblrow2 = lcl.tbl.addItem("tablerow")>
		<cfset lcl.tblrow2.setName("typerow2")>
		
		<cfset lcl.tblr2c1 = lcl.tblrow2.addItem("tablecolumn")>
		<cfset lcl.tblr2c1.setName("spiritstd")>
		
		<cfset lcl.txt = lcl.tblr2c1.addItem("checkboxitem")>
		<cfset lcl.txt.setName('product_category')>
		<cfset lcl.txt.setLabel('Beer')>
		<cfset lcl.txt.setDefault("beer")>
		<cfset lcl.txt.setChecked(listfindnocase(requestObject.getFormUrlVar("product_category",""), 'beer'))>
		
		<cfset lcl.tblr2c2 = lcl.tblrow2.addItem("tablecolumn")>
		<cfset lcl.tblr2c2.setName("liqueurstd")>
				
		<cfset lcl.txt = lcl.tblr2c2.addItem("checkboxitem")>
		<cfset lcl.txt.setName('product_category')>
		<cfset lcl.txt.setLabel('Cordials/Liqueurs')>
		<cfset lcl.txt.setDefault("cordials_liqueurs")>
		<cfset lcl.txt.setChecked(listfindnocase(requestObject.getFormUrlVar("product_category",""), 'cordials_liqueurs'))>
		
		
		<cfset lcl.txt = lcl.div.addItem("select")>
		<cfset lcl.txt.setName('price')>
		<cfset lcl.txt.setLabel('Price Range')>
		<cfset lcl.data = structnew()>
		<cfset lcl.s = structnew()>
		<cfset lcl.s.sort = "sortkey">
		<cfset lcl.data.query = lcl.taxobj.gettaxonomyitemswithrelations("price", lcl.s)>
		<cfset lcl.data.valuesfield = 'safename'>
		<cfset lcl.data.labelsfield = 'name'>
		<cfset lcl.txt.setData(lcl.data)>
		<cfset lcl.txt.firstOption("")>
		<cfset lcl.txt.setDefault(requestObject.getFormUrlVar("price",""))>
		
		
		<cfset lcl.txt = lcl.div.addItem("select")>
		<cfset lcl.txt.setName('country')>
		<cfset lcl.txt.setLabel('Country')>
		<cfset lcl.txt.firstOption("")>
		<cfset lcl.data = structnew()>
		<cfset lcl.s = structnew()>
		<cfset lcl.s.sort = "name">
		<cfset lcl.data.query = lcl.taxobj.gettaxonomyitemswithrelations("country", lcl.s)>
		<cfset lcl.data.valuesfield = 'safename'>
		<cfset lcl.data.labelsfield = 'name'>
		<cfset lcl.txt.setData(lcl.data)>
		<cfset lcl.txt.setDefault(requestObject.getFormUrlVar("country",""))>
					
		<cfset lcl.txt = lcl.div.addItem("select")>
		<cfset lcl.txt.setName('region')>
		<cfset lcl.txt.setLabel('Region')>
		<cfset lcl.txt.firstOption("")>
		<cfset lcl.data = structnew()>
		<cfset lcl.s = structnew()>
		<cfset lcl.s.sort = "name">
		<cfset lcl.data.query = lcl.taxobj.gettaxonomyitemswithrelations("region", lcl.s)>
		<cfset lcl.data.valuesfield = 'safename'>
		<cfset lcl.data.labelsfield = 'name'>
		<cfset lcl.txt.setData(lcl.data)>
		<cfset lcl.txt.setDefault(requestObject.getFormUrlVar("region",""))>
		
		<cfset lcl.txt = lcl.div.addItem("select")>
		<cfset lcl.txt.setName('vintage')>
		<cfset lcl.txt.setLabel('Vintage')>
		<cfset lcl.txt.firstOption("")>
		<cfset lcl.data = structnew()>
		<cfset lcl.s = structnew()>
		<cfset lcl.s.sort = "name">
		<cfset lcl.data.query = lcl.taxobj.gettaxonomyitemswithrelations("vintage", lcl.s)>
		<cfset lcl.data.valuesfield = 'safename'>
		<cfset lcl.data.labelsfield = 'name'>
		<cfset lcl.txt.setData(lcl.data)>

		<cfset lcl.txt.setDefault(requestObject.getFormUrlVar("vintage",""))>
		
		<cfset lcl.txt = lcl.div.addItem("select")>
		<cfset lcl.txt.setName('grape')>
		<cfset lcl.txt.setLabel('Varietal')>
		<cfset lcl.txt.firstOption("")>
		<cfset lcl.data = structnew()>
		<cfset lcl.s = structnew()>
		<cfset lcl.s.sort = "name">
		<cfset lcl.data.query = lcl.taxobj.gettaxonomyitemswithrelations("grape", lcl.s)>
		<cfset lcl.data.valuesfield = 'safename'>
		<cfset lcl.data.labelsfield = 'name'>
		<cfset lcl.txt.setData(lcl.data)>
		<cfset lcl.txt.setDefault(requestObject.getFormUrlVar("grape",""))>
					
		
		<cfset lcl.txt = lcl.div.addItem("select")>
		<cfset lcl.txt.setName('containersize')>
		<cfset lcl.txt.setLabel('Size')>
		<cfset lcl.txt.firstOption("")>
		<cfset lcl.data = structnew()>
		<cfset lcl.data.query = lcl.taxobj.gettaxonomyitemswithrelations("containersize")>
		<cfset lcl.data.valuesfield = 'safename'>
		<cfset lcl.data.labelsfield = 'name'>
		<cfset lcl.txt.setData(lcl.data)>
		<cfset lcl.txt.setDefault(requestObject.getFormUrlVar("containersize",""))>
			
		<cfreturn observed>
	</cffunction>
	
	<cffunction name="form_make_newuserform">
		<cfargument name="observed" required="true">
		
		<cfset var lcl = structnew()>
		
		<cfset lcl.leftcol = observed.findbyfullpath("newuserform.wraptable.wraptablerow.wraptablecolumn")>
		<cfset lcl.leftcol = lcl.leftcol["newuserform.wraptable.wraptablerow.wraptablecolumn"][1]>

		<cfset lcl.bwrap = lcl.leftcol.addItem("section")>
		<cfset lcl.bwrap.setName("bday section")>
		<cfset lcl.bwrap.setLabel("Your Birthday")>
		
		<cfset lcl.txt = lcl.bwrap.addItem("Text")>
		<cfset lcl.txt.setName('birthday')>
		<cfset lcl.txt.setLabel("Birthday (mm/dd/yyyy)")>
		<cfset lcl.txt.addValidation("isValidDate")>
		
		<cfset lcl.acard = lcl.leftcol.addItem("section")>
		<cfset lcl.acard.setName("acard")>
		<cfset lcl.acard.setLabel("Applejack Advantage Card")>
		
		<cfset lcl.ck = lcl.acard.addItem("checkboxitem")>
		<cfset lcl.ck.setName('advcard')>
		<cfset lcl.ck.setDefault('yes')>
		<cfset lcl.ck.setLabel("Do you want to be sent an Advantage Card by mail?")>

		<cfreturn observed>
	</cffunction>
	
	<cffunction name="form_validation_users_newclientform">
		<cfargument name="observed" required="true">
		
		<cfset var lcl = structnew()>
		
		<cfif isdate(requestObject.getFormUrlVar("birthday",""))>
		
			<cfset lcl.bd = createodbcdate(requestObject.getFormUrlVar("birthday"))>
			
			<cfif dateadd("YYYY", 21, lcl.bd) GT NOW()>
				<cfset observed.addError("birthday", "In order to be a member, you must be over 21.")>
			</cfif>
		</cfif>
		
		<cfreturn observed>
	</cffunction>	
	
	<cffunction name="form_validation_cart_orderconfirmation">
		<cfargument name="observed" required="true">
		
		<cfset var lcl = structnew()>
		<cfset lcl.cart = createObject("component", "modules.cart.models.cart").init(requestObject)>
		<cfset lcl.cart.load()>

		<cfset lcl.shippingid = lcl.cart.getShippingQuoteId()>
		
		<cfset lcl.shippingQuoteObj =  createObject("component", "modules.cart_shipping.models.cartshippingquotes").init(requestObject)>
		<cfset lcl.shippingQuoteObj.load(lcl.shippingid)>
		
		<cfif trim(requestObject.getFormUrlVar("ordernotestxt")) EQ "" 
			AND lcl.shippingQuoteObj.getShippingModule() EQ "modules.applejack.models.shipping">
			<cfset observed.addError("Message","Please specify a date and time in the Delivery Notes for the pickup/delivery.")>
		</cfif>

		<cfreturn observed>
	</cffunction>	
	
	<cffunction name="form_submission_cart_shippingpaymentinfo">
		<cfargument name="observed" required="true">
		
		<cfset var lcl = structnew()>
		<cfset lcl.cart = createObject("component", "modules.cart.models.cart").init(requestObject)>
		<cfset lcl.cart.load()>

		<cfset lcl.shippingid = lcl.cart.getShippingQuoteId()>
		
		<cfset lcl.shippingQuoteObj =  createObject("component", "modules.cart_shipping.models.cartshippingquotes").init(requestObject)>
		<cfset lcl.shippingQuoteObj.load(lcl.shippingid)>
		
		<cfif lcl.shippingQuoteObj.getShippingModule() EQ "modules.applejack.models.shipping">
			<cfset session.user.setFlash("Please specify a date and time in the Delivery Notes(at the bottom of this page) for the pickup/delivery.")>
		</cfif>

		<cfreturn observed>
	</cffunction>	
	
	<cffunction name="form_submission_users_newclientform">
		<cfargument name="observed" required="true">
		<!--- aj card email if submitted --->
		<cfset var lcl = structnew()>
		
		<cfif not requestObject.isformurlvarset("advcard")>
			<cfreturn observed>
		</cfif>
		
		<cfset lcl.msg = createObject("component", "modules.messaging.models.messaging").init(requestObject)>
		<cfset lcl.msg.sendMessage(
			requestObject.getVar("newCardRequestsEmail", requestObject.getVar("systememailto")),
			"Customer Wants Card",
			requestobject.getAllFormUrlVars()
		)> 
		
		<cfreturn observed>
	</cffunction>	
	
	<cffunction name="search_searchcriteria">
		<cfargument name="observed" required="true">
		<cfset var lcl = structnew()>
		
		<!--- assumes full solr search with dyanmic field tax_* --->
		<cfloop list="country,price,region,vintage,grape,containersize" index="lcl.idx">
			<cfif requestObject.getFormUrlVar(lcl.idx,"") NEQ "">
				<cfset observed.categories = listappend(observed.categories, " +tax_" & lcl.idx & ":" & requestObject.getFormUrlVar(lcl.idx), " ")>
			</cfif>
		</cfloop>
		
		<cfset lcl.cats = "">
		<cfset lcl.allcats = "other,wine,spirits,beer,cordials_liqueurs">
		
		<cfloop list="#requestObject.getFormUrlVar('product_category',"")#" index="lcl.itm">
			<cfif listfindnocase(lcl.allcats, lcl.itm)>
				<cfset lcl.allcats = listdeleteat(lcl.allcats, listfindnocase(lcl.allcats, lcl.itm))>
			</cfif>
		</cfloop>
		
		<cfif lcl.allcats NEQ "">
			<cfset observed.categories = observed.categories & " -(tax_product_categories:"  & replace(lcl.allcats, ",", " tax_product_categories:", "all") & ")">
		</cfif>
		
		<cfset lcl.sort = requestObject.getFormUrlVar('sort',"relevance")>
		
		<cfif lcl.sort NEQ 'relevance' AND lcl.sort NEQ "">
			<cfset observed.sort = structnew()>
			<cfset observed.sort.field = listfirst(lcl.sort,"_")>
			<cfif observed.sort.field EQ "price">
				<cfset observed.sort.field = "more_price_d">
			</cfif>
			<cfif observed.sort.field EQ "country">
				<cfset observed.sort.field = "tax_country">
			</cfif>
			<cfset observed.sort.dir = listlast(lcl.sort,"_")>
		</cfif>

		<cfreturn observed>
	</cffunction>
	
	<cffunction name="orm_save_indexables">
		<!--- 
			this observer maintains the price to be indexed by notices save actions on indexables, 
			and updates the moreinfo structure to have the price to be indexed 
		--->
		<cfargument name="observed" required="true">
		
		<cfset var lcl = structnew()>
		
		<cfif observed.getViewCfc() EQ "modules.productcatalog.searchview">
			<cfquery name="lcl.priceq" datasource="#requestObject.getVar("dsn")#">
				SELECT price FROM productPrices WHERE isdefault = 1 AND productid = <cfqueryparam value="#observed.getObjId()#" cfsqltype="cf_sql_varchar">
			</cfquery>
			<cfif lcl.priceq.recordcount>
				<cfset lcl.morejson = observed.getMoreInfoJson()>
				<cfif left(lcl.morejson,1) EQ "{">
					<cfset lcl.morejson = deserializejson(lcl.morejson)>
				<cfelse>
					<cfset lcl.morejson = structnew()>
				</cfif>
				<cfset lcl.morejson['price_d'] = arraynew(1)>
				<cfset arrayappend(lcl.morejson.price_d, replace(decimalformat(lcl.priceq.price),",","","all"))>
				<cfset observed.setMoreInfoJson(serializejson(lcl.morejson))>
				<cfset lcl.s = structnew()>
				<cfset lcl.s.noobserve = 1>
				<cfset observed.save(lcl.s)>
			</cfif>
		</cfif>
		
		<cfreturn observed>
	</cffunction>
	
	
	<!--->
	<cffunction name="pagenotfound">
		<cfargument name="observed" required="true">
		<cfset var lcl = structnew()>
		
		<cfset lcl.find = refindnocase("ui/productimages/([0-9]+)/(w\_[0-9]+)/[0-9]+\.jpg", observed, 1, 1)>
		
		<cfif lcl.find.len[1] NEQ 0>
			<cfset lcl.idstr = mid(observed, lcl.find.pos[2], lcl.find.len[2])>
			<cfset lcl.widthstr = mid(observed, lcl.find.pos[3], lcl.find.len[3])>
			<cfset lcl.newwidth = mid(lcl.widthstr,3, len(lcl.widthstr))>
			<cfset lcl.imagepath = requestObject.getVar("machineroot") & '/ui/productimages/#lcl.idstr#/#lcl.idstr#.jpg'>
			<cfif fileexists(lcl.imagepath)>
				<!--- load image --->
				<cfimage action="read" name="lcl.imgref" source="#lcl.imagepath#">
				
				<!--- resize image --->
				<cfset ImageResize(lcl.imgref,lcl.newwidth,"")>
				
				<!--- make directory if not existing --->
				<cfif NOT directoryexists(requestObject.getVar("machineroot") & '/ui/productimages/#lcl.idstr#/#lcl.widthstr#')>
					<cfdirectory action="create" directory="#requestObject.getVar("machineroot") & '/ui/productimages/#lcl.idstr#/#lcl.widthstr#'#">
				</cfif>
				
				<!--- save image to that dir --->
				<cfimage source="#lcl.imgref#" action="write" destination="#requestObject.getVar("machineroot") & '/ui/productimages/#lcl.idstr#/#lcl.widthstr#/#lcl.idstr#.jpg'#">
				
				<!--- pass image back to browser --->
				<cfimage action="writeToBrowser" source="#lcl.imgref#"><cfabort>
			</cfif>
		</cfif>

		<cfreturn observed>
	</cffunction>--->
	<!--- <cffunction name="formmake_checkoutclientshippingform">
		<cfargument name="observed" required="true">
		
		<cfset lcl.list = observed.findbyfullpath('checkoutclientshippingform.Payment Options.pmtinfo_cvv_number')>
		<cfset lcl.list[structkeylist(lcl.list)][1].setLabel("haha")>

		<cfreturn observed>
	</cffunction> --->
</cfcomponent>