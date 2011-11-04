<cfcomponent displayname="MyCFCTest" extends="mxunit.framework.TestCase">
		
	<cffunction name="setUp" returntype="void" access="public">
		<cfset var lcl = structNew()>
		
		<cfset variables.unittestname = "unittesting">
		<cfset this.unittestsearchterm = variables.unittestname>
		<cfset variables.productgroupid = createuuid()>
		<cfset variables.productid = createuuid()>
		<cfset variables.productToproductgroupid = createuuid()>
		<cfset variables.requestObject = request.requestObject>
		<cfset lcl.userid = '8C8DD7E6-EA08-57D6-6556D3BB74048D54'> 
		
		<cfquery datasource="#variables.requestObject.getVar('dsn')#">
			INSERT INTO productGroups (id,name,title,changedby,siteid)
			VALUES (
				<cfqueryparam value="#variables.productgroupid#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#variables.unittestname#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#variables.unittestname#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#lcl.userid#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#variables.requestObject.getVar('siteid')#" cfsqltype="cf_sql_varchar">
			)
		</cfquery>
		
		<cfquery datasource="#variables.requestObject.getVar('dsn')#">
			INSERT INTO products ( id,name,title,description,changedby,siteid)
			VALUES (
				<cfqueryparam value="#variables.productid#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#variables.unittestname#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#variables.unittestname#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#variables.unittestname#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#lcl.userid#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#variables.requestObject.getVar('siteid')#" cfsqltype="cf_sql_varchar">
			)			
		</cfquery>
		
		<cfquery datasource="#variables.requestObject.getVar('dsn')#">
			INSERT INTO productsToProductGroups ( id,productgroupid,productid)
			VALUES (
				<cfqueryparam value="#variables.productToproductgroupid#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#variables.productgroupid#" cfsqltype="cf_sql_varchar">,
				<cfqueryparam value="#variables.productid#" cfsqltype="cf_sql_varchar">
			)			
		</cfquery>
          
	</cffunction>
    
    <cffunction name="teardown" returntype="void" access="public">
		<cfquery datasource="#variables.requestObject.getVar('dsn')#">
			DELETE FROM productsToProductGroups WHERE id = <cfqueryparam value="#variables.productToproductgroupid#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfquery datasource="#variables.requestObject.getVar('dsn')#">
			DELETE FROM products WHERE id = <cfqueryparam value="#variables.productid#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<cfquery datasource="#variables.requestObject.getVar('dsn')#">
			DELETE FROM productGroups WHERE id = <cfqueryparam value="#variables.productgroupid#" cfsqltype="cf_sql_varchar">
		</cfquery>
	</cffunction>
    
    <cffunction name="loadController" access="private">
    	<cfargument name="data" default="#structnew()#">
    	<cfargument name="requestObject" default="#variables.requestObject#">
    	<cfargument name="pageref" default="#structnew()#">
    	<cfset variables.controller = createObject("component","modules.productcatalog.controller").init(
			data=arguments.data,
			requestObject=arguments.requestObject,
			pageref=arguments.pageref,
			name = "default"
		)>
    </cffunction>
	
    <!--- model tests --->
    <cffunction name="testproductinactive">
		<cfset var lcl = structNew()>
		<cfset var data = structnew()>
    	<cfset var itm = "">
        <cfset var count = "">
		
    	<cfset loadController(data = data)>
		<cfset itm = variables.controller.getProductsModel("productCatalog")>
		
        <cfquery datasource="#variables.requestObject.getVar('dsn')#" result="m">
			UPDATE products SET active = 0
            WHERE id = <cfqueryparam value="#variables.productid#" cfsqltype="cf_sql_varchar">
		</cfquery>
        
		<cfset count = itm.getAvailableproducts( productgroupid = variables.productgroupid )>

        <cfset assertequals(expected=0,actual=count.recordcount,message="should not have found inactive product")>
    </cffunction>
    
    <cffunction name="testGettingProducts">
		<cfset var lcl = structNew()>
    	<cfset var itm = "">
        <cfset var count = "">
		
		<cfset loadcontroller(lcl)>
		<cfset itm = variables.controller.getProductsModel("productCatalog")>
		
		<cfset count = itm.getAvailableProducts( productgroupid = variables.productgroupid ).recordcount>
        <cfset assertequals(expected=1,actual=count,message="did not find available products")>
		
		<cfset count = itm.getProduct(id = variables.productid).recordcount>
        <cfset assertequals(expected=1,actual=count,message="did not find product")>
		
		<cfset count = itm.getAllAvailableProducts().recordcount>
        <cfset assertNotEquals(expected=0,actual=count,message="did not find any products available")>		
    </cffunction>
    
    <!--- ctrlr tests --->
    <cffunction name="testShowHTML">
        <cfset var data = structnew()>
		<cfset var furl = structnew()>
		<cfset var itm = "">
		<cfset var page = structnew()>
    	
		<!--- product listing --->	
		<cfset data.itemid = variables.productgroupid>
		<cfset data.pageing = 10>
		<cfset page = application.site.getPage(variables.requestObject)>
		<cfset page.preObjectLoad()>
    	<cfset loadController(data = data, pageref = page)>
		<cfset variables.controller = variables.controller.group(module="news", moduleaction="productcatalog")>
		<cfset html = variables.controller.showHTML(module="productcatalog", moduleaction="group")>
		
        <cfset asserttrue(condition = refind('<div class="productcatalogList">.*</div>',html),message="did not find matching div elements")>
        <cfset asserttrue(condition = refind('.*#variables.productid#.*',html),message="did not find #variables.unittestname# link")>
		
		<!--- product detail --->
		<cfset data.view = "productdetail">
		<cfset itm = variables.controller.getProductsModel("productCatalog")>
		<cfset data.productInfo = itm.getproduct(id = variables.productid)>
		
    	<cfset loadController(data = data)>
		<cfset variables.controller = variables.controller.item(module="productcatalog", moduleaction="productdetail")>
		
		<cfset html = variables.controller.showHTML(module="productcatalog", moduleaction="productdetail")>

        <cfset asserttrue(condition = refind('<div class="productcatalogDetail">.*</div>',html),message="did not find matching div elements")>
    </cffunction>
	
    
     <cffunction name="testGetPagesforSiteSearch">
        <cfset var data = structnew()>
        <cfset var html = "">
        <cfset var aggregator = createobject('component','modules.search.searchableaggregator').init(requestObject=variables.requestObject)>
		
		<cftry>
			<cfset loadController(data = data)>
		
        	<cfset variables.controller.getPagesforSiteSearch( aggregator = aggregator)>
            <cfcatch>
            	<cfset fail("product search indexing fails : #cfcatch.message#")>
            </cfcatch>
        </cftry>
    </cffunction>
   
</cfcomponent>