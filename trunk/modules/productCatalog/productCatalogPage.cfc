<cfcomponent name="product View" extends="resources.page">
	<cffunction name="preobjectLoad">
		<cfset lcl = structNew()>
		<cfset lcl.p = requestobject.getFormUrlVar("path")>
	
		<cfif NOT refindnocase("^[^\/]+\/catalog\/(by\_[0-9a-z \-\_]+\/[0-9a-z \-\_]+\/)?$", lcl.p)>
			<cflocation url="/#listgetat(lcl.p, 1, "/")#/catalog/" addtoken="false">
		</cfif>

		<cfset lcl.bca = arraynew(1)>

		<cfset lcl.p1 = listfirst(lcl.p, "/")>
		<cfset arrayappend(lcl.bca, "Home~NULL~/")>
		
		<cfset lcl.pt = ucase(mid(lcl.p1, 1,1)) & lcase(mid(lcl.p1, 2, len(lcl.p1)))>
		
		<cfset arrayappend(lcl.bca, lcl.pt  & " Home" & "~NULL~/" & lcl.pt & "/")>
		
		<cfset arrayappend(lcl.bca, "Catalog" & "~NULL~/" & lcl.pt & "/Catalog/")>
		
		<cfif listlen(lcl.p, "/") GT 2>
			<cfset lcl.p3 = listgetat(lcl.p, 3,"/")>
			<cfset lcl.label = ucase(mid(lcl.p3, 4,1)) & lcase(mid(lcl.p3, 5, len(lcl.p3)))>
			<cfset lcl.p4 = listgetat(lcl.p, 4,"/")>
			<cfset lcl.label2 = ucase(mid(lcl.p4, 1,1)) & lcase(mid(lcl.p4, 2, len(lcl.p4)))>
			<cfset lcl.label2 = replacenocase(lcl.label2, '_', ' ',"all")>
			<cfset lcl.label2 = rereplacenocase(lcl.label2,'([0-9]+)', '$\1', "all")>
			<cfset arrayappend(lcl.bca, lcl.label & " : " & lcl.label2 & "~NULL~")>
		</cfif>
		
		<cfset addtoheader('<link rel="stylesheet" href="/ui/css/productcatalog.css" type="text/css"/>')>
		
		<cfset variables.pageinfo.breadcrumbs = arraytolist(lcl.bca, "|")>
	</cffunction>
    
	<cffunction name="postObjectLoad">
		<cfset var data = structnew()>
		<cfset var lcl = structnew()>
		
		<!--- main title --->
		<cfset data.content = variables.pageinfo.title>
		<cfset addObjectByModulePath('mainTitle', 'simpleContent', "", data)>

		<!--- leftContent
		<cfset data = structnew()>
		<cfset data.content = variables.productInfo.htmltext>
		<cfset addObjectByModulePath('leftItem_1_BoxFree', 'HTMLContent', data)>--->

		<!--- mainContent 
		<cfif variables.productInfo.filename NEQ "">
			<cfset data = structnew()>
			<cfset data.content = '<img src="/docs/assets/#variables.productInfo.asset_id#/#variables.productInfo.filename#">'>
			<cfset addObjectByModulePath('mainbanner_Content', 'HTMLContent', data)>
		</cfif>--->
		
		<cfset addObjectByModulePath('middleItem_1_Content', 'productcatalog', "", data, "group")>
		
		<!--- Reviews
		<cfset data = structnew()>
		<cfset data.moduleInfo = variables.productInfo>
		<cfset addObjectByModulePath('middleItem_6_Content', 'Reviews', data, "products")> --->	
	</cffunction>
</cfcomponent>