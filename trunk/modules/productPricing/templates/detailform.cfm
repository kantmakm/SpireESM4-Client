<cfoutput> 
<div class="detailPriceForm">
	<div> 
		<span class="quantitytext">Quantity: </span>
		<form action="/cart/add/" method="post">
        <input name="quantity" type="text" size="3" value="1" class="quantityinput"> 
        &nbsp;&nbsp;&nbsp;
        
        <cfif variables.hasType("unit") and variables.hasType("pack") and variables.hasType("case")>
			<br />
		</cfif>
		<!--- special rule for aj. do not show unit if has pack price --->
        <cfif NOT (listfindnocase('beer,wine',variables.pricedObj.getTaxonomyObj().getFirstTermItemName("product_categories")) AND variables.hasType("pack")) AND variables.hasType("unit")>
            <cfset lcl.type = getTypePrice("unit")>
			<!---<button type="submit" class="img" value="#lcl.type.id#" name="priceid"><img src="/ui/images/cart/addToCartBtn.png"/></button>--->
            <input type="submit" value="#lcl.type.id#" id="action" name="priceid" class="submit-img submit-img-addtocart">
			<input type="hidden" value="#lcl.type.id#" name="default_priceid"><cfset lcl.defaultwritten = 1>
        </cfif>
        <cfif variables.hasType("pack")>
            <cfset lcl.type = getTypePrice("pack")>
			<!---<button type="submit" class="img" value="#lcl.type.id#" name="priceid"><img src="/ui/images/cart/addCaseBtn.png"/></button>--->
            <input type="submit" value="#lcl.type.id#" id="action" name="priceid" class="submit-img submit-img-addpack">
			<cfif not isdefined("lcl.defaultwritten")><input type="hidden" value="#lcl.type.id#" name="default_priceid"><cfset lcl.defaultwritten = 1></cfif>
        </cfif>
		<cfif variables.hasType("case")>
            <cfset lcl.type = getTypePrice("case")>
			<!---<button type="submit" class="img" value="#lcl.type.id#" name="priceid"><img src="/ui/images/cart/addCaseBtn.png"/></button>--->
            <input type="submit" value="#lcl.type.id#" id="action" name="priceid" class="submit-img submit-img-addcase">
			<cfif not isdefined("lcl.defaultwritten")><input type="hidden" value="#lcl.type.id#" name="default_priceid"><cfset lcl.defaultwritten = 1></cfif>
        </cfif>
		</form>
		<form action="/cart/update/" method="post">
			<!---<button type="submit" class="img" name="action" value="checkout"><img src="/ui/images/cart/checkoutBtn.png"/></button>--->
            <input type="submit" value="checkout" id="action" name="action" class="submit-img submit-img-checkout">
        </form>
    </div>
</div>
</cfoutput>