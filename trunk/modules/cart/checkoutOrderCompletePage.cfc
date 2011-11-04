<cfcomponent name="clientinfoform" extends="resources.page">
	
	<cffunction name="preObjectLoad">
		<cfset var uo = requestObject.getUserObject()>
		<cfif NOT uo.isloggedin()>
			<cfset uo.setFlash("Your session has expired. Please relogin. Your cart will still be available.")>
			<cflocation url="/user/login/?returnto=/cart/" addtoken="false">
		</cfif>
	</cffunction>
	
    <cffunction name="postObjectLoad">
		<cfset var form = "">
		<cfset var formitem = "">
		<cfset var data = structnew()>
		<cfset addObjectByModulePath('middleItem_2_Content', 'cart', "", structnew(), 'checkoutordercomplete')>
	</cffunction>

	<cffunction name="getCacheLength">
		<cfreturn 0>
	</cffunction>
</cfcomponent>