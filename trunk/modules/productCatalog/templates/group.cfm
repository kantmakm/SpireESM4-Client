<div class="productcatalogList">
<cfif variables.productlist.recordcount>
	<cfoutput>
	<div class="left">#variables.pager.showPageLinks()#</div>
	<div class="right">#variables.showProductSort()#</div>
	<div class="clear">&nbsp;</div>
	<div class="pagingSep"></div>
	</cfoutput>
	<cfoutput query="variables.productlist">
		<cfif variables.productlist.currentrow mod variables.maxcolumns EQ 1>
			<div class="productListRow">
		</cfif>
			#showProductListItem(id)#
		<cfif variables.productlist.currentrow mod variables.maxcolumns EQ 0>
			<br class="clear"/>
			</div>
		</cfif>
	</cfoutput>

	<cfoutput>#variables.pager.showPageLinks()#</cfoutput>
	<br class="clear"/>
<cfelse>
	<p>No products available</p>
</cfif>
</div>