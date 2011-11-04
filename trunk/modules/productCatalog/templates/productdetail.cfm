<cfoutput>
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