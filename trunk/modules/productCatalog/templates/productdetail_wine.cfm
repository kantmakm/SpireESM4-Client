<cfoutput>
<cfset lcl.tax = variables.data.productObj.getTaxonomyObj()>
<cfset lcl.pricingObj = variables.data.pricingObj>
<!--- special rules for wine, packs is default over units --->

<cfset lcl.productimage = createobject("component", "modules.productImages.models.imageresizer").init(requestObject)>
<cfset lcl.productimage.setHeight(260)>
<cfset lcl.productimage.setWidth(240)>
<cfset lcl.productimage.setImageId(variables.data.productObj.getId())>
<cfset lcl.availableUnits = variables.data.productObj.getAvailableUnits()>

<cfif NOT isvalid("integer", lcl.availableUnits)>
	<cfset lcl.availableUnits = 1>
</cfif>

<cfif lcl.pricingObj.getDefaultPriceType() NEQ "">
	<cfset lcl.dfltpricetype = lcl.pricingObj.getDefaultPriceType()>
	<cfset lcl.dfltprice = lcl.pricingObj.getTypePrice(lcl.pricingObj.getDefaultPriceType())>
<cfelse>
	<!---<cfthrow message="Product #variables.data.productObj.getId()# has no default price">--->
</cfif>

<div class="productcatalogDetail">
	<table>
		<tr>
        <td valign="top" class="pictureColumn">
            <cfif lcl.productimage.process()>
				<img class="productcatalogmain" src="#lcl.productimage.getImagePath()#"/>
			<cfelse>
				<img class="productcatalogmain" src="/ui/images/general/no_image_wine_big.png" alt="No Product Image">
			</cfif>
            <br />
            <div class="innerDetail">
                <cfif listfindnocase("red,white", lcl.tax.getFirstTermItemName("color"))>
		        	<img src="/ui/images/#lcl.tax.getFirstTermItemName("color")#wine.png"  title="This is a #lcl.tax.getFirstTermItemName("color")# wine" alt="This is a #lcl.tax.getFirstTermItemName("color")# wine"/>
				</cfif>
                <span class="itemnumber">Item ## - #variables.data.productObj.getId()#</span>
            </div>
		</td>
		<td valign="top" style="min-width:390px;">
        	<div class="textDetail">
				<cfif isdefined("lcl.dfltprice")>
					<div class="regularPrice">Regular Price (#lcl.dfltpricetype#): #dollarformat(lcl.dfltprice.price)#</div>
					
					<cfif lcl.dfltprice.price_sale NEQ 0>
						<div class="salePrice">SALE PRICE: #dollarformat(lcl.dfltprice.price_sale)#</div>
						<div id="subsaleprice">A savings of #dollarformat(lcl.dfltprice.price - lcl.dfltprice.price_sale)#</div>
					</cfif>
					
					<cfif lcl.dfltprice.price_member NEQ 0>
						<div class="cardPrice">Advantage Card Price: #dollarformat(lcl.dfltprice.price_member)#</div>
						<div id="subcardprice">A savings of #dollarformat(lcl.dfltprice.price - lcl.dfltprice.price_member)#</div>
					</cfif>
					
					<cfif lcl.availableunits GT 0>
						#lcl.pricingObj.showDetailForm()#
					<cfelse>
						<p>Item temporarily out of stock.<br/>Call for info.</p>
					</cfif>
					<hr class="fullwidthdottedhrwithmargins">
				<cfelse>
					<p>Call for info</p>
				</cfif>

				<div class="prodInfo">
					<cfif lcl.tax.getFirstTermItemName("Country") neq "">
					<div><strong>Country:</strong>
					<span>#ucase(lcl.tax.getFirstTermItemName("Country"))#</span></div></cfif>
					<cfif lcl.tax.getFirstTermItemName("Region") neq "">
					<div><strong>Region:</strong>
					<span>#ucase(lcl.tax.getFirstTermItemName("Region"))#</span></div></cfif>
					<cfif variables.data.productObj.getsub_region1() neq "">
					<div><strong>Sub-Region:</strong>
					<span>#ucase(variables.data.productObj.getsub_region1())#</span></div></cfif>
					<cfif lcl.tax.getFirstTermItemName("Vintage") neq "">
					<div><strong>Vintage:</strong>
					<span>#ucase(lcl.tax.getFirstTermItemName("Vintage"))#</span></div></cfif>
					<cfif lcl.tax.getFirstTermItemName("Grape") neq "">
					<div><strong>Grape:</strong>
					<span>#ucase(lcl.tax.getFirstTermItemName("Grape"))#</span></div></cfif>
					<cfif lcl.tax.getFirstTermItemName("Color") neq "">
					<div><strong>Color:</strong>
					<span>#ucase(lcl.tax.getFirstTermItemName("Color"))#</span></div></cfif>
					<cfif lcl.tax.getFirstTermItemName("Classification") neq "">
					<div><strong>Classification:</strong>
					<span>#ucase(lcl.tax.getFirstTermItemName("Classification"))#</span></div></cfif>
					<cfif variables.data.productObj.getSizeDescription() neq "">
					<div><strong>Bottle Size:</strong>
					<span>#ucase(variables.data.productObj.getSizeDescription())#</span></div></cfif>
					<cfset lcl.grapes = lcl.tax.getTermItems('grape')>
					<cfif arraylen(lcl.grapes)>
					<div><strong>Varietal:</strong>
					<span><cfloop from="1" to="#arraylen(lcl.grapes)#" index="lcl.cidx"><cfif lcl.cidx NEQ 1>, </cfif>#ucase(lcl.grapes[lcl.cidx].name)#</cfloop><u></u></span></div></cfif>
					<cfif variables.data.productObj.getUnitsPerCase() neq "">
					<div><strong>Number in Case:</strong>
					<span>#variables.data.productObj.getUnitsPerCase()#</span></div></cfif>
					<div style="color:##4f4823;">#ucase(variables.data.productObj.getDescription())#</div>
				</div>
		  	</div>
		  </td>
		</tr>
	</table>
</div>
</cfoutput>

