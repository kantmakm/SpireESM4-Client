<cfcomponent name="ordersobservers" extends="resources.abstractobserver">
	
	<cffunction name="page_objects">
		<cfargument name="observed" required="true">
		<cfset var path = requestObject.getFormUrlVar("path")>

		<cfif requestObject.getFormUrlVar("path") EQ "user/">
			<cfset observed.addObjectByModulePath('middleItem_2_Content', 'orders', '', structnew(), 'myhistory')>
		</cfif>

		<cfreturn observed>
	</cffunction>

</cfcomponent>