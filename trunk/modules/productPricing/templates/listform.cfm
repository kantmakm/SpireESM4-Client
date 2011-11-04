<cfoutput>
<div class="listPriceForm">
	<form action="/cart/add/" method="post">
<cfif NOT (listfindnocase("beer,wine", variables.pricedObj.getTaxonomyObj().getFirstTermItemName("product_categories")) AND variables.hasType("pack")) AND variables.hasType("unit")>
	<cfset unitprice= variables.getTypePrice('unit')>
	<!--- <input type="image" src="/ui/images/cart/addToCartBtn.png" name="priceid" value="#unitprice.id#">
	<button type="submit" class="img" value="#unitprice.id#" name="priceid"><img src="/ui/images/cart/addToCartBtn.png"/></button> --->
    <input type="submit" value="#unitprice.id#" id="action" name="priceid" class="submit-img submit-img-addtocart">
<cfelseif  variables.hasType("pack")>
	<cfset packprice= variables.getTypePrice('pack')>
	<!--- <input type="image" src="/ui/images/cart/addCaseBtn.png" name="priceid" value="#unitprice.id#">
	<button type="submit" class="img" value="#caseprice.id#" name="priceid"><img src="/ui/images/cart/addCaseBtn.png"/></button> --->
    <input type="submit" value="#packprice.id#" id="action" name="priceid" class="submit-img submit-img-addpack"><strong></strong>
</cfif>
<cfif variables.hasType("case")>
	<cfset caseprice= variables.getTypePrice('case')>
	<!--- <input type="image" src="/ui/images/cart/addCaseBtn.png" name="priceid" value="#unitprice.id#">
	<button type="submit" class="img" value="#caseprice.id#" name="priceid"><img src="/ui/images/cart/addCaseBtn.png"/></button> --->
    <input type="submit" value="#caseprice.id#" id="action" name="priceid" class="submit-img submit-img-addcase">
</cfif>
	</form>
</div>
</cfoutput>
