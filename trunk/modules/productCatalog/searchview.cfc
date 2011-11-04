<cfcomponent name="product search view" extends="resources.abstractSearchResultView">
	<cffunction name="showhtml">
		<cfset var lcl = structnew()>
		<cfoutput>
		<cfset lcl.productObj = createObject("component","modules.productcatalog.models.product").init(requestObject)>
		<cfset lcl.productObj.load(variables.data.objid)>
		
		<cfset lcl.tax = lcl.productObj.getTaxonomyObj()>
		
		<cfset lcl.pricingObj = createObject('component','modules.productPricing.models.productpricing').init(requestObject)>
		<cfset lcl.pricingObj.setPricedObj(lcl.productObj)>
		
		<cfif lcl.pricingObj.getDefaultPriceType() NEQ "">
			<cfset lcl.unitprice = lcl.pricingObj.getTypePrice(lcl.pricingObj.getDefaultPriceType())>
		</cfif>
		
		<cfset lcl.productRatingsModel = createObject("component","modules.productRatings.models.productRatings").init(requestObject)>
		<cfset lcl.productRatingsModel.setRatedObj(lcl.productObj)>
		<cfset lcl.ratings = lcl.productRatingsModel.getRatings()>
		
		<cfset lcl.productimage = createobject("component", "modules.productImages.models.imageresizer").init(requestObject)>
		<cfset lcl.productimage.setHeight(125)>
		<cfset lcl.productimage.setWidth(100)>
		<cfset lcl.productimage.setImageId(lcl.productObj.getId())>

		<cfsavecontent variable="lcl.html">
		<div class="productcatalog-search-result">
			<h4><a href="/#variables.data.key#">#variables.data.title#</a></h4>
			<div class="search-thumb left">
				<cfif lcl.productimage.process()>
					<a href="/#variables.data.key#"><img class="productcatalogmain" src="#lcl.productimage.getImagePath()#" alt="sample"/></a>
				<cfelse>
					<a href="/#variables.data.key#"><img class="productcatalogmain" src="/ui/images/general/no_image_search.png" alt="sample"/></a>
				</cfif>
			</div>
			<div class="details">
				<div class="description">
				#variables.data.description#
				</div>
				<div class="size">#ucase(lcl.productObj.getSizeDescription())#</div>
				<cfif isdefined("lcl.unitprice")>
				<div class="prices">
					<div class="price">Regular Price #dollarformat(lcl.unitprice.price)#</div>
					<cfif lcl.unitprice.price_sale NEQ 0>
	                	<div class="price sale-price">Sale Price: #dollarformat(lcl.unitprice.price_sale)#</div>
	                </cfif>
					<cfif lcl.unitprice.price_member NEQ 0>
	                	<div class="price card-price">Advantage Card Price: #dollarformat(lcl.unitprice.price_member)#</div>
					</cfif>
				</div>
				</cfif>
				<div class="ratings">
				<cfloop query="lcl.ratings">
					<div class="rating">
			            <div class="#lcase(lcl.ratings.tiname)#_rating" style="float:left;color:##4f4823">
			            	<strong>#lcl.ratings.rating#</strong>
			            </div>
					</div>
				</cfloop>
				</div><!--- end rating --->
			</div><!--- end details --->
			<br class="clear"/>
		</div><!--- end pss --->
		</cfsavecontent>
		</cfoutput>
		<cfreturn lcl.html>
	</cffunction>
</cfcomponent>