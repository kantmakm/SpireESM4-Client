<cfcomponent name="product View" extends="resources.page">
	<cffunction name="preobjectLoad">
		<cfset var lcl = structNew()>
		
		<cfset variables.path = variables.requestObject.getFormUrlVar('path')>
		<cfset variables.urlname = listlast(variables.path, "/")>
		<cfset variables.productid = listfirst(variables.urlname,"-")>
		<cfset variables.productType = listfirst(variables.requestObject.getFormUrlVar('path'),"/")>
			
		<cfset variables.productObj = createObject('component','modules.productcatalog.models.product')
									.init(requestObject)>
		<cfif NOT variables.productObj.load(variables.productid)>
			<cfset variables.load404()>
		</cfif>
		
		<cfif variables.urlname NEQ variables.productObj.getUrlName() AND variables.urlname NEQ variables.productObj.getUrlName() & '/'>
			<cfset lcl.tax = variables.productObj.getTaxonomyObj()>
			<cflocation url="/#replace(lcl.tax.getFirstTermItemName("product_categories")," ","-","all")#/product/#variables.productObj.getUrlName()#" addtoken="false">
		</cfif>

		<cfset variables.requestObject.setRequestRegistryVar("productObj", variables.productObj)>
	
		<cfset lcl.firstPath = listfirst(requestObject.getFormUrlVar("path"),"/")>
		<cfset lcl.firstLabel = ucase(mid(lcl.firstPath,1,1)) & lcase(mid(lcl.firstPath,2,len(lcl.firstPath)))>

		<cfset variables.pageInfo.breadCrumbs = 'Home~NULL~/|#lcl.firstLabel# Home~NULL~/#lcl.firstpath#/|#lcl.firstLabel# Catalog~NULL~/#lcl.firstpath#/catalog/|#variables.productObj.gettitle()#|'>

		<cfset variables.pageInfo.title = variables.productObj.gettitle()>
		<cfset variables.pageInfo.pagename = variables.productObj.gettitle()>
		<cfset variables.pageInfo.description = XmlFormat(variables.productObj.getdescription())>
		<cfset variables.pageInfo.keywords = XmlFormat(variables.productObj.getdescription())>
		
		<cfset addtoheader('<link rel="stylesheet" href="/ui/css/productcatalog.css" type="text/css"/>')>
	</cffunction>
    
	<cffunction name="load404">
		<cflocation url="/404/?notfound=#urlencodedformat(requestObject.getFormUrlVar("path"))#" addtoken="false">
	</cffunction>
	
	<cffunction name="postObjectLoad">
		<cfset var data = structnew()>
		<!--- main title --->
		<cfset data.content = variables.pageinfo.title>
		<cfset addObjectByModulePath('mainTitle', 'simpleContent', "", data)>

		<!---
		<!--- leftContent --->
		<cfset data = structnew()>
		<cfset data.content = variables.productInfo.htmltext>
		<cfset addObjectByModulePath('leftItem_1_BoxFree', 'HTMLContent', data)>
		--->
		
		<!--- mainContent --->
		<!--->
		<cfif variables.productObj.getFile() NEQ "">
			<cfset data = structnew()>
			<cfset data.content = '<img src="/docs/assets/#variables.productInfo.asset_id#/#variables.productInfo.filename#">'>
			<cfset addObjectByModulePath('mainbanner_Content', 'HTMLContent', data)>
		</cfif>
		--->
		
		<cfset data = structnew()>
		<cfset data.productObj = variables.productObj>
		<cfset data.pricingObj = createObject('component','modules.productPricing.models.productpricing').init(requestObject)>
		<cfset data.pricingObj.setPricedObj(data.productObj)>
		
		<cfset addObjectByModulePath('middleItem_2_Content', 'productcatalog', "", data, "productdetail_#variables.productType#")>
		
		<cfset addObjectByModulePath('middleItem_3_Content', 'productratings', "", data, "ratingsforproductview")>
		

<!--- 		<!--- Reviews --->	
		<cfset data = structnew()>
		<cfset data.moduleInfo = variables.productObj>
		<cfset addObjectByModulePath('middleItem_6_Content', 'Reviews', "", data, "products")> --->

	</cffunction>
</cfcomponent>