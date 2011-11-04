<cfcomponent name="moremenu" extends="resources.page">
		
    <cffunction name="postObjectLoad">
		<cfset var data = structnew()>
		<cfset data.menuitemid = requestObject.getFormUrlVar("menuitemid", 0)>

		<cfset addObjectByModulePath('onecontent', 'taxonomies', "", data, 'moremenu')>
	</cffunction>

</cfcomponent>
