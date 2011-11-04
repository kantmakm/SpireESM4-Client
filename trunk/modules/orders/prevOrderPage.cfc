<cfcomponent name="Previous Order View" extends="resources.page">
	<cffunction name="preobjectLoad">
		<cfset var lcl = structnew()>
		<cfset lcl.uo = requestObject.getUserObject()>
		
		<cfif NOT lcl.uo.isLoggedIn()>
			<cfset lcl.uo.setFlash("You must be logged in to see this page.")>
			<cflocation url="/user/login/" addtoken="false">
		</cfif>
		
		<cfset variables.orderid = listlast(variables.requestObject.getFormUrlVar('path'), "/")>
		<cfset variables.orderObj = createObject('component','modules.orders.models.orders').init(requestObject)>
		<cfset variables.orderObj.load(variables.orderid)>
		
		<cfset requestObject.setRequestRegistryVar("orderObj", orderObj)>

		<cfset variables.pageInfo.breadCrumbs = "Home~NULL~/|My Account~ ~/user/|Order Summary|">

		
        <cfset variables.pageinfo.title = variables.pageInfo.title & " ##" & variables.orderid & " (" & variables.orderObj.getOrderStatus() & ")">
		<cfset variables.pageInfo.pagename = variables.pageInfo.title>
		<cfset variables.pageInfo.description = "Previous order">
		<cfset variables.pageInfo.keywords = "previous order">
	</cffunction>
    
	<cffunction name="postObjectLoad">
		<cfset var data = structnew()>
		<cfset data.orderObj = variables.orderObj>
		<cfset addObjectByModulePath('middleItem_2_Content', 'orders', "", data, 'previousorder')>
	</cffunction>
	
	<cffunction name="getCacheLength">
		<cfreturn 0>
	</cffunction>
	
</cfcomponent>