<cfcomponent name="checkoutOrderCompleteCtrl" extends="resources.abstractsubcontroller">

	<cffunction name="showHTML">
		<cfset var ud = requestObject.getUserObject().exportUserData()>
		<cfset var msg = createObject("component","modules.messaging.models.messaging").init(requestObject)>
		
		<cfset msg.setupMessage("Order Complete", ud)>
		<cfreturn msg.getMessage().message>
	</cffunction>

</cfcomponent>