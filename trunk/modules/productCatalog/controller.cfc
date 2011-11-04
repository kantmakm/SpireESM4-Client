<cfcomponent extends="resources.abstractController" ouput="false">
	
	<cfset variables.useparseforlanguage = true>
	<cfset variables.maxcolumns = 3>
	<cfset variables.itemsperpage = 9>
	
	<!--- <cffunction name="getPagesforSiteSearch">
		<cfargument name="aggregator">

		<cfset var model = this.getProductsModel("productCatalog")>
		<cfset var itms = model.getAllAvailableProducts()>
		<cfset var webpath = "ProductsServices/">
		<cfset var indexable = "">

		<cfloop query="itms">
		<cfset indexable = aggregator.newpageindexable()>
		<cfset indexable.setkey(itms.id)>
		<cfset indexable.setpath(webpath & rereplace(itms.productgroupTitle, '[^a-zA-Z0-9\-]', '', 'ALL') & '/ProductView/' & itms.id & '/')>
		<cfset indexable.settitle(itms.title)>
		<cfset indexable.setdescription(itms.description)>
		<cfset indexable.saveForIndex()>
        </cfloop>
		
	</cffunction> --->
	
	<!--- <cffunction name="listItem">
		<cfset variables.pageObject.addHTMLtoHead("/ui/css/productCatalog.css")>
		<cfreturn this>
	</cffunction> --->
	
	<cffunction name="group">
		<cfset var lcl = structNew()>
		<cfset var path = listtoarray(requestObject.getFormUrlVar("path"),"/")>
			
		<!---<cfset tmpStrc = requestObject.dump()>--->
		<cfset lcl.model = createobject("component","modules.productCatalog.models.productlists").init(requestObject)>
		
		<cfif requestObject.isformurlvarset('productsortfield')>
			<cfset lcl.productsortfield = requestObject.getformurlvar('productsortfield')>
		</cfif>		
		
		<cfset lcl.page = structnew()>
		<cfset lcl.dd = requestObject.getFormUrlVar("dd",1)>
		<cfif NOT isvalid("integer", lcl.dd)>
			<cfset lcl.dd = 1>
		</cfif>
		<cfset lcl.page.from = (lcl.dd - 1) * variables.itemsperpage +1>
		<cfset lcl.page.to = lcl.dd * variables.itemsperpage>
		
		<cfset lcl.productlist = lcl.model.getCatalogIds(path, lcl.page)>

		<cfif structkeyexists(variables.pageref, "addtoheader")>
			<cfset variables.pageref.addtoheader('<link rel="stylesheet" href="/ui/css/productcatalog.css" type="text/css"/>')>
		</cfif>
		
		<cfset variables.pager = this.getUtility("pager").init(requestObject)>
		<cfset variables.pager.setItemsPerPage(variables.itemsperpage)>
		<cfset variables.pager.setparams(rows=lcl.productlist.rcnt)>
		

		<cfset variables.pager.seturlparams()>		
		
		<cfset variables.productlist = lcl.productlist>
		<!---<cfset variables.productlist = variables.pager.chopQuery(lcl.productlist)>--->
		<cfset variables.pager.setNoRecordsTitlePattern("No records were found")>
 		
		<cfreturn this>
	</cffunction>

	<cffunction name="showProductSort" output="false">
		<cfset var lcl = structNew()>
		<cfset variables.productsortfield = requestObject.getFormUrlVar("productsortfield",'name')>	
		<cfsavecontent variable="lcl.html">
            <form action="" method="get">
				<label for="productsortfield">Sort By:</label>&nbsp;&nbsp;
				<select id="productsortfield" name="productsortfield" onchange="submit();">
					<option value="name" <cfif variables.productsortfield eq 'name'>selected="selected"</cfif>>Name</option>
					<option value="region" <cfif variables.productsortfield eq 'region'>selected="selected"</cfif>>Region</option>
					<option value="country" <cfif variables.productsortfield eq 'country'>selected="selected"</cfif>>Country</option>
					<option value="price_down" <cfif variables.productsortfield eq 'price_down'>selected="selected"</cfif>>Price (Lowest to Highest)</option>
					<option value="price_up" <cfif variables.productsortfield eq 'price_up'>selected="selected"</cfif>>Price (Highest to Lowest)</option>
				</select>
			</form>
		</cfsavecontent>		
		<cfreturn lcl.html>
	</cffunction>
	
	<cffunction name="showProductListItem">
		<cfargument name="id" required="true">
				
		<cfset var data = structnew()>
		<cfset var item = "">
		
		<cfset data.productObj = createObject('component','modules.productcatalog.models.product').init(requestObject)>
		<cfset data.productObj.load(arguments.id)>
		
		<cfset data.pricingObj = createObject('component','modules.productPricing.models.productpricing').init(requestObject)>
		<cfset data.pricingObj.setPricedObj(data.productObj)>
		
		<cfset data.ratedObj = createObject('component','modules.productRatings.models.productratings').init(requestObject)>
		<cfset data.ratedObj.setRatedObj(data.productObj)>

		<cfset item = createobject('component', "modules.productcatalog.controller").init(
			"",
			data,
			variables.requestObject,
			variables.pageRef,
			'listitem'
		)>

		<cfreturn item.showHTML('productCatalog', 'listitem')>
	</cffunction>
	
	<!---<cffunction name="getCacheLength">
		<cfreturn 0>
	</cffunction>--->
	
	<cffunction name="showHTML">
		<cfreturn parseforlanguage(super.showHTML(argumentcollection=arguments))>
	</cffunction>
	
</cfcomponent>