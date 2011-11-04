<cfoutput>
<cfset lcl.tax = variables.data.productObj.getTaxonomyObj()>
<cfset lcl.pricingObj = variables.data.pricingObj>
<!--- special rules for beer, packs is default over units --->

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
					<img class="productcatalogmain" src="/ui/images/general/no_image_beer_big.png" alt="No Product Image">
				</cfif>
				<br />
				<div class="innerDetail">
					<span class="itemnumber">Item ## - #lcl.dfltprice.productid#</span>
				</div>
			</td>
			<td valign="top" style="min-width:390px;">
				<div class="textDetail">
					<cfif isdefined("lcl.dfltprice")>
						<div class="regularPrice">Regular Price (#lcl.dfltpricetype#): #dollarformat(lcl.dfltprice.price)#</div>
						<cfif lcl.dfltprice.price_sale NEQ 0>
							<div class="salePrice">SALE PRICE: #dollarformat(lcl.dfltprice.price_sale)#</div>
						</cfif>
						 <cfif lcl.dfltprice.price_member NEQ 0>
							<div class="cardPrice">Advantage Card Price: #dollarformat(lcl.dfltprice.price_member)#</div>
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
                    	<cfif lcl.tax.getFirstTermItemName("Classification") neq "">
                            <div><strong>Type</strong> : 
                            <span>#lcl.tax.getFirstTermItemName("Classification")#</span></div></cfif>
                        <cfif lcl.tax.getFirstTermItemName("manufacturer") neq "">
                            <div><strong>Manufacturer</strong> : 
                            <span>(dummy - need created)</span></div></cfif>
                        <cfif lcl.tax.getFirstTermItemName("grape") neq "">
                            <div><strong>Style</strong> : 
                            <span>#lcl.tax.getFirstTermItemName("grape")#</span></div></cfif>
                        <cfif lcl.tax.getFirstTermItemName("country") neq "">
                            <div><strong>Country</strong> : 
                            <span>#lcl.tax.getFirstTermItemName("country")#</span></div></cfif>
                        <cfif lcl.tax.getFirstTermItemName("region") neq "">
                            <div><strong>State</strong> : 
                            <span>#lcl.tax.getFirstTermItemName("region")#</span></div></cfif>
                        <cfif variables.data.productObj.getUnitsPerPack() neq "">
                            <div><strong>Number in Pack</strong> : 
                            <span>#variables.data.productObj.getUnitsPerPack()#</span></div></cfif>
						<cfif variables.data.productObj.getUnitsPerCase() neq "">
                            <div><strong>Number in Case</strong> : 
                            <span>#variables.data.productObj.getUnitsPerCase()#</span></div></cfif>
                        <cfif variables.data.productObj.getSizeDescription() neq "">
                            <div><strong>Size of Bottle</strong> : 
                            <span>#variables.data.productObj.getSizeDescription()#</span></div></cfif>
                        <div style="color:##4f4823;">#variables.data.productObj.getDescription()#</div>
                    </div>
		  		</div>
			</td>
		</tr>
	</table>
</div>
</cfoutput>
