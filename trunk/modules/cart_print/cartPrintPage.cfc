<cfcomponent name="product View" extends="resources.page">
	<cffunction name="preobjectLoad">
			<cfset variables.pageInfo.breadCrumbs = 'Home~NULL~/|Print Cart~NULL~/'>
		
	</cffunction>
    
	<cffunction name="postObjectLoad">
		<cfset var data = structnew()>
		<!--- 
			main title 
			<cfset data.content = variables.pageinfo.title>
			<cfset addObjectByModulePath('mainTitle', 'simpleContent', data)>

			<!--- leftContent --->
			<cfset data = structnew()>
			<cfset data.content = variables.productInfo.htmltext>
			<cfset addObjectByModulePath('leftItem_1_BoxFree', 'HTMLContent', data)>
		--->

		<cfset addObjectByModulePath('middleItem_1_Content', 'cart_print', "", structnew(), "print")>
		
<	/cffunction>
</cfcomponent>