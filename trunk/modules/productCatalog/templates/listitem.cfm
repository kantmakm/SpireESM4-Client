<cfoutput>
<cfset lcl.productObj = variables.data.productObj>
<cfset lcl.tax = lcl.productObj.getTaxonomyObj()>
<cfset lcl.pricingObj = variables.data.pricingObj>
<cfset lcl.categoryLink = replace(lcl.tax.getFirstTermItemSafeName("product_categories"),"_","-","all")>
<cfset lcl.productimage = createobject("component", "modules.productImages.models.imageresizer").init(requestObject)>
<cfset lcl.productimage.setHeight(125)>
<cfset lcl.productimage.setWidth(100)>
<cfset lcl.availableUnits = lcl.productObj.getAvailableUnits()>

<cfif NOT isvalid("integer", lcl.availableUnits)>
	<cfset lcl.availableUnits = 1>
</cfif>

<cfif lcl.pricingObj.getDefaultPriceType() NEQ "">
	<cfset lcl.dfltpricetype = lcl.pricingObj.getDefaultPriceType()>
	<cfset lcl.dfltprice = lcl.pricingObj.getTypePrice(lcl.pricingObj.getDefaultPriceType())>
<cfelse>
	<!---<cfthrow message="Product id = #lcl.productObj.getId()#">--->
</cfif>
<cfset lcl.ratings = variables.data.ratedObj.getRatings()>
<div class="productListItem">
	<h5><a href="/#lcl.categoryLink#/product/#data.productObj.getUrlName()#">#variables.data.productObj.getTitle()#</a></h5>
	
	<a href="/#lcl.categoryLink#/product/#data.productObj.getUrlName()#">
		<cfset lcl.productimage.setImageId(lcl.productObj.getId())>
        <cfif lcl.productimage.process()>
            <img class="productcatalogthumb" src="#lcl.productimage.getImagePath()#"/>
        <cfelse>
            <img class="productcatalogthumb" src="/ui/images/general/no_image_#lcl.categoryLink#_small.png"/>
        </cfif>
	</a>
       
    <div style="float:left;">
        <cfloop query="lcl.ratings">
			<cfsilent>
			<cfset lcl.ratingtitle = "This product received a rating of #lcl.ratings.rating# out of 100">
			<cfif lcl.ratings.tiname EQ "aj"><cfset lcl.ratingtitle = lcl.ratingtitle & " by our Applejack tasters">
			<cfelseif lcl.ratings.tiname EQ "ws"><cfset lcl.ratingtitle = lcl.ratingtitle & " by Wine Spectator">
			<cfelseif lcl.ratings.tiname EQ "rp"><cfset lcl.ratingtitle = lcl.ratingtitle & " by Robert Parker's Wine advocate">
			</cfif>
			</cfsilent>
            <div title="#lcl.ratingtitle#" class="#lcase(lcl.ratings.tiname)#_rating">#lcl.ratings.rating#</div>
        </cfloop>
		<cfif listfindnocase("red,white", lcl.tax.getFirstTermItemName("color"))>
        	<img src="/ui/images/#lcl.tax.getFirstTermItemName("color")#wine.png" alt="This is a #lcl.tax.getFirstTermItemName("color")# wine"  title="This is a #lcl.tax.getFirstTermItemName("color")# wine"/>
		</cfif>
    </div>
    <br class="clear"/>
<!--- </cfif> --->
    <div class="textDetail">
        <div style="padding-bottom:10px"><strong>Item ## - <span style="color:##4f4820"><strong>#variables.data.productObj.getId()#</strong></span></strong></div>
        <div class="prodInfoSmall">   
            <cfif lcl.tax.getFirstTermItemName("country") NEQ ""><div>Country: <span>#lcl.tax.getFirstTermItemName("country")#</span></span></div></cfif>
            <cfif lcl.tax.getFirstTermItemName("region") NEQ ""><div>Region: <span>#lcl.tax.getFirstTermItemName("region")#</span></div></cfif>
            <cfif variables.data.productObj.getsub_region1() NEQ ""><div>Sub-Region: <span>#variables.data.productObj.getsub_region1()#</span></div></cfif>
    	</div>
        <div class="spacer"></div>
        <!--- <cfif lcl.pricingObj.hasType("unit")> --->
		<cfif isdefined("lcl.dfltprice")>
            <div class="regularPriceSmall">Regular Price
				<cfif lcl.dfltpricetype NEQ "unit">(#lcl.dfltpricetype#)</cfif>
				: 
				<span class="listValue">#dollarformat(lcl.dfltprice.price)#</span>
			</div>
           
            <cfif lcl.dfltprice.price_sale>
                <div class="salePriceSmall">SALE PRICE: <span class="listValue">#dollarformat(lcl.dfltprice.price_sale)#</span></div>
            </cfif>
            
			<cfif lcl.dfltprice.price_member>
	            <div class="cardPriceSmall">Advantage Card Price: <span class="listValue">#dollarformat(lcl.dfltprice.price_member)#</span></div>
			</cfif>
        </cfif>
		<cfif lcl.availableunits GT 0 AND isdefined("lcl.dfltprice")>
			#lcl.pricingObj.showListForm()#
		<cfelseif NOT isdefined("lcl.dfltprice")>
			<p>Call for info.</p>
		<cfelse>
			<p>Item temporarily out of stock.<br/>Call for info.</p>
		</cfif>
    </div>
</div>
</cfoutput>