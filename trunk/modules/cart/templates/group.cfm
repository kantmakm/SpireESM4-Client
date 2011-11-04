<div class="productcatalogList">
<cfif variables.productlist.recordcount>
	<cfoutput>
	<div class="left">#variables.pager.showPageLinks()#</div>
	<div class="right">#variables.showProductSort()#</div>
	<div class="clear">&nbsp;</div>
	<div class="pagingSep"></div>
	</cfoutput>
	<cfloop from="0" to="#ceiling(variables.data.pageing/variables.maxcolumns)-1#" index="column">
		<cfif variables.productlist.recordcount gte ((column*variables.maxcolumns)+1)>
			<div class="productRow">
			<cfset lcl.CurrentColumn = 0>
			<cfoutput query="variables.productlist" startrow="#((column*variables.maxcolumns)+1)#" maxrows="#variables.maxcolumns#">
				<cfset lcl.CurrentColumn = lcl.CurrentColumn + 1>
				<div class="productColumn <cfif (lcl.CurrentColumn eq variables.maxcolumns)>productColumnlast</cfif>">
					<div class="productcatalogthumb">
						<cfif len(thmbfilename) neq 0>
							<a href="/<cfif variables.pageref.isFieldSet('urlpath')>#variables.pageref.getfield('urlpath')#</cfif>ProductView/#id#/">
								<img src="/docs/productcatalog/#id#/#thmbfilename#" alt="#thmbfilename#">
							</a>
						</cfif>
					</div>
					<p >
						<a href="/<cfif variables.pageref.isFieldSet('urlpath')>#variables.pageref.getfield('urlpath')#</cfif>ProductView/#id#/">
							#title#
						</a>
					</p>
					<p><b>Type :</b> #type#</p>
					<p><b>Manufacturer :</b> #Manufacturer#</p>
					<p><b>Price :</b> #priceFormatted#</p>
				</div>
			</cfoutput>
			</div>
			<div class="clear">&nbsp;</div>
		</cfif>
	</cfloop>
	<div class="pagingSep"></div>
	<cfoutput>#variables.pager.showPageLinks()#</cfoutput>
	<br class="clear"/>
</cfif>
</div>