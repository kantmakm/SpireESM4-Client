<cfoutput>
<cfset lcl.tax = variables.data.productObj.getTaxonomyObj()>
<cfset lcl.pricingObj = variables.data.pricingObj>

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
				<img class="productcatalogmain" src="/ui/images/general/no_image_cordials-liqueurs_big.png" alt="No Product Image">
			</cfif>
            <br />
            <div class="innerDetail">                
                <span class="itemnumber">Item ## - #variables.data.productObj.getId()#</span>
            </div>
		</td>
		<td valign="top" style="min-width:390px;">
        	<div class="textDetail">
				<cfif isdefined("lcl.dfltprice")>
					<div class="regularPrice">Regular Price: #dollarformat(lcl.dfltprice.price)#</div>
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
                            <div>Type : 
                            <span>#ucase(lcl.tax.getFirstTermItemName("Classification"))#</span></div></cfif>
                        <!---><cfif lcl.tax.getFirstTermItemName("manufacturer") neq "">
                            <div>Manufacturer : 
                            <span>#lcl.tax.getFirstTermItemName("manufacturer")#(dummy - need created)</span></div></cfif>--->
                        <cfif lcl.tax.getFirstTermItemName("country") neq "">
                            <div>Country : 
                            <span>#UCASE(lcl.tax.getFirstTermItemName("country"))#</span></div></cfif>
                        <cfif lcl.tax.getFirstTermItemName("region") neq "">
                            <div>Region : 
                            <span>#lcl.tax.getFirstTermItemName("region")#</span></div></cfif>  
                        <cfif lcl.tax.getFirstTermItemName("Units_per_case") neq "">
                            <div>Number in Case : 
                            <span>#lcl.tax.getFirstTermItemName("Units_per_case")#(dummy - need hook)</span></div></cfif>
                        <cfif lcl.tax.getFirstTermItemName("Units_in_pack") neq "">
                            <div>Number in Pack : 
                            <span>#UCASE(lcl.tax.getFirstTermItemName("Units_in_pack"))#</span></div></cfif>
                        <cfif variables.data.productObj.getSizeDescription() neq "">
                            <div>Size of Bottle : 
                            <span>#ucase(variables.data.productObj.getSizeDescription())#</span></div></cfif>
                        <div style="color:##4f4823;">#ucase(variables.data.productObj.getDescription())#</div>
                    </div>
		  		</div>
		   </div>
		  </td>
		</tr>
	</table>
</div>
</cfoutput>

<!---<cfoutput>
<div class="productcatalogDetail">
	<cfif StructKeyExists(variables.data,"productInfo") AND variables.data.productInfo.recordcount>
		<dl class="bclear" >
			<cfif len(variables.data.productInfo.mainfilename) neq 0>
				<img class="productcatalogmain" src="/docs/productcatalog/#variables.data.productInfo.id#/#variables.data.productInfo.mainfilename#" alt="#variables.data.productInfo.mainfilename#">
			</cfif>
			<dt class="left">Type :&nbsp;</dt>
			<dd>#variables.data.productInfo.type#&nbsp;</dd><br />
			<dt class="left">Manufacturer :&nbsp;</dt>
			<dd>#variables.data.productInfo.Manufacturer#&nbsp;</dd><br />
			<dt class="left">Price :&nbsp;</dt>
			<dd class="morebotpadding">#variables.data.productInfo.price#&nbsp;</dd><br />
			<dt class="morebotpadding">Product Description :</dt>
			<dd>#variables.data.productInfo.description#&nbsp;</dd>
			<dt class="morebotpadding">Product Specification :</dt>
			<dd>#variables.data.productInfo.specification#&nbsp;</dd>
			<br class="clear" />
			<dt class="morebotpadding">Product Review :</dt>
			<dd>#variables.data.productInfo.review#&nbsp;</dd>
		</dl>
		<!--- <p style="margin-top:30px;">
			<a href="javascript:history.go(-1);">&laquo; Back</a>
		</p> --->
	<cfelse>
	   <p>Sorry, that product cannot be found.</p>
	</cfif>
</div>
</cfoutput>
--->