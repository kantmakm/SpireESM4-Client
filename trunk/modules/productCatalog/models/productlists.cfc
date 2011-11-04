<cfcomponent name="product-catalog" extends="resources.abstractmodel">

	<cffunction name="init">
		<cfargument name="requestObject" required="true">
		<cfset variables.requestObject = arguments.requestObject>
		<cfset startorm("products")>
		<cfreturn this>
	</cffunction>

	<cffunction name="getCatalogIds">
		<cfargument name="path" required="true">
		<cfargument name="page" default="#structnew()#">
		<cfset var list = "">
		<cfset var field = "">
		<cfset var srt = "">
		
		<cfset lcl.taxonomyquery = createObject("component", "modules.taxonomies.models.taxonomyrelationquery").init(requestObject)>
		<cfset lcl.taxonomyquery.setRelation("products")>
		<cfset lcl.taxonomyquery.addTaxonomyTypeFilter("product_categories", replace(path[1],"-","_","all"))>
		
		<cfset lcl.taxonomyquery.setmore("p.deleted", 0)>
		
		<cfif arraylen(path) EQ 4 AND refindnocase("^by\_", path[3])>
			<cfset taxonomytypeid = mid(path[3],4, len(path[3]))>
			<cfset taxonomytypeterm = path[4]>			
			<cfset lcl.taxonomyquery.addTaxonomyTypeFilter(taxonomytypeid, taxonomytypeterm)>
		</cfif>
		
		<cfset formCollection = requestobject.getallformurlvars()>

        <cfloop collection="#formCollection#" item="menu">
            <cfif refindnocase("^by\_", menu)>
                <cfset label = ucase(mid(menu, 4,len(menu)))>
				<cfset taxonomytypeid = label>
				<cfset taxonomytypeterm = formCollection[menu]>
				<cfset lcl.taxonomyquery.addTaxonomyTypeFilter(taxonomytypeid, taxonomytypeterm)>						
                <cfset lcl.taxonomyquery.addTaxonomyTypeRelation(label)>
            </cfif> 
        </cfloop>
		
		<cfif requestObject.isformurlvarset('productsortfield')>
			<cfset srt = requestObject.getformurlvar('productsortfield')>
		<cfelse>
			<cfset srt = "name">
		</cfif>
		
		<cfswitch expression="#srt#">
			<cfcase value="categoryid">
				<cfset lcl.taxonomyquery.addTaxonomyTypeRelation("categoryid")>
				<!----<cfset lcl.taxonomyquery.setSort("region_ti.name")> ---->
			</cfcase>
			
			<cfcase value="region">
				<cfset lcl.taxonomyquery.addTaxonomyTypeRelation("region")>
				<cfset lcl.taxonomyquery.setSort("region_ti.name")>
			</cfcase>
			
			<cfcase value="country">
				<cfset lcl.taxonomyquery.addTaxonomyTypeRelation("country")>
				<cfset lcl.taxonomyquery.setSort("country_ti.name")>
			</cfcase>
			
			<cfcase value="price_up">
				<cfset lcl.taxonomyquery.setJoin("productPrices", "p.id = productPrices.productid AND productPrices.isdefault = 1")>
				<cfset lcl.taxonomyquery.setSort("productPrices.price DESC")>
			</cfcase>
			
			<cfcase value="price_down">
				<cfset lcl.taxonomyquery.setJoin("productPrices", "p.id = productPrices.productid AND productPrices.isdefault = 1")>
				<cfset lcl.taxonomyquery.setSort("productPrices.price ASC")>
			</cfcase>
			
			<cfdefaultcase>
				<cfset lcl.taxonomyquery.setJoin("productPrices", "p.id = productPrices.productid AND productPrices.isdefault = 1")>
				<!---<cfset lcl.taxonomyquery.setSort("productPrices.price ASC")>--->
			</cfdefaultcase>
		</cfswitch>

		<cfset q = lcl.taxonomyquery.run(arguments.page)>

		<cfreturn q>
	</cffunction>
	
	<cffunction name="getSearchCatalog">
		<cfargument name="path" required="true">
		<cfargument name="page" default="#structnew()#">
		<cfset var list = "">
		<cfset var field = "">
		<cfset var srt = "">
		
		<cfset lcl.taxonomyquery = createObject("component", "modules.taxonomies.models.taxonomyrelationquery").init(requestObject)>
		<cfset lcl.taxonomyquery.setRelation("products")>
		<cfset lcl.taxonomyquery.addTaxonomyTypeFilter("product_categories", replace(path[1],"-","_","all"))>
		
		<cfset lcl.taxonomyquery.setmore("p.deleted", 0)>
		
		<cfif arraylen(path) EQ 4 AND refindnocase("^by\_", path[3])>
			<cfset taxonomytypeid = mid(path[3],4, len(path[3]))>
			<cfset taxonomytypeterm = path[4]>			
			<cfset lcl.taxonomyquery.addTaxonomyTypeFilter(taxonomytypeid, taxonomytypeterm)>
		</cfif>

		<cfif requestObject.isformurlvarset('productsortfield')>
			<cfset srt = requestObject.getformurlvar('productsortfield')>
		<cfelse>
			<cfset srt = "name">
		</cfif>
		
		<cfswitch expression="#srt#">
			<cfcase value="categoryid">
				<cfset lcl.taxonomyquery.addTaxonomyTypeRelation("categoryid")>
				<!----<cfset lcl.taxonomyquery.setSort("region_ti.name")> ---->
			</cfcase>
			
			<cfcase value="region">
				<cfset lcl.taxonomyquery.addTaxonomyTypeRelation("region")>
				<cfset lcl.taxonomyquery.setSort("region_ti.name")>
			</cfcase>
			
			<cfcase value="country">
				<cfset lcl.taxonomyquery.addTaxonomyTypeRelation("country")>
				<cfset lcl.taxonomyquery.setSort("country_ti.name")>
			</cfcase>
			
			<cfcase value="price_up">
				<cfset lcl.taxonomyquery.setJoin("productPrices", "p.id = productPrices.productid AND productPrices.isdefault = 1")>
				<cfset lcl.taxonomyquery.setSort("productPrices.price DESC")>
			</cfcase>
			
			<cfcase value="price_down">
				<cfset lcl.taxonomyquery.setJoin("productPrices", "p.id = productPrices.productid AND productPrices.isdefault = 1")>
				<cfset lcl.taxonomyquery.setSort("productPrices.price ASC")>
			</cfcase>
			
			<cfdefaultcase>
				<cfset lcl.taxonomyquery.setJoin("productPrices", "p.id = productPrices.productid AND productPrices.isdefault = 1")>
				<!---<cfset lcl.taxonomyquery.setSort("productPrices.price ASC")>--->
			</cfdefaultcase>
		</cfswitch>

		<cfset q = lcl.taxonomyquery.run(arguments.page)>

		<cfreturn q>
	</cffunction>

</cfcomponent>