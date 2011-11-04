<cfcomponent name="clientinfo" extends="utilities.forms2">

	<cffunction name="make">
		<cfset var lcl = structnew()>
		
		<cfset var cartModel = createObject("component","modules.cart.models.cart").init(requestObject)>
		<cfset var cartItemsModel = cartModel.getCartItemsObj()>
		<cfset var cartItems = cartItemsModel.getCartItems()>
					
		<cfset variables.forminfo.action="/cart/update/">
		<cfset variables.forminfo.name = "cartlist">
		
		<cfif structisempty(cartitems)>
			<cfset lcl.txt = addItem("html")>
			<cfset lcl.txt.setName('cart_noitems')>
			<cfset lcl.txt.setHTML('<p>Your shopping cart is empty. </p>')>
			<cfreturn>
		</cfif>
		
		<cfset lcl.tbl = addItem("table")>
        <cfset lcl.tbl.addClass("fullwidth")>
		<cfset lcl.tbl.setName("cartlistheadertbl")>

		<cfset lcl.r = lcl.tbl.addItem("tablerow")>
        <cfset lcl.r.setStyle("text-align","right")>
        <cfset lcl.r.setStyle("vertical-align","bottom")>
		<cfset lcl.r.setName("cart_header_row")>
		
		<!--- col1 --->
		<cfset lcl.c1 = lcl.r.addItem("tablecolumn")>
		<cfset lcl.c1.setName("cart_header_title_col")>
		
		<cfset lcl.txt = lcl.c1.addItem("html")>
		<cfset lcl.txt.setName('cart_header_title')>
		<cfset lcl.txt.setHTML('<h3 class="cart">Your Current Cart</h3>')>
		
		<!--- col2 --->
		<cfset lcl.c2 = lcl.r.addItem("tablecolumn")>
		<cfset lcl.c2.setName("cart_header_buttons")>
        <cfset lcl.c2.setStyle("vertical-align","middle")>
	        
		<cfset lcl.txt = lcl.c2.addItem("html")>
		<cfset lcl.txt.setName('print_shopping_list_link')>
		<!--- <cfset lcl.txt.setLabel('Name')> --->
		<cfset lcl.txt.setHTML("<a class=""printlist"" href=""/cart/printlist"">Print a Shopping List</a> with the items in your Cart")>
	
    	<!--- col3 --->
        <cfset lcl.c3 = lcl.r.addItem("tablecolumn")>
		<cfset lcl.c3.setName("cart_header_buttons2")>
        <cfset lcl.c3.setStyle("padding-right","0")>
        
		<cfset lcl.btn = lcl.c3.addItem("submit")>
		<cfset lcl.btn.setName("action")>
		<cfset lcl.btn.addClassToForm("submit-img submit-img-resume")>
		<cfset lcl.btn.setDefault("Resume Shopping")>
		
		<cfset lcl.btn = lcl.c3.addItem("submit")>
		<cfset lcl.btn.setName("action")>
		<cfset lcl.btn.addClassToForm("submit-img submit-img-update-cart")>
		<cfset lcl.btn.setDefault("Update Cart")>
		 
		<cfset lcl.btn = lcl.c3.addItem("submit")>
		<cfset lcl.btn.setName("action")>
		<cfset lcl.btn.addClassToForm("submit-img submit-img-checkout")>
		<cfset lcl.btn.setDefault("Checkout")>
		
		<!--- MAKE CART TABLE HERE --->
		<cfset lcl.tbl = addAlternateItem(createObject("component", "utilities.table").init(requestObject))>
		<cfset lcl.tbl.setName("cartview")>
		<cfset lcl.cols = lcl.tbl.getColumns()>
		<cfset lcl.tblatts = structnew()>
		<cfset lcl.tblatts['class'] = 'cart fancytable'>

		<cfset lcl.tbl.setTableAttributes(lcl.tblatts)>
		
        <cfset lcl.tblformats = structnew()>
		<cfset lcl.tblformats['price_total'] = 'money'>
		<cfset lcl.tblformats['price'] = 'money'>
		
		<cfset lcl.tbl.setformats(lcl.tblformats)>
        	
		<cfset lcl.tmp = structnew()>
		<cfset lcl.tmp.title = "Item ##">
		<cfset lcl.tmp.field = "productid">
		<cfset arrayappend(lcl.cols, lcl.tmp)>
		
		<cfset lcl.tmp = structnew()>
        <cfset lcl.tmp.attributes = structnew()>
		<cfset lcl.tmp.attributes.align = "left">
		<cfset lcl.tmp.title = "Description">
		<cfset lcl.tmp.format = "<a href=""[producturl]"">[title]</a>">
		<cfset lcl.tmp.field = "title">
		
		<cfset arrayappend(lcl.cols, lcl.tmp)>

		<cfset lcl.tmp = structnew()>
		<cfset lcl.tmp.title = "Price">
		<cfset lcl.tmp.field = "price">
		<cfset lcl.tmp.attributes = structnew()>
		<cfset lcl.tmp.attributes.align = "right">
		<cfset arrayappend(lcl.cols, lcl.tmp)>

		<cfset lcl.tmp = structnew()>
		<cfset lcl.tmp.attributes = structnew()>
		<cfset lcl.tmp.attributes.align = "center">
		<cfset lcl.tmp.title = "Qty">	
		<cfset lcl.tmp.field = "priceform">
		<cfset lcl.tmp.format = "<input type=""text"" name=""id_[priceid]"" value=""[quantity]"" size=""2""><br/> <a href=""/cart/update/?id_[priceid]=0&action=update"">remove</a>">
		<cfset arrayappend(lcl.cols, lcl.tmp)>		

		<cfset lcl.tmp = structnew()>
		<cfset lcl.tmp.title = "Total">
		<cfset lcl.tmp.field = "price_total">
		<cfset lcl.tmp.attributes = structnew()>
		<cfset lcl.tmp.attributes.align = "right">
        <cfset lcl.tmp.setClass = "greyfont">
		<cfset arrayappend(lcl.cols, lcl.tmp)>

		<cfset lcl.tbl.setColumns(lcl.cols)>
		<cfset lcl.tbl.setData(cartitems)>      

		<!--- export items here --->
		<cfset lcl.div = addItem("div")>
		<cfset lcl.div.setName("below_cart")>
		
		<cfset lcl.lineitems = cartModel.getCartLineItems()>

		<!--- <cfset lcl.ctr.> --->
			
		<cfset lcl.tbl = lcl.div.addItem("table")>
		<cfset lcl.tbl.setName("cartlisttotals")>
		<cfset lcl.tbl.addClass("cartlisttotals")>
	
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
            <cfif (lcl.idx.total NEQ 0) or (lcl.idx.name eq "TOTAL") or (lcl.idx.name eq "SUBTOTAL")>
            	<cfset lcl.tdhtml.setHTML(dollarformat(lcl.idx.total))>
            </cfif>
		</cfloop>
        <!--- sub options --->
        <cfset lcl.tbl = lcl.div.addItem("table")>
		<cfset lcl.tbl.setName("substitutionoptions")>
		<cfset lcl.tbl.addClass("substitutionoptions")>
        
        <cfset lcl.tr = lcl.tbl.addItem("tablerow")>
		<!---<cfset lcl.tr.addClass(lcl.idx.name)>--->
        <cfset lcl.tr.setName("test_row")>
        <cfset lcl.td = lcl.tr.addItem("tablecolumn")>
		<cfset lcl.td.setName("Test_col")>
        <cfset lcl.tdhtml = lcl.td.addItem("html")>
        <cfset lcl.tdhtml.setName(lcl.idx.name & "_label")>
        <cfsavecontent variable="lcl.suboptions">
        	<div class="left">
                <h3 class="redfont">Substitution Options:</h3>
            </div>
            <div class="right">
                <select id="selSubOptions" class="substituteselect">
                	<option value=0 selected="yes"></option>
                    <option value=1>Hold my order</option>
                    <option value=3>Issue a refund</option>
                    <option value=4>Substitute with a similar item</option>
                </select>
            </div>
            <br class="clear">
            <div class="greyfont">
            	Applejack will contact you regarding out of stock items. However you may provide general instructions for substitutions to assist the process.
            </div>
        </cfsavecontent>
        <cfset lcl.tdhtml.setHTML(lcl.suboptions)>
        
        <cfset lcl.txt = lcl.div.addItem("html")>
		<cfset lcl.txt.setName('hr')>
		<cfset lcl.txt.setHTML('<br class="clear"/><hr class="fullwidthdottedhr">')>
        
        <!--- Applejack Shipping/Delivery Rules & Options: --->
        <cfsavecontent variable="lcl.shipoptions">
            <div class="left">
                <h3 class="redfont">Applejack Shipping/Delivery Rules & Options:</h3>
            </div>
            <br class="clear">
            <div class="greyfont">
            	<ul class="redbullet">
                	<li>Applejack cannot ship Beer outside of Colorado</li>
                    <li>Applejack cannot ship 1.75 L bottles of liquor or irregularly shaped bottles</li>
                    <li><span class="redfont">In Store Pickup:</span> Pick up your order at Applejack within 1-2 business days - no shipping charge</li>
                    <li><span class="redfont">Delivery Denver Area:</span> Flat fee of $X for delivery to qualified Denver Zip codes within 1-2 business days.
     Denver Zip Codes We Deliver To: 80202, 80203, 80204-80227, 80403</li>
                    <li><span class="redfont">Delivery Colorado Mountain Area:</span> Flat fee of $X for delivery to qualified Colorado Mountain Area zip codes within 1-2 business days<br>Colorado Mountain Zip Codes We Deliver To: 80202, 80203, 80204-80227, 80403</li>
                    <li><span class="redfont">Shipped Via Fed Ex:</span> Order delivered to qualified states via Fed Ex Ground or Express<br>
     States We CANNOT Deliver Wine & Liquor To: Alabama, Arkansas, Maryland, Massachusetts, Mississippi, Pennsylvania, Utah<br>
     We Have Limited Deliverability to the Following States: Alaska, Hawaii, Tennessee, West Virginia - please call to ensure we can ship to your location</li>
                    <li><span class="redfont">International Orders:</span> Please call</li>
                </ul>
            </div>
        </cfsavecontent>
        <cfset lcl.div = addItem("div")>
		<cfset lcl.div.setName("shippingoptions")>
        <cfset lcl.tdhtml = lcl.div.addItem("html")>
        <cfset lcl.div.addClass("shippingoptions")>
        <cfset lcl.tdhtml.setName("shippingoptions_label")>
        <cfset lcl.tdhtml.setHTML(lcl.shipoptions)>
        
        <cfset lcl.txt = lcl.div.addItem("html")>
		<cfset lcl.txt.setName('hr')>
		<cfset lcl.txt.setHTML('<br class="clear"/><hr class="fullwidthdottedhr">')>
        
        <cfset lcl.div = addItem("div")>
		<cfset lcl.div.setName("shippingoptions")>
        <cfset lcl.div.setStyle("text-align","right")>
        
		<cfset lcl.btn = lcl.div.addItem("submit")>
		<cfset lcl.btn.setName("action")>
		<cfset lcl.btn.addClassToForm("submit-img submit-img-resume")>
		<cfset lcl.btn.setDefault("Resume Shopping")>
		
		<cfset lcl.btn = lcl.div.addItem("submit")>
		<cfset lcl.btn.setName("action")>
		<cfset lcl.btn.addClassToForm("submit-img submit-img-update-cart")>
		<cfset lcl.btn.setDefault("Update Cart")>
		 
		<cfset lcl.btn = lcl.div.addItem("submit")>
		<cfset lcl.btn.setName("action")>
		<cfset lcl.btn.addClassToForm("submit-img submit-img-checkout")>
		<cfset lcl.btn.setDefault("Checkout")>
		
        
	</cffunction>
		
	<!--- 
	<cffunction name="validate">
		<cfargument name="clear" default="false">
	
		<cfset var vdtr = super.validate(clear)>
					
		<cfreturn vdtr>
	</cffunction>
	
	<cffunction name="submit">
		<!--- check if cart record exists , if not create it, else update it with all the fields  --->
		<cfset var lcl = structnew()>
		<cfset lcl.forminfo = requestObject.getAllFormUrlVars()>
	
		<!--- make billing and shipping structures --->
		<cfset lcl.billinginfo = structnew()>
		<cfset lcl.deliveryinfo = structnew()>
		<cfloop collection="#lcl.forminfo#" item="lcl.itm">
			<cfif left(lcl.itm, 7) EQ "billing">
				<cfset lcl.billinginfo[lcl.itm] = lcl.forminfo[lcl.itm]>
			<cfelseif left(lcl.itm, 8) EQ "delivery">
				<cfset lcl.deliveryinfo[lcl.itm] = lcl.forminfo[lcl.itm]>
			</cfif>
		</cfloop>
		
		<cfset lcl.cart = createObject("component", "modules.cart.models.cart").init(requestObject)>
		
		<cfset lcl.cart.setBillingAddressInfo(serializejson(lcl.billinginfo))>
		<cfset lcl.cart.setDeliveryAddressInfo(serializejson(lcl.deliveryinfo))>
		<cfset lcl.cart.setShippingMethodInfo("")>
		
		<cfset lcl.iscart = lcl.cart.getByCartId(lcl.cart.getCartId())>
		<cfset lcl.cart.setCartId(lcl.cart.getCartId())>

		<cfif lcl.iscart.recordcount>
			<cfset lcl.cart.setId(lcl.iscart.Id)>
		</cfif>
		
		<cfset lcl.cart.save()>
	</cffunction>
	
	<cffunction name="onsuccessinfo">
		<cfset var lcl = structnew()>
		<cfset var s = structnew()>
		<!--- Here we use the checkout order to determine the current page and go to the next one --->
		<cfset lcl.cart = createObject("component", "modules.cart.models.cart").init(requestObject)>
		<cfset lcl.order = lcl.cart.checkoutorder()>
		<cfset lcl.cpage = requestObject.getFormUrlVar("submitfrom")>
		
		<cfloop from="1" to="#arraylen(lcl.order)#" index="lcl.i">
			<cfif lcl.order[lcl.i].page & '/' EQ lcl.cpage AND arraylen(lcl.order) NEQ lcl.i>
				<cfset s.relocate = lcl.order[lcl.i + 1].page>
				<cfbreak>
			</cfif>
		</cfloop>
	
		<cfset s.message = "Thanks for that. Now please choose a shipping option.">
		
		<cfreturn s>
	</cffunction> --->
</cfcomponent>