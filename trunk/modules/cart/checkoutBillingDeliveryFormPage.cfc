<cfcomponent name="clientinfoform" extends="resources.page">
	
	<cffunction name="preObjectLoad">
		<cfset var uo = requestObject.getUserObject()>
		<cfif NOT uo.isloggedin()>
			<cfset uo.setFlash("Your session has expired. Please relogin. Your cart will still be available.")>
			<cflocation url="/user/login/?returnto=/cart/">
		</cfif>		
	</cffunction>
	
    <cffunction name="postObjectLoad">
		<cfset var form = "">
		<cfset var formitem = "">
		
		<cfset variables.pageInfo.breadCrumbs = "Home~NULL~/|Checkout : Delivery Info~NULL">
		
		<cfset addObjectByModulePath('item_above_cols', 'cart', "", structnew(), 'cartprogressindicator')>

		<cfset addObjectByModulePath('middleItem_2_Content', 'cart', "", structnew(), 'checkoutbillingdeliveryform')>

	</cffunction>

	<cffunction name="getCacheLength">
		<cfreturn 0>
	</cffunction>
</cfcomponent>